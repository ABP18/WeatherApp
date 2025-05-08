import 'dart:math';
import 'package:flutter/material.dart';

class SunnyEffect extends StatefulWidget {
  const SunnyEffect({super.key});

  @override
  _SunnyEffectState createState() => _SunnyEffectState();
}

class _SunnyEffectState extends State<SunnyEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<SunRay> rays = [];
  List<SunParticle> particles = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _controller.addListener(() {
      if (_isInitialized) {
        setState(() {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;
          for (var ray in rays) {
            ray.update();
          }
          for (var particle in particles) {
            particle.move(screenHeight, screenWidth);
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
    if (!_isInitialized) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      for (int i = 0; i < 8; i++) {
        rays.add(SunRay(screenWidth: screenWidth, screenHeight: screenHeight));
      }
      for (int i = 0; i < 100; i++) {
        particles.add(SunParticle(screenWidth: screenWidth, screenHeight: screenHeight));
      }
      _isInitialized = true;
    }

    return CustomPaint(
      painter: SunnyPainter(rays, particles),
      size: Size.infinite,
    );
  }
}

class SunRay {
  double xStart;
  double angle;
  double length;
  double opacity;
  double oscillation;
  double oscillationSpeed;

  SunRay({required double screenWidth, required double screenHeight})
      : xStart = screenWidth / 2 + (Random().nextDouble() - 0.5) * screenWidth * 0.6,
        angle = (Random().nextDouble() * 1.6 - 0.8) + pi / 2,
        length = screenHeight * 1.3,
        opacity = Random().nextDouble() * 0.1 + 0.03, // Lower opacity for cloud diffusion
        oscillation = 0,
        oscillationSpeed = Random().nextDouble() * 0.01 + 0.005; // Slower for a calmer effect

  void update() {
    oscillation += oscillationSpeed;
    if (oscillation > 2 * pi) oscillation -= 2 * pi;
  }
}

class SunParticle {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  double opacity;
  double life;
  double drift; // Added for subtle lateral movement

  SunParticle({required double screenWidth, required double screenHeight})
      : x = screenWidth / 2 + (Random().nextDouble() - 0.5) * screenWidth * 0.6,
        y = 0,
        size = Random().nextDouble() * 2 + 1,
        speed = Random().nextDouble() * 1.2 + 0.3, // Slower speed for a softer effect
        angle = (Random().nextDouble() * 1.6 - 0.8) + pi / 2,
        opacity = Random().nextDouble() * 0.25 + 0.05, // Slightly lower opacity
        life = 1.0,
        drift = Random().nextDouble() * 0.2 - 0.1; // Subtle lateral drift

  void move(double screenHeight, double screenWidth) {
    x += speed * cos(angle) + drift; // Add lateral drift for cloud-like irregularity
    y += speed * sin(angle);

    life = 1 - (y / screenHeight);

    if (y > screenHeight) {
      x = screenWidth / 2 + (Random().nextDouble() - 0.5) * screenWidth * 0.6;
      y = 0;
      angle = (Random().nextDouble() * 1.6 - 0.8) + pi / 2;
      speed = Random().nextDouble() * 1.2 + 0.3;
      drift = Random().nextDouble() * 0.2 - 0.1; // Reset drift
      life = 1.0;
    }
  }
}

class SunnyPainter extends CustomPainter {
  final List<SunRay> rays;
  final List<SunParticle> particles;

  SunnyPainter(this.rays, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    // Softer gradient to mimic cloud diffusion
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.12), // Slightly reduced for cloud effect
          Colors.white.withOpacity(0.06), // Softer fade
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);

    // Diffused rays for cloud-like effect
    for (var ray in rays) {
      final path = Path();
      final startX = ray.xStart + 5 * sin(ray.oscillation);
      final endX = startX + ray.length * cos(ray.angle);
      final endY = ray.length * sin(ray.angle);

      path.moveTo(startX - 40, 0); // Wider at top for diffusion
      path.lineTo(endX - 180, endY); // Even wider at bottom
      path.lineTo(endX + 180, endY);
      path.lineTo(startX + 40, 0);
      path.close();

      final rayPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(ray.opacity),
            Colors.white.withOpacity(ray.opacity * 0.4), // Softer fade
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6); // Increased blur for diffusion

      canvas.drawPath(path, rayPaint);
    }

    // Particles with cloud-like softness
    for (var particle in particles) {
      final effectiveOpacity = particle.opacity * particle.life;
      final paint = Paint()
        ..color = Colors.white.withOpacity(effectiveOpacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3); // Slightly more blur

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}