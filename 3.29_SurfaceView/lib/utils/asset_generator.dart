import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 资源生成器，用于生成和管理示例图片资源
class AssetGenerator {
  // 单例模式
  static final AssetGenerator _instance = AssetGenerator._internal();
  factory AssetGenerator() => _instance;
  AssetGenerator._internal();

  // 缓存生成的图片
  final Map<String, ui.Image> _imageCache = {};
  
  // 固定种子的随机数生成器
  final Random _random = Random(42);
  
  // 缓存Widget，避免重复创建
  final Map<String, Widget> _widgetCache = {};
  
  // 默认颜色列表
  final List<Color> _colors = [
    const Color(0xFF3498DB), // 蓝色
    const Color(0xFFE74C3C), // 红色
    const Color(0xFF2ECC71), // 绿色
    const Color(0xFFF39C12), // 橙色
    const Color(0xFF9B59B6), // 紫色
    const Color(0xFF1ABC9C), // 青色
    const Color(0xFF34495E), // 深蓝灰
    const Color(0xFFD35400), // 深橙色
  ];
  
  // 图片主题
  final List<ImageTheme> _imageThemes = [
    ImageTheme(
      name: "自然风景", 
      icons: [Icons.landscape, Icons.forest, Icons.terrain, Icons.beach_access, Icons.water],
      baseColors: [Colors.green.shade700, Colors.blue.shade700, Colors.brown.shade700]
    ),
    ImageTheme(
      name: "城市风光", 
      icons: [Icons.location_city, Icons.apartment, Icons.business, Icons.domain, Icons.home_work],
      baseColors: [Colors.blueGrey.shade700, Colors.grey.shade700, Colors.indigo.shade700]
    ),
    ImageTheme(
      name: "美食分享", 
      icons: [Icons.restaurant, Icons.fastfood, Icons.local_cafe, Icons.food_bank, Icons.bakery_dining],
      baseColors: [Colors.orange.shade700, Colors.red.shade700, Colors.amber.shade700]
    ),
    ImageTheme(
      name: "运动健身", 
      icons: [Icons.sports_soccer, Icons.sports_basketball, Icons.fitness_center, Icons.directions_run, Icons.sports_tennis],
      baseColors: [Colors.blue.shade700, Colors.green.shade700, Colors.red.shade700]
    ),
    ImageTheme(
      name: "旅行游记", 
      icons: [Icons.flight, Icons.train, Icons.directions_car, Icons.directions_boat, Icons.hotel],
      baseColors: [Colors.teal.shade700, Colors.cyan.shade700, Colors.indigo.shade700]
    ),
  ];

  /// 获取或生成图片
  Future<ui.Image> getImage(String key, int width, int height) async {
    // 如果缓存中已存在，直接返回
    if (_imageCache.containsKey(key)) {
      return _imageCache[key]!;
    }
    
    // 生成新图片
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // 填充背景
    final backgroundColor = _colors[_random.nextInt(_colors.length)];
    final Paint paint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);
    
    // 添加一些图形元素
    _drawRandomShapes(canvas, width, height);
    
    // 添加文本标识
    _drawText(canvas, key, width, height);
    
    // 完成绘制
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    
    // 缓存并返回
    _imageCache[key] = image;
    return image;
  }

  /// 绘制一些随机图形
  void _drawRandomShapes(Canvas canvas, int width, int height) {
    final shapePaint = Paint()..color = Colors.white.withOpacity(0.3);
    
    // 绘制随机圆形
    for (int i = 0; i < 5; i++) {
      final x = _random.nextDouble() * width;
      final y = _random.nextDouble() * height;
      final radius = 10 + _random.nextDouble() * 30;
      canvas.drawCircle(Offset(x, y), radius, shapePaint);
    }
    
    // 绘制随机矩形
    for (int i = 0; i < 3; i++) {
      final x = _random.nextDouble() * width;
      final y = _random.nextDouble() * height;
      final rectWidth = 20 + _random.nextDouble() * 40;
      final rectHeight = 20 + _random.nextDouble() * 40;
      canvas.drawRect(
        Rect.fromLTWH(x, y, rectWidth, rectHeight), 
        shapePaint,
      );
    }
  }

  /// 绘制文本标识
  void _drawText(Canvas canvas, String text, int width, int height) {
    final textStyle = ui.TextStyle(
      color: Colors.white,
      fontSize: 16,
    );
    
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
      ..pushStyle(textStyle)
      ..addText(text);
    
    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: width.toDouble()));
    
    final textWidth = paragraph.longestLine;
    final textHeight = paragraph.height;
    
    canvas.drawParagraph(
      paragraph, 
      Offset(
        (width - textWidth) / 2, 
        (height - textHeight) / 2,
      ),
    );
  }

  /// 获取朋友圈顶部背景图
  Widget getMainBackground() {
    const String mainBackgroundPath = 'assets/images/main_bg.jpg';
    
    // 使用缓存key避免重复创建widget
    if (_widgetCache.containsKey(mainBackgroundPath)) {
      return _widgetCache[mainBackgroundPath]!;
    }
    
    final Widget backgroundWidget = Image.asset(
      mainBackgroundPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        print('Failed to load main background: $error');
        // 如果加载失败，显示备用背景
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blueGrey.shade700,
                Colors.blueGrey.shade900,
              ],
            ),
          ),
        );
      },
    );
    
    _widgetCache[mainBackgroundPath] = backgroundWidget;
    return backgroundWidget;
  }
  
  /// 获取朋友圈顶部头像
  Widget getMainAvatar({double size = 80}) {
    const String mainAvatarPath = 'assets/avatars/main_avatar.jpg';
    
    // 使用缓存key避免重复创建widget
    final String cacheKey = 'main_avatar_$size';
    if (_widgetCache.containsKey(cacheKey)) {
      return _widgetCache[cacheKey]!;
    }
    
    final Widget avatarWidget = ClipRRect(
      borderRadius: BorderRadius.circular(4), // 使用圆角矩形，与朋友圈保持一致
      child: Image.asset(
        mainAvatarPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Failed to load main avatar: $error');
          // 如果加载失败，显示备用头像
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.grey.shade600,
            ),
          );
        },
      ),
    );
    
    _widgetCache[cacheKey] = avatarWidget;
    return avatarWidget;
  }

  /// 生成头像图片Widget
  Widget generateAvatarWidget(String userId, {double size = 40}) {
    final cacheKey = "avatar_${userId}_$size";
    
    if (_widgetCache.containsKey(cacheKey)) {
      return _widgetCache[cacheKey]!;
    }
    
    // 使用userId的hashCode来确保同一用户获得相同的头像
    final hash = userId.hashCode.abs(); // 使用绝对值避免负数
    final avatarIndex = (hash % 11) + 1; // 1-11之间的数字
    final String avatarPath = 'assets/avatars/avatar$avatarIndex.jpg';
    
    // 构建真实头像
    final Widget avatarWidget = ClipRRect(
      borderRadius: BorderRadius.circular(4), // 使用圆角矩形，与微信朋友圈一致
      child: Image.asset(
        avatarPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Failed to load avatar: $error for path: $avatarPath');
          // 如果加载失败，显示备用头像
          return _buildFallbackAvatar(userId, size);
        },
      ),
    );
    
    _widgetCache[cacheKey] = avatarWidget;
    return avatarWidget;
  }
  
  /// 构建备用头像（当图片加载失败时）
  Widget _buildFallbackAvatar(String userId, double size) {
    // 使用userId的hashCode来生成一致的颜色
    final hash = userId.hashCode;
    final random = Random(hash);
    
    final double hue = random.nextDouble() * 360;
    final Color avatarColor = HSLColor.fromAHSL(
      1.0, 
      hue, 
      0.7, 
      0.5 + random.nextDouble() * 0.3
    ).toColor();
    
    // 构建文本头像
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            avatarColor,
            avatarColor.withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          userId.isNotEmpty ? userId.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size / 2,
          ),
        ),
      ),
    );
  }

  /// 生成图片Widget
  Widget generateImageWidget(String imageId, {double? width, double? height}) {
    final cacheKey = "image_${imageId}_${width ?? 0}_${height ?? 0}";
    
    if (_widgetCache.containsKey(cacheKey)) {
      return _widgetCache[cacheKey]!;
    }
    
    // 解析imageId获取图片信息 - imageId可能是"postId-index"格式
    // 或者直接是图片名称，如"local1"
    String imageName;
    
    if (imageId.contains('-')) {
      // 如果是复合ID (如 post_1-0)，提取index部分
      final hash = imageId.hashCode.abs();
      final imageIndex = (hash % 11) + 1; // 1-11之间的数字
      imageName = 'local$imageIndex';
    } else if (imageId.startsWith('local') && imageId.length > 5) {
      // 如果已经是local开头，直接使用
      imageName = imageId;
    } else {
      // 否则，使用hash生成一个1-11的索引
      final hash = imageId.hashCode.abs();
      final imageIndex = (hash % 11) + 1;
      imageName = 'local$imageIndex';
    }
    
    final String imagePath = 'assets/images/$imageName.jpeg';
    
    // 构建真实图片
    final Widget imageWidget = Container(
      width: width,
      height: height,
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Failed to load image: $error for path: $imagePath');
          // 如果加载失败，显示备用图片
          return _buildFallbackImage(imageId, width, height);
        },
      ),
    );
    
    _widgetCache[cacheKey] = imageWidget;
    return imageWidget;
  }
  
  /// 构建备用图片（当图片加载失败时）
  Widget _buildFallbackImage(String imageId, double? width, double? height) {
    // 使用图片ID的hashCode来确保同一ID获得相同的图片
    final hash = imageId.hashCode;
    final random = Random(hash);
    
    // 选择一个随机颜色
    final baseColor = Color.fromRGBO(
      50 + random.nextInt(150),
      50 + random.nextInt(150),
      50 + random.nextInt(150),
      1.0,
    );
    
    // 构建占位图
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            baseColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.white.withOpacity(0.7),
          size: (width ?? 100) / 3,
        ),
      ),
    );
  }
}

/// 图片主题类
class ImageTheme {
  final String name;
  final List<IconData> icons;
  final List<Color> baseColors;
  
  ImageTheme({
    required this.name,
    required this.icons,
    required this.baseColors,
  });
}

/// 头像图案绘制器
class AvatarPatternPainter extends CustomPainter {
  final Random random;
  
  AvatarPatternPainter(this.random);
  
  @override
  void paint(Canvas canvas, Size size) {
    final pattern = random.nextInt(3);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    switch (pattern) {
      case 0: // 同心圆
        final circles = 3 + random.nextInt(3);
        final step = size.width / (circles * 2);
        
        for (int i = 0; i < circles; i++) {
          final radius = step * (i + 1);
          canvas.drawCircle(
            Offset(size.width / 2, size.height / 2),
            radius,
            paint,
          );
        }
        break;
      case 1: // 十字线
        canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          paint,
        );
        break;
      case 2: // 波纹
        final wavePaint = Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        
        final waveCount = 3 + random.nextInt(3);
        final path = Path();
        
        for (int i = 0; i < waveCount; i++) {
          final y = 5 + i * (size.height - 10) / waveCount;
          
          path.moveTo(0, y);
          for (double x = 0; x <= size.width; x += size.width / 20) {
            path.lineTo(
              x,
              y + sin(x / 10) * 3,
            );
          }
          canvas.drawPath(path, wavePaint);
          path.reset();
        }
        break;
    }
  }
  
  @override
  bool shouldRepaint(AvatarPatternPainter oldDelegate) => false;
}

/// 图片图案绘制器
class ImagePatternPainter extends CustomPainter {
  final Random random;
  final Color baseColor;
  
  ImagePatternPainter(this.random, this.baseColor);
  
  @override
  void paint(Canvas canvas, Size size) {
    final pattern = random.nextInt(4);
    
    switch (pattern) {
      case 0: // 山脉
        _drawMountains(canvas, size);
        break;
      case 1: // 波浪
        _drawWaves(canvas, size);
        break;
      case 2: // 网格
        _drawGrid(canvas, size);
        break;
      case 3: // 随机圆点
        _drawDots(canvas, size);
        break;
    }
  }
  
  // 绘制山脉
  void _drawMountains(Canvas canvas, Size size) {
    final mountainCount = 2 + random.nextInt(3);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < mountainCount; i++) {
      final path = Path();
      final height = size.height - (i * size.height / mountainCount) - random.nextInt(20);
      
      path.moveTo(0, size.height);
      
      // 第一个控制点
      path.lineTo(0, height + random.nextInt(20));
      
      // 绘制山脉
      int steps = 4 + random.nextInt(3);
      double stepWidth = size.width / steps;
      
      for (int j = 1; j <= steps; j++) {
        double x = j * stepWidth;
        double y = height - 10 - random.nextInt(30);
        
        if (j == steps) {
          y = height;
        }
        
        double controlX1 = x - stepWidth / 2;
        double controlY1 = height - 20 - random.nextInt(40).toDouble();
        
        path.quadraticBezierTo(controlX1, controlY1, x, y);
      }
      
      path.lineTo(size.width, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  
  // 绘制波浪
  void _drawWaves(Canvas canvas, Size size) {
    final waveCount = 3 + random.nextInt(3);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < waveCount; i++) {
      final path = Path();
      final y = size.height * (0.3 + 0.5 * i / waveCount);
      
      path.moveTo(0, y);
      
      // 绘制波浪线
      double amplitude = 5 + random.nextInt(15).toDouble();
      double frequency = 0.02 + random.nextDouble() * 0.03;
      
      for (double x = 0; x <= size.width; x += 1) {
        path.lineTo(
          x,
          y + sin(x * frequency) * amplitude,
        );
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  // 绘制网格
  void _drawGrid(Canvas canvas, Size size) {
    final gridSize = 10 + random.nextInt(20).toDouble();
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;
    
    // 水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // 垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }
  
  // 绘制圆点
  void _drawDots(Canvas canvas, Size size) {
    final dotCount = 50 + random.nextInt(50);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1 + random.nextDouble() * 3;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(ImagePatternPainter oldDelegate) => false;
} 
