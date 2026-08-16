import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../data/portfolio_data.dart';
import '../utils/constants.dart';
import '../utils/scroll_controller_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/section_header.dart';
import '../widgets/section_backgrounds.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  bool _triggered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final provider = context.read<PortfolioProvider>();

    return VisibilityDetector(
      key: const Key('projects-section'),
      onVisibilityChanged: (info) {
        if (!_triggered && info.visibleFraction > 0.1) {
          setState(() => _triggered = true);
          provider.setActiveSection('projects');
        }
      },
      child: Stack(
        children: [
          const Positioned.fill(child: ComicDotBackground()),
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
                    title: 'Key Projects',
                    subtitle: 'Production apps I\'ve built and shipped.',
                  ),
                  const SizedBox(height: 60),
                  (isMobile || isTablet)
                      ? _buildColumn()
                      : _buildDesktopGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn() {
    final projects = PortfolioData.projects;
    return Column(
      children: projects.asMap().entries.map((entry) {
        final index = entry.key;
        final project = entry.value;
        final isLast = index == projects.length - 1;
        Widget card = ProjectCard(project: project);
        if (_triggered) {
          card = card
              .animate(delay: Duration(milliseconds: index * 100))
              .fadeIn(duration: 700.ms)
              .slideY(begin: 0.12, end: 0, duration: 700.ms, curve: Curves.easeOut);
        } else {
          card = Opacity(opacity: 0, child: card);
        }
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
          child: card,
        );
      }).toList(),
    );
  }

  Widget _buildDesktopGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.62,
      ),
      itemCount: PortfolioData.projects.length,
      itemBuilder: (context, index) {
        Widget card = ProjectCard(project: PortfolioData.projects[index]);
        if (_triggered) {
          card = card
              .animate(delay: Duration(milliseconds: (index % 3) * 120))
              .fadeIn(duration: 700.ms)
              .slideY(begin: 0.15, end: 0, duration: 700.ms, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1, 1),
                duration: 700.ms,
              );
        } else {
          card = Opacity(opacity: 0, child: card);
        }
        return card;
      },
    );
  }
}
