import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../sections/about_section.dart';
import '../sections/contact_section.dart';
import '../sections/experience_section.dart';
import '../sections/hero_section.dart';
import '../sections/projects_section.dart';
import '../sections/skills_section.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/scroll_controller_provider.dart';
import '../widgets/nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, GlobalKey> _sectionKeys = {
    'hero': GlobalKey(),
    'about': GlobalKey(),
    'skills': GlobalKey(),
    'projects': GlobalKey(),
    'experience': GlobalKey(),
    'contact': GlobalKey(),
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PortfolioProvider>();
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: isMobile
          ? NavDrawer(sectionKeys: _sectionKeys)
          : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: provider.scrollController,
            child: Column(
              children: [
                SizedBox(
                  key: _sectionKeys['hero'],
                  child: HeroSection(
                    aboutKey: _sectionKeys['about']!,
                  ),
                ),
                SizedBox(
                  key: _sectionKeys['about'],
                  child: const AboutSection(),
                ),
                SizedBox(
                  key: _sectionKeys['skills'],
                  child: const SkillsSection(),
                ),
                SizedBox(
                  key: _sectionKeys['projects'],
                  child: const ProjectsSection(),
                ),
                SizedBox(
                  key: _sectionKeys['experience'],
                  child: const ExperienceSection(),
                ),
                SizedBox(
                  key: _sectionKeys['contact'],
                  child: const ContactSection(),
                ),
                _buildFooter(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NavBar(sectionKeys: _sectionKeys),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            blendMode: BlendMode.srcIn,
            child: Text('KK', style: AppTextStyles.sectionTitle.copyWith(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text(
            'Built with Flutter Web · Kalirajan K © 2025',
            style: AppTextStyles.bodySm.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
