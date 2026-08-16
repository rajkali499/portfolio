import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SpiderWebBackground extends StatefulWidget {
  final Color? webColor;
  final Offset centerRatio;

  const SpiderWebBackground({
    super.key,
    this.webColor,
    this.centerRatio = const Offset(0.72, 0.42),
  });

  @override
  State<SpiderWebBackground> createState() => _SpiderWebBackgroundState();
}

class _SpiderWebBackgroundState extends State<SpiderWebBackground>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _spiderController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _spiderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _drawController.dispose();
    _spiderController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_drawController, _spiderController, _shimmerController]),
      builder: (context, _) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _SpiderWebPainter(
            drawProgress: CurvedAnimation(
                    parent: _drawController, curve: Curves.easeOut)
                .value,
            spiderProgress: _spiderController.value,
            shimmer: _shimmerController.value,
            webColor: widget.webColor ?? AppColors.webSilver,
            centerRatio: widget.centerRatio,
          ),
        ),
      ),
    );
  }
}

class _SpiderWebPainter extends CustomPainter {
  final double drawProgress;
  final double spiderProgress;
  final double shimmer;
  final Color webColor;
  final Offset centerRatio;

  static const int numSpokes = 16;
  static const int numRings = 9;

  _SpiderWebPainter({
    required this.drawProgress,
    required this.spiderProgress,
    required this.shimmer,
    required this.webColor,
    required this.centerRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (drawProgress <= 0.01) return;

    final center =
        Offset(size.width * centerRatio.dx, size.height * centerRatio.dy);
    final maxRadius = size.width * 0.50;

    // Direction from center toward bottom-left corner (draw starts here)
    final blAngle = atan2(size.height - center.dy, 0.0 - center.dx);

    final List<double> ringRadii = List.generate(numRings, (i) {
      final t = (i + 1) / numRings;
      return maxRadius * (0.10 + 0.90 * (t * t * 0.7 + t * 0.3));
    });

    _drawBottomLeftAnchor(canvas, center, size, blAngle);
    _drawSpokes(canvas, center, maxRadius, blAngle);
    _drawRings(canvas, center, ringRadii, blAngle);
    _drawRadialConnectors(canvas, center, ringRadii);
    _drawThreeSpiders(canvas, center, ringRadii, size, blAngle);
    _drawCornerWebs(canvas, size);
    _drawAnchorLines(canvas, center, size);
  }

  // Prominent anchor line drawn from bottom-left to center (intro effect)
  void _drawBottomLeftAnchor(
      Canvas canvas, Offset center, Size size, double blAngle) {
    if (drawProgress < 0.04) return;
    final progress = ((drawProgress - 0.04) / 0.30).clamp(0.0, 1.0);

    final blCorner = Offset(size.width * 0.02, size.height * 0.96);
    final endPoint = Offset.lerp(blCorner, center, progress)!;
    final opacity = 0.20 * progress * (1 + 0.10 * shimmer);

    // Glow
    canvas.drawLine(
      blCorner,
      endPoint,
      Paint()
        ..color = webColor.withOpacity(opacity * 0.5)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // Main thread
    canvas.drawLine(
      blCorner,
      endPoint,
      Paint()
        ..color = webColor.withOpacity(opacity)
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawSpokes(
      Canvas canvas, Offset center, double maxRadius, double blAngle) {
    for (int i = 0; i < numSpokes; i++) {
      final angle = (2 * pi / numSpokes) * i - pi / 2;

      // Stagger draw start: spokes near bottom-left draw first
      var diff = (angle - blAngle) % (2 * pi);
      if (diff < 0) diff += 2 * pi;
      final spokeFrac = diff / (2 * pi); // 0 = first, 1 = last
      final threshold = 0.05 + spokeFrac * 0.40;
      if (drawProgress < threshold) continue;

      final shimmerBoost = (i % 3 == 0) ? 0.05 * shimmer : 0.0;
      final opacity = (0.20 + shimmerBoost) * drawProgress;

      final isMain = i % 2 == 0;
      final strokeW = isMain ? 1.0 : 0.65;

      final endX = center.dx + cos(angle) * maxRadius * drawProgress;
      final endY = center.dy + sin(angle) * maxRadius * drawProgress;

      if (isMain) {
        canvas.drawLine(
          center,
          Offset(endX, endY),
          Paint()
            ..color = webColor.withOpacity(opacity * 0.4)
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }

      canvas.drawLine(
        center,
        Offset(endX, endY),
        Paint()
          ..color = webColor.withOpacity(opacity)
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawRings(Canvas canvas, Offset center, List<double> ringRadii,
      double blAngle) {
    for (int r = 0; r < numRings; r++) {
      final ringThreshold = (r + 1) / (numRings + 2);
      if (drawProgress < ringThreshold) continue;

      final ringProgress =
          ((drawProgress - ringThreshold) / (1.0 - ringThreshold))
              .clamp(0.0, 1.0);

      final isOuter = r >= numRings - 2;
      final baseOpacity = isOuter ? 0.22 : 0.14;
      final opacity = (baseOpacity + 0.05 * shimmer) * ringProgress;

      final ringPaint = Paint()
        ..color = webColor.withOpacity(opacity)
        ..strokeWidth = isOuter ? 1.1 : 0.75
        ..style = PaintingStyle.stroke;

      if (isOuter) {
        final glowPath = _buildRingPath(center, ringRadii[r]);
        canvas.drawPath(
          glowPath,
          Paint()
            ..color = webColor.withOpacity(opacity * 0.5)
            ..strokeWidth = 3.5
            ..style = PaintingStyle.stroke
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }

      canvas.drawPath(_buildRingPath(center, ringRadii[r]), ringPaint);
    }
  }

  Path _buildRingPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i <= numSpokes; i++) {
      final angle = (2 * pi / numSpokes) * i - pi / 2;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  void _drawRadialConnectors(
      Canvas canvas, Offset center, List<double> ringRadii) {
    if (drawProgress < 0.7) return;
    final opacity =
        ((drawProgress - 0.7) / 0.3).clamp(0.0, 1.0) * 0.08;
    final p = Paint()
      ..color = webColor.withOpacity(opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int r = 0; r < numRings - 1; r++) {
      for (int i = 0; i < numSpokes; i++) {
        final a1 = (2 * pi / numSpokes) * i - pi / 2;
        final a2 = (2 * pi / numSpokes) * (i + 1) - pi / 2;
        final aMid = (a1 + a2) / 2;

        final inner = Offset(
          center.dx + cos(aMid) * ringRadii[r],
          center.dy + sin(aMid) * ringRadii[r],
        );
        final outer = Offset(
          center.dx + cos(aMid) * ringRadii[r + 1],
          center.dy + sin(aMid) * ringRadii[r + 1],
        );
        canvas.drawLine(inner, outer, p);
      }
    }
  }

  void _drawAnchorLines(Canvas canvas, Offset center, Size size) {
    if (drawProgress < 0.5) return;
    final opacity =
        ((drawProgress - 0.5) / 0.5).clamp(0.0, 1.0) * 0.10;
    final p = Paint()
      ..color = webColor.withOpacity(opacity)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final anchors = [
      Offset(size.width, 0),
      Offset(size.width, size.height * 0.3),
      Offset(size.width * 0.9, size.height),
    ];

    for (final a in anchors) {
      canvas.drawLine(center, a, p);
    }
  }

  // Three spiders working simultaneously on the web
  void _drawThreeSpiders(Canvas canvas, Offset center, List<double> ringRadii,
      Size size, double blAngle) {
    if (drawProgress < 0.35) return;
    final opacity = ((drawProgress - 0.35) / 0.25).clamp(0.0, 1.0);

    final outerR = ringRadii.last;
    final midR = ringRadii[numRings ~/ 2];

    // Spider A: outer ring patrol (full circuit)
    final angleA = spiderProgress * 2 * pi - pi / 2;
    final posA = Offset(
      center.dx + cos(angleA) * outerR,
      center.dy + sin(angleA) * outerR,
    );
    _drawSilkToCenter(canvas, center, posA, opacity * 0.30);
    _paintSpider(canvas, posA, angleA, opacity: opacity);

    // Spider B: mid ring patrol (offset phase)
    final angleB = ((spiderProgress + 0.38) % 1.0) * 2 * pi - pi / 2;
    final posB = Offset(
      center.dx + cos(angleB) * midR,
      center.dy + sin(angleB) * midR,
    );
    _drawSilkToCenter(canvas, center, posB, opacity * 0.25);
    _paintSpider(canvas, posB, angleB, opacity: opacity, scale: 0.78);

    // Spider C: starts at bottom-left corner, walks to web, then circles inner ring
    final blCorner = Offset(size.width * 0.03, size.height * 0.95);
    final innerR = ringRadii[2];
    final phase3 = (spiderProgress + 0.70) % 1.0;
    Offset posC;
    double angleC;

    if (phase3 < 0.35) {
      // Walking from BL corner toward center
      final t = phase3 / 0.35;
      posC = Offset.lerp(blCorner, center, Curves.easeIn.transform(t))!;
      angleC = atan2(center.dy - blCorner.dy, center.dx - blCorner.dx);
      // Draw thread from BL corner to spider
      canvas.drawLine(
        blCorner,
        posC,
        Paint()
          ..color = webColor.withOpacity(opacity * 0.22)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke,
      );
    } else {
      // Circling inner ring
      final circleT = (phase3 - 0.35) / 0.65;
      final circleAngle = circleT * 2 * pi + blAngle;
      posC = Offset(
        center.dx + cos(circleAngle) * innerR,
        center.dy + sin(circleAngle) * innerR,
      );
      angleC = circleAngle + pi / 2;
      _drawSilkToCenter(canvas, center, posC, opacity * 0.20);
    }
    _paintSpider(canvas, posC, angleC, opacity: opacity, scale: 0.65);
  }

  void _drawSilkToCenter(
      Canvas canvas, Offset center, Offset pos, double opacity) {
    canvas.drawLine(
      center,
      pos,
      Paint()
        ..color = webColor.withOpacity(opacity)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintSpider(Canvas canvas, Offset pos, double headAngle,
      {double opacity = 1.0, double scale = 1.0}) {
    const Color red = Color(0xFFE5231C);
    const Color darkRed = Color(0xFFB01010);
    const Color blue = Color(0xFF1B3A6B);
    const Color midBlue = Color(0xFF2A5298);
    const Color ink = Color(0xFF080808);

    final s = scale;

    _paintSpiderLegs(canvas, pos, headAngle, scale: s, opacity: opacity);

    // Body glow
    canvas.drawCircle(
      pos,
      9 * s,
      Paint()
        ..color = red.withOpacity(0.22 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Abdomen
    canvas.drawCircle(
        pos, 7.5 * s, Paint()..color = ink..style = PaintingStyle.fill);
    canvas.drawCircle(
        pos, 6.8 * s, Paint()..color = red..style = PaintingStyle.fill);

    _miniWebPattern(canvas, pos, 6.8 * s, 5);

    // Pedicel
    final pedicel = Offset(
      pos.dx + cos(headAngle) * 8.5 * s,
      pos.dy + sin(headAngle) * 8.5 * s,
    );
    canvas.drawCircle(
        pedicel, 2.2 * s, Paint()..color = ink..style = PaintingStyle.fill);
    canvas.drawCircle(
        pedicel, 1.8 * s, Paint()..color = darkRed..style = PaintingStyle.fill);

    // Cephalothorax
    final thorax = Offset(
      pos.dx + cos(headAngle) * 14 * s,
      pos.dy + sin(headAngle) * 14 * s,
    );
    canvas.drawCircle(
        thorax, 5.5 * s, Paint()..color = ink..style = PaintingStyle.fill);
    canvas.drawCircle(
        thorax, 4.8 * s, Paint()..color = blue..style = PaintingStyle.fill);
    canvas.drawCircle(
      thorax,
      4.8 * s,
      Paint()
        ..color = midBlue.withOpacity(0.45)
        ..style = PaintingStyle.fill,
    );

    _miniWebPattern(canvas, thorax, 4.8 * s, 4);

    // Eyes
    final eyePerp = headAngle + pi / 2;
    final eyeFwd =
        Offset(cos(headAngle) * 2.5 * s, sin(headAngle) * 2.5 * s);
    for (final side in [-1.0, 1.0]) {
      final ep = Offset(
        thorax.dx + eyeFwd.dx + cos(eyePerp) * side * 2.0 * s,
        thorax.dy + eyeFwd.dy + sin(eyePerp) * side * 2.0 * s,
      );
      canvas.drawCircle(
          ep, 1.5 * s, Paint()..color = ink..style = PaintingStyle.fill);
      canvas.drawCircle(ep, 1.2 * s,
          Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(
        Offset(ep.dx + 0.3 * s, ep.dy - 0.3 * s),
        0.45 * s,
        Paint()..color = Colors.black..style = PaintingStyle.fill,
      );
    }
  }

  void _miniWebPattern(
      Canvas canvas, Offset center, double radius, int spokes) {
    final p = Paint()
      ..color = Colors.black.withOpacity(0.28)
      ..strokeWidth = 0.55
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < spokes; i++) {
      final a = (2 * pi / spokes) * i;
      canvas.drawLine(
        Offset(center.dx + cos(a) * radius * 0.2,
            center.dy + sin(a) * radius * 0.2),
        Offset(center.dx + cos(a) * radius * 0.90,
            center.dy + sin(a) * radius * 0.90),
        p,
      );
    }
    for (final frac in [0.50, 0.78]) {
      final path = Path();
      for (int i = 0; i <= spokes; i++) {
        final a = (2 * pi / spokes) * i;
        final x = center.dx + cos(a) * radius * frac;
        final y = center.dy + sin(a) * radius * frac;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, p);
    }
  }

  void _paintSpiderLegs(Canvas canvas, Offset body, double faceAngle,
      {double scale = 1.0, double opacity = 1.0}) {
    final legPaint = Paint()
      ..color = const Color(0xFF111111).withOpacity(opacity)
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final perp = faceAngle + pi / 2;
    const spreads = [0.18, 0.40, 0.62, 0.84];
    const lengths = [18.0, 20.0, 18.0, 15.0];

    for (int i = 0; i < 4; i++) {
      for (final side in [-1.0, 1.0]) {
        final baseAngle =
            perp + side * (pi * 0.5 * spreads[i] + pi * 0.12);
        final mid = Offset(
          body.dx + cos(baseAngle) * lengths[i] * 0.46 * scale,
          body.dy + sin(baseAngle) * lengths[i] * 0.46 * scale,
        );
        final tipAngle = baseAngle + side * pi / 5;
        final tip = Offset(
          mid.dx + cos(tipAngle) * lengths[i] * 0.54 * scale,
          mid.dy + sin(tipAngle) * lengths[i] * 0.54 * scale,
        );
        canvas.drawLine(body, mid, legPaint);
        canvas.drawLine(mid, tip, legPaint);
      }
    }
  }

  void _drawCornerWebs(Canvas canvas, Size size) {
    if (drawProgress < 0.4) return;
    final opacity =
        ((drawProgress - 0.4) / 0.6).clamp(0.0, 1.0) * 0.14;
    final paint = Paint()
      ..color = webColor.withOpacity(opacity)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    // Bottom-left corner (more prominent — where spiders originate)
    _drawCornerWeb(
        canvas, Offset(0, size.height), pi / 2, -pi, 6, 220.0, paint);
    // Top-right corner
    _drawCornerWeb(
        canvas, Offset(size.width, 0), -pi / 2, 0, 5, 140.0, paint);
  }

  void _drawCornerWeb(Canvas canvas, Offset corner, double startAngle,
      double endAngle, int spokes, double size, Paint paint) {
    final sweepAngle = (endAngle - startAngle).abs();
    for (int i = 0; i < spokes; i++) {
      final a = startAngle + (sweepAngle / (spokes - 1)) * i;
      canvas.drawLine(
        corner,
        Offset(corner.dx + cos(a) * size, corner.dy + sin(a) * size),
        paint,
      );
    }
    for (int r = 1; r <= 4; r++) {
      final rPath = Path();
      for (int i = 0; i <= spokes; i++) {
        final a = startAngle +
            (sweepAngle / (spokes - 1)) * i.clamp(0, spokes - 1);
        final x = corner.dx + cos(a) * size * r / 4;
        final y = corner.dy + sin(a) * size * r / 4;
        i == 0 ? rPath.moveTo(x, y) : rPath.lineTo(x, y);
      }
      canvas.drawPath(rPath, paint);
    }
  }

  @override
  bool shouldRepaint(_SpiderWebPainter old) => true;
}
