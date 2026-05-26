import 'dart:math';
import 'package:flutter/scheduler.dart';
import '../constants.dart';

/// Simple Linear Congruential Generator for deterministic pseudo-random
class _PseudoRandom {
  int _state;
  static const int _multiplier = 1103515245;
  static const int _increment = 12345;
  static const int _modulus = 2147483648;

  _PseudoRandom(int seed) : _state = seed.abs() % _modulus;

  double nextDouble() {
    _state = (_multiplier * _state + _increment) % _modulus;
    return _state / _modulus;
  }

  int nextInt(int max) {
    return (nextDouble() * max).toInt();
  }
}

/// Scroll phase used to gate synthetic load execution.
enum LoadScrollPhase {
  idle,
  dragging,
  inertial,
}

/// Load Calculator Utility Class
///
/// 对齐原生 LoadSimulator + LoadScheduler:
/// 1. 伪随机帧间隔触发（3~5帧间隔）
/// 2. 概率触发（Light 32% / Medium 48% / Heavy 72%）
/// 3. 滚动阶段感知（仅惯性滑动时执行负载）
/// 4. 固定种子确保测试可重现
class LoadCalculator {
  static final LoadCalculator _instance = LoadCalculator._internal();
  factory LoadCalculator() => _instance;
  LoadCalculator._internal() {
    resetState();
  }

  static final List<double> _workBuffer = List.filled(256, 0.0);

  // ========== 伪随机数生成器（对齐原生多组固定种子）==========
  late _PseudoRandom _taskProbabilityRandom;
  late _PseudoRandom _doFrameIntervalRandom;
  late _PseudoRandom _betweenFrameIntervalRandom;

  // ========== 帧计数器（对齐原生帧间隔触发机制）==========
  int _doFrameCounter = 0;
  int _nextDoFrameTarget = 0;
  int _currentDoFrameLoadLevel = 0;

  int _betweenFrameCounter = 0;
  int _nextBetweenFrameTarget = 0;
  int _currentBetweenFrameLoadLevel = 0;

  // ========== 滚动阶段感知（按压拖动不加负载，仅惯性滑动加负载）==========
  LoadScrollPhase _scrollPhase = LoadScrollPhase.idle;

  /// 设置滚动阶段（由 UnifiedLoadScreen 调用）
  bool setScrollPhase(LoadScrollPhase phase) {
    if (_scrollPhase == phase) return false;
    _scrollPhase = phase;
    return true;
  }

  /// 只有惯性滑动阶段允许执行负载
  bool get isInertialScrolling => _scrollPhase == LoadScrollPhase.inertial;

  /// 重置所有状态（对齐原生 resetRandomState）
  void resetState() {
    _taskProbabilityRandom = _PseudoRandom(Constants.TASK_INTERVAL_SEED);
    _doFrameIntervalRandom = _PseudoRandom(Constants.DOFRAME_INTERVAL_SEED);
    _betweenFrameIntervalRandom =
        _PseudoRandom(Constants.BETWEEN_FRAME_INTERVAL_SEED);
    _doFrameCounter = 0;
    _nextDoFrameTarget = 0;
    _currentDoFrameLoadLevel = 0;
    _betweenFrameCounter = 0;
    _nextBetweenFrameTarget = 0;
    _currentBetweenFrameLoadLevel = 0;
    _scrollPhase = LoadScrollPhase.idle;
  }

  // ========== 概率触发（对齐原生 shouldExecuteByProbability）==========

  /// 获取负载级别对应的触发概率
  double _getTaskProbability(int loadType) {
    int level = _getLoadLevel(loadType);
    double baseProbability;
    switch (level) {
      case 1:
        baseProbability = Constants.LIGHT_TASK_PROBABILITY;
        break;
      case 2:
        baseProbability = Constants.MEDIUM_TASK_PROBABILITY;
        break;
      case 3:
        baseProbability = Constants.HEAVY_TASK_PROBABILITY;
        break;
      default:
        return 0.0;
    }
    // 混合负载额外增益
    if (isMixedLoadType(loadType)) {
      double boosted = baseProbability * Constants.MIXED_TASK_PROBABILITY_BOOST;
      return boosted > 1.0 ? 1.0 : boosted;
    }
    return baseProbability;
  }

  /// 概率判定（对齐原生 shouldExecuteByProbability）
  bool _shouldExecuteByProbability(int loadType) {
    double probability = _getTaskProbability(loadType);
    if (probability <= 0) return false;
    if (probability >= 1.0) return true;
    return _taskProbabilityRandom.nextDouble() < probability;
  }

  // ========== 帧间隔控制（对齐原生 calculateNextDoFrameInterval）==========

  int _getMinFrameInterval(int loadLevel) {
    switch (loadLevel) {
      case 1:
        return Constants.LIGHT_MIN_FRAME_INTERVAL;
      case 2:
        return Constants.MEDIUM_MIN_FRAME_INTERVAL;
      case 3:
        return Constants.HEAVY_MIN_FRAME_INTERVAL;
      default:
        return Constants.LIGHT_MIN_FRAME_INTERVAL;
    }
  }

  int _getMaxFrameInterval(int loadLevel) {
    switch (loadLevel) {
      case 1:
        return Constants.LIGHT_MAX_FRAME_INTERVAL;
      case 2:
        return Constants.MEDIUM_MAX_FRAME_INTERVAL;
      case 3:
        return Constants.HEAVY_MAX_FRAME_INTERVAL;
      default:
        return Constants.LIGHT_MAX_FRAME_INTERVAL;
    }
  }

  int _calculateNextDoFrameInterval(int loadLevel) {
    int minInterval = _getMinFrameInterval(loadLevel);
    int maxInterval = _getMaxFrameInterval(loadLevel);
    return minInterval +
        _doFrameIntervalRandom.nextInt(maxInterval - minInterval + 1);
  }

  int _calculateNextBetweenFrameInterval(int loadLevel) {
    int minInterval = _getMinFrameInterval(loadLevel);
    int maxInterval = _getMaxFrameInterval(loadLevel);
    return minInterval +
        _betweenFrameIntervalRandom.nextInt(maxInterval - minInterval + 1);
  }

  // ========== Build Load（对齐原生 executeInFrameLoad）==========

  /// 执行 Build 负载
  /// 对齐原生: 帧间隔控制 + 概率触发 + 滚动阶段感知
  double performBuildLoad(int loadType) {
    // 阶段感知：按压/拖动/静止都不推进调度节奏，只有惯性滑动执行
    if (!isInertialScrolling) return 0.0;

    int iterations;
    int complexity;

    switch (loadType) {
      case Constants.LOAD_TYPE_BUILD_LIGHT:
        iterations = Constants.BUILD_LIGHT_ITERATIONS;
        complexity = 1;
        break;
      case Constants.LOAD_TYPE_BUILD_MEDIUM:
        iterations = Constants.BUILD_MEDIUM_ITERATIONS;
        complexity = 2;
        break;
      case Constants.LOAD_TYPE_BUILD_HEAVY:
        iterations = Constants.BUILD_HEAVY_ITERATIONS;
        complexity = 3;
        break;
      case Constants.LOAD_TYPE_MIXED_LIGHT:
        iterations = Constants.MIXED_BUILD_LIGHT_ITERATIONS;
        complexity = 1;
        break;
      case Constants.LOAD_TYPE_MIXED_MEDIUM:
        iterations = Constants.MIXED_BUILD_MEDIUM_ITERATIONS;
        complexity = 2;
        break;
      case Constants.LOAD_TYPE_MIXED_HEAVY:
        iterations = Constants.MIXED_BUILD_HEAVY_ITERATIONS;
        complexity = 3;
        break;
      default:
        return 0.0;
    }

    // 帧间隔控制（对齐原生）
    int level = _getLoadLevel(loadType);
    if (level != _currentDoFrameLoadLevel) {
      _currentDoFrameLoadLevel = level;
      _nextDoFrameTarget =
          _doFrameCounter + _calculateNextDoFrameInterval(level);
    }
    _doFrameCounter++;
    if (_doFrameCounter < _nextDoFrameTarget) {
      return 0.0; // 还没到执行时机
    }
    _nextDoFrameTarget = _doFrameCounter + _calculateNextDoFrameInterval(level);

    // 概率触发（对齐原生）
    if (!_shouldExecuteByProbability(loadType)) {
      return 0.0;
    }

    return _performCpuCalculation(iterations, complexity);
  }

  // ========== PostFrame Load（对齐原生 executePureBetweenFrameLoad / executeBetweenFrameLoad）==========

