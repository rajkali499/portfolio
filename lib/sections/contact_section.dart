import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/scroll_controller_provider.dart';
import '../widgets/section_header.dart';
import '../widgets/section_backgrounds.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final provider = context.read<PortfolioProvider>();

    return VisibilityDetector(
      key: const Key('contact-section'),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.2) {
          setState(() => _visible = true);
          provider.setActiveSection('contact');
        }
      },
      child: Stack(
        children: [
          const Positioned.fill(child: CornerWebBackground()),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : (isTablet ? 48 : 80),
              vertical: AppConstants.sectionPaddingV,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
              const SectionHeader(
                title: 'Get In Touch',
                subtitle:
                    'I\'m open to opportunities and collaborations. Let\'s build something great together.',
              ),
              const SizedBox(height: 60),
              AnimatedScale(
                scale: _visible ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: EdgeInsets.all(isMobile ? 24 : 40),
                          decoration: BoxDecoration(
                            color: AppColors.card.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildAvailabilityBadge(),
                              const SizedBox(height: 32),
                              _buildContactItem(
                                Icons.mail_outline_rounded,
                                AppConstants.email,
                                AppConstants.gmailCompose,
                              ),
                              const SizedBox(height: 12),
                              _buildContactItem(
                                Icons.phone_outlined,
                                AppConstants.phone,
                                'tel:${AppConstants.phone}',
                              ),
                              const SizedBox(height: 12),
                              _buildContactItem(
                                Icons.location_on_outlined,
                                AppConstants.location,
                                null,
                              ),
                              const SizedBox(height: 32),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  _SocialButton(
                                    label: 'GitHub',
                                    icon: Icons.code_rounded,
                                    url: AppConstants.github,
                                  ),
                                  _SocialButton(
                                    label: 'Email Me',
                                    icon: Icons.mail_rounded,
                                    url: AppConstants.gmailCompose,
                                    outlined: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(4),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .custom(
                duration: 1500.ms,
                curve: Curves.easeOut,
                builder: (context, value, child) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success
                            .withOpacity(0.6 * (1 - value)),
                        blurRadius: 12 * value,
                        spreadRadius: 4 * value,
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(width: 8),
          Text(
            'Available for opportunities',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, String? url) {
    return _ContactItem(icon: icon, text: text, url: url);
  }
}

class _ContactItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final String? url;

  const _ContactItem({
    required this.icon,
    required this.text,
    this.url,
  });

  @override
  State<_ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<_ContactItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.url != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.url != null
            ? () => launchUrl(Uri.parse(widget.url!))
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          transform: Matrix4.identity()
            ..translate(_hovered ? 4.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.accent.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? AppColors.border : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: _hovered ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.text,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: _hovered ? AppColors.accent : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final String url;
  final bool outlined;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.url,
    this.outlined = false,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.url)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          transform: Matrix4.identity()
            ..translate(0.0, _hovered ? -3.0 : 0.0),
          decoration: BoxDecoration(
            gradient: _hovered && !widget.outlined
                ? AppColors.primaryGradient
                : null,
            color: !_hovered && !widget.outlined
                ? AppColors.primary.withOpacity(0.2)
                : _hovered && widget.outlined
                    ? AppColors.accent.withOpacity(0.1)
                    : null,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: _hovered
                  ? AppColors.accent
                  : AppColors.primary.withOpacity(0.5),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 20,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _hovered ? Colors.white : AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTextStyles.buttonLabel.copyWith(
                  color: _hovered ? Colors.white : AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
