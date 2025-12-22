import 'dart:math';
import 'package:flutter/scheduler.dart';
import '../constants.dart';

/// Load Calculator Utility Class
///
/// Provides unified load calculation methods to simulate different types and levels of load:
/// 1. Build Load - CPU computation during Widget building
/// 2. Paint Load - Returns drawing parameters, executed by CustomPainter
/// 3. PostFrame Load - Computation after frame rendering
/// 4. Mixed Load - Combines Build and PostFrame loads
class LoadCalculator {
  // Singleton pattern
  static final LoadCalculator _instance = LoadCalculator._internal();
  factory LoadCalculator() => _instance;
  LoadCalculator._internal();

  /// ========== Build Load Calculation ==========
  /// Called in Widget.build() method, generates CPU load
  /// Returns calculation result, can be used to dynamically adjust UI parameters
  double performBuildLoad(int loadType) {
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
        return 0.0; // No load or other load types
    }

    return _performCpuCalculation(iterations, complexity);
  }

  /// ========== PostFrame Load Calculation ==========
  /// Called after frame rendering, simulates between-frame computation
  void performPostFrameLoad(int loadType) {
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
        return; // No load or other load types
    }

    _performCpuCalculation(iterations, complexity);
  }

  /// ========== Paint Load Parameters ==========
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

  /// ========== Register PostFrame Callback ==========
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

  /// ========== Core CPU Calculation Method ==========
  double _performCpuCalculation(int iterations, int complexity) {
    double result = 0.0;

    for (int i = 0; i < iterations; i++) {
      if (complexity == 1) {
        // Light load - simple calculation
        result += i * 0.001;
      } else if (complexity == 2) {
        // Medium load - trigonometric calculation
        result += sin(i * 0.01) * cos(i * 0.01);
      } else {
        // Heavy load - complex math calculation
        result += sin(i * 0.01) * cos(i * 0.01) * tan((i * 0.01) % 1.5) * sqrt((i % 10) + 1);
      }
    }

    return result;
  }

  /// ========== Get Data Generation Parameters ==========
  /// Returns data generation parameters based on load type (comments, likes, image counts)
  DataGenerationParams getDataGenerationParams(int loadType) {
    // Return parameters based on load level (light/medium/heavy)
    int level = _getLoadLevel(loadType);

    switch (level) {
      case 1: // Light
        return DataGenerationParams(
          maxComments: Constants.LIGHT_LOAD_COMMENT_MAX,
          maxPraises: Constants.LIGHT_LOAD_PRAISE_MAX,
          maxImages: Constants.LIGHT_LOAD_IMAGE_MAX,
        );
      case 2: // Medium
        return DataGenerationParams(
          maxComments: Constants.MEDIUM_LOAD_COMMENT_MAX,
          maxPraises: Constants.MEDIUM_LOAD_PRAISE_MAX,
          maxImages: Constants.MEDIUM_LOAD_IMAGE_MAX,
        );
      case 3: // Heavy
        return DataGenerationParams(
          maxComments: Constants.HEAVY_LOAD_COMMENT_MAX,
          maxPraises: Constants.HEAVY_LOAD_PRAISE_MAX,
          maxImages: Constants.HEAVY_LOAD_IMAGE_MAX,
        );
      default: // Minimal
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

    // Determine level based on load type
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
  final int shapeCount;      // Number of shapes to draw
  final int pathPoints;      // Number of path points
  final bool enableShadow;   // Enable shadow effect
  final bool enableBlur;     // Enable blur effect
  final int complexity;      // Complexity level (1-3)

  PaintLoadParams({
    required this.shapeCount,
    required this.pathPoints,
    required this.enableShadow,
    required this.enableBlur,
    required this.complexity,
  });

  /// No load parameters
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
  final int maxComments;  // Max comment count
  final int maxPraises;   // Max like count
  final int maxImages;    // Max image count

  DataGenerationParams({
    required this.maxComments,
    required this.maxPraises,
    required this.maxImages,
  });
}
