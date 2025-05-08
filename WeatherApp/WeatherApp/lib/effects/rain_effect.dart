import 'dart:math';
import 'package:flutter/material.dart';

class RainEffect extends StatefulWidget {
  const RainEffect({super.key});

  @override
  _RainEffectState createState() => _RainEffectState();
}

class _RainEffectState extends State<RainEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<RainDrop> rainDrops = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _controller.addListener(() {
      if (_isInitialized) {
        setState(() {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;
          for (var drop in rainDrops) {
            drop.fall(screenHeight, screenWidth);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar las gotas solo la primera vez que se construye el widget
    if (!_isInitialized) {
      final screenWidth = MediaQuery.of(context).size.width;
      for (int i = 0; i < 100; i++) {
        rainDrops.add(RainDrop(screenWidth: screenWidth));
      }
      _isInitialized = true;
    }

    return CustomPaint(
      painter: RainPainter(rainDrops),
      size: Size.infinite,
    );
  }
}

class RainDrop {
  double x; // Posición inicial en X
  double y; // Posición inicial en Y
  double length; // Longitud de la gota
  double speed; // Velocidad de caída
  double windOffset; // Desplazamiento horizontal por viento
  double opacity; // Opacidad para simular profundidad
  bool splash = false; // Indica si está salpicando
  double splashRadius = 0; // Radio de la salpicadura

  RainDrop({required double screenWidth})
      : x = Random().nextDouble() * screenWidth,
        y = Random().nextDouble() * -200 - 50, // Comienzan fuera de la pantalla
        length = Random().nextDouble() * 15 + 5, // Tamaños variados
        speed = Random().nextDouble() * 8 + 4, // Velocidades variadas
        windOffset = Random().nextDouble() * 2 - 1, // Viento leve (-1 a 1)
        opacity = Random().nextDouble() * 0.5 + 0.3; // Opacidad entre 0.3 y 0.8

  void fall(double screenHeight, double screenWidth) {
    y += speed; // Caída vertical
    x += windOffset; // Movimiento horizontal por viento

    if (y > screenHeight - length && !splash) {
      splash = true; // Activar salpicadura
      splashRadius = 0; // Reiniciar radio de salpicadura
    }

    if (splash) {
      splashRadius += 2; // Expandir salpicadura
      if (splashRadius > 10) {
        // Reiniciar gota después de la salpicadura
        y = Random().nextDouble() * -200 - 50; // Volver arriba
        x = Random().nextDouble() * screenWidth; // Nueva posición X
        splash = false; // Desactivar salpicadura
        splashRadius = 0;
        speed = Random().nextDouble() * 8 + 4; // Nueva velocidad
        windOffset = Random().nextDouble() * 2 - 1; // Nuevo viento
      }
    }

    // Mantener las gotas dentro de los límites horizontales
    if (x < 0) x = screenWidth;
    if (x > screenWidth) x = 0;
  }
}

class RainPainter extends CustomPainter {
  final List<RainDrop> rainDrops;

  RainPainter(this.rainDrops);

  @override
  void paint(Canvas canvas, Size size) {
    for (var drop in rainDrops) {
      // Pintar la gota
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.blue.withOpacity(drop.opacity),
            Colors.grey.withOpacity(drop.opacity * 0.5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(drop.x, drop.y, 2, drop.length))
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + drop.windOffset, drop.y + drop.length),
        paint,
      );

      // Pintar salpicadura si está activa
      if (drop.splash) {
        final splashPaint = Paint()
          ..color = Colors.blue.withOpacity(drop.opacity * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        canvas.drawCircle(
          Offset(drop.x, size.height),
          drop.splashRadius,
          splashPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}