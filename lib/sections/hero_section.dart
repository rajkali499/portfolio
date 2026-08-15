import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/scroll_controller_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/particles_background.dart';

class HeroSection extends StatelessWidget {
  final GlobalKey aboutKey;

  const HeroSection({super.key, required this.aboutKey});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final provider = context.read<PortfolioProvider>();

    return VisibilityDetector(
      key: const Key('hero-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.4) {
          provider.setActiveSection('hero');
        }
      },
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            const Positioned.fill(child: ParticlesBackground()),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.6, -0.3),
                    radius: 1.2,
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : (isTablet ? 48 : 80),
                    vertical: 80,
                  ),
                  child: isMobile
                      ? _buildMobileLayout(context, provider)
                      : _buildDesktopLayout(context, provider),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text('Scroll',
                      style: AppTextStyles.bodySm
                          .copyWith(fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Container(
                    width: 1.5,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradientVertical,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 800.ms)
                      .then()
                      .fadeOut(duration: 800.ms),
                ],
              )
                  .animate()
                  .fadeIn(delay: 2200.ms, duration: 800.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, PortfolioProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: _buildTextContent(context, provider, mobile: false),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 4,
          child: Center(child: _buildPhoneMockup()),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, PortfolioProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextContent(context, provider, mobile: true),
        const SizedBox(height: 40),
        SizedBox(
          height: 320,
          child: _buildPhoneMockup(scale: 0.75),
        ),
      ],
    );
  }

  Widget _buildTextContent(
      BuildContext context, PortfolioProvider provider, {required bool mobile}) {
    final crossAlign =
        mobile ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = mobile ? TextAlign.center : TextAlign.left;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          'Hello, I\'m',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
        const SizedBox(height: 8),
        ...'Kalirajan K'.split('').asMap().entries.map(
              (e) => _NameLetter(char: e.value, index: e.key),
            ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedTextKit(
              animatedTexts: AppConstants.typingStrings
                  .map((s) => TypewriterAnimatedText(
                        s,
                        textStyle: mobile
                            ? AppTextStyles.heroRoleMobile
                            : AppTextStyles.heroRole,
                        speed: const Duration(milliseconds: 75),
                      ))
                  .toList(),
              repeatForever: true,
              pause: const Duration(milliseconds: 1800),
              isRepeatingAnimation: true,
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 700.ms, delay: 1000.ms),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            AppConstants.summary,
            style: AppTextStyles.bodyMd,
            textAlign: textAlign,
          ),
        )
            .animate()
            .fadeIn(duration: 700.ms, delay: 1300.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: mobile
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            GradientButton(
              label: 'View Work',
              icon: Icons.work_outline_rounded,
              onTap: () => provider.scrollTo(aboutKey),
            ),
            const SizedBox(width: 16),
            GradientButton(
              label: 'Contact Me',
              icon: Icons.mail_outline_rounded,
              outlined: true,
              onTap: () => launchUrl(
                Uri.parse('mailto:${AppConstants.email}'),
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 700.ms, delay: 1600.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildPhoneMockup({double scale = 1.0}) {
    return Transform.scale(
      scale: scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 230,
            height: 440,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A2340), Color(0xFF0F1629)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.18),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 80,
                  spreadRadius: -10,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Container(
                color: const Color(0xFF060D1A),
                child: _buildMockUI(),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .custom(
                duration: 3000.ms,
                curve: Curves.easeInOut,
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(0, value * -14),
                  child: child,
                ),
              ),
          Positioned(
            top: -20,
            right: -85,
            child: _buildCodeCard(
              '''// BLoC Event
abstract class PaymentEvent {}

class InitiateUPI
  extends PaymentEvent {
  final String vpa;
  final double amount;
}''',
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .custom(
                  duration: 4200.ms,
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, value * -12),
                    child: Transform.rotate(
                      angle: 0.04 - value * 0.08,
                      child: child,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 1800.ms, duration: 700.ms),
          ),
          Positioned(
            bottom: 60,
            right: -90,
            child: _buildCodeCard(
              '''final authProvider =
  StateNotifierProvider<
    AuthNotifier,
    AuthState
  >((ref) => AuthNotifier());''',
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .custom(
                  duration: 3800.ms,
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, value * -10),
                    child: Transform.rotate(
                      angle: -0.03 + value * 0.06,
                      child: child,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 2200.ms, duration: 700.ms),
          ),
          Positioned(
            top: 100,
            left: -100,
            child: _buildCodeCard(
              '''BlocBuilder<ThemeBloc,
  ThemeState>(
  builder: (ctx, state) =>
    MaterialApp(
      theme: state.themeData,
    ),
)''',
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .custom(
                  duration: 4800.ms,
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, value * -16),
                    child: Transform.rotate(
                      angle: 0.02 - value * 0.05,
                      child: child,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 2600.ms, duration: 700.ms),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 800.ms, delay: 600.ms)
          .slideX(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildCodeCard(String code) {
    return Container(
      width: 195,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629).withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.accent.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Text(code, style: AppTextStyles.codeSnippet),
    );
  }

  Widget _buildMockUI() {
    return Column(
      children: [
        Container(
          height: 22,
          color: AppColors.primary.withOpacity(0.9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.signal_cellular_alt,
                    size: 10, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Text('ABCD Pay',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const Spacer(),
              Icon(Icons.notifications_none_rounded,
                  size: 16, color: Colors.white.withOpacity(0.8)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF02569B), Color(0xFF0175C2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balance',
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                color: Colors.white70,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text('₹ 24,850.00',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _mockAction(Icons.arrow_upward_rounded, 'Send'),
                            const SizedBox(width: 10),
                            _mockAction(Icons.arrow_downward_rounded, 'Receive'),
                            const SizedBox(width: 10),
                            _mockAction(Icons.receipt_long_rounded, 'Pay'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _mockQuickAction(Icons.flash_on_rounded, 'UPI',
                          const Color(0xFF54C5F8)),
                      _mockQuickAction(Icons.receipt_rounded, 'BBPS',
                          const Color(0xFF4CAF50)),
                      _mockQuickAction(Icons.account_balance_rounded,
                          'Bank', const Color(0xFFFFB400)),
                      _mockQuickAction(Icons.more_horiz_rounded, 'More',
                          AppColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  ('UPI Payment', '₹ 500.00', true),
                  ('BBPS - Electricity', '₹ 1,200.00', false),
                  ('Transfer', '₹ 2,000.00', true),
                ].map((t) => _mockTransaction(t.$1, t.$2, t.$3)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mockAction(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(height: 3),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 7, color: Colors.white70)),
      ],
    );
  }

  Widget _mockQuickAction(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 8,
                color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _mockTransaction(String name, String amount, bool incoming) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: incoming
                  ? AppColors.success.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              incoming
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 13,
              color: incoming ? AppColors.success : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name,
                style: GoogleFonts.inter(
                    fontSize: 9,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500)),
          ),
          Text(
            (incoming ? '+' : '-') + amount,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: incoming ? AppColors.success : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameLetter extends StatelessWidget {
  final String char;
  final int index;

  const _NameLetter({required this.char, required this.index});

  @override
  Widget build(BuildContext context) {
    if (char == ' ') return const SizedBox(width: 12);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return ShaderMask(
      shaderCallback: (bounds) =>
          AppColors.primaryGradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        char,
        style: (isMobile
                ? AppTextStyles.heroNameMobile
                : AppTextStyles.heroName)
            .copyWith(color: Colors.white),
      ),
    )
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: 400 + index * 55),
        )
        .slideY(
          begin: 0.5,
          end: 0,
          duration: 600.ms,
          delay: Duration(milliseconds: 400 + index * 55),
          curve: Curves.easeOut,
        )
        .blurXY(
          begin: 6,
          end: 0,
          duration: 500.ms,
          delay: Duration(milliseconds: 400 + index * 55),
        );
  }
}