  /// 执行 PostFrame 负载
  /// 对齐原生: 帧间隔控制 + 概率触发 + 滚动阶段感知
  void performPostFrameLoad(int loadType) {
    // 阶段感知：按压/拖动/静止都不推进调度节奏，只有惯性滑动执行
    if (!isInertialScrolling) return;

    int iterations;
    int complexity;

    switch (loadType) {
      case Constants.LOAD_TYPE_POSTFRAME_LIGHT:
        iterations = Constants.POSTFRAME_LIGHT_ITERATIONS;
        complexity = 1;
        break;
      case Constants.LOAD_TYPE_POSTFRAME_MEDIUM:
        iterations = Constants.POSTFRAME_MEDIUM_ITERATIONS;
        complexity = 2;
        break;
      case Constants.LOAD_TYPE_POSTFRAME_HEAVY:
        iterations = Constants.POSTFRAME_HEAVY_ITERATIONS;
        complexity = 3;
        break;
      case Constants.LOAD_TYPE_MIXED_LIGHT:
        iterations = Constants.MIXED_POSTFRAME_LIGHT_ITERATIONS;
        complexity = 1;
        break;
      case Constants.LOAD_TYPE_MIXED_MEDIUM:
        iterations = Constants.MIXED_POSTFRAME_MEDIUM_ITERATIONS;
        complexity = 2;
        break;
      case Constants.LOAD_TYPE_MIXED_HEAVY:
        iterations = Constants.MIXED_POSTFRAME_HEAVY_ITERATIONS;
        complexity = 3;
        break;
      default:
        return;
    }

    // 帧间隔控制（对齐原生）
    int level = _getLoadLevel(loadType);
    if (level != _currentBetweenFrameLoadLevel) {
      _currentBetweenFrameLoadLevel = level;
      _nextBetweenFrameTarget =
          _betweenFrameCounter + _calculateNextBetweenFrameInterval(level);
    }
    _betweenFrameCounter++;
    if (_betweenFrameCounter < _nextBetweenFrameTarget) {
      return; // 还没到执行时机
    }
    _nextBetweenFrameTarget =
        _betweenFrameCounter + _calculateNextBetweenFrameInterval(level);

    // 概率触发（对齐原生）
    if (!_shouldExecuteByProbability(loadType)) {
      return;
    }

    _performCpuCalculation(iterations, complexity);
  }

  // ========== Paint Load Parameters ==========

  /// Returns Paint load parameters for CustomPainter usage
  PaintLoadParams getPaintLoadParams(int loadType) {
    switch (loadType) {
      case Constants.LOAD_TYPE_PAINT_LIGHT:
        return PaintLoadParams(
          shapeCount: Constants.PAINT_LIGHT_SHAPES,
          pathPoints: Constants.PAINT_LIGHT_PATH_POINTS,
          enableShadow: false,
          enableBlur: false,
          complexity: 1,
        );
      case Constants.LOAD_TYPE_PAINT_MEDIUM:
        return PaintLoadParams(
          shapeCount: Constants.PAINT_MEDIUM_SHAPES,
          pathPoints: Constants.PAINT_MEDIUM_PATH_POINTS,
          enableShadow: true,
          enableBlur: false,
          complexity: 2,
        );
      case Constants.LOAD_TYPE_PAINT_HEAVY:
        return PaintLoadParams(
          shapeCount: Constants.PAINT_HEAVY_SHAPES,
          pathPoints: Constants.PAINT_HEAVY_PATH_POINTS,
          enableShadow: true,
          enableBlur: true,
          complexity: 3,
        );
      default:
        return PaintLoadParams.none();
    }
  }

  // ========== Register PostFrame Callback ==========

