import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/scroll_controller_provider.dart';

class NavBar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, GlobalKey> sectionKeys;

  const NavBar({super.key, required this.sectionKeys});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PortfolioProvider>();
      provider.scrollController.addListener(() {
        final isScrolled = provider.scrollController.offset > 60;
        if (_scrolled != isScrolled) {
          setState(() => _scrolled = isScrolled);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 64,
      decoration: BoxDecoration(
        color: _scrolled
            ? AppColors.background.withOpacity(0.95)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: _scrolled ? AppColors.border : Colors.transparent,
          ),
        ),
        boxShadow: _scrolled
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLogo(),
            if (isMobile)
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded,
                      color: AppColors.textPrimary),
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                ),
              )
            else
              _buildNavLinks(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ShaderMask(
      shaderCallback: (bounds) =>
          AppColors.primaryGradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        'KK',
        style: AppTextStyles.sectionTitle.copyWith(
          fontSize: 28,
          letterSpacing: -1,
        ),
      ),
    );
  }

  Widget _buildNavLinks(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final links = [
      ('About', 'about'),
      ('Skills', 'skills'),
      ('Projects', 'projects'),
      ('Experience', 'experience'),
      ('Contact', 'contact'),
    ];

    return Row(
      children: links.map((link) {
        final isActive = provider.activeSection == link.$2;
        return _NavLink(
          label: link.$1,
          isActive: isActive,
          onTap: () {
            final key = widget.sectionKeys[link.$2];
            if (key != null) {
              provider.scrollTo(key);
            }
          },
        );
      }).toList(),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.navLink.copyWith(
                  color: widget.isActive || _hovered
                      ? AppColors.accent
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 2,
                width: widget.isActive || _hovered ? 20 : 0,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavDrawer extends StatelessWidget {
  final Map<String, GlobalKey> sectionKeys;

  const NavDrawer({super.key, required this.sectionKeys});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final links = [
      ('Hero', 'hero'),
      ('About', 'about'),
      ('Skills', 'skills'),
      ('Projects', 'projects'),
      ('Experience', 'experience'),
      ('Contact', 'contact'),
    ];

    return Drawer(
      backgroundColor: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
              blendMode: BlendMode.srcIn,
              child: Text('KK',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 32)),
            ),
            const SizedBox(height: 40),
            ...links.map(
              (link) => ListTile(
                title: Text(
                  link.$1,
                  style: AppTextStyles.navLink.copyWith(
                    fontSize: 18,
                    color: provider.activeSection == link.$2
                        ? AppColors.accent
                        : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  final key = sectionKeys[link.$2];
                  if (key != null) provider.scrollTo(key);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
