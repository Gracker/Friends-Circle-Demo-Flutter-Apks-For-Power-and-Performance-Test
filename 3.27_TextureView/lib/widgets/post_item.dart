import 'package:flutter/material.dart';
import 'dart:math';
import '../models/post_model.dart';
import '../constants.dart';
import '../data/data_center.dart';
import 'post_image_grid.dart';
import 'post_action_bar.dart';
import 'user_avatar.dart';

/// 朋友圈帖子项组件
class PostItem extends StatelessWidget {
  /// 帖子数据
  final PostModel post;
  
  /// 负载类型，用于在UI逻辑中添加不同程度的计算负载
  final int? loadType;
  
  /// 构造函数
  const PostItem({
    Key? key,
    required this.post,
    this.loadType,
  }) : super(key: key);
  
  /// 在UI逻辑中执行负载计算，作为Widget构建过程的一部分
  double _performUILoadCalculation() {
    if (loadType == null) return 0.0;
    
    int iterations;
    int complexity;

    switch (loadType!) {
      case Constants.LOAD_TYPE_LIGHT:
        iterations = 10; // 轻负载：极少迭代，几乎无感知，保证流畅体验
        complexity = 1;
        break;
      case Constants.LOAD_TYPE_MEDIUM:
        iterations = 2000; // 中负载：适度迭代，轻微卡顿
        complexity = 2;
        break;
      case Constants.LOAD_TYPE_HEAVY:
        iterations = 20000; // 重负载：大量迭代，明显卡顿，增加负载
        complexity = 3;
        break;
      default:
        iterations = 10;
        complexity = 1;
    }

    // 执行计算作为UI逻辑的一部分，用于影响UI的布局和样式计算
    double result = 0.0;
    for (int i = 0; i < iterations; i++) {
      if (complexity == 1) {
        // 轻负载 - 最简单的计算，几乎无感知
        result += i * 0.001;
      } else if (complexity == 2) {
        // 中负载 - 稍复杂的计算，轻微影响性能
        result += sin(i * 0.01) * cos(i * 0.01);
      } else {
        // 重负载 - 复杂计算，明显影响性能
        result += sin(i * 0.01) * cos(i * 0.01) * tan((i * 0.01) % 1.5) * sqrt((i % 10) + 1);
      }
    }
    return result;
  }
  
  @override
  Widget build(BuildContext context) {
    // 在UI构建过程中执行负载计算，结果用于影响UI显示
    final loadResult = _performUILoadCalculation();
    
    // 根据负载计算结果微调UI参数（让负载计算有实际意义）
    final dynamicPadding = 16.0 + (loadResult.abs() % 2); // 动态调整padding
    final dynamicBorderOpacity = 0.15 + (loadResult.abs() % 0.05); // 动态调整边框透明度
    
    return Container(
      padding: EdgeInsets.fromLTRB(dynamicPadding, 16, dynamicPadding, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(dynamicBorderOpacity),
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
                
                // 帖子文本内容 - 增大字体，根据负载调整行高
                Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 16, // 增大字体
                    color: const Color(0xFF333333),
                    height: 1.4 + (loadResult.abs() % 0.1), // 根据负载动态调整行高
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