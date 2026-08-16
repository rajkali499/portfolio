import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ══════════════════════════════════════════════════════════════════════════════
// RoamingSpider — wanders the full viewport randomly, jumps occasionally
// ══════════════════════════════════════════════════════════════════════════════

class RoamingSpider extends StatefulWidget {
  final int seed;
  const RoamingSpider({super.key, required this.seed});

  @override
  State<RoamingSpider> createState() => _RoamingSpiderState();
}

class _RoamingSpiderState extends State<RoamingSpider>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final Random _rng;

  double _x = 0.0;
  double _y = 0.0;
  double _angle = 0.0;
  double _targetAngle = 0.0;
  double _gaitPhase = 0.0;
  double _jumpY = 0.0;
  double _jumpVel = 0.0;
  bool _jumping = false;
  double _nextEvent = 1.0;
  bool _initialized = false;
  Duration _lastTick = Duration.zero;

  static const double _walkSpeed = 46.0; // px/s
  static const double _gaitFreq  = 4.2;
  static const double _gravity   = 760.0;
  static const double _jumpForce = 250.0;
  static const double _turnSpeed = 3.0;  // rad/s
  static const double _margin    = 50.0;
  static const double _navH      = 68.0;

  @override
  void initState() {
    super.initState();
    _rng = Random(widget.seed);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final sz = MediaQuery.of(context).size;
      _x = sz.width  * (0.15 + _rng.nextDouble() * 0.70);
      _y = sz.height * (0.20 + _rng.nextDouble() * 0.55);
      _angle = _rng.nextDouble() * 2 * pi;
      _targetAngle = _angle;
      _nextEvent = 0.4 + _rng.nextDouble() * 1.6;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastTick = elapsed;
    if (dt == 0 || !_initialized) return;

    final sz = MediaQuery.of(context).size;

    // Smooth turn toward target direction
    double diff = _targetAngle - _angle;
    while (diff >  pi) { diff -= 2 * pi; }
    while (diff < -pi) { diff += 2 * pi; }
    _angle += diff.clamp(-_turnSpeed * dt, _turnSpeed * dt);

    if (_jumping) {
      _jumpVel -= _gravity * dt;
      _jumpY   += _jumpVel * dt;
      _x += cos(_angle) * _walkSpeed * 0.45 * dt;
      _y += sin(_angle) * _walkSpeed * 0.45 * dt;
      _gaitPhase += _gaitFreq * dt * 0.35;
      if (_jumpY <= 0) { _jumpY = 0; _jumpVel = 0; _jumping = false; }
    } else {
      _x += cos(_angle) * _walkSpeed * dt;
      _y += sin(_angle) * _walkSpeed * dt;
      _gaitPhase += _gaitFreq * dt;
    }

    // Bounce off screen edges
    bool bounced = false;
    if (_x < _margin)                  { _x = _margin;                 _targetAngle = pi - _angle; bounced = true; }
    if (_x > sz.width  - _margin)      { _x = sz.width  - _margin;     _targetAngle = pi - _angle; bounced = true; }
    if (_y < _margin + _navH)          { _y = _margin + _navH;         _targetAngle = -_angle;     bounced = true; }
    if (_y > sz.height - _margin)      { _y = sz.height - _margin;     _targetAngle = -_angle;     bounced = true; }

    // Random event: turn or jump
    _nextEvent -= dt;
    if (_nextEvent <= 0 && !bounced) {
      if (_rng.nextDouble() < 0.60) {
        _targetAngle = _rng.nextDouble() * 2 * pi;
      } else if (!_jumping) {
        _jumping = true;
        _jumpVel = _jumpForce;
      }
      _nextEvent = 0.9 + _rng.nextDouble() * 2.6;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _FreeSpiderPainter(
          x: _x, y: _y,
          faceAngle: _angle,
          gaitPhase: _gaitPhase,
          jumpY: _jumpY,
          isJumping: _jumping,
          isCursor: false,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CursorSpider — hunts the mouse pointer across the viewport
// ══════════════════════════════════════════════════════════════════════════════

class CursorSpider extends StatefulWidget {
  /// Cursor position in local screen-space pixels.
  /// Offset.zero means "not yet seen" — spider idles until first hover.
  final ValueNotifier<Offset> cursor;

  const CursorSpider({super.key, required this.cursor});

  @override
  State<CursorSpider> createState() => _CursorSpiderState();
}

class _CursorSpiderState extends State<CursorSpider>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  double _x = 0.0;
  double _y = 0.0;
  double _angle = 0.0;
  double _gaitPhase = 0.0;
  double _jumpY = 0.0;
  double _jumpVel = 0.0;
  bool _jumping = false;
  double _nextLunge = 3.0;
  bool _initialized = false;
  Duration _lastTick = Duration.zero;

  static const double _walkSpeed  = 90.0;
  static const double _gaitFreq   = 5.5;
  static const double _gravity    = 920.0;
  static const double _jumpForce  = 380.0;
  static const double _stopRadius = 22.0;
  static const double _turnSpeed  = 11.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final sz = MediaQuery.of(context).size;
      _x = sz.width  * 0.5;
      _y = sz.height * 0.75;
      _angle = -pi / 2;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastTick = elapsed;
    if (dt == 0 || !_initialized) return;

    final cursor = widget.cursor.value;

    // Cursor not yet tracked → idle leg twitch
    if (cursor == Offset.zero) {
      _gaitPhase += _gaitFreq * 0.10 * dt;
      setState(() {});
      return;
    }

    final dx = cursor.dx - _x;
    final dy = cursor.dy - _y;
    final dist = sqrt(dx * dx + dy * dy);

    // Snap-turn toward cursor
    if (dist > 5) {
      final ta = atan2(dy, dx);
      double diff = ta - _angle;
      while (diff >  pi) diff -= 2 * pi;
      while (diff < -pi) diff += 2 * pi;
      _angle += diff.clamp(-_turnSpeed * dt, _turnSpeed * dt);
    }

    final moving = dist > _stopRadius;

    if (_jumping) {
      _jumpVel -= _gravity * dt;
      _jumpY   += _jumpVel * dt;
      _x += cos(_angle) * _walkSpeed * 0.55 * dt;
      _y += sin(_angle) * _walkSpeed * 0.55 * dt;
      _gaitPhase += _gaitFreq * dt * 0.35;
      if (_jumpY <= 0) { _jumpY = 0; _jumpVel = 0; _jumping = false; }
    } else if (moving) {
      final step = (_walkSpeed * dt).clamp(0.0, dist - _stopRadius);
      _x += cos(_angle) * step;
      _y += sin(_angle) * step;
      _gaitPhase += _gaitFreq * dt;

      // Hunting lunge when close enough
      _nextLunge -= dt;
      if (_nextLunge <= 0 && dist < 200) {
        _jumping   = true;
        _jumpVel   = _jumpForce;
        _nextLunge = 2.0 + Random().nextDouble() * 3.0;
      }
    } else {
      // Caught up to cursor — slow idle twitch
      _gaitPhase += _gaitFreq * 0.12 * dt;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _FreeSpiderPainter(
          x: _x, y: _y,
          faceAngle: _angle,
          gaitPhase: _gaitPhase,
          jumpY: _jumpY,
          isJumping: _jumping,
          isCursor: true,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared painter — draws a spider at any position and facing angle
// ══════════════════════════════════════════════════════════════════════════════

class _FreeSpiderPainter extends CustomPainter {
  final double x, y;
  final double faceAngle;
  final double gaitPhase;
  final double jumpY;
  final bool   isJumping;
  final bool   isCursor; // golden eyes for the cursor hunter

  static const _red     = Color(0xFFE5231C);
  static const _darkRed = Color(0xFFB01010);
  static const _blue    = Color(0xFF1B3A6B);
  static const _midBlue = Color(0xFF2A5298);
  static const _ink     = Color(0xFF080808);

  const _FreeSpiderPainter({
    required this.x,
    required this.y,
    required this.faceAngle,
    required this.gaitPhase,
    required this.jumpY,
    required this.isJumping,
    required this.isCursor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final body = Offset(x, y);

    // Airborne shadow — offset slightly to imply a light source
    if (jumpY > 2) {
      final fade  = (1 - jumpY / 90).clamp(0.08, 0.35);
      final scale = (1 - jumpY / 110).clamp(0.25, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + jumpY * 0.14, y + jumpY * 0.09),
          width:  28 * scale,
          height: 10 * scale,
        ),
        Paint()..color = Colors.black.withOpacity(fade),
      );
    }

    // Scale body up during jump (simulate height in top-down view)
    final riseScale = isJumping
        ? (1.0 + (jumpY / 80.0).clamp(0.0, 0.20))
        : 1.0;

    if (riseScale != 1.0) {
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(riseScale);
      canvas.translate(-x, -y);
    }

    _drawLegs(canvas, body, faceAngle);
    _drawBody(canvas, body, faceAngle);

    if (riseScale != 1.0) canvas.restore();
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  void _drawBody(Canvas canvas, Offset pos, double fa) {
    // Glow — golden for cursor spider, red for roamer
    canvas.drawCircle(
      pos, 14,
      Paint()
        ..color = (isCursor ? const Color(0xFFFFAA00) : _red).withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    // Abdomen
    canvas.drawCircle(pos, 9, Paint()..color = _ink);
    canvas.drawCircle(pos, 8, Paint()..color = _red);
    _drawWebPattern(canvas, pos, 8, 6);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: 4.5, height: 16),
        const Radius.circular(3),
      ),
      Paint()..color = _ink.withOpacity(0.40),
    );

    // Pedicel
    final pedicel = Offset(pos.dx + cos(fa) * 10, pos.dy + sin(fa) * 10);
    canvas.drawCircle(pedicel, 2.6, Paint()..color = _ink);
    canvas.drawCircle(pedicel, 2.0, Paint()..color = _darkRed);

    // Cephalothorax
    final thorax = Offset(pos.dx + cos(fa) * 16, pos.dy + sin(fa) * 16);
    canvas.drawCircle(thorax, 6.5, Paint()..color = _ink);
    canvas.drawCircle(thorax, 5.5, Paint()..color = _blue);
    canvas.drawCircle(thorax, 5.5, Paint()..color = _midBlue.withOpacity(0.5));
    _drawWebPattern(canvas, thorax, 5.5, 4);

    _drawEyes(canvas, thorax, fa);

    // Chelicerae
    final chelPerp = fa + pi / 2;
    final chelBase = Offset(thorax.dx + cos(fa) * 5, thorax.dy + sin(fa) * 5);
    for (final s in [-1.0, 1.0]) {
      canvas.drawLine(
        chelBase,
        Offset(chelBase.dx + cos(chelPerp) * s * 1.8 + cos(fa) * 2.2,
               chelBase.dy + sin(chelPerp) * s * 1.8 + sin(fa) * 2.2),
        Paint()
          ..color = _ink
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawEyes(Canvas canvas, Offset thorax, double fa) {
    final ep = fa + pi / 2;
    final ef = Offset(cos(fa) * 3, sin(fa) * 3);
    for (final s in [-1.0, 1.0]) {
      _drawSingleEye(
        canvas,
        Offset(thorax.dx + ef.dx + cos(ep) * s * 2.0,
               thorax.dy + ef.dy + sin(ep) * s * 2.0),
        1.6,
      );
    }
    for (final s in [-1.0, 1.0]) {
      _drawSingleEye(
        canvas,
        Offset(thorax.dx + cos(ep) * s * 4.2 + cos(fa) * 1.0,
               thorax.dy + sin(ep) * s * 4.2 + sin(fa) * 1.0),
        1.1,
      );
    }
  }

  void _drawSingleEye(Canvas canvas, Offset pos, double r) {
    canvas.drawCircle(pos, r + 0.4, Paint()..color = _ink);
    // Cursor spider has golden eyes — easy to spot
    canvas.drawCircle(
        pos, r,
        Paint()..color = isCursor ? const Color(0xFFFFE566) : Colors.white);
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

  void _drawLegs(Canvas canvas, Offset body, double fa) {
    final legPaint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final legHL = Paint()
      ..color = const Color(0xFF2A1010)
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final perp = fa + pi / 2;
    const spreadFrac = [0.11, 0.33, 0.58, 0.80];
    const legLen     = [19.0, 21.0, 20.0, 17.0];

    // Tuck legs during airborne phase
    final tuck = isJumping ? (1 - jumpY / 70).clamp(0.65, 1.0) : 1.0;

    for (int i = 0; i < 4; i++) {
      // Even pairs (0,2) are Group A; odd pairs (1,3) are Group B (offset π)
      final phase   = (gaitPhase + (i.isEven ? 0 : pi)) % (2 * pi);
      final isSwing = phase < pi;
      // Retract during swing to simulate lift in top-down view
      final retract = isSwing ? sin(phase) * 0.18 : 0.0;
      // Foot tip advances forward during swing
      final advance = isSwing ? sin(phase) * 5.0 : 0.0;

      for (final side in [-1.0, 1.0]) {
        final baseAngle = perp + side * (pi * 0.5 * spreadFrac[i] + 0.09);
        final len = legLen[i] * tuck * (1 - retract);

        final mid = Offset(
          body.dx + cos(baseAngle) * len * 0.46 + cos(fa) * advance * 0.3,
          body.dy + sin(baseAngle) * len * 0.46 + sin(fa) * advance * 0.3,
        );

        final tipAngle = baseAngle + side * (pi / 4.2);
        final tip = Offset(
          mid.dx + cos(tipAngle) * len * 0.54 + cos(fa) * advance * 0.7,
          mid.dy + sin(tipAngle) * len * 0.54 + sin(fa) * advance * 0.7,
        );

        canvas.drawLine(body, mid, legPaint);
        canvas.drawLine(mid, tip, legPaint);
        canvas.drawLine(body, mid, legHL);
      }
    }
  }

  @override
  bool shouldRepaint(_FreeSpiderPainter old) =>
      old.x         != x         ||
      old.y         != y         ||
      old.faceAngle != faceAngle ||
      old.gaitPhase != gaitPhase ||
      old.jumpY     != jumpY;
}
