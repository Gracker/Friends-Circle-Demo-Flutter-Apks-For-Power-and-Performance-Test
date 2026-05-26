import 'package:flutter/material.dart';
import '../utils/asset_generator.dart';

/// 朋友圈顶部视图组件
class FriendCircleHeader extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final VoidCallback onBackPressed;

  const FriendCircleHeader({
    Key? key,
    required this.title,
    required this.backgroundColor,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Stack(
        children: [
          // 背景图
          Positioned.fill(
            child: AssetGenerator().getMainBackground(),
          ),

          // 背景渐变层（增加可读性）
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),

          // 顶部状态栏区域
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 40,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 顶部导航栏
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildNavBar(context),
          ),

          // 用户信息区域
          Positioned(
            bottom: 20,
            right: 15,
            child: _buildUserInfo(),
          ),

          // 页面标题 (显示在副标题位置，模拟朋友圈状态信息)
          Positioned(
            bottom: 25,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLoadTypeName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建导航栏
  Widget _buildNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: onBackPressed,
          ),

          // 标题
          Text(
            "朋友圈",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),

          // 相机按钮
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 用户名
        Padding(
          padding: const EdgeInsets.only(right: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '微信用户',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 头像
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AssetGenerator().getMainAvatar(size: 75),
        ),
      ],
    );
  }

  /// 获取加载类型名称
  String _getLoadTypeName() {
    if (backgroundColor == Colors.blue) {
      return "轻量级加载";
    } else if (backgroundColor == Colors.orange) {
      return "中量级加载";
    } else {
      return "重量级加载";
    }
  }
}
