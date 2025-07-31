import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/friend_circle_model.dart';
import '../utils/asset_generator.dart';
import 'image_grid.dart';
import 'praise_section.dart';
import 'comment_section.dart';

/// 朋友圈列表项组件
class FriendCircleItem extends StatelessWidget {
  final FriendCircleModel item;
  final int loadType;
  final Function(int) onSimulateLoad;

  const FriendCircleItem({
    Key? key,
    required this.item,
    required this.loadType,
    required this.onSimulateLoad,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 在构建时模拟负载
    onSimulateLoad(loadType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部分割线
          const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFEEEEEE)),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息
                _buildUserInfo(),
                
                const SizedBox(height: 8),
                
                // 内容
                Text(
                  item.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF333333),
                  ),
                ),
                
                // 图片网格
                if (item.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ImageGrid(imageUrls: item.imageUrls),
                ],
                
                const SizedBox(height: 8),
                
                // 发布时间和操作按钮
                _buildBottomBar(),
                
                // 点赞和评论区域
                if (item.praises.isNotEmpty || item.comments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInteractionSection(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AssetGenerator().generateAvatarWidget(item.user.id),
        ),
        
        const SizedBox(width: 8),
        
        // 用户名和内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.user.nickname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(Constants.COLOR_PRIMARY),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建底部栏
  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 发布时间
        Text(
          _formatTime(item.createTime),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
        
        // 操作按钮
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Icon(
            Icons.more_horiz,
            size: 16,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  /// 构建交互区域（点赞和评论）
  Widget _buildInteractionSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 点赞区域
          if (item.praises.isNotEmpty) ...[
            PraiseSection(praises: item.praises),
          ],
          
          // 分割线（如果既有点赞又有评论）
          if (item.praises.isNotEmpty && item.comments.isNotEmpty)
            const Divider(height: 8, thickness: 0.5),
          
          // 评论区域
          if (item.comments.isNotEmpty)
            CommentSection(comments: item.comments),
        ],
      ),
    );
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return DateFormat('MM-dd HH:mm').format(time);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
} 