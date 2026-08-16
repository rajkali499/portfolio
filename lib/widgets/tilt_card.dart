import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final Color? glowColor;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 8,
    this.glowColor,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _rotateX = 0;
  double _rotateY = 0;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final glow = widget.glowColor ?? AppColors.accent;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) {
        setState(() {
          _hovered = false;
          _rotateX = 0;
          _rotateY = 0;
        });
      },
      onHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        final size = box.size;
        if (size.isEmpty) return;
        final pos = event.localPosition;
        setState(() {
          _rotateY = ((pos.dx / size.width) - 0.5) * widget.maxTilt * 2;
          _rotateX = -((pos.dy / size.height) - 0.5) * widget.maxTilt * 2;
        });
      },
      child: AnimatedContainer(
        duration: _hovered
            ? const Duration(milliseconds: 150)
            : const Duration(milliseconds: 500),
        curve: _hovered ? Curves.easeOut : Curves.elasticOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: glow.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotateX * pi / 180)
            ..rotateY(_rotateY * pi / 180),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
