import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A small spider that walks along the very bottom of the viewport,
/// turns at screen edges, and leaps forward occasionally.
class WalkingSpider extends StatefulWidget {
  const WalkingSpider({super.key});

  @override
  State<WalkingSpider> createState() => _WalkingSpiderState();
}

class _WalkingSpiderState extends State<WalkingSpider>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  double _x = 0.08;        // body centre X as fraction of viewport width
  double _facing = 1.0;    // +1 = right, −1 = left
  double _gaitPhase = 0.0; // drives leg animation (radians)
  double _jumpY = 0.0;     // current height above ground (px, upward = positive)
  double _jumpVel = 0.0;   // vertical velocity (px/s)
  bool _jumping = false;
  double _nextJumpIn = 2.5 + Random().nextDouble() * 2.0;
  Duration _lastTick = Duration.zero;

  static const double _walkSpeed = 0.052;  // viewport-width fractions per second
  static const double _gaitFreq  = 4.5;   // leg-cycle rotations per second
  static const double _gravity   = 860.0; // px / s²
  static const double _jumpForce = 300.0; // initial upward velocity px / s

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt =
        ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastTick = elapsed;
    if (dt == 0) return;

    if (_jumping) {
      _jumpVel -= _gravity * dt;
      _jumpY  += _jumpVel * dt;
      _x      += _facing * _walkSpeed * 0.45 * dt;
      _gaitPhase += _gaitFreq * dt * 0.35;

      if (_jumpY <= 0) {
        _jumpY  = 0;
        _jumpVel = 0;
        _jumping = false;
      }
    } else {
      _x         += _facing * _walkSpeed * dt;
      _gaitPhase += _gaitFreq * dt;

      // Turn at screen edges
      if (_facing > 0 && _x > 0.93) {
        _facing = -1.0;
        _x = 0.93;
      } else if (_facing < 0 && _x < 0.07) {
        _facing = 1.0;
        _x = 0.07;
      }

      // Random hunting leap
      _nextJumpIn -= dt;
      if (_nextJumpIn <= 0) {
        _jumping   = true;
        _jumpVel   = _jumpForce;
        _nextJumpIn = 1.6 + Random().nextDouble() * 3.4;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _WalkingSpiderPainter(
          xFrac:     _x,
          facing:    _facing,
          gaitPhase: _gaitPhase,
          jumpY:     _jumpY,
          isJumping: _jumping,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _WalkingSpiderPainter extends CustomPainter {
  final double xFrac;
  final double facing;
  final double gaitPhase;
  final double jumpY;
  final bool isJumping;

  static const _red     = Color(0xFFE5231C);
  static const _darkRed = Color(0xFFB01010);
  static const _blue    = Color(0xFF1B3A6B);
  static const _midBlue = Color(0xFF2A5298);
  static const _ink     = Color(0xFF080808);

  const _WalkingSpiderPainter({
    required this.xFrac,
    required this.facing,
    required this.gaitPhase,
    required this.jumpY,
    required this.isJumping,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ground is 6 px above the very bottom edge of the full viewport canvas
    final groundY = size.height - 6.0;
    final bodyX   = xFrac * size.width;
    // Slight body-bob during walking (twice per stride cycle)
    final bodyBob = isJumping ? 0.0 : sin(gaitPhase * 2) * 1.2;
    final bodyY   = groundY - 11.0 - jumpY + bodyBob;
    final body    = Offset(bodyX, bodyY);

    // Airborne shadow
    if (jumpY > 1) {
      final fade  = (1 - jumpY / 90).clamp(0.08, 0.30);
      final scale = (1 - jumpY / 110).clamp(0.3, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(bodyX, groundY - 3),
          width:  28 * scale,
          height: 6  * scale,
        ),
        Paint()..color = Colors.black.withOpacity(fade),
      );
    }

    final faceAngle = facing > 0 ? 0.0 : pi;

    _drawLegs(canvas, body, faceAngle, groundY);
    _drawBody(canvas, body, faceAngle);
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  void _drawBody(Canvas canvas, Offset pos, double faceAngle) {
    // Glow
    canvas.drawCircle(
      pos, 14,
      Paint()
        ..color = _red.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    // Abdomen
    canvas.drawCircle(pos, 9,  Paint()..color = _ink);
    canvas.drawCircle(pos, 8,  Paint()..color = _red);
    _drawWebPattern(canvas, pos, 8, 6);

    // Stripe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: 4.5, height: 16),
        const Radius.circular(3),
      ),
      Paint()..color = _ink.withOpacity(0.40),
    );

    // Pedicel
    final pedicel = Offset(
      pos.dx + cos(faceAngle) * 10,
      pos.dy + sin(faceAngle) * 10,
    );
    canvas.drawCircle(pedicel, 2.6, Paint()..color = _ink);
    canvas.drawCircle(pedicel, 2.0, Paint()..color = _darkRed);

    // Cephalothorax
    final thorax = Offset(
      pos.dx + cos(faceAngle) * 16,
      pos.dy + sin(faceAngle) * 16,
    );
    canvas.drawCircle(thorax, 6.5, Paint()..color = _ink);
    canvas.drawCircle(thorax, 5.5, Paint()..color = _blue);
    canvas.drawCircle(
        thorax, 5.5, Paint()..color = _midBlue.withOpacity(0.5));
    _drawWebPattern(canvas, thorax, 5.5, 4);

    _drawEyes(canvas, thorax, faceAngle);

    // Chelicerae
    final chelPerp = faceAngle + pi / 2;
    final chelBase = Offset(
      thorax.dx + cos(faceAngle) * 5,
      thorax.dy + sin(faceAngle) * 5,
    );
    for (final s in [-1.0, 1.0]) {
      canvas.drawLine(
        chelBase,
        Offset(
          chelBase.dx + cos(chelPerp) * s * 1.8 + cos(faceAngle) * 2.2,
          chelBase.dy + sin(chelPerp) * s * 1.8 + sin(faceAngle) * 2.2,
        ),
        Paint()
          ..color = _ink
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawEyes(Canvas canvas, Offset thorax, double faceAngle) {
    final eyePerp = faceAngle + pi / 2;
    final ef = Offset(cos(faceAngle) * 3, sin(faceAngle) * 3);

    for (final s in [-1.0, 1.0]) {
      _drawSingleEye(
        canvas,
        Offset(thorax.dx + ef.dx + cos(eyePerp) * s * 2.0,
               thorax.dy + ef.dy + sin(eyePerp) * s * 2.0),
        1.6,
      );
    }
    for (final s in [-1.0, 1.0]) {
      _drawSingleEye(
        canvas,
        Offset(thorax.dx + cos(eyePerp) * s * 4.2 + cos(faceAngle) * 1.0,
               thorax.dy + sin(eyePerp) * s * 4.2 + sin(faceAngle) * 1.0),
        1.1,
      );
    }
  }

  void _drawSingleEye(Canvas canvas, Offset pos, double r) {
    canvas.drawCircle(pos, r + 0.4, Paint()..color = _ink);
    canvas.drawCircle(pos, r,       Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(pos.dx + r * 0.25, pos.dy - r * 0.25),
      r * 0.38,
      Paint()..color = Colors.black,
    );
  }

  void _drawWebPattern(Canvas canvas, Offset c, double r, int spokes) {
    final p = Paint()
      ..color = Colors.black.withOpacity(0.26)
      ..strokeWidth = 0.55
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < spokes; i++) {
      final a = 2 * pi / spokes * i;
      canvas.drawLine(
        Offset(c.dx + cos(a) * r * 0.22, c.dy + sin(a) * r * 0.22),
        Offset(c.dx + cos(a) * r * 0.90, c.dy + sin(a) * r * 0.90),
        p,
      );
    }
    for (final frac in [0.44, 0.72]) {
      final path = Path();
      for (int i = 0; i <= spokes; i++) {
        final a = 2 * pi / spokes * i;
        final pt = Offset(c.dx + cos(a) * r * frac, c.dy + sin(a) * r * frac);
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, p);
    }
  }

  // ── Legs ──────────────────────────────────────────────────────────────────

  void _drawLegs(
      Canvas canvas, Offset body, double faceAngle, double groundY) {
    final legPaint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final legHighlight = Paint()
      ..color = const Color(0xFF2A1010)
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Legs spread perpendicular to the walking direction
    final perp = faceAngle + pi / 2;

    // 4 pairs. Even pairs (0,2) swing together; odd pairs (1,3) are offset by π
    const spreadFrac = [0.11, 0.33, 0.58, 0.80];
    const legLen     = [19.0, 21.0, 20.0, 17.0];

    // Reduce spread slightly while airborne for a tucked look
    final jumpTuck = isJumping ? (1 - jumpY / 70).clamp(0.65, 1.0) : 1.0;

    for (int i = 0; i < 4; i++) {
      final pairPhase = (gaitPhase + (i.isEven ? 0 : pi)) % (2 * pi);
      final isSwing   = pairPhase < pi;
      // Lift foot during swing; advance foot tip forward during swing
      final lift    = isSwing ? sin(pairPhase) * 8.0 : 0.0;
      final advance = isSwing ? sin(pairPhase) * 6.0 * facing : 0.0;

      for (final side in [-1.0, 1.0]) {
        final baseAngle =
            perp + side * (pi * 0.5 * spreadFrac[i] + 0.09) ;
        final len = legLen[i] * jumpTuck;

        // Upper segment: body → knee
        final mid = Offset(
          body.dx + cos(baseAngle) * len * 0.46 + advance * 0.3,
          body.dy + sin(baseAngle) * len * 0.46,
        );

        // Lower segment: knee → foot tip
        final tipAngle = baseAngle + side * (pi / 4.2);
        var tip = Offset(
          mid.dx + cos(tipAngle) * len * 0.54 + advance * 0.7,
          mid.dy + sin(tipAngle) * len * 0.54 - lift,
        );

        // Clamp foot to ground level
        if (tip.dy > groundY) tip = Offset(tip.dx, groundY);

        canvas.drawLine(body, mid, legPaint);
        canvas.drawLine(mid, tip, legPaint);
        canvas.drawLine(body, mid, legHighlight);
      }
    }
  }

  @override
  bool shouldRepaint(_WalkingSpiderPainter old) =>
      old.xFrac     != xFrac     ||
      old.facing    != facing    ||
      old.gaitPhase != gaitPhase ||
      old.jumpY     != jumpY;
}
