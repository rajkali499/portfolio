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
      child: Container(
        width: double.infinity,
        color: const Color(0xFF080D18),
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
              _buildTimeline(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(bool isMobile) {
    if (isMobile) {
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

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                AnimatedSlide(
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
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildTimelineDot(active: true),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _lineAnimation,
                    builder: (context, _) => FractionallySizedBox(
                      heightFactor: _lineAnimation.value,
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradientVertical,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildTimelineDot(active: false),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Spacer(),
                AnimatedSlide(
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
              ],
            ),
          ),
        ],
      ),
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
