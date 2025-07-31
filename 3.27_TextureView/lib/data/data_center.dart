import 'dart:math';

import '../constants.dart';
import '../models/friend_circle_model.dart';
import '../models/post_model.dart';

/// 数据中心，用于生成和管理测试数据
class DataCenter {
  // 单例模式
  static final DataCenter _instance = DataCenter._internal();
  factory DataCenter() => _instance;
  DataCenter._internal();

  // 缓存的数据
  List<FriendCircleModel>? _cachedLightLoadData;
  List<FriendCircleModel>? _cachedMediumLoadData;
  List<FriendCircleModel>? _cachedHeavyLoadData;

  // 固定种子的随机数生成器，确保每次生成相同的随机数
  final Random _random = Random(Constants.RANDOM_SEED);

  /// 清除缓存的数据
  void clearCachedData() {
    _cachedLightLoadData = null;
    _cachedMediumLoadData = null;
    _cachedHeavyLoadData = null;
  }

  /// 获取指定负载类型的朋友圈数据
  List<FriendCircleModel> getFriendCircleData(int loadType) {
    switch (loadType) {
      case Constants.LOAD_TYPE_LIGHT:
        _cachedLightLoadData ??= _generateFriendCircleData(loadType);
        return _cachedLightLoadData!;
      case Constants.LOAD_TYPE_MEDIUM:
        _cachedMediumLoadData ??= _generateFriendCircleData(loadType);
        return _cachedMediumLoadData!;
      case Constants.LOAD_TYPE_HEAVY:
        _cachedHeavyLoadData ??= _generateFriendCircleData(loadType);
        return _cachedHeavyLoadData!;
      default:
        _cachedLightLoadData ??= _generateFriendCircleData(Constants.LOAD_TYPE_LIGHT);
        return _cachedLightLoadData!;
    }
  }

  /// 生成指定负载类型的朋友圈数据
  List<FriendCircleModel> _generateFriendCircleData(int loadType) {
    // 根据负载类型确定评论、点赞和图片的最大数量
    int maxCommentCount;
    int maxPraiseCount;
    int maxImageCount;
    Random seedRandom;

    switch (loadType) {
      case Constants.LOAD_TYPE_LIGHT:
        maxCommentCount = Constants.LIGHT_LOAD_COMMENT_MAX;
        maxPraiseCount = Constants.LIGHT_LOAD_PRAISE_MAX;
        maxImageCount = Constants.LIGHT_LOAD_IMAGE_MAX;
        seedRandom = Random(Constants.RANDOM_SEED);
        break;
      case Constants.LOAD_TYPE_MEDIUM:
        maxCommentCount = Constants.MEDIUM_LOAD_COMMENT_MAX;
        maxPraiseCount = Constants.MEDIUM_LOAD_PRAISE_MAX;
        maxImageCount = Constants.MEDIUM_LOAD_IMAGE_MAX;
        seedRandom = Random(Constants.RANDOM_SEED + 100);
        break;
      case Constants.LOAD_TYPE_HEAVY:
        maxCommentCount = Constants.HEAVY_LOAD_COMMENT_MAX;
        maxPraiseCount = Constants.HEAVY_LOAD_PRAISE_MAX;
        maxImageCount = Constants.HEAVY_LOAD_IMAGE_MAX;
        seedRandom = Random(Constants.RANDOM_SEED + 200);
        break;
      default:
        maxCommentCount = Constants.LIGHT_LOAD_COMMENT_MAX;
        maxPraiseCount = Constants.LIGHT_LOAD_PRAISE_MAX;
        maxImageCount = Constants.LIGHT_LOAD_IMAGE_MAX;
        seedRandom = Random(Constants.RANDOM_SEED);
    }

    // 生成朋友圈数据
    return List.generate(Constants.FRIEND_CIRCLE_COUNT, (index) {
      // 使用固定种子 + 索引确保数据一致性
      final localRandom = Random(seedRandom.nextInt(10000) + index);
      
      // 生成评论和点赞数量
      final commentCount = localRandom.nextInt(maxCommentCount) + 1;
      final praiseCount = localRandom.nextInt(maxPraiseCount) + 1;
      
      // 生成图片数量 - 50%的概率有图片
      int imageCount = 0;
      if (localRandom.nextBool()) {
        // 有图片的情况下，随机生成图片数量
        imageCount = localRandom.nextInt(maxImageCount) + 1;
      }
      
      // 根据负载类型调整内容长度 - 增加中高负载时内容的复杂度
      String baseContent = _getBaseContent(index);
      String content;
      
      if (loadType == Constants.LOAD_TYPE_MEDIUM) {
        // 中负载增加内容长度
        content = baseContent + " " + baseContent;
      } else if (loadType == Constants.LOAD_TYPE_HEAVY) {
        // 重负载进一步增加内容长度
        content = baseContent + " " + baseContent + " " + baseContent;
      } else {
        content = baseContent;
      }

      return FriendCircleModel.sample(
        index,
        commentCount: commentCount,
        praiseCount: praiseCount,
        imageCount: imageCount,
        content: content,
      );
    });
  }
  
  /// 获取基础内容
  String _getBaseContent(int index) {
    final contentPool = [
      "今天天气真好，心情也很棒！",
      "刚看了一部很感人的电影，推荐给大家。",
      "新买的相机终于到了，迫不及待想出去拍照！",
      "周末去爬山，风景太美了！",
      "做了一顿丰盛的晚餐，超级满足~",
      "工作太忙了，好想放假啊！",
      "终于拿到了期待已久的书，准备好好阅读。",
      "今天遇到了一位老朋友，聊了很多往事。",
      "新学的菜获得了家人的一致好评！",
      "刚跑完5公里，感觉真不错。"
    ];
    
    return contentPool[index % contentPool.length];
  }

  /// 模拟计算负载
  void simulateComputeLoad(int loadType) {
    int iterations;
    int complexity = 1;  // 计算复杂度

    switch (loadType) {
      case Constants.LOAD_TYPE_LIGHT:
        iterations = Constants.LIGHT_LOAD_COMPUTE_ITERATIONS;
        complexity = 1;
        break;
      case Constants.LOAD_TYPE_MEDIUM:
        iterations = Constants.MEDIUM_LOAD_COMPUTE_ITERATIONS;
        complexity = 2;
        break;
      case Constants.LOAD_TYPE_HEAVY:
        iterations = Constants.HEAVY_LOAD_COMPUTE_ITERATIONS;
        complexity = 3;
        break;
      default:
        iterations = Constants.LIGHT_LOAD_COMPUTE_ITERATIONS;
        complexity = 1;
    }

    // 执行计算密集型操作 - 模拟不同负载级别的计算
    double result = 0;
    for (int i = 0; i < iterations; i++) {
      // 根据复杂度执行不同的计算
      if (complexity == 1) {
        // 轻负载 - 简单计算
        result += sin(i.toDouble()) * cos(i.toDouble());
      } else if (complexity == 2) {
        // 中负载 - 中等计算
        result += sin(i.toDouble()) * cos(i.toDouble()) * tan(i.toDouble() % 1.5);
      } else {
        // 重负载 - 复杂计算
        result += sin(i.toDouble()) * cos(i.toDouble()) * tan(i.toDouble() % 1.5) * sqrt(i % 10 + 1);
      }
    }
  }
} 