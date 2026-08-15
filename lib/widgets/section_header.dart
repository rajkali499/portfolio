import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool animate;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    Widget content = Column(
      children: [
        Text(
          title,
          style: isMobile
              ? AppTextStyles.sectionTitleMobile
              : AppTextStyles.sectionTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 16),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (animate) {
      content = content
          .animate()
          .fadeIn(duration: 700.ms)
          .slideY(begin: 0.2, end: 0, duration: 700.ms, curve: Curves.easeOut);
    }

    return content;
  }
}
