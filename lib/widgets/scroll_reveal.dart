import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double slideY;
  final double slideX;
  final String uniqueKey;

  const ScrollReveal({
    super.key,
    required this.child,
    required this.uniqueKey,
    this.delay = Duration.zero,
    this.slideY = 0.15,
    this.slideX = 0.0,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.uniqueKey),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.1) {
          setState(() => _visible = true);
        }
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 700),
        opacity: _visible ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 700),
          offset: _visible
              ? Offset.zero
              : Offset(widget.slideX, widget.slideY),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class StaggerReveal extends StatefulWidget {
  final List<Widget> children;
  final Duration intervalDelay;
  final double slideY;
  final String baseKey;

  const StaggerReveal({
    super.key,
    required this.children,
    required this.baseKey,
    this.intervalDelay = const Duration(milliseconds: 100),
    this.slideY = 0.15,
  });

  @override
  State<StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<StaggerReveal> {
  bool _triggered = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('stagger-${widget.baseKey}'),
      onVisibilityChanged: (info) {
        if (!_triggered && info.visibleFraction > 0.1) {
          setState(() => _triggered = true);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children
            .asMap()
            .entries
            .map(
              (e) => AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _triggered ? 1.0 : 0.0,
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 600),
                  offset: _triggered ? Offset.zero : Offset(0, widget.slideY),
                  curve: Curves.easeOut,
                  child: e.value,
                ),
              )
                  .animate(delay: widget.intervalDelay * e.key)
                  .custom(
                    duration: Duration.zero,
                    builder: (context, value, child) => child ?? const SizedBox.shrink(),
                  ),
            )
            .toList(),
      ),
    );
  }
}
