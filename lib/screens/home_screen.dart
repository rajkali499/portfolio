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
import '../widgets/roaming_spider.dart';
import '../widgets/swinging_spider.dart';
import '../widgets/walking_spider.dart';

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

  double _scrollOffset = 0;
  double _maxScrollExtent = 0;
  bool _mobileNavOpen = false;

  // Cursor position for the hunting spider (Offset.zero = not yet tracked)
  final _cursor = ValueNotifier<Offset>(Offset.zero);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sc = context.read<PortfolioProvider>().scrollController;
      sc.addListener(() {
        if (mounted) {
          setState(() {
            _scrollOffset = sc.offset;
            _maxScrollExtent = sc.position.maxScrollExtent;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  void _closeMobileNav() => setState(() => _mobileNavOpen = false);
  void _toggleMobileNav() =>
      setState(() => _mobileNavOpen = !_mobileNavOpen);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PortfolioProvider>();
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Listener(
        behavior: HitTestBehavior.translucent,
        // Track cursor on desktop hover and touch drag
        onPointerHover: (e) { _cursor.value = e.localPosition; },
        onPointerMove:  (e) { _cursor.value = e.localPosition; },
        child: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            controller: provider.scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  key: _sectionKeys['hero'],
                  width: double.infinity,
                  child: HeroSection(aboutKey: _sectionKeys['about']!),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  key: _sectionKeys['about'],
                  width: double.infinity,
                  child: const AboutSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  key: _sectionKeys['skills'],
                  width: double.infinity,
                  child: const SkillsSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  key: _sectionKeys['projects'],
                  width: double.infinity,
                  child: const ProjectsSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  key: _sectionKeys['experience'],
                  width: double.infinity,
                  child: const ExperienceSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  key: _sectionKeys['contact'],
                  width: double.infinity,
                  child: const ContactSection(),
                ),
              ),
              SliverToBoxAdapter(child: _buildFooter()),
            ],
          ),

          // Two corner swinging spiders (left + right, follow scroll)
          SwingingSpider(
            scrollOffset: _scrollOffset,
            maxScrollExtent: _maxScrollExtent,
          ),

          // Bottom walking spider — patrols the screen edge
          const Positioned.fill(child: WalkingSpider()),

          // Two roaming spiders wander the full viewport
          const Positioned.fill(child: RoamingSpider(seed: 73)),
          const Positioned.fill(child: RoamingSpider(seed: 137)),

          // Cursor hunter — golden eyes, chases the mouse pointer
          Positioned.fill(child: CursorSpider(cursor: _cursor)),

          // Mobile side nav overlay (above content, behind nav bar)
          if (isMobile)
            IgnorePointer(
              ignoring: !_mobileNavOpen,
              child: MobileNavOverlay(
                isOpen: _mobileNavOpen,
                sectionKeys: _sectionKeys,
                onClose: _closeMobileNav,
              ),
            ),

          // NavBar always on top
          Positioned(
            height: 64,
            top: 0,
            left: 0,
            right: 0,
            child: NavBar(
              sectionKeys: _sectionKeys,
              isDrawerOpen: _mobileNavOpen,
              onMenuTap: isMobile ? _toggleMobileNav : null,
            ),
          ),
        ],
      ),
      ), // Listener
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
            child: Text('KK',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 24)),
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
