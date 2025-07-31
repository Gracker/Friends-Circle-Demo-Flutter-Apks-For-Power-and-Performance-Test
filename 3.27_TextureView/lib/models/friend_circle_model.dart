import 'dart:math';
import 'user_model.dart';
import 'comment_model.dart';
import 'praise_model.dart';
import '../constants.dart';

/// 朋友圈数据模型
class FriendCircleModel {
  final String id;
  final UserModel user;
  final String content;
  final List<String> imageUrls;
  final DateTime createTime;
  final List<PraiseModel> praises;
  final List<CommentModel> comments;

  FriendCircleModel({
    required this.id,
    required this.user,
    required this.content,
    required this.imageUrls,
    required this.createTime,
    required this.praises,
    required this.comments,
  });

  /// 创建一个示例朋友圈
  factory FriendCircleModel.sample(int index, {
    required int praiseCount,
    required int commentCount,
    int imageCount = -1, // -1表示随机生成
    String? content,
  }) {
    final random = Random(Constants.RANDOM_SEED + index);
    
    final user = UserModel.sample(index);
    
    // 生成图片
    final int finalImageCount = imageCount >= 0 ? imageCount : random.nextInt(10);
    final imageUrls = List.generate(
      finalImageCount,
      (i) => 'local${(i % 11) + 1}', // 使用local1-local11的图片名称
    );
    
    // 生成朋友圈内容
    String finalContent;
    if (content != null) {
      finalContent = content;
    } else {
      final contentType = random.nextInt(5);
      
      switch (contentType) {
        case 0:
          finalContent = '今天天气真不错，心情也很好！这是第${index + 1}条朋友圈，包含了${praiseCount}个点赞和${commentCount}条评论。';
          break;
        case 1:
          finalContent = '周末去爬山，拍了一些照片分享给大家。山上风景真美，空气清新，身心愉悦！#户外运动# #登山#';
          break;
        case 2:
          finalContent = '新买的相机终于到了，迫不及待想试一下效果。朋友们觉得拍得怎么样？求点评！';
          break;
        case 3:
          finalContent = '刚看了一部超感人的电影，情节扣人心弦，演员表演细腻，强烈推荐！';
          break;
        default:
          finalContent = '这是第${index + 1}条性能测试的朋友圈内容，包含了${praiseCount}个点赞和${commentCount}条评论。滑动时可以感受不同负载级别带来的性能差异。';
      }
    }
    
    // 生成点赞
    final praises = List.generate(
      praiseCount,
      (i) => PraiseModel.sample(index, i, UserModel.sample(i + 10)),
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
    
    return FriendCircleModel(
      id: 'post_$index',
      user: user,
      content: finalContent,
      imageUrls: imageUrls,
      createTime: DateTime.now().subtract(Duration(hours: index * 3)),
      praises: praises,
      comments: comments,
    );
  }
} 