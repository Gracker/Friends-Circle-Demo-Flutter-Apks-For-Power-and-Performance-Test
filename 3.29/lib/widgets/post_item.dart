import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'post_image_grid.dart';
import 'post_action_bar.dart';
import 'user_avatar.dart';

/// 朋友圈帖子项组件
class PostItem extends StatelessWidget {
  /// 帖子数据
  final PostModel post;
  
  /// 构造函数
  const PostItem({
    Key? key,
    required this.post,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户头像 - 使用圆角矩形
          UserAvatar(
            userId: post.user.id,
            size: 48, // 微信朋友圈的头像更大一些
          ),
          
          const SizedBox(width: 12), // 增加间距
          
          // 帖子内容
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 使用min确保内容尽可能紧凑
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名称 - 增大字体
                Text(
                  post.user.nickname,
                  style: const TextStyle(
                    color: Color(0xFF576B95),
                    fontWeight: FontWeight.bold,
                    fontSize: 17, // 增大字体
                  ),
                ),
                
                const SizedBox(height: 6), // 增加间距
                
                // 帖子文本内容 - 增大字体
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 16, // 增大字体
                    color: Color(0xFF333333),
                    height: 1.4, // 增加行高
                  ),
                ),
                
                // 图片网格 - 设置合适的上边距，确保紧跟在文本后面
                if (post.imageUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: PostImageGrid(
                      imageUrls: post.imageUrls,
                      postId: post.id,
                    ),
                  ),
                
                // 位置信息 - 设置合适的上边距
                if (post.location != null && post.location!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildLocationInfo(post.location!),
                  ),
                
                // 底部时间和操作区域
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildTimeAndActionBar(),
                ),
                
                // 点赞和评论区域
                PostActionBar(post: post),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建位置信息
  Widget _buildLocationInfo(String location) {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          size: 15,
          color: Color(0xFF576B95),
        ),
        const SizedBox(width: 2),
        Text(
          location,
          style: const TextStyle(
            color: Color(0xFF576B95),
            fontSize: 14, // 增大字体
          ),
        ),
      ],
    );
  }
  
  /// 构建时间和操作栏
  Widget _buildTimeAndActionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 发布时间
        Text(
          '1小时前',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14, // 增大字体
          ),
        ),
        
        // 操作按钮
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.more_horiz,
            size: 16,
            color: Color(0xFF576B95),
          ),
        ),
      ],
    );
  }
} 