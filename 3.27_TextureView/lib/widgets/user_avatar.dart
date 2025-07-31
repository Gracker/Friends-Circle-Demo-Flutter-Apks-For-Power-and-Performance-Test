import 'package:flutter/material.dart';
import '../utils/asset_generator.dart';

/// 用户头像组件
class UserAvatar extends StatelessWidget {
  /// 用户ID
  final String userId;
  
  /// 头像尺寸
  final double size;
  
  /// 是否显示边框
  final bool hasBorder;
  
  /// 构造函数
  const UserAvatar({
    Key? key,
    required this.userId,
    this.size = 48,
    this.hasBorder = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 圆角大小 - 微信朋友圈头像使用圆角矩形
    final double borderRadius = 4.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
        boxShadow: hasBorder
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AssetGenerator().generateAvatarWidget(userId, size: size),
      ),
    );
  }
} 