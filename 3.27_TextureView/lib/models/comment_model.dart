import 'dart:math';
import 'user_model.dart';
import '../constants.dart';

/// 评论数据模型
class CommentModel {
  final String id;
  final UserModel user;
  final String content;
  final DateTime createTime;
  final UserModel? replyTo; // 回复的用户，如果为null则表示直接评论

  CommentModel({
    required this.id,
    required this.user,
    required this.content,
    required this.createTime,
    this.replyTo,
  });

  /// 创建一个示例评论
  factory CommentModel.sample(int postIndex, int commentIndex, UserModel user, {UserModel? replyTo}) {
    final random = Random(Constants.RANDOM_SEED + postIndex + commentIndex);
    
    // 评论内容列表
    final List<String> commentContents = [
      '赞一个！',
      '支持一下',
      '不错哦！',
      '太棒了',
      '很喜欢',
      '拍得真好看！',
      '厉害了',
      '羡慕啊',
      '真的很美',
      '太有才了',
      '期待下次分享',
      '学习了',
      '666',
      '图片拍得真不错，是用什么相机拍的？',
      '风景太美了，下次也想去',
      '什么时候有机会一起出去玩啊',
      '看起来很开心的样子',
      '真的很棒，感谢分享',
      '这条朋友圈也太有意思了',
      '这次的活动真不错',
    ];
    
    // 根据是否是回复生成不同的内容
    String content;
    if (replyTo != null) {
      final replyContents = [
        '谢谢支持！',
        '是啊，真的很棒',
        '下次一起去啊',
        '这是用手机拍的',
        '好的，有机会聊聊',
        '我也这么觉得',
        '确实如此',
        '哈哈，那是当然',
        '知道啦，谢谢',
        '一定一定',
      ];
      content = replyContents[random.nextInt(replyContents.length)];
    } else {
      content = commentContents[random.nextInt(commentContents.length)];
    }
    
    return CommentModel(
      id: 'comment_${postIndex}_$commentIndex',
      user: user,
      content: content,
      createTime: DateTime.now().subtract(Duration(hours: commentIndex * 2)),
      replyTo: replyTo,
    );
  }
} 