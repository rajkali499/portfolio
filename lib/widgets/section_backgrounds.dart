import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ─── About Section: falling red web threads ──────────────────────────────────

class WebThreadBackground extends StatefulWidget {
  const WebThreadBackground({super.key});

  @override
  State<WebThreadBackground> createState() => _WebThreadBackgroundState();
}

class _WebThreadBackgroundState extends State<WebThreadBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_Thread> _threads = [];
  final _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat()
      ..addListener(_tick);
  }

  void _tick() {
    for (final t in _threads) {
      t.y += t.speed;
      if (t.y > 1.2) {
        t.y = -0.2;
        t.x = _rng.nextDouble();
      }
    }
    setState(() {});
  }

  void _initThreads(Size size) {
    _threads.clear();
    for (int i = 0; i < 28; i++) {
      _threads.add(_Thread(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        len: 0.06 + _rng.nextDouble() * 0.1,
        speed: 0.0008 + _rng.nextDouble() * 0.0012,
        opacity: 0.08 + _rng.nextDouble() * 0.12,
      ));
    }
  }

  Size _lastSize = Size.zero;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final size = Size(c.maxWidth, c.maxHeight);
      if (_lastSize != size) {
        _lastSize = size;
        _initThreads(size);
      }
      return RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: _ThreadPainter(threads: List.from(_threads)),
        ),
      );
    });
  }
}

class _Thread {
  double x, y, len, speed, opacity;
  _Thread(
      {required this.x,
      required this.y,
      required this.len,
      required this.speed,
      required this.opacity});
}

class _ThreadPainter extends CustomPainter {
  final List<_Thread> threads;
  _ThreadPainter({required this.threads});

  @override
  void paint(Canvas canvas, Size size) {
    for (final t in threads) {
      final paint = Paint()
        ..color = AppColors.webSilver.withOpacity(t.opacity)
        ..strokeWidth = 0.8;
      canvas.drawLine(
        Offset(t.x * size.width, t.y * size.height),
        Offset(t.x * size.width, (t.y + t.len) * size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ThreadPainter old) => true;
}

// ─── Skills Section: hexagonal web grid ──────────────────────────────────────

class HexWebBackground extends StatefulWidget {
  const HexWebBackground({super.key});

  @override
  State<HexWebBackground> createState() => _HexWebBackgroundState();
}

class _HexWebBackgroundState extends State<HexWebBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _HexPainter(t: _ctrl.value),
        ),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  final double t;
  _HexPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    const hexR = 46.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final cols = (size.width / (hexR * 1.73)).ceil() + 2;
    final rows = (size.height / (hexR * 1.5)).ceil() + 2;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        final offsetX = row.isOdd ? hexR * 0.87 : 0.0;
        final cx = col * hexR * 1.73 + offsetX;
        final cy = row * hexR * 1.5;

        final dist = Offset(cx - size.width / 2, cy - size.height / 2).distance;
        final maxDist = size.width * 0.72;
        final fade = (1 - (dist / maxDist)).clamp(0.0, 1.0);
        final pulse = 0.08 + 0.06 * sin(t * pi * 2 + dist * 0.012);

        paint.color = AppColors.webSilver.withOpacity(fade * pulse);
        _drawHex(canvas, Offset(cx, cy), hexR, paint);
      }
    }
  }

  void _drawHex(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = pi / 6 + i * pi / 3;
      final pt = Offset(center.dx + cos(angle) * r, center.dy + sin(angle) * r);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HexPainter old) => old.t != t;
}

// ─── Projects Section: comic-book halftone dots (animated pulse) ─────────────

class ComicDotBackground extends StatefulWidget {
  const ComicDotBackground({super.key});

  @override
  State<ComicDotBackground> createState() => _ComicDotBackgroundState();
}

class _ComicDotBackgroundState extends State<ComicDotBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _HalftonePainter(t: _ctrl.value),
        ),
      ),
    );
  }
}

class _HalftonePainter extends CustomPainter {
  final double t;
  _HalftonePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 28.0;
    final paint = Paint()..style = PaintingStyle.fill;

