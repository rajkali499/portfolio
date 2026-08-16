import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/scroll_controller_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/spider_web_background.dart';
import '../widgets/spider_mask_profile.dart';

class HeroSection extends StatelessWidget {
  final GlobalKey aboutKey;

  const HeroSection({super.key, required this.aboutKey});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final provider = context.read<PortfolioProvider>();

    final screenH = MediaQuery.of(context).size.height;

    return VisibilityDetector(
      key: const Key('hero-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.4) {
          provider.setActiveSection('hero');
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenH),
        child: SizedBox(
          width: double.infinity,
          // Mobile: intrinsic height (no overflow). Desktop: full screen.
          height: isMobile ? null : screenH,
          child: Stack(
            children: [
              // Spider web fills the right side of the hero
              const Positioned.fill(child: SpiderWebBackground()),

              // Red vignette overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.7, 0),
                      radius: 1.0,
                      colors: [
                        AppColors.primary.withOpacity(0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Red edge glow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.spiderRedDark.withOpacity(0.08),
                        Colors.transparent,
                        AppColors.spiderRedDark.withOpacity(0.08),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.only(
                  top: isMobile ? 80 : 0,
                  bottom: isMobile ? 60 : 0,
                ),
                child: isMobile
                    ? Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24),
                            child: _buildMobileLayout(context, provider),
                          ),
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 48 : 80,
                              vertical: 80,
                            ),
                            child: _buildDesktopLayout(context, provider),
                          ),
                        ),
                      ),
              ),

              // Scroll indicator (only when content fits full screen)
              if (!isMobile)
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
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, PortfolioProvider provider) {
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: _buildTextContent(context, provider, mobile: false),
        ),
        SizedBox(width: isTablet ? 32 : 60),
        Expanded(
          flex: 4,
          child: Center(
            child: _buildProfileWidget(size: isTablet ? 220.0 : 290.0),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, PortfolioProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure ring2 (size * 1.31) never exceeds available width
        final profileSize = (constraints.maxWidth * 0.60).clamp(120.0, 200.0);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTextContent(context, provider, mobile: true),
            const SizedBox(height: 32),
            Center(child: _buildProfileWidget(size: profileSize)),
          ],
        );
      },
    );
  }

  Widget _buildProfileWidget({required double size}) {
    final ring1 = size * 1.17;
    final ring2 = size * 1.31;
    return SizedBox(
      width: ring2,
      height: ring2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Decorative web rings behind the picture
          Container(
            width: ring1,
            height: ring1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.webSilver.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          Container(
            width: ring2,
            height: ring2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.webSilver.withOpacity(0.04),
                width: 1,
              ),
            ),
          ),
          // The spider-masked profile photo
          SpiderMaskProfile(size: size),
        ],
      )
          .animate()
          .fadeIn(duration: 800.ms, delay: 600.ms)
          .slideX(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildTextContent(
      BuildContext context, PortfolioProvider provider,
      {required bool mobile}) {
    final crossAlign =
        mobile ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = mobile ? TextAlign.center : TextAlign.left;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAlign,
      children: [
        // "Hello, I'm" with spider-web underline
        Stack(
          children: [
            Text(
              'Hello, I\'m',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.spiderRed,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: mobile ? Alignment.center : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: 'Kalirajan K'.split('').asMap().entries.map(
              (e) => _NameLetter(char: e.value, index: e.key),
            ).toList(),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AnimatedTextKit(
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
        const SizedBox(height: 20),
        Wrap(
          alignment:
              mobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 16,
          runSpacing: 12,
          children: [
            GradientButton(
              label: 'View Work',
              icon: Icons.work_outline_rounded,
              onTap: () => provider.scrollTo(aboutKey),
            ),
            GradientButton(
              label: 'Contact Me',
              icon: Icons.mail_outline_rounded,
              outlined: true,
              onTap: () => launchUrl(
                Uri.parse(AppConstants.gmailCompose),
                mode: LaunchMode.externalApplication,
              ),
            ),
            GradientButton(
              label: 'Download CV',
              icon: Icons.download_rounded,
              outlined: true,
              onTap: () => launchUrl(
                Uri.parse(AppConstants.resumeAsset),
                mode: LaunchMode.externalApplication,
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
