import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/scroll_controller_provider.dart';
import '../widgets/section_header.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _counterController;

  final List<_StatData> _stats = const [
    _StatData('4+', 'Years Experience'),
    _StatData('2', 'Companies'),
    _StatData('3', 'Platforms'),
    _StatData('7', 'Devs Led'),
  ];

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final provider = context.read<PortfolioProvider>();

    return VisibilityDetector(
      key: const Key('about-section'),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.2) {
          setState(() => _visible = true);
          _counterController.forward();
          provider.setActiveSection('about');
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : (isTablet ? 48 : 80),
          vertical: AppConstants.sectionPaddingV,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const SectionHeader(title: 'About Me'),
              const SizedBox(height: 60),
              isMobile
                  ? _buildMobileLayout()
                  : _buildDesktopLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildTextContent()),
        const SizedBox(width: 60),
        Expanded(flex: 4, child: _buildStats()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildTextContent(),
        const SizedBox(height: 40),
        _buildStats(),
      ],
    );
  }

  Widget _buildTextContent() {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(-0.08, 0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.summary, style: AppTextStyles.bodyMd),
            const SizedBox(height: 24),
            _highlight(Icons.code_rounded, 'Flutter & Dart Expert',
                'Building production FinTech apps with complex architecture and state management.'),
            const SizedBox(height: 16),
            _highlight(Icons.payment_rounded, 'Payment Systems',
                'Deep expertise in UPI, BBPS, NPCI compliance, Stripe, and Razorpay.'),
            const SizedBox(height: 16),
            _highlight(Icons.groups_rounded, 'Tech Leadership',
                'Led a 7-member Flutter team delivering code quality, reviews, and best practices.'),
            const SizedBox(height: 16),
            _highlight(Icons.devices_rounded, 'Cross-Platform',
                'Shipped apps on Android, iOS, Web, and Windows Desktop using a single Flutter codebase.'),
          ],
        ),
      ),
    );
  }

  Widget _highlight(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.bodyMdPrimary
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(description, style: AppTextStyles.bodySm),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0.08, 0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 800),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: _stats.map((s) => _StatCard(
                data: s,
                controller: _counterController,
              )).toList(),
        ),
      ),
    );
  }
}

class _StatData {
  final String value;
  final String label;
  const _StatData(this.value, this.label);
}

class _StatCard extends StatefulWidget {
  final _StatData data;
  final AnimationController controller;

  const _StatCard({required this.data, required this.controller});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? AppColors.accent.withOpacity(0.5) : AppColors.border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
              blendMode: BlendMode.srcIn,
              child: Text(
                widget.data.value,
                style: AppTextStyles.statNumber,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.data.label,
              style: AppTextStyles.statLabel,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
