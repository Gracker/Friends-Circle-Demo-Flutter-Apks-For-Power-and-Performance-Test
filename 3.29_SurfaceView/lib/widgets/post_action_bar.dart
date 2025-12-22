import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';

/// 朋友圈帖子动作栏组件（点赞、评论）
class PostActionBar extends StatelessWidget {
  /// 帖子数据
  final PostModel post;
  
  /// 构造函数
  const PostActionBar({
    Key? key,
    required this.post,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 如果没有点赞和评论，返回空组件
    if (post.likes.isEmpty && post.comments.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 仅当有点赞或评论时才显示容器
        Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 点赞区域
              if (post.likes.isNotEmpty)
                _buildLikesSection(),
              
              // 评论区域
              if (post.comments.isNotEmpty) _buildCommentsSection(context),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 构建点赞区域
  Widget _buildLikesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 点赞图标
          Padding(
            padding: const EdgeInsets.only(top: 3, right: 4),
            child: Icon(
              Icons.favorite,
              color: Colors.red.shade400,
              size: 13,
            ),
          ),
          
          // 点赞用户名列表
          Expanded(
            child: Wrap(
              spacing: 5,
              children: _buildLikeUserNames(),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建点赞用户名列表
  List<Widget> _buildLikeUserNames() {
    final List<Widget> nameWidgets = [];
    
    for (int i = 0; i < post.likes.length; i++) {
      // 添加用户名
      nameWidgets.add(
        Text(
          post.likes[i].nickname,
          style: const TextStyle(
            color: Color(0xFF576B95),
            fontSize: 13,
          ),
        ),
      );
      
      // 如果不是最后一个，添加逗号
      if (i < post.likes.length - 1) {
        nameWidgets.add(
          const Text(
            ", ",
            style: TextStyle(
              color: Color(0xFF454545),
              fontSize: 13,
            ),
          ),
        );
      }
    }
    
    return nameWidgets;
  }
  
  /// 构建评论区域
  Widget _buildCommentsSection(BuildContext context) {
    // 如果同时有点赞和评论，添加分隔线
    Widget divider = (post.likes.isNotEmpty)
        ? const Divider(height: 1, thickness: 0.5, indent: 0, endIndent: 0, color: Color(0xFFEAEAEA))
        : const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        divider,
        ...post.comments.map((comment) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: _buildCommentItem(comment),
          );
        }).toList(),
      ],
    );
  }
  
  /// 构建评论项
  Widget _buildCommentItem(CommentModel comment) {
    // 回复评论
    if (comment.replyTo != null) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Color(0xFF454545)),
          children: [
            TextSpan(
              text: comment.user.nickname,
              style: const TextStyle(color: Color(0xFF576B95)),
            ),
            const TextSpan(text: ' 回复 '),
            TextSpan(
              text: comment.replyTo!.nickname,
              style: const TextStyle(color: Color(0xFF576B95)),
            ),
            const TextSpan(text: '：'),
            TextSpan(text: comment.content),
          ],
        ),
      );
    }
    
    // 普通评论
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Color(0xFF454545)),
        children: [
          TextSpan(
            text: comment.user.nickname,
            style: const TextStyle(color: Color(0xFF576B95)),
          ),
          const TextSpan(text: '：'),
          TextSpan(text: comment.content),
        ],
      ),
    );
  }
} 