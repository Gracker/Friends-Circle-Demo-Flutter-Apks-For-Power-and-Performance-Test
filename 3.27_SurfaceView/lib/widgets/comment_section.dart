import 'package:flutter/material.dart';
import '../models/comment_model.dart';

/// 评论区域组件
class CommentSection extends StatelessWidget {
  final List<CommentModel> comments;

  const CommentSection({
    Key? key,
    required this.comments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: comments.map((comment) => _buildCommentItem(comment)).toList(),
    );
  }

  /// 构建单个评论项
  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF333333),
            height: 1.3,
          ),
          children: [
            TextSpan(
              text: comment.user.nickname,
              style: const TextStyle(
                color: Color(0xFF576B95),
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // 如果是回复评论，显示回复对象
            if (comment.replyTo != null) ...[
              const TextSpan(text: ' 回复 '),
              TextSpan(
                text: comment.replyTo!.nickname,
                style: const TextStyle(
                  color: Color(0xFF576B95),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            const TextSpan(text: '：'),
            TextSpan(text: comment.content),
          ],
        ),
      ),
    );
  }
} 