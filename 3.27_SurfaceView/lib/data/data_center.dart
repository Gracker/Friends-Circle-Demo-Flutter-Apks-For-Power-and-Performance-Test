import 'dart:math';

import '../constants.dart';
import '../models/friend_circle_model.dart';
import '../utils/load_calculator.dart';

/// Data Center for generating and managing test data
class DataCenter {
  // Singleton pattern
  static final DataCenter _instance = DataCenter._internal();
  factory DataCenter() => _instance;
  DataCenter._internal();

  // Cached data (by load type)
  final Map<int, List<FriendCircleModel>> _cachedData = {};

  /// Clear cached data
  void clearCachedData() {
    _cachedData.clear();
  }

  /// Get friend circle data for specified load type (new API, supports all 13 load types)
  List<FriendCircleModel> getFriendCircleDataForLoadType(int loadType) {
    // Check cache
    if (_cachedData.containsKey(loadType)) {
      return _cachedData[loadType]!;
    }

    // Generate data and cache
    final data = _generateFriendCircleDataForLoadType(loadType);
    _cachedData[loadType] = data;
    return data;
  }

  /// Generate friend circle data for specified load type
  List<FriendCircleModel> _generateFriendCircleDataForLoadType(int loadType) {
    // Use LoadCalculator to get data generation parameters
    final params = LoadCalculator().getDataGenerationParams(loadType);
    
    // Use different random seed based on load type for data consistency
    final seedOffset = loadType * 100;
    final seedRandom = Random(Constants.RANDOM_SEED + seedOffset);

    // Generate friend circle data
    return List.generate(Constants.FRIEND_CIRCLE_COUNT, (index) {
      // Use fixed seed + index for data consistency
      final localRandom = Random(seedRandom.nextInt(10000) + index);
      
      // Generate comment and like counts
      final commentCount = localRandom.nextInt(params.maxComments) + 1;
      final praiseCount = localRandom.nextInt(params.maxPraises) + 1;
      
      // Generate image count - 50% chance of having images
      int imageCount = 0;
      if (localRandom.nextBool()) {
        imageCount = localRandom.nextInt(params.maxImages) + 1;
      }
      
      // Generate content based on load type
      String content = _generateContent(index, loadType);

      return FriendCircleModel.sample(
        index,
        commentCount: commentCount,
        praiseCount: praiseCount,
        imageCount: imageCount,
        content: content,
      );
    });
  }

  /// Generate content text
  String _generateContent(int index, int loadType) {
    final baseContent = _getBaseContent(index);
    
    // Adjust content length based on load level
    final level = _getLoadLevel(loadType);
    
    switch (level) {
      case 0: // Minimal
        return baseContent;
      case 1: // Light
        return baseContent;
      case 2: // Medium
        return '$baseContent $baseContent';
      case 3: // Heavy
        return '$baseContent $baseContent $baseContent';
      default:
        return baseContent;
    }
  }

  /// Get load level
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
  
  /// Get base content
  String _getBaseContent(int index) {
    final contentPool = [
      "Beautiful weather today, feeling great!",
      "Just watched a touching movie, highly recommend it.",
      "My new camera finally arrived, can't wait to take photos!",
      "Went hiking this weekend, the scenery was amazing!",
      "Made a delicious dinner, super satisfied~",
      "Work has been so busy, really need a vacation!",
      "Finally got the book I've been waiting for, ready to read.",
      "Met an old friend today, talked about old times.",
      "The new dish I learned got great reviews from family!",
      "Just finished a 5km run, feeling awesome."
    ];
    
    return contentPool[index % contentPool.length];
  }

}
