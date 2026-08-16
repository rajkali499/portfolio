import 'dart:math';
import 'package:flutter/material.dart';

// Per-spider configuration — drives anchor position, swing character, and depth
class _SpiderSpec {
  final double anchorFrac;  // anchor X as fraction of screen width
  final double amplitude;   // max swing angle in radians
  final double phase;       // phase offset so spiders swing out-of-sync
  final double speedMult;   // relative oscillation speed
  final double threadMinH;  // min thread length as fraction of screen height
  final double threadMaxH;  // max thread length as fraction of screen height

  const _SpiderSpec({
    required this.anchorFrac,
    required this.amplitude,
    required this.phase,
    required this.speedMult,
    required this.threadMinH,
    required this.threadMaxH,
  });
}

// Two corner spiders: one swings from the right, one from the left
const _spiderSpecs = [
  // Right spider — drops deep, moderate swing
  _SpiderSpec(
    anchorFrac: 0.94,
    amplitude: 0.30,
    phase: 0.0,
    speedMult: 1.0,
    threadMinH: 0.08,
    threadMaxH: 0.65,
  ),
  // Left spider — shallower, slightly faster, ~190° out-of-phase
  _SpiderSpec(
    anchorFrac: 0.06,
    amplitude: 0.26,
    phase: 3.3,
    speedMult: 1.12,
    threadMinH: 0.06,
    threadMaxH: 0.50,
  ),
];

class SwingingSpider extends StatefulWidget {
  final double scrollOffset;
  final double maxScrollExtent;

  const SwingingSpider({
    super.key,
    required this.scrollOffset,
    required this.maxScrollExtent,
  });

  @override
  State<SwingingSpider> createState() => _SwingingSpiderState();
}

class _SwingingSpiderState extends State<SwingingSpider>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // Use a full-cycle repeat (no reverse) so each spider gets a true
    // ±amplitude pendulum via sin(t·2π·speed + phase).
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final scrollFraction = widget.maxScrollExtent > 0
        ? (widget.scrollOffset / widget.maxScrollExtent).clamp(0.0, 1.0)
        : 0.0;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => CustomPaint(
          painter: _MultiSpiderPainter(
            t: _ctrl.value,
            scrollFraction: scrollFraction,
            screenH: screenH,
          ),
        ),
      ),
    );
  }
}

class _MultiSpiderPainter extends CustomPainter {
  final double t;
  final double scrollFraction;
  final double screenH;

  static const Color _red = Color(0xFFE5231C);
  static const Color _darkRed = Color(0xFFB01010);
  static const Color _blue = Color(0xFF1B3A6B);
  static const Color _midBlue = Color(0xFF2A5298);
  static const Color _ink = Color(0xFF080808);
  static const Color _silk = Color(0xFFD0DDE8);

  _MultiSpiderPainter({
    required this.t,
    required this.scrollFraction,
    required this.screenH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final spec in _spiderSpecs) {
      final anchorX = size.width * spec.anchorFrac;
      const anchorY = 0.0;

      // Thread length grows as the user scrolls down
      final minLen = spec.threadMinH * screenH;
      final maxLen = spec.threadMaxH * screenH;
      final threadLen = minLen + scrollFraction * (maxLen - minLen);

      // True pendulum: swings both left and right
      final swingAngle =
          sin(t * 2 * pi * spec.speedMult + spec.phase) * spec.amplitude;

      final spiderX = anchorX + sin(swingAngle) * threadLen;
      final spiderY = anchorY + cos(swingAngle) * threadLen;

      _drawSilkThread(
          canvas, Offset(anchorX, anchorY), Offset(spiderX, spiderY));
      _paintSpider(canvas, Offset(spiderX, spiderY), swingAngle + pi);
    }
  }

  void _drawSilkThread(Canvas canvas, Offset from, Offset to) {
    // Outer glow
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = _silk.withOpacity(0.07)
        ..strokeWidth = 8.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // Main silk strand
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = _silk.withOpacity(0.60)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );
    // Subtle secondary strand
    canvas.drawLine(
      Offset(from.dx + 1.2, from.dy),
      Offset(to.dx + 1.2, to.dy),
      Paint()
        ..color = _silk.withOpacity(0.22)
        ..strokeWidth = 0.6
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintSpider(Canvas canvas, Offset pos, double faceAngle) {
    _drawLegs(canvas, pos, faceAngle);

    // Body glow
    canvas.drawCircle(
      pos,
      20,
      Paint()
        ..color = _red.withOpacity(0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Abdomen
    canvas.drawCircle(
        pos, 12, Paint()..color = _ink..style = PaintingStyle.fill);
    canvas.drawCircle(
        pos, 11, Paint()..color = _red..style = PaintingStyle.fill);
    _drawBodyWebPattern(canvas, pos, 11, 6);

    final stripeRect = Rect.fromCenter(center: pos, width: 7, height: 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(stripeRect, const Radius.circular(4)),
      Paint()
        ..color = _ink.withOpacity(0.45)
        ..style = PaintingStyle.fill,
    );

    // Pedicel
    final pedicel = Offset(
      pos.dx + cos(faceAngle) * 13.5,
      pos.dy + sin(faceAngle) * 13.5,
    );
    canvas.drawCircle(
        pedicel, 3.5, Paint()..color = _ink..style = PaintingStyle.fill);
    canvas.drawCircle(
        pedicel, 2.8, Paint()..color = _darkRed..style = PaintingStyle.fill);

    // Cephalothorax
    final thoraxPos = Offset(
      pos.dx + cos(faceAngle) * 22,
      pos.dy + sin(faceAngle) * 22,
    );
    canvas.drawCircle(
        thoraxPos, 9, Paint()..color = _ink..style = PaintingStyle.fill);
    canvas.drawCircle(
        thoraxPos, 8, Paint()..color = _blue..style = PaintingStyle.fill);
    canvas.drawCircle(
      thoraxPos,
      8,
      Paint()
        ..color = _midBlue.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );
    _drawBodyWebPattern(canvas, thoraxPos, 8, 4);

    _drawEyes(canvas, thoraxPos, faceAngle);

    // Chelicerae
    final chelPerp = faceAngle + pi / 2;
    final chelBase = Offset(
      thoraxPos.dx + cos(faceAngle) * 7,
      thoraxPos.dy + sin(faceAngle) * 7,
    );
    for (final s in [-1.0, 1.0]) {
      final tip = Offset(
        chelBase.dx + cos(chelPerp) * s * 2.5 + cos(faceAngle) * 3,
        chelBase.dy + sin(chelPerp) * s * 2.5 + sin(faceAngle) * 3,
      );
      canvas.drawLine(
        chelBase,
        tip,
        Paint()
          ..color = _ink
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawEyes(Canvas canvas, Offset thoraxPos, double faceAngle) {
    final eyePerp = faceAngle + pi / 2;
    final eyeForward = Offset(cos(faceAngle) * 4, sin(faceAngle) * 4);

    for (final s in [-1.0, 1.0]) {
      final ep = Offset(
        thoraxPos.dx + eyeForward.dx + cos(eyePerp) * s * 2.8,
        thoraxPos.dy + eyeForward.dy + sin(eyePerp) * s * 2.8,
      );
      _drawSingleEye(canvas, ep, 2.2);
    }
    for (final s in [-1.0, 1.0]) {
      final ep = Offset(
        thoraxPos.dx + cos(eyePerp) * s * 5.8 + cos(faceAngle) * 1.5,
        thoraxPos.dy + sin(eyePerp) * s * 5.8 + sin(faceAngle) * 1.5,
      );
      _drawSingleEye(canvas, ep, 1.5);
    }
  }

  void _drawSingleEye(Canvas canvas, Offset pos, double r) {
    canvas.drawCircle(
        pos, r + 0.5, Paint()..color = _ink..style = PaintingStyle.fill);
    canvas.drawCircle(
        pos, r, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(
      Offset(pos.dx + r * 0.25, pos.dy - r * 0.25),
      r * 0.38,
      Paint()..color = Colors.black..style = PaintingStyle.fill,
    );
  }

  void _drawBodyWebPattern(
      Canvas canvas, Offset center, double radius, int spokes) {
    final p = Paint()
      ..color = Colors.black.withOpacity(0.30)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < spokes; i++) {
      final a = (2 * pi / spokes) * i;
      canvas.drawLine(
        Offset(center.dx + cos(a) * radius * 0.22,
            center.dy + sin(a) * radius * 0.22),
        Offset(center.dx + cos(a) * radius * 0.92,
            center.dy + sin(a) * radius * 0.92),
        p,
      );
    }
    for (final frac in [0.45, 0.72]) {
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

  void _drawLegs(Canvas canvas, Offset bodyCenter, double faceAngle) {
    final legPaint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final legHighlight = Paint()
      ..color = const Color(0xFF2A1010)
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final perp = faceAngle + pi / 2;
    const legAngles = [0.15, 0.38, 0.62, 0.85];
    const legLengths = [26.0, 28.0, 25.0, 22.0];

    for (int i = 0; i < 4; i++) {
      for (final side in [-1.0, 1.0]) {
        final baseAngle =
            perp + side * (pi * 0.5 * legAngles[i] + pi * 0.1);
        final mid = Offset(
          bodyCenter.dx + cos(baseAngle) * legLengths[i] * 0.48,
          bodyCenter.dy + sin(baseAngle) * legLengths[i] * 0.48,
        );
        final tipAngle = baseAngle + side * pi / 4.5;
        final tip = Offset(
          mid.dx + cos(tipAngle) * legLengths[i] * 0.52,
          mid.dy + sin(tipAngle) * legLengths[i] * 0.52,
        );
        canvas.drawLine(bodyCenter, mid, legPaint);
        canvas.drawLine(mid, tip, legPaint);
        canvas.drawLine(bodyCenter, mid, legHighlight);
      }
    }
  }

  @override
  bool shouldRepaint(_MultiSpiderPainter old) =>
      old.t != t ||
      old.scrollFraction != scrollFraction ||
      old.screenH != screenH;
}
