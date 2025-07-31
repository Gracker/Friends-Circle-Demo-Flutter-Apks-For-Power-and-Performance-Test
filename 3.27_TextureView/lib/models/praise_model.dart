import 'user_model.dart';

/// 点赞数据模型
class PraiseModel {
  final String id;
  final UserModel user;
  final DateTime createTime;

  PraiseModel({
    required this.id,
    required this.user,
    required this.createTime,
  });

  /// 创建一个示例点赞
  factory PraiseModel.sample(int postIndex, int praiseIndex, UserModel user) {
    return PraiseModel(
      id: 'praise_${postIndex}_$praiseIndex',
      user: user,
      createTime: DateTime.now().subtract(Duration(minutes: praiseIndex * 5)),
    );
  }
} 