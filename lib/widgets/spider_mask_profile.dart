import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SpiderMaskProfile extends StatefulWidget {
  final double size;

  const SpiderMaskProfile({super.key, this.size = 300});

  @override
  State<SpiderMaskProfile> createState() => _SpiderMaskProfileState();
}

class _SpiderMaskProfileState extends State<SpiderMaskProfile>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _glowController;
  late AnimationController _webController;

  @override
  void initState() {
    super.initState();

    _webController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) _revealController.forward();
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _glowController.dispose();
    _webController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AspectRatio guarantees a square bounding box regardless of parent constraints,
    // so ClipOval always produces a perfect circle.
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth;
          return AnimatedBuilder(
            animation: Listenable.merge(
                [_revealController, _glowController, _webController]),
            builder: (context, _) {
              final reveal = CurvedAnimation(
                parent: _revealController,
                curve: Curves.easeInOut,
              ).value;
              final glow = _glowController.value;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Outer glow ring — lives outside ClipOval so shadow can bleed
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withOpacity(0.3 + 0.15 * glow),
                            blurRadius: 40 + 20 * glow,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: AppColors.spiderBlue.withOpacity(0.15),
                            blurRadius: 60,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Photo + mask inside a single ClipOval → always a perfect circle
                  Positioned.fill(
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Profile photo
                          Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.cover,
                          ),
                          // Spider-Man mask slides up as reveal goes 0→1
                          OverflowBox(
                            maxHeight: s * 2,
                            child: Transform.translate(
                              offset: Offset(0, -s * reveal),
                              child: SizedBox(
                                width: s,
                                height: s,
                                child: CustomPaint(
                                  painter: _SpiderMaskPainter(
                                    webProgress: _webController.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Glowing border ring — on top of everything
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              AppColors.primary.withOpacity(0.5 + 0.3 * glow),
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),

                  // Web corner decoration fades out as mask reveals
                  if (reveal < 0.5)
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Opacity(
                        opacity: (1 - reveal * 2).clamp(0.0, 1.0),
                        child: CustomPaint(
                          size: const Size(60, 60),
                          painter: _CornerWebPainter(),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SpiderMaskPainter extends CustomPainter {
  final double webProgress;

  _SpiderMaskPainter({required this.webProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Red base — full circle fill
    final redPaint = Paint()..color = AppColors.primary;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), redPaint);

    // Blue sections for Spider-Man suit
    final bluePaint = Paint()..color = AppColors.spiderBlue;
    final headPath = Path()
      ..moveTo(w * 0.0, h * 0.0)
      ..lineTo(w * 1.0, h * 0.0)
      ..lineTo(w * 1.0, h * 0.1)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.0, h * 0.1)
      ..close();
    canvas.drawPath(headPath, bluePaint);

    final chinPath = Path()
      ..moveTo(w * 0.15, h * 0.88)
      ..quadraticBezierTo(w * 0.5, h * 1.02, w * 0.85, h * 0.88)
      ..lineTo(w * 1.0, h * 1.0)
      ..lineTo(w * 0.0, h * 1.0)
      ..close();
    canvas.drawPath(chinPath, bluePaint);

    _drawWebLines(canvas, size);

    _drawEye(canvas, Offset(w * 0.31, h * 0.40), w * 0.21, h * 0.115);
    _drawEye(canvas, Offset(w * 0.69, h * 0.40), w * 0.21, h * 0.115);
  }

  void _drawWebLines(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final webCenter = Offset(w * 0.5, h * -0.05);

    final webPaint = Paint()
      ..color = Colors.black.withOpacity(0.45 * webProgress)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    const numSpokes = 18;
    const numRings = 8;

    for (int i = 0; i < numSpokes; i++) {
      final angle = (pi / (numSpokes - 1)) * i;
      canvas.drawLine(
        webCenter,
        Offset(
          webCenter.dx + cos(angle) * h * 1.4,
          webCenter.dy + sin(angle) * h * 1.4,
        ),
        webPaint,
      );
    }

    for (int r = 1; r <= numRings; r++) {
      if (webProgress < r / numRings) continue;
      final radius = r * h * 0.17;
      canvas.drawArc(
        Rect.fromCenter(
            center: webCenter, width: radius * 2, height: radius * 2),
        0,
        pi,
        false,
        webPaint,
      );
    }
  }

  void _drawEye(Canvas canvas, Offset center, double eyeW, double eyeH) {
    final eyePath = Path();
    eyePath.moveTo(center.dx - eyeW / 2, center.dy);
    eyePath.cubicTo(
      center.dx - eyeW * 0.1, center.dy - eyeH * 1.8,
      center.dx + eyeW * 0.1, center.dy - eyeH * 1.8,
      center.dx + eyeW / 2, center.dy,
    );
    eyePath.cubicTo(
      center.dx + eyeW * 0.2, center.dy + eyeH * 0.6,
      center.dx - eyeW * 0.2, center.dy + eyeH * 0.6,
      center.dx - eyeW / 2, center.dy,
    );
    eyePath.close();

    canvas.drawPath(eyePath, Paint()..color = Colors.white);
    canvas.drawPath(
      eyePath,
      Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    final shimmerPath = Path();
    shimmerPath.moveTo(center.dx - eyeW * 0.3, center.dy - eyeH * 0.3);
    shimmerPath.quadraticBezierTo(
      center.dx, center.dy - eyeH * 1.2,
      center.dx + eyeW * 0.1, center.dy - eyeH * 0.5,
    );
    shimmerPath.close();
    canvas.drawPath(
      shimmerPath,
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_SpiderMaskPainter old) =>
      old.webProgress != webProgress;
}

class _CornerWebPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.webSilver.withOpacity(0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const origin = Offset(60, 0);
    const spokes = 5;

    for (int i = 0; i < spokes; i++) {
      final angle = pi + (pi / 2 / (spokes - 1)) * i;
      canvas.drawLine(
        origin,
        Offset(origin.dx + cos(angle) * 55, origin.dy + sin(angle) * 55),
        paint,
      );
    }

    for (int r = 1; r <= 3; r++) {
      final rPath = Path();
      for (int i = 0; i < spokes; i++) {
        final angle = pi + (pi / 2 / (spokes - 1)) * i;
        final pt = Offset(
          origin.dx + cos(angle) * 18.0 * r,
          origin.dy + sin(angle) * 18.0 * r,
        );
        i == 0 ? rPath.moveTo(pt.dx, pt.dy) : rPath.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(rPath, paint);
    }
  }

  @override
  bool shouldRepaint(_CornerWebPainter old) => false;
}
