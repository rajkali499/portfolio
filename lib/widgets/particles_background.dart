import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class _Particle {
  double x, y, vx, vy, size;
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
  });
}

class ParticlesBackground extends StatefulWidget {
  const ParticlesBackground({super.key});

  @override
  State<ParticlesBackground> createState() => _ParticlesBackgroundState();
}

class _ParticlesBackgroundState extends State<ParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final _random = Random();
  Size _lastSize = Size.zero;

  void _initParticles(Size size) {
    _particles.clear();
    for (int i = 0; i < 65; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        vx: (_random.nextDouble() - 0.5) * 0.6,
        vy: (_random.nextDouble() - 0.5) * 0.6,
        size: _random.nextDouble() * 1.5 + 0.8,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      if (_lastSize != size) {
        _lastSize = size;
        _initParticles(size);
      }
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          _updateParticles(_lastSize);
          return RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: _ParticlesPainter(
                particles: List.from(_particles),
              ),
            ),
          );
        },
      );
    });
  }

  void _updateParticles(Size size) {
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      if (p.x < 0) p.x = size.width;
      if (p.x > size.width) p.x = 0;
      if (p.y < 0) p.y = size.height;
      if (p.y > size.height) p.y = 0;
    }
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint();
    final linePaint = Paint()..strokeWidth = 0.7;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = particles[i].x - particles[j].x;
        final dy = particles[i].y - particles[j].y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < 130) {
          final opacity = 0.22 * (1 - dist / 130);
          linePaint.color = AppColors.primary.withOpacity(opacity);
          canvas.drawLine(
            Offset(particles[i].x, particles[i].y),
            Offset(particles[j].x, particles[j].y),
            linePaint,
          );
        }
      }
    }

    for (final p in particles) {
      dotPaint.color = AppColors.accent.withOpacity(0.45);
      canvas.drawCircle(Offset(p.x, p.y), p.size, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) => true;
}
