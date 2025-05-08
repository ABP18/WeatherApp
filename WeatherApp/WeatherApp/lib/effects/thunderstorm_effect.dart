import 'package:flutter/material.dart';
import 'dart:math';

class ThunderstormEffect extends StatefulWidget {
  const ThunderstormEffect({super.key});

  @override
  _ThunderstormEffectState createState() => _ThunderstormEffectState();
}

class _ThunderstormEffectState extends State<ThunderstormEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rainAnimation;
  double _lightningOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5), // Ciclo de animación de la lluvia
      vsync: this,
    )..repeat();

    _rainAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Simular relámpagos intermitentes
    Future.delayed(Duration(milliseconds: Random().nextInt(3000)), _triggerLightning);
  }

  void _triggerLightning() {
    if (!mounted) return;
    setState(() => _lightningOpacity = 1.0); // Destello completo
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() => _lightningOpacity = 0.3); // Atenuación rápida
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() => _lightningOpacity = 0.0); // Apagar
        Future.delayed(Duration(milliseconds: 2000 + Random().nextInt(3000)), _triggerLightning); // Siguiente relámpago
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rainAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ThunderstormPainter(_rainAnimation.value, _lightningOpacity),
          size: Size.infinite,
        );
      },
    );
  }
}

class ThunderstormPainter extends CustomPainter {
  final double rainAnimationValue;
  final double lightningOpacity;

  ThunderstormPainter(this.rainAnimationValue, this.lightningOpacity);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final rainPaint = Paint()
      ..color = Colors.blueGrey[400]!.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Dibujar lluvia intensa
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = (rainAnimationValue * size.height + i * 20) % size.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + random.nextDouble() * 5 - 2.5, y + 20), // Lluvia inclinada
        rainPaint,
      );
    }

    // Dibujar relámpago (destello en toda la pantalla)
    if (lightningOpacity > 0) {
      final lightningPaint = Paint()
        ..color = Colors.white.withOpacity(lightningOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        lightningPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}