import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/scroll_controller_provider.dart';

class NavBar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, GlobalKey> sectionKeys;
  final bool isDrawerOpen;
  final VoidCallback? onMenuTap;

  const NavBar({
    super.key,
    required this.sectionKeys,
    this.isDrawerOpen = false,
    this.onMenuTap,
  });

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
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

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
          horizontal: isMobile ? 20 : (isTablet ? 32 : 60),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLogo(),
            if (isMobile)
              GestureDetector(
                onTap: widget.onMenuTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: Tween<double>(begin: 0.15, end: 0.0)
                          .animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      widget.isDrawerOpen
                          ? Icons.close_rounded
                          : Icons.menu_rounded,
                      key: ValueKey(widget.isDrawerOpen),
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                  ),
                ),
              )
            else
              _buildNavLinks(context, isTablet: isTablet),
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

  Widget _buildNavLinks(BuildContext context, {bool isTablet = false}) {
    final provider = context.watch<PortfolioProvider>();
    const links = [
      ('About', 'about'),
      ('Skills', 'skills'),
      ('Projects', 'projects'),
      ('Experience', 'experience'),
      ('Contact', 'contact'),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: links.map((link) {
        final isActive = provider.activeSection == link.$2;
        return _NavLink(
          label: link.$1,
          isActive: isActive,
          isTablet: isTablet,
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
  final bool isTablet;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isTablet = false,
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
          margin: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? 8 : 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.navLink.copyWith(
                  fontSize: widget.isTablet ? 13 : 14,
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

/// Full-screen animated side nav overlay for mobile.
class MobileNavOverlay extends StatefulWidget {
  final bool isOpen;
  final Map<String, GlobalKey> sectionKeys;
  final VoidCallback onClose;

  const MobileNavOverlay({
    super.key,
    required this.isOpen,
    required this.sectionKeys,
    required this.onClose,
  });

  @override
  State<MobileNavOverlay> createState() => _MobileNavOverlayState();
}

class _MobileNavOverlayState extends State<MobileNavOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _backdropAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _backdropAnim =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(MobileNavOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        if (_ctrl.isDismissed) return const SizedBox.shrink();
        return Stack(
          children: [
            // Backdrop — tap to close
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                color: Colors.black.withOpacity(0.65 * _backdropAnim.value),
              ),
            ),
            // Slide panel from right
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 280,
              child: SlideTransition(
                position: _slideAnim,
                child: _NavPanel(
                  sectionKeys: widget.sectionKeys,
                  onClose: widget.onClose,
                  animation: _ctrl,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NavPanel extends StatelessWidget {
  final Map<String, GlobalKey> sectionKeys;
  final VoidCallback onClose;
  final Animation<double> animation;

  const _NavPanel({
    required this.sectionKeys,
    required this.onClose,
    required this.animation,
  });

  static const _links = [
    ('About', 'about'),
    ('Skills', 'skills'),
    ('Projects', 'projects'),
    ('Experience', 'experience'),
    ('Contact', 'contact'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(left: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40C41230),
            blurRadius: 40,
            offset: Offset(-8, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle corner web decoration
          Positioned.fill(
            child: CustomPaint(painter: _PanelWebPainter()),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppColors.primaryGradient.createShader(b),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          'KK',
                          style: AppTextStyles.sectionTitle
                              .copyWith(fontSize: 28),
                        ),
                      ),
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                // Nav links with staggered entry
                ..._links.asMap().entries.map((e) {
                  final isActive =
                      provider.activeSection == e.value.$2;
                  return _AnimatedNavItem(
                    label: e.value.$1,
                    index: e.key,
                    isActive: isActive,
                    animation: animation,
                    onTap: () {
                      onClose();
                      final k = sectionKeys[e.value.$2];
                      if (k != null) provider.scrollTo(k);
                    },
                  );
                }),
                const Spacer(),
                // Footer hint
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    'Flutter Developer · Chennai',
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary
                          .withOpacity(0.5),
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
}

class _AnimatedNavItem extends StatefulWidget {
  final String label;
  final int index;
  final bool isActive;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.label,
    required this.index,
    required this.isActive,
    required this.animation,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (ctx, _) {
        final start = (0.12 + widget.index * 0.07).clamp(0.0, 0.95);
        final end = (start + 0.35).clamp(0.0, 1.0);
        final t = CurvedAnimation(
          parent: widget.animation,
          curve: Interval(start, end, curve: Curves.easeOut),
        ).value;

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(22 * (1 - t), 0),
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    border: widget.isActive
                        ? const Border(
                            left: BorderSide(
                              color: AppColors.accent,
                              width: 3,
                            ),
                          )
                        : Border(
                            left: BorderSide(
                              color: _hovered
                                  ? AppColors.border
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                    color: widget.isActive
                        ? AppColors.accent.withOpacity(0.07)
                        : _hovered
                            ? AppColors.surface.withOpacity(0.4)
                            : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.label,
                          style: AppTextStyles.navLink.copyWith(
                            fontSize: 16,
                            color: widget.isActive
                                ? AppColors.accent
                                : _hovered
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                            fontWeight: widget.isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (widget.isActive)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Spider-web decoration painted in the side panel background
class _PanelWebPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.055)
      ..strokeWidth = 0.65
      ..style = PaintingStyle.stroke;

    // Top-right corner web
    const origin = Offset(280, 0);
    const spokes = 7;
    const webR = 190.0;
    for (int i = 0; i < spokes; i++) {
      final a = pi + (pi / 2 / (spokes - 1)) * i;
      canvas.drawLine(
          origin,
          Offset(origin.dx + cos(a) * webR, origin.dy + sin(a) * webR),
          paint);
    }
    for (int r = 1; r <= 4; r++) {
      final path = Path();
      for (int i = 0; i <= spokes; i++) {
        final a = pi + (pi / 2 / (spokes - 1)) * i.clamp(0, spokes - 1);
        final pt = Offset(
          origin.dx + cos(a) * webR * r / 4,
          origin.dy + sin(a) * webR * r / 4,
        );
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, paint);
    }

    // Bottom-right corner web
    final origin2 = Offset(280, size.height);
    for (int i = 0; i < spokes; i++) {
      final a = pi / 2 + (pi / 2 / (spokes - 1)) * i;
      canvas.drawLine(
          origin2,
          Offset(origin2.dx + cos(a) * 130, origin2.dy + sin(a) * 130),
          paint);
    }
    for (int r = 1; r <= 3; r++) {
      final path = Path();
      for (int i = 0; i <= spokes; i++) {
        final a = pi / 2 + (pi / 2 / (spokes - 1)) * i.clamp(0, spokes - 1);
        final pt = Offset(
          origin2.dx + cos(a) * 130 * r / 3,
          origin2.dy + sin(a) * 130 * r / 3,
        );
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_PanelWebPainter old) => false;
}
