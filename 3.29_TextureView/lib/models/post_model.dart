import 'dart:math';
import 'user_model.dart';
import 'comment_model.dart';
import 'friend_circle_model.dart';
import '../constants.dart';

/// 朋友圈帖子数据模型
class PostModel {
  /// 唯一标识
  final String id;
  
  /// 发帖用户
  final UserModel user;
  
  /// 文本内容
  final String content;
  
  /// 图片URL列表
  final List<String> imageUrls;
  
  /// 位置信息
  final String? location;
  
  /// 发布时间
  final DateTime createTime;
  
  /// 点赞用户列表
  final List<UserModel> likes;
  
  /// 评论列表
  final List<CommentModel> comments;

  /// 构造函数
  PostModel({
    required this.id,
    required this.user,
    required this.content,
    required this.imageUrls,
    this.location,
    required this.createTime,
    required this.likes,
    required this.comments,
  });

  /// 创建一个示例帖子
  factory PostModel.sample(int index, {
    required int likeCount,
    required int commentCount,
  }) {
    final random = Random(Constants.RANDOM_SEED + index);
    
    final user = UserModel.sample(index);
    
    // 生成0-9张图片
    final imageCount = random.nextInt(6);
    final imageUrls = List.generate(
      imageCount,
      (i) => 'image_${index}_$i', // 使用索引作为图片ID
    );
    
    // 生成帖子内容
    final contentType = random.nextInt(5);
    String content;
    
    switch (contentType) {
      case 0:
        content = '今天天气真不错，心情也很好！#心情随笔#';
        break;
      case 1:
        content = '周末去爬山，拍了一些照片分享给大家。山上风景真美，空气清新，身心愉悦！#户外运动# #登山#';
        break;
      case 2:
        content = '新买的相机终于到了，迫不及待想试一下效果。朋友们觉得拍得怎么样？求点评！';
        break;
      case 3:
        content = '刚看了一部超感人的电影，情节扣人心弦，演员表演细腻，强烈推荐！';
        break;
      default:
        content = '分享一组照片，记录生活中的美好瞬间。';
    }
    
    // 生成位置信息
    String? location;
    if (random.nextDouble() < 0.3) {
      final locationTypes = [
        '星巴克咖啡',
        '香格里拉酒店',
        '长城',
        '故宫博物院',
        '环球购物中心',
        '中央公园',
        '西湖',
        '珠峰大本营',
        '三里屯',
        '外滩',
      ];
      location = locationTypes[random.nextInt(locationTypes.length)];
    }
    
    // 生成点赞用户
    final likes = List.generate(
      likeCount,
      (i) => UserModel.sample(i + 10),
    );
    
    // 生成评论
    final comments = List.generate(
      commentCount,
      (i) {
        // 30%的概率生成回复评论
        final hasReply = random.nextDouble() < 0.3 && i > 0;
        return CommentModel.sample(
          index,
          i,
          UserModel.sample(i + 20),
          replyTo: hasReply ? UserModel.sample(i + 19) : null,
        );
      },
    );
    
    return PostModel(
      id: 'post_$index',
      user: user,
      content: content,
      imageUrls: imageUrls,
      location: location,
      createTime: DateTime.now().subtract(Duration(hours: random.nextInt(24) + 1)),
      likes: likes,
      comments: comments,
    );
  }
  
  /// 从FriendCircleModel创建PostModel
  factory PostModel.fromFriendCircleModel(FriendCircleModel model) {
    return PostModel(
      id: model.id,
      user: model.user,
      content: model.content,
      imageUrls: model.imageUrls,
      location: null, // FriendCircleModel没有位置信息
      createTime: model.createTime,
      likes: model.praises.map((praise) => praise.user).toList(),
      comments: model.comments,
    );
  }
} 