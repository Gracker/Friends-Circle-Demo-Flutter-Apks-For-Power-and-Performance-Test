import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/load_calculator.dart';
import '../constants.dart';

/// CustomPainter for Paint Phase Load
///
/// Generates GPU load by drawing complex shapes in the paint() method:
/// - Light load: Draw few simple shapes
/// - Medium load: Draw moderate shapes + shadows
/// - Heavy load: Draw many complex shapes + shadows + blur
class PaintLoadPainter extends CustomPainter {
  final PaintLoadParams params;
  final int seed;  // Random seed for consistency

  PaintLoadPainter({
    required this.params,
    this.seed = Constants.RANDOM_SEED,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (params.shapeCount == 0) return;

    final random = Random(seed);

    // Select drawing method based on complexity level
    switch (params.complexity) {
      case 1:
        _paintLightLoad(canvas, size, random);
        break;
      case 2:
        _paintMediumLoad(canvas, size, random);
        break;
      case 3:
        _paintHeavyLoad(canvas, size, random);
        break;
    }
  }

  /// Light load drawing - simple shapes
  void _paintLightLoad(Canvas canvas, Size size, Random random) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < params.shapeCount; i++) {
      // Random color (low opacity, doesn't affect visuals)
      paint.color = Color.fromARGB(
        10, // Low opacity
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );

      // Random position and size
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 5 + 1;

      // Draw circle
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  /// Medium load drawing - shapes + shadows
  void _paintMediumLoad(Canvas canvas, Size size, Random random) {
    for (int i = 0; i < params.shapeCount; i++) {
      // Random color
      final color = Color.fromARGB(
        15,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );

      // Random position and size
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 8 + 2;

      // Create Paint with shadow
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      if (params.enableShadow) {
        // Draw shadow
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(x + 2, y + 2), radius, shadowPaint);
      }

      // Draw main shape
      canvas.drawCircle(Offset(x, y), radius, paint);

      // Draw complex path
      if (i % 3 == 0) {
        _drawComplexPath(canvas, size, random, params.pathPoints, color);
      }
    }
  }

  /// Heavy load drawing - many complex shapes + shadows + blur
  void _paintHeavyLoad(Canvas canvas, Size size, Random random) {
    for (int i = 0; i < params.shapeCount; i++) {
      // Random color
      final color = Color.fromARGB(
        8,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );

      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 10 + 3;

      // Draw shadow (larger blur)
      if (params.enableShadow) {
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.03)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset(x + 3, y + 3), radius * 1.2, shadowPaint);
      }

      // Draw main shape
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Heavy load uses blur effect
      if (params.enableBlur) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      }

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Draw more complex paths
      if (i % 2 == 0) {
        _drawComplexPath(canvas, size, random, params.pathPoints, color);
      }

      // Draw gradient rectangle
      if (i % 5 == 0) {
        _drawGradientRect(canvas, size, random);
      }
    }
  }

  /// Draw complex path
  void _drawComplexPath(Canvas canvas, Size size, Random random, int points, Color color) {
    final path = Path();
    final startX = random.nextDouble() * size.width;
    final startY = random.nextDouble() * size.height;
    path.moveTo(startX, startY);

    for (int j = 0; j < points; j++) {
      final controlX1 = random.nextDouble() * size.width;
      final controlY1 = random.nextDouble() * size.height;
      final controlX2 = random.nextDouble() * size.width;
      final controlY2 = random.nextDouble() * size.height;
      final endX = random.nextDouble() * size.width;
      final endY = random.nextDouble() * size.height;

      // Use cubic bezier curve (more complex calculation)
      path.cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
    }

    final pathPaint = Paint()
      ..color = color.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawPath(path, pathPaint);
  }

  /// Draw gradient rectangle
  void _drawGradientRect(Canvas canvas, Size size, Random random) {
    final rect = Rect.fromLTWH(
      random.nextDouble() * size.width * 0.8,
      random.nextDouble() * size.height * 0.8,
      random.nextDouble() * 20 + 10,
      random.nextDouble() * 20 + 10,
    );

    final gradient = LinearGradient(
      colors: [
        Color.fromARGB(5, random.nextInt(256), random.nextInt(256), random.nextInt(256)),
        Color.fromARGB(5, random.nextInt(256), random.nextInt(256), random.nextInt(256)),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant PaintLoadPainter oldDelegate) {
    return oldDelegate.params.shapeCount != params.shapeCount ||
           oldDelegate.params.complexity != params.complexity ||
           oldDelegate.seed != seed;
  }
}

/// Paint Load Widget Wrapper
class PaintLoadWidget extends StatelessWidget {
  final int loadType;
  final Widget child;

  const PaintLoadWidget({
    Key? key,
    required this.loadType,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calculator = LoadCalculator();

    // Only add paint load for Paint load types
    if (!calculator.isPaintLoadType(loadType)) {
      return child;
    }

    final params = calculator.getPaintLoadParams(loadType);

    return Stack(
      children: [
        child,
        // Overlay paint load on top of content (low opacity, doesn't affect visuals)
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: PaintLoadPainter(params: params),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated Paint Load Widget (for continuous GPU load)
class AnimatedPaintLoadWidget extends StatefulWidget {
  final int loadType;
  final Widget child;

  const AnimatedPaintLoadWidget({
    Key? key,
    required this.loadType,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedPaintLoadWidget> createState() => _AnimatedPaintLoadWidgetState();
}

class _AnimatedPaintLoadWidgetState extends State<AnimatedPaintLoadWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _frameCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    )..addListener(() {
        setState(() {
          _frameCount++;
        });
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculator = LoadCalculator();

    if (!calculator.isPaintLoadType(widget.loadType)) {
      return widget.child;
    }

    final params = calculator.getPaintLoadParams(widget.loadType);

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: PaintLoadPainter(
                params: params,
                seed: Constants.RANDOM_SEED + _frameCount, // Change each frame
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}
