import 'package:flutter/material.dart';
import 'dart:math';

class CloudyEffect extends StatefulWidget {
  const CloudyEffect({super.key});

  @override
  _CloudyEffectState createState() => _CloudyEffectState();
}

class _CloudyEffectState extends State<CloudyEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: CloudyPainter(_animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class CloudyPainter extends CustomPainter {
  final double animationValue;
  final Random random = Random();

  CloudyPainter(this.animationValue);

  Path createCloudPath(Offset center, double size) {
    Path path = Path();
    double variation = size * 0.3;

    path.moveTo(center.dx - size, center.dy);
    path.quadraticBezierTo(
      center.dx - size * 0.7, center.dy - size * 0.5,
      center.dx - size * 0.3, center.dy - variation * random.nextDouble(),
    );
    path.quadraticBezierTo(
      center.dx, center.dy - size * 0.6,
      center.dx + size * 0.3, center.dy - variation * random.nextDouble(),
    );
    path.quadraticBezierTo(
      center.dx + size * 0.7, center.dy - size * 0.5,
      center.dx + size, center.dy,
    );
    path.quadraticBezierTo(
      center.dx + size * 0.6, center.dy + size * 0.4,
      center.dx, center.dy + size * 0.3,
    );
    path.quadraticBezierTo(
      center.dx - size * 0.6, center.dy + size * 0.4,
      center.dx - size, center.dy,
    );
    path.close();

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 5; i++) {
      final offsetX = (animationValue * size.width + i * 200) % (size.width + 200) - 200;
      final offsetY = size.height * 0.2 + i * 60;
      final cloudSize = 60.0 + i * 15;

      final basePaint = Paint()
        ..color = Colors.grey[400]!.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      Path baseCloud = createCloudPath(Offset(offsetX, offsetY), cloudSize);
      canvas.drawPath(baseCloud, basePaint);

      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      Path highlightCloud = createCloudPath(
        Offset(offsetX - 2, offsetY - 2),
        cloudSize * 0.9,
      );
      canvas.drawPath(highlightCloud, highlightPaint);

      final shadowPaint = Paint()
        ..color = Colors.grey[600]!.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      Path shadowCloud = createCloudPath(
        Offset(offsetX + 2, offsetY + 2),
        cloudSize * 0.95,
      );
      canvas.drawPath(shadowCloud, shadowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}