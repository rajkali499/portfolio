import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../data/portfolio_data.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../utils/scroll_controller_provider.dart';
import '../widgets/experience_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/section_backgrounds.dart';

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _lineAnimation = CurvedAnimation(
      parent: _lineController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final provider = context.read<PortfolioProvider>();

    return VisibilityDetector(
      key: const Key('experience-section'),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.15) {
          setState(() => _visible = true);
          _lineController.forward();
          provider.setActiveSection('experience');
        }
      },
      child: Stack(
        children: [
          const Positioned.fill(child: BlueprintWebBackground()),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : (isTablet ? 48 : 80),
              vertical: AppConstants.sectionPaddingV,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  const SectionHeader(title: 'Work Experience'),
                  const SizedBox(height: 60),
                  _buildTimeline(isMobile, isTablet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(bool isMobile, bool isTablet) {
    if (isMobile) return _buildMobileTimeline();
    if (isTablet) return _buildTabletTimeline();
    return _buildDesktopTimeline();
  }

  // Mobile: stacked cards with short connector between them
  Widget _buildMobileTimeline() {
    return Column(
      children: PortfolioData.experience.asMap().entries.map((e) {
        return Column(
          children: [
            AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, 0.1),
              duration: Duration(milliseconds: 600 + e.key * 200),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 600 + e.key * 200),
                child: ExperienceTile(experience: e.value),
              ),
            ),
            if (e.key < PortfolioData.experience.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (context, _) => Container(
                    width: 2,
                    height: 40 * _lineAnimation.value,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradientVertical,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  // Tablet: timeline dots on the left, cards in a column on the right
  Widget _buildTabletTimeline() {
    final experiences = PortfolioData.experience;
    return Column(
      children: experiences.asMap().entries.map((entry) {
        final i = entry.key;
        final exp = entry.value;
        final isLast = i == experiences.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: dot + vertical connector filling card height
              SizedBox(
                width: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildTimelineDot(active: exp.isCurrent),
                    if (!isLast)
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _lineAnimation,
                          builder: (context, _) => Opacity(
                            opacity: _lineAnimation.value,
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradientVertical,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right: experience card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: AnimatedSlide(
                    offset: _visible ? Offset.zero : const Offset(0.08, 0),
                    duration: Duration(milliseconds: 600 + i * 200),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 600 + i * 200),
                      child: ExperienceTile(experience: exp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Desktop: alternating left/right with centre timeline
  Widget _buildDesktopTimeline() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left tile — first experience, right-aligned
        Expanded(
          child: AnimatedSlide(
            offset: _visible ? Offset.zero : const Offset(-0.1, 0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 700),
              child: ExperienceTile(
                experience: PortfolioData.experience[0],
                alignRight: true,
              ),
            ),
          ),
        ),

        // Centre timeline — fixed height, no Expanded/Spacer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimelineDot(active: true),
              AnimatedBuilder(
                animation: _lineAnimation,
                builder: (context, _) => SizedBox(
                  width: 2,
                  height: 220 * _lineAnimation.value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradientVertical,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
              _buildTimelineDot(active: false),
            ],
          ),
        ),

        // Right tile — second experience, staggered down
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 120),
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0.1, 0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 700),
                child: ExperienceTile(
                  experience: PortfolioData.experience[1],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDot({required bool active}) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: active ? AppColors.success : AppColors.accent,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: (active ? AppColors.success : AppColors.accent)
                .withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}
