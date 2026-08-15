import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, _hovered ? -3.0 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: widget.outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: _hovered
                        ? AppColors.accent
                        : AppColors.accent.withOpacity(0.7),
                    width: 1.5,
                  ),
                  color: _hovered
                      ? AppColors.accent.withOpacity(0.1)
                      : Colors.transparent,
                  boxShadow: _hovered
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: _hovered
                          ? AppColors.accent.withOpacity(0.45)
                          : AppColors.primary.withOpacity(0.35),
                      blurRadius: _hovered ? 28 : 16,
                      spreadRadius: _hovered ? 2 : 0,
                    ),
                  ],
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.outlined ? AppColors.accent : Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppTextStyles.buttonLabel.copyWith(
                  color: widget.outlined ? AppColors.accent : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
