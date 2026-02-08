import 'user_model.dart';
import 'comment_model.dart';
import 'friend_circle_model.dart';

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