    int col = 0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      int row = 0;
      final xOff = col.isOdd ? spacing / 2 : 0;
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final dist = Offset(x + xOff - size.width / 2, y - size.height / 2).distance;
        final maxD = size.width * 0.7;
        final fade = (1 - (dist / maxD)).clamp(0.0, 1.0);
        if (fade < 0.01) {
          row++;
          continue;
        }
        final pulse = 0.18 + 0.08 * sin(t * pi + dist * 0.008);
        final useRed = (col + row).isEven;
        paint.color = (useRed ? AppColors.primary : AppColors.spiderBlue)
            .withOpacity(fade * pulse);
        canvas.drawCircle(Offset(x + xOff, y), spacing * fade * 0.32, paint);
        row++;
      }
      col++;
    }
  }

  @override
  bool shouldRepaint(_HalftonePainter old) => old.t != t;
}

// ─── Experience Section: blueprint web pattern ───────────────────────────────

class BlueprintWebBackground extends StatefulWidget {
  const BlueprintWebBackground({super.key});

  @override
  State<BlueprintWebBackground> createState() => _BlueprintWebBackgroundState();
}

class _BlueprintWebBackgroundState extends State<BlueprintWebBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _BlueprintPainter(t: _ctrl.value),
        ),
      ),
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  final double t;
  _BlueprintPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Rotating concentric web
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const numSpokes = 8;
    const numRings = 5;
    final maxR = size.width * 0.45;
    final rotation = t * 2 * pi * 0.1;

    for (int i = 0; i < numSpokes; i++) {
      final angle = (2 * pi / numSpokes) * i + rotation;
      paint.color = AppColors.accent.withOpacity(0.20);
      canvas.drawLine(center,
          Offset(center.dx + cos(angle) * maxR, center.dy + sin(angle) * maxR), paint);
    }

    for (int r = 1; r <= numRings; r++) {
      final radius = maxR * r / numRings;
      final pulse = 0.16 + 0.08 * sin(t * pi * 2 - r * 0.5);
      paint.color = AppColors.accent.withOpacity(pulse);
      final path = Path();
      for (int i = 0; i <= numSpokes; i++) {
        final angle = (2 * pi / numSpokes) * i + rotation;
        final pt = Offset(center.dx + cos(angle) * radius,
            center.dy + sin(angle) * radius);
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BlueprintPainter old) => old.t != t;
}

// ─── Contact Section: corner web decorations ─────────────────────────────────

class CornerWebBackground extends StatefulWidget {
  const CornerWebBackground({super.key});

  @override
  State<CornerWebBackground> createState() => _CornerWebBackgroundState();
}

class _CornerWebBackgroundState extends State<CornerWebBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _CornerWebBgPainter(t: _ctrl.value),
        ),
      ),
    );
  }
}

class _CornerWebBgPainter extends CustomPainter {
  final double t;
  _CornerWebBgPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    _drawCorner(canvas, const Offset(0, 0), 0, size);
    _drawCorner(canvas, Offset(size.width, 0), pi / 2, size);
    _drawCorner(canvas, Offset(0, size.height), -pi / 2, size);
    _drawCorner(canvas, Offset(size.width, size.height), pi, size);
  }

  void _drawCorner(Canvas canvas, Offset origin, double rotation, Size size) {
    const spokes = 6;
    final webSize = size.width * 0.22;
    final opacity = 0.13 + 0.05 * sin(t * pi);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.webSilver.withOpacity(opacity);

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(rotation);

    for (int i = 0; i < spokes; i++) {
      final angle = (pi / 2 / (spokes - 1)) * i;
      canvas.drawLine(
          Offset.zero,
          Offset(cos(angle) * webSize, sin(angle) * webSize),
          paint);
    }

    for (int r = 1; r <= 4; r++) {
      final rPath = Path();
      for (int i = 0; i < spokes; i++) {
        final angle = (pi / 2 / (spokes - 1)) * i;
        final pt = Offset(cos(angle) * webSize * r / 4, sin(angle) * webSize * r / 4);
        i == 0 ? rPath.moveTo(pt.dx, pt.dy) : rPath.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(rPath, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CornerWebBgPainter old) => old.t != t;
}