  /// Used for PostFrame and Mixed load types
  void schedulePostFrameLoad(int loadType, {bool continuous = true}) {
    if (!_isPostFrameLoadType(loadType)) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      performPostFrameLoad(loadType);

      // If continuous mode, schedule next frame
      if (continuous) {
        schedulePostFrameLoad(loadType, continuous: true);
      }
    });
  }

  /// Check if load type is PostFrame type
  bool _isPostFrameLoadType(int loadType) {
    return loadType == Constants.LOAD_TYPE_POSTFRAME_LIGHT ||
        loadType == Constants.LOAD_TYPE_POSTFRAME_MEDIUM ||
        loadType == Constants.LOAD_TYPE_POSTFRAME_HEAVY ||
        loadType == Constants.LOAD_TYPE_MIXED_LIGHT ||
        loadType == Constants.LOAD_TYPE_MIXED_MEDIUM ||
        loadType == Constants.LOAD_TYPE_MIXED_HEAVY;
  }

  /// Check if load type is Build type
  bool isBuildLoadType(int loadType) {
    return loadType == Constants.LOAD_TYPE_BUILD_LIGHT ||
        loadType == Constants.LOAD_TYPE_BUILD_MEDIUM ||
        loadType == Constants.LOAD_TYPE_BUILD_HEAVY ||
        loadType == Constants.LOAD_TYPE_MIXED_LIGHT ||
        loadType == Constants.LOAD_TYPE_MIXED_MEDIUM ||
        loadType == Constants.LOAD_TYPE_MIXED_HEAVY;
  }

  /// Check if load type is Paint type
  bool isPaintLoadType(int loadType) {
    return loadType == Constants.LOAD_TYPE_PAINT_LIGHT ||
        loadType == Constants.LOAD_TYPE_PAINT_MEDIUM ||
        loadType == Constants.LOAD_TYPE_PAINT_HEAVY;
  }

  /// Check if load type is Mixed type
  bool isMixedLoadType(int loadType) {
    return loadType == Constants.LOAD_TYPE_MIXED_LIGHT ||
        loadType == Constants.LOAD_TYPE_MIXED_MEDIUM ||
        loadType == Constants.LOAD_TYPE_MIXED_HEAVY;
  }

  /// Core CPU Calculation Method with pseudo-random data dependency
  double _performCpuCalculation(int iterations, int complexity) {
    final random = _PseudoRandom(Constants.COMPUTATION_SEED);
    double result = 0.0;
    int bufferIndex = 0;

    for (int i = 0; i < iterations; i++) {
      final double r1 = random.nextDouble();
      final double r2 = random.nextDouble();

      if (complexity == 1) {
        result += (i * 0.001 + r1 * 0.0001) + _workBuffer[bufferIndex] * 0.01;
      } else if (complexity == 2) {
        final double angle = i * 0.01 + r1;
        result += sin(angle) * cos(angle + r2) + _workBuffer[bufferIndex];
      } else {
        final double base = i * 0.01 + r1;
        final double tanArg = (base + r2) % 1.5 + 0.001;
        result += sin(base) * cos(base) * tan(tanArg) * sqrt((i % 10) + 1 + r1);
        result +=
            _workBuffer[bufferIndex] * _workBuffer[(bufferIndex + 128) % 256];
      }

      _workBuffer[bufferIndex] = result * 0.0001;
      bufferIndex = (bufferIndex + 1) % 256;
    }

    return result;
  }

  // ========== Get Data Generation Parameters ==========

  /// Returns data generation parameters based on load type
  DataGenerationParams getDataGenerationParams(int loadType) {
    int level = _getLoadLevel(loadType);

    switch (level) {
      case 1:
        return DataGenerationParams(
          maxComments: Constants.LIGHT_LOAD_COMMENT_MAX,
          maxPraises: Constants.LIGHT_LOAD_PRAISE_MAX,
          maxImages: Constants.LIGHT_LOAD_IMAGE_MAX,
        );
      case 2:
        return DataGenerationParams(
          maxComments: Constants.MEDIUM_LOAD_COMMENT_MAX,
          maxPraises: Constants.MEDIUM_LOAD_PRAISE_MAX,
          maxImages: Constants.MEDIUM_LOAD_IMAGE_MAX,
        );
      case 3:
        return DataGenerationParams(
          maxComments: Constants.HEAVY_LOAD_COMMENT_MAX,
          maxPraises: Constants.HEAVY_LOAD_PRAISE_MAX,
          maxImages: Constants.HEAVY_LOAD_IMAGE_MAX,
        );
      default:
        return DataGenerationParams(
          maxComments: 1,
          maxPraises: 1,
          maxImages: 1,
        );
    }
  }

  /// Get load level (0=minimal, 1=light, 2=medium, 3=heavy)
  int _getLoadLevel(int loadType) {
    if (loadType == Constants.LOAD_TYPE_MINIMAL) return 0;

    if (loadType == Constants.LOAD_TYPE_BUILD_LIGHT ||
        loadType == Constants.LOAD_TYPE_PAINT_LIGHT ||
        loadType == Constants.LOAD_TYPE_POSTFRAME_LIGHT ||
        loadType == Constants.LOAD_TYPE_MIXED_LIGHT) {
      return 1;
    } else if (loadType == Constants.LOAD_TYPE_BUILD_MEDIUM ||
        loadType == Constants.LOAD_TYPE_PAINT_MEDIUM ||
        loadType == Constants.LOAD_TYPE_POSTFRAME_MEDIUM ||
        loadType == Constants.LOAD_TYPE_MIXED_MEDIUM) {
      return 2;
    } else {
      return 3;
    }
  }
}

/// Paint Load Parameters Class
class PaintLoadParams {
  final int shapeCount;
  final int pathPoints;
  final bool enableShadow;
  final bool enableBlur;
  final int complexity;

  PaintLoadParams({
    required this.shapeCount,
    required this.pathPoints,
    required this.enableShadow,
    required this.enableBlur,
    required this.complexity,
  });

  factory PaintLoadParams.none() {
    return PaintLoadParams(
      shapeCount: 0,
      pathPoints: 0,
      enableShadow: false,
      enableBlur: false,
      complexity: 0,
    );
  }
}

/// Data Generation Parameters Class
class DataGenerationParams {
  final int maxComments;
  final int maxPraises;
  final int maxImages;

  DataGenerationParams({
    required this.maxComments,
    required this.maxPraises,
    required this.maxImages,
  });
}
