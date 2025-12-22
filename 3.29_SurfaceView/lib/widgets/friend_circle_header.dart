import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';
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

/// 山脉绘制器
class MountainPainter extends CustomPainter {
  final Color color;
  final Random random = Random(42); // 固定种子
  
  MountainPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // 绘制远山
    _drawMountain(
      canvas: canvas,
      width: size.width,
      height: size.height * 0.5,
      baseHeight: size.height * 0.9,
      peakCount: 3,
      paint: Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.fill,
    );
    
    // 绘制中景山
    _drawMountain(
      canvas: canvas,
      width: size.width,
      height: size.height * 0.7,
      baseHeight: size.height,
      peakCount: 4,
      paint: Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );
    
    // 绘制近景山
    _drawMountain(
      canvas: canvas,
      width: size.width,
      height: size.height * 0.9,
      baseHeight: size.height + 20,
      peakCount: 5,
      paint: paint,
    );
  }
  
  void _drawMountain({
    required Canvas canvas,
    required double width,
    required double height,
    required double baseHeight,
    required int peakCount,
    required Paint paint,
  }) {
    final path = Path();
    final peakWidth = width / peakCount;
    
    path.moveTo(0, baseHeight);
    
    for (int i = 0; i < peakCount; i++) {
      final peakX = (i + 0.5) * peakWidth;
      final peakHeight = baseHeight - height * (0.7 + random.nextDouble() * 0.3);
      
      final leftControlX = peakX - peakWidth * 0.3;
      final rightControlX = peakX + peakWidth * 0.3;
      
      if (i == 0) {
        path.lineTo(0, baseHeight - height * 0.5);
      }
      
      path.cubicTo(
        leftControlX, baseHeight - height * 0.2 - random.nextDouble() * height * 0.3,
        leftControlX, peakHeight + height * 0.2,
        peakX, peakHeight,
      );
      
      path.cubicTo(
        rightControlX, peakHeight + height * 0.2,
        rightControlX, baseHeight - height * 0.2 - random.nextDouble() * height * 0.3,
        (i + 1) * peakWidth, i == peakCount - 1 ? baseHeight - height * 0.4 : baseHeight - height * (0.3 + random.nextDouble() * 0.4),
      );
    }
    
    path.lineTo(width, baseHeight);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(MountainPainter oldDelegate) => false;
}

/// 城市绘制器
class CityPainter extends CustomPainter {
  final Color color;
  final Random random = Random(43); // 固定种子
  
  CityPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final cityPath = Path();
    cityPath.moveTo(0, size.height);
    
    double currentX = 0;
    while (currentX < size.width) {
      final buildingWidth = 10 + random.nextDouble() * 40;
      
      if (currentX + buildingWidth > size.width) {
        break;
      }
      
      final buildingHeight = 20 + random.nextDouble() * 70;
      
      // 绘制建筑
      _drawBuilding(
        cityPath,
        currentX,
        size.height,
        buildingWidth,
        buildingHeight,
      );
      
      currentX += buildingWidth;
    }
    
    cityPath.lineTo(size.width, size.height);
    cityPath.close();
    
    canvas.drawPath(cityPath, paint);
  }
  
  void _drawBuilding(
    Path path,
    double x,
    double baseHeight,
    double width,
    double height,
  ) {
    // 建筑类型
    final buildingType = random.nextInt(3);
    
    switch (buildingType) {
      case 0: // 平顶建筑
        path.lineTo(x, baseHeight - height);
        path.lineTo(x + width, baseHeight - height);
        path.lineTo(x + width, baseHeight);
        break;
        
      case 1: // 尖顶建筑
        path.lineTo(x, baseHeight - height);
        path.lineTo(x + width / 2, baseHeight - height - 15);
        path.lineTo(x + width, baseHeight - height);
        path.lineTo(x + width, baseHeight);
        break;
        
      case 2: // 复合建筑
        final segments = 2 + random.nextInt(3);
        final segmentWidth = width / segments;
        
        for (int i = 0; i < segments; i++) {
          final segHeight = height * (0.7 + random.nextDouble() * 0.3);
          final segX = x + i * segmentWidth;
          
          path.lineTo(segX, baseHeight - segHeight);
          path.lineTo(segX + segmentWidth, baseHeight - segHeight);
        }
        
        path.lineTo(x + width, baseHeight);
        break;
    }
  }
  
  @override
  bool shouldRepaint(CityPainter oldDelegate) => false;
}

/// 抽象图案绘制器
class AbstractPainter extends CustomPainter {
  final Color color;
  final Random random = Random(44); // 固定种子
  
  AbstractPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // 绘制线条网格
    for (int i = 0; i < 20; i++) {
      final path = Path();
      
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      
      path.moveTo(startX, startY);
      
      for (int j = 0; j < 5; j++) {
        final controlPoint1X = random.nextDouble() * size.width;
        final controlPoint1Y = random.nextDouble() * size.height;
        
        final controlPoint2X = random.nextDouble() * size.width;
        final controlPoint2Y = random.nextDouble() * size.height;
        
        final endX = random.nextDouble() * size.width;
        final endY = random.nextDouble() * size.height;
        
        path.cubicTo(
          controlPoint1X, controlPoint1Y,
          controlPoint2X, controlPoint2Y,
          endX, endY,
        );
      }
      
      final pathPaint = Paint()
        ..color = color.withOpacity(0.1 + random.nextDouble() * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(path, pathPaint);
    }
    
    // 绘制圆形
    for (int i = 0; i < 10; i++) {
      final centerX = random.nextDouble() * size.width;
      final centerY = random.nextDouble() * size.height;
      final radius = 10 + random.nextDouble() * 40;
      
      final circlePaint = Paint()
        ..color = color.withOpacity(0.05 + random.nextDouble() * 0.1)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        circlePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(AbstractPainter oldDelegate) => false;
} 