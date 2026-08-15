import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../data/portfolio_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/scroll_controller_provider.dart';
import '../widgets/section_header.dart';
import '../widgets/skill_bar.dart';

class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  bool _triggered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final provider = context.read<PortfolioProvider>();

    return VisibilityDetector(
      key: const Key('skills-section'),
      onVisibilityChanged: (info) {
        if (!_triggered && info.visibleFraction > 0.15) {
          setState(() => _triggered = true);
          provider.setActiveSection('skills');
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
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const SectionHeader(
                title: 'Technical Skills',
                subtitle: 'Technologies and tools I work with every day.',
              ),
              const SizedBox(height: 60),
              isMobile
                  ? _buildMobileLayout(isMobile)
                  : _buildDesktopLayout(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Core Proficiency', style: AppTextStyles.cardTitle),
              const SizedBox(height: 24),
              ...PortfolioData.coreSkills.asMap().entries.map(
                    (e) => SkillBar(
                      name: e.value.name,
                      level: e.value.level,
                      index: e.key,
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 5,
          child: _buildCategoryGrid(isTablet ? 1 : 2),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isMobile) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Core Proficiency', style: AppTextStyles.cardTitle),
            const SizedBox(height: 24),
            ...PortfolioData.coreSkills.asMap().entries.map(
                  (e) => SkillBar(
                    name: e.value.name,
                    level: e.value.level,
                    index: e.key,
                  ),
                ),
          ],
        ),
        const SizedBox(height: 40),
        _buildCategoryGrid(1),
      ],
    );
  }

  Widget _buildCategoryGrid(int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: crossAxisCount == 2 ? 1.1 : 2.0,
      ),
      itemCount: PortfolioData.skillCategories.length,
      itemBuilder: (context, index) {
        return _SkillCategoryCard(
          category: PortfolioData.skillCategories[index],
          index: index,
          triggered: _triggered,
        );
      },
    );
  }
}

class _SkillCategoryCard extends StatefulWidget {
  final dynamic category;
  final int index;
  final bool triggered;

  const _SkillCategoryCard({
    required this.category,
    required this.index,
    required this.triggered,
  });

  @override
  State<_SkillCategoryCard> createState() => _SkillCategoryCardState();
}

class _SkillCategoryCardState extends State<_SkillCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Widget card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? AppColors.accent.withOpacity(0.4)
                : AppColors.border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.category.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.category.title,
                    style: AppTextStyles.bodyMdPrimary
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.category.skills
                      .asMap()
                      .entries
                      .map<Widget>((e) {
                    final isHighlighted = e.key < 2;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isHighlighted || _hovered
                            ? AppColors.accent.withOpacity(0.12)
                            : AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isHighlighted || _hovered
                              ? AppColors.accent.withOpacity(0.5)
                              : AppColors.primary.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        e.value as String,
                        style: AppTextStyles.chipLabel.copyWith(
                          color: isHighlighted || _hovered
                              ? AppColors.accent
                              : AppColors.textPrimary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.triggered) {
      return card
          .animate(
            delay: Duration(milliseconds: widget.index * 120),
          )
          .fadeIn(duration: 600.ms)
          .slideY(
            begin: 0.2,
            end: 0,
            duration: 600.ms,
            curve: Curves.easeOut,
          );
    }

    return Opacity(opacity: 0, child: card);
  }
}
