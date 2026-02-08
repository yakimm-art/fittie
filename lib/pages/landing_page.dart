import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'features_page.dart';
import 'morphic_ui_page.dart';
import 'voice_coach_page.dart';
import 'about_page.dart';
import 'blog_page.dart';
import 'careers_page.dart';
import 'community_page.dart';
import 'help_center_page.dart';

// --- 1. THEME ENGINE ---
class AppColors {
  // New gradient palette
  static const mintGreen = Color(0xFFC4F7E5);
  static const limeYellow = Color(0xFFE8F5A3);
  static const cardSurface = Color(0xFFFFFEFC);
  
  static const bgCream = Color(0xFFFDFBF7);
  static const primaryTeal = Color(0xFF38B2AC);
  static const primaryLight = Color(0xFFB2F5EA);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const borderBlack = Color(0xFF1F2937);
  static const accentOrange = Color(0xFFFF9F43);
  static const accentPurple = Color(0xFF9B59B6);
  static const accentPink = Color(0xFFFED7E2);
  static const accentYellow = Color(0xFFF6E05E);
}

class BearColors {
  static const primaryTeal = Color(0xFF38B2AC);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const blush = Color(0xFFFFB6C1);
  static const furWhite = Color(0xFFFFFFFF);
  static const bellyCream = Color(0xFFF7FAFC);
  static const bgCream = Color(0xFFFDFBF7);
}

class AppDimensions {
  static const double borderWeight = 3.0;
  static const double borderRadiusLarge = 32.0;
  static const double borderRadiusSmall = 16.0;
  static const double shadowOffset = 6.0;
  static const double maxWidth = 1100.0;
}

// --- SCROLL-TRIGGERED FADE-IN WIDGET ---
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final double offsetY;
  final int delayMs;
  const FadeSlideIn(
      {super.key, required this.child, this.offsetY = 30, this.delayMs = 0});
  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  late Animation<double> _scale;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _slide = Tween<Offset>(begin: Offset(0, widget.offsetY), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _scale = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(double visibleFraction) {
    if (visibleFraction > 0.15 && !_triggered) {
      _triggered = true;
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _VisibilityDetector(
          onVisibilityChanged: _onVisibilityChanged,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Transform.translate(
                offset: _slide.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Opacity(opacity: _opacity.value, child: widget.child),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _VisibilityDetector extends StatefulWidget {
  final Widget child;
  final ValueChanged<double> onVisibilityChanged;
  const _VisibilityDetector(
      {required this.child, required this.onVisibilityChanged});
  @override
  State<_VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<_VisibilityDetector> {
  final GlobalKey _key = GlobalKey();
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_checked) return;
    final ctx = _key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) {
      // Retry
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      return;
    }
    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH) {
      _checked = true;
      widget.onVisibilityChanged(1.0);
    } else {
      // Keep checking via scroll
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-check on every build (triggered by scroll)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_checked) _check();
    });
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

// --- HERO ENTRANCE ANIMATION ---
class _HeroEntrance extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _HeroEntrance({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    final fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 0.5, curve: Curves.easeOut)));
    final slideUp = Tween<Offset>(begin: const Offset(0, 60), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.05, 0.7, curve: Curves.easeOutCubic)));
    final scaleIn = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.65, curve: Curves.easeOutBack)));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: slideUp.value,
          child: Transform.scale(
            scale: scaleIn.value,
            child: Opacity(opacity: fadeIn.value, child: child),
          ),
        );
      },
    );
  }
}

// --- 2. LANDING PAGE ---

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _blobController;
  late AnimationController _heroEntrance;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _heroEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Start hero entrance after a brief delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _heroEntrance.forward();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset != _scrollOffset) {
        setState(() => _scrollOffset = _scrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _blobController.dispose();
    _heroEntrance.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mintGreen, AppColors.limeYellow],
              ),
            ),
            child: Stack(
              children: [

              SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: isMobile ? 90 : 100),
                    _HeroEntrance(
                      animation: _heroEntrance,
                      child: HeroSection(isMobile: isMobile),
                    ),
                    const SizedBox(height: 80),
                    const _TapeStripDivider(),
                    const SizedBox(height: 80),
                    FeaturesSection(isMobile: isMobile),
                    const SizedBox(height: 100),
                    PhilosophySection(isMobile: isMobile),
                    const SizedBox(height: 100),
                    StepsSection(isMobile: isMobile),
                    const SizedBox(height: 100),
                    const CTASection(),
                    FooterSection(isMobile: isMobile),
                  ],
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                      parent: _heroEntrance,
                      curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: _heroEntrance,
                        curve: const Interval(0.1, 0.6,
                            curve: Curves.easeOutCubic))),
                    child: PopHeader(
                        scrollOffset: _scrollOffset, isMobile: isMobile),
                  ),
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

// --- 3. SECTIONS ---

class PopHeader extends StatelessWidget {
  final double scrollOffset;
  final bool isMobile;
  const PopHeader(
      {super.key, required this.scrollOffset, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    // Smoothly interpolate from 0.0 to 1.0 over 0..80px of scroll
    final t = (scrollOffset / 80).clamp(0.0, 1.0);
    final isActive = t > 0.05;

    final bgOpacity = 0.0 + (0.88 * t);
    final blurSigma = 16.0 * t;
    final shadowY = 5.0 * t;
    final hPad = isMobile ? (8.0 + 8.0 * t) : (8.0 + 16.0 * t);
    final borderWidth = 2.5 * t;
    final topMargin = isMobile ? (16.0 - 4.0 * t) : (24.0 - 8.0 * t);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
        margin: EdgeInsets.only(top: topMargin, left: 16, right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 8 : 12,
                horizontal: hPad,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(bgOpacity),
                borderRadius: BorderRadius.circular(50),
                border: isActive
                    ? Border.all(
                        color: AppColors.borderBlack.withOpacity(t),
                        width: borderWidth)
                    : null,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: AppColors.borderBlack.withOpacity(t * 0.8),
                            offset: Offset(0, shadowY))
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AnimatedScale(
                        scale: 1.0 - (0.08 * t),
                        duration: const Duration(milliseconds: 150),
                        child: FittieLogo(size: isMobile ? 32 : 40),
                      ),
                      const SizedBox(width: 12),
                      Text("Fittie",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                            fontSize: (isMobile ? 22 : 26) - (2.0 * t),
                            letterSpacing: -1,
                          )),
                      if (!isMobile) ...[
                        const SizedBox(width: 24),
                        _NavLink("Features", () => const FeaturesPage()),
                        _NavLink("About", () => const AboutPage()),
                        _NavLink("Blog", () => const BlogPage()),
                        _NavLink("Community", () => const CommunityPage()),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(isMobile ? "Log In" : "LOGIN",
                            style: GoogleFonts.inter(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      SquishyButton(
                        label: isMobile ? "START" : "GET STARTED",
                        isSmall: true,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()));
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final Widget Function() builder;
  const _NavLink(this.label, this.builder);
  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => widget.builder())),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: GoogleFonts.inter(
              color: _hov ? AppColors.primaryTeal : AppColors.textSoft,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  final bool isMobile;
  const HeroSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: isMobile
              ? Column(children: [
                  FadeSlideIn(child: const _HeroVisualContent(isMobile: true)),
                  const SizedBox(height: 40),
                  FadeSlideIn(
                      delayMs: 200,
                      child: _HeroTextContent(isMobile: true, center: true)),
                ])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 5,
                        child: FadeSlideIn(
                            offsetY: 0,
                            child: _HeroTextContent(
                                isMobile: false, center: false))),
                    const SizedBox(width: 40),
                    Expanded(
                        flex: 5,
                        child: FadeSlideIn(
                            delayMs: 300,
                            child: const _HeroVisualContent(isMobile: false))),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeroTextContent extends StatelessWidget {
  final bool center;
  final bool isMobile;
  const _HeroTextContent({required this.center, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final align = center ? TextAlign.center : TextAlign.start;
    final crossAlign =
        center ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        const HeroBadge(),
        const SizedBox(height: 20),
        RichText(
          textAlign: align,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: isMobile ? 36 : 56,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
              height: 1.05,
              letterSpacing: -2,
            ),
            children: [
              const TextSpan(text: "The Agent that "),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Transform.rotate(
                  angle: -0.03,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow,
                      border:
                          Border.all(color: AppColors.borderBlack, width: 3),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.borderBlack, offset: Offset(4, 4))
                      ],
                    ),
                    child: Text(
                      "Flows",
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 36 : 56,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        height: 1.05,
                        letterSpacing: -2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
              const TextSpan(text: " with You."),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Stop following static plans. Fittie adapts your routine to your energy, environment, and heart rate—real-time.",
          textAlign: align,
          style: GoogleFonts.inter(
              fontSize: isMobile ? 16 : 18,
              color: AppColors.textSoft,
              height: 1.5,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        SquishyButton(
          label: "START TRAINING FREE",
          isLarge: !isMobile,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpPage()));
          },
        ),
        const SizedBox(height: 36),
        const _StatRow(),
      ],
    );
  }
}

class _HeroVisualContent extends StatelessWidget {
  final bool isMobile;
  const _HeroVisualContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final mascotSize = isMobile ? 240.0 : 320.0;

    return SizedBox(
      height: mascotSize * 1.25 + 40,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: mascotSize * 1.25,
            height: mascotSize * 1.25,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderBlack, width: 3),
              boxShadow: const [
                BoxShadow(color: AppColors.borderBlack, offset: Offset(6, 6))
              ],
            ),
          ),
          SizedBox(
            height: mascotSize,
            width: mascotSize,
            child: const KawaiiPolarBear(isTalking: false),
          ),
          Positioned(
              top: 10,
              left: 10,
              child: const PopFloatingCard(
                  icon: "⚡", label: "Recovery", value: "88%")),
          Positioned(
              bottom: 30,
              right: 10,
              child: const PopFloatingCard(
                  icon: "🔥", label: "Readiness", value: "Optimal")),
          Positioned(
            top: -5,
            right: isMobile ? 0 : 10,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderBlack, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.borderBlack, offset: Offset(2, 2))
                  ],
                ),
                child: const Text("AI \u26A1",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturesSection extends StatelessWidget {
  final bool isMobile;
  const FeaturesSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: Column(
            children: [
              FadeSlideIn(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(3, 3))
                    ],
                  ),
                  child: Text("THE ENGINE",
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2)),
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                  delayMs: 100,
                  child: Text("Biological Logic.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: isMobile ? 36 : 56,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          letterSpacing: -2))),
              const SizedBox(height: 24),
              FadeSlideIn(
                  delayMs: 200,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Text(
                      "Every rep, every rest is driven by your biological signals—not guesswork.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 17,
                          color: AppColors.textSoft,
                          height: 1.5,
                          fontWeight: FontWeight.w500),
                    ),
                  )),
              const SizedBox(height: 64),
              if (isMobile)
                Column(
                  children: [
                    FadeSlideIn(
                        child: const SizedBox(
                            height: 280,
                            child: PopBentoCard(
                              title: "Morphic UI",
                              icon: "🎨",
                              desc:
                                  "The interface reshapes based on your focus level.",
                              color: AppColors.primaryLight,
                            ))),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                        delayMs: 150,
                        child: const SizedBox(
                            height: 280,
                            child: PopBentoCard(
                              title: "Voice Coach",
                              icon: "🎙️",
                              desc:
                                  "Real-time AI guidance that listens to your breath.",
                              color: AppColors.accentPink,
                            ))),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                        delayMs: 300,
                        child: const SizedBox(
                            height: 280,
                            child: PopBentoCard(
                              title: "Safety Shield",
                              icon: "🛡️",
                              desc: "Biomechanical checks to prevent injury.",
                              color: AppColors.accentYellow,
                            ))),
                  ],
                )
              else
                FadeSlideIn(
                  delayMs: 300,
                  child: SizedBox(
                    height: 600,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: const PopBentoCard(
                            title: "Morphic UI",
                            icon: "🎨",
                            desc:
                                "Interface reshapes based on your bio-feedback. Calm during rest, high-contrast during peak sets.",
                            color: AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: const [
                              Expanded(
                                child: PopBentoCard(
                                  title: "Voice",
                                  icon: "🎙️",
                                  desc:
                                      "Powered by ElevenLabs for natural tone.",
                                  color: AppColors.accentPink,
                                ),
                              ),
                              SizedBox(height: 24),
                              Expanded(
                                child: PopBentoCard(
                                  title: "Soma",
                                  icon: "🧠",
                                  desc: "Constraint-aware routine planning.",
                                  color: AppColors.accentPurple,
                                  isDark: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: const PopBentoCard(
                            title: "Safety Shield",
                            icon: "🛡️",
                            desc:
                                "Real-time posture and load validation using local AI vision.",
                            color: AppColors.accentYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhilosophySection extends StatelessWidget {
  final bool isMobile;
  const PhilosophySection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.textDark,
        border: Border(
          top: BorderSide(color: AppColors.primaryTeal, width: 5),
          bottom: BorderSide(color: AppColors.primaryTeal, width: 5),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              FadeSlideIn(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Transform.rotate(
                      angle: -0.02,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 48, horizontal: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                              color: AppColors.borderBlack, width: 4),
                          boxShadow: const [
                            BoxShadow(
                                color: AppColors.borderBlack,
                                offset: Offset(10, 10))
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Fittie isn't an app—\nit's a presence.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: isMobile ? 28 : 48,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                                letterSpacing: -1,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: 60,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: Text(
                                "Open the website, sign up in seconds, and get a workout built around your body and energy—instantly.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  color: AppColors.textSoft,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -16,
                      left: isMobile ? 16 : 40,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.borderBlack, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                  color: AppColors.borderBlack,
                                  offset: Offset(3, 3))
                            ],
                          ),
                          child: Text("❝",
                              style: TextStyle(
                                fontSize: 28,
                                color: AppColors.textDark,
                                height: 1,
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -12,
                      right: isMobile ? 16 : 40,
                      child: Transform.rotate(
                        angle: 0.08,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentPink,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.borderBlack, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                  color: AppColors.borderBlack,
                                  offset: Offset(2, 2))
                            ],
                          ),
                          child: const Text("PHILOSOPHY",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: AppColors.textDark,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepsSection extends StatelessWidget {
  final bool isMobile;
  const StepsSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: Column(
            children: [
              FadeSlideIn(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.textDark,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(3, 3))
                    ],
                  ),
                  child: Text("THE WORKFLOW",
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2)),
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                  delayMs: 100,
                  child: Text("From Advice to Agency",
                      style: GoogleFonts.inter(
                          fontSize: isMobile ? 28 : 42,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark))),
              const SizedBox(height: 24),
              FadeSlideIn(
                  delayMs: 200,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Text(
                      "Three steps. That's all it takes to start flowing.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 17,
                          color: AppColors.textSoft,
                          height: 1.5,
                          fontWeight: FontWeight.w500),
                    ),
                  )),
              const SizedBox(height: 80),
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FadeSlideIn(
                      delayMs: 300,
                      child: const _StepItem(
                          "01", "Sign Up", "Create your account in seconds.",
                          color: AppColors.primaryTeal)),
                  if (!isMobile) const _StepConnector(),
                  if (isMobile) const SizedBox(height: 40),
                  FadeSlideIn(
                      delayMs: 450,
                      child: const _StepItem(
                          "02", "Set Your State", "Tell Fittie how you feel.",
                          color: AppColors.accentOrange)),
                  if (!isMobile) const _StepConnector(),
                  if (isMobile) const SizedBox(height: 40),
                  FadeSlideIn(
                      delayMs: 600,
                      child: const _StepItem(
                          "03", "Generate & Train", "Get today's workout. Go.",
                          color: AppColors.accentPurple)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.borderBlack, width: 4),
                boxShadow: const [
                  BoxShadow(
                      color: AppColors.borderBlack, offset: Offset(12, 12))
                ],
              ),
              child: Column(
                children: [
                  Text("Ready to flow?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1)),
                  const SizedBox(height: 16),
                  Text("Start your AI-powered fitness journey with Fittie.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 48),
                  SquishyButton(
                    label: "START FREE TRIAL",
                    isWhite: true,
                    isLarge: true,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()));
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: -14,
              right: 48,
              child: Transform.rotate(
                angle: 0.15,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(2, 2))
                    ],
                  ),
                  child: const Text("FREE \u2728",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: AppColors.textDark)),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: 40,
              child: Transform.rotate(
                angle: -0.12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentPink,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(2, 2))
                    ],
                  ),
                  child: const Text("NO CAP \uD83D\uDD25",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: AppColors.textDark)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  final bool isMobile;
  const FooterSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textDark,
      padding: const EdgeInsets.only(top: 80, bottom: 40, left: 24, right: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FittieLogo(size: 32, color: Colors.white),
                          const SizedBox(width: 12),
                          Text("Fittie",
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                          "The Agentic Fitness Companion\nthat Flows with You.",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              height: 1.5)),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: const [
                          _Badge(
                              label: "ElevenLabs TTS",
                              color: AppColors.accentOrange),
                          _Badge(
                              label: "Gemini AI",
                              color: AppColors.accentPurple),
                          _Badge(
                              label: "Firebase", color: AppColors.accentYellow),
                        ],
                      )
                    ],
                  ),
                  if (isMobile) const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FooterColumn(
                          title: "Product",
                          links: const ["Features", "Morphic UI", "Voice Coach"],
                          routes: {
                            "Features": () => const FeaturesPage(),
                            "Morphic UI": () => const MorphicUiPage(),
                            "Voice Coach": () => const VoiceCoachPage(),
                          }),
                      const SizedBox(width: 40),
                      _FooterColumn(
                          title: "Company",
                          links: const ["About", "Blog", "Careers"],
                          routes: {
                            "About": () => const AboutPage(),
                            "Blog": () => const BlogPage(),
                            "Careers": () => const CareersPage(),
                          }),
                      if (!isMobile) ...[
                        const SizedBox(width: 40),
                        _FooterColumn(
                            title: "Resources",
                            links: const ["Community", "Help Center"],
                            routes: {
                              "Community": () => const CommunityPage(),
                              "Help Center": () => const HelpCenterPage(),
                            }),
                      ]
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("© 2026 Fittie",
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(width: 8),
                  Text("·",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.25), fontSize: 13)),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Developed with ",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF027DFD),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            FlutterLogo(size: 14),
                            SizedBox(width: 4),
                            Text("Flutter",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 4. MASCOT IMPLEMENTATION ---
class KawaiiPolarBear extends StatefulWidget {
  final bool isTalking;
  const KawaiiPolarBear({super.key, this.isTalking = false});
  @override
  State<KawaiiPolarBear> createState() => _KawaiiPolarBearState();
}

class _KawaiiPolarBearState extends State<KawaiiPolarBear>
    with TickerProviderStateMixin {
  late AnimationController _idleCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _talkCtrl;

  @override
  void initState() {
    super.initState();
    _idleCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _blinkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _talkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    if (widget.isTalking) _talkCtrl.repeat(reverse: true);
    _startBlinking();
  }

  @override
  void didUpdateWidget(KawaiiPolarBear oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTalking != oldWidget.isTalking) {
      if (widget.isTalking)
        _talkCtrl.repeat(reverse: true);
      else
        _talkCtrl.reset();
    }
  }

  void _startBlinking() async {
    if (!mounted) return;
    while (mounted) {
      await Future.delayed(
          Duration(milliseconds: 2000 + math.Random().nextInt(3000)));
      if (mounted) {
        try {
          await _blinkCtrl.forward();
          await _blinkCtrl.reverse();
        } catch (e) {}
      }
    }
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _blinkCtrl.dispose();
    _talkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleCtrl, _blinkCtrl, _talkCtrl]),
      builder: (context, child) {
        final idleValue = Curves.easeInOutQuad.transform(_idleCtrl.value);
        return Transform.scale(
          scale: 1.0 + (0.02 * idleValue),
          child: CustomPaint(
            painter: _PolarBearPainter(
              idleValue: idleValue,
              blinkValue: _blinkCtrl.value,
              talkValue: _talkCtrl.value,
            ),
          ),
        );
      },
    );
  }
}

class _PolarBearPainter extends CustomPainter {
  final double idleValue;
  final double blinkValue;
  final double talkValue;

  _PolarBearPainter(
      {required this.idleValue,
      required this.blinkValue,
      required this.talkValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    final floatY = -5.0 * idleValue;
    _drawShadow(canvas, center, idleValue);
    canvas.save();
    canvas.translate(center.dx, center.dy + floatY);
    canvas.translate(-center.dx, -center.dy);
    final paint = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = BearColors.textDark
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _drawEar(canvas, center.translate(-95, -60), paint, stroke);
    _drawEar(canvas, center.translate(95, -60), paint, stroke);
    _drawCuteBody(canvas, center, paint, stroke);
    final headRect = Rect.fromCenter(center: center, width: 280, height: 190);
    paint.color = BearColors.furWhite;
    canvas.drawOval(headRect, paint);
    canvas.drawOval(headRect, stroke);
    _drawFace(canvas, center, paint, stroke);
    _drawArmWithDumbbell(
        canvas, center.translate(-90, 80), true, stroke, paint);
    _drawArmWithDumbbell(
        canvas, center.translate(90, 80), false, stroke, paint);
    canvas.restore();
  }

  void _drawShadow(Canvas canvas, Offset center, double lift) {
    final shadowPaint = Paint()
      ..color = const Color(0xFFCBD5E0).withOpacity(0.3 - (0.1 * lift))
      ..style = PaintingStyle.fill;
    final width = 140.0 - (15.0 * lift);
    canvas.drawOval(
        Rect.fromCenter(
            center: center.translate(0, 165), width: width, height: 20),
        shadowPaint);
  }

  void _drawEar(Canvas canvas, Offset pos, Paint paint, Paint stroke) {
    paint.color = BearColors.furWhite;
    canvas.drawCircle(pos, 36, paint);
    canvas.drawCircle(pos, 36, stroke);
    paint.color = BearColors.blush;
    canvas.drawOval(Rect.fromCenter(center: pos, width: 34, height: 34), paint);
  }

  void _drawCuteBody(Canvas canvas, Offset center, Paint paint, Paint stroke) {
    final bodyCenter = center.translate(0, 70);
    final path = Path();
    path.moveTo(bodyCenter.dx - 65, bodyCenter.dy - 40);
    path.quadraticBezierTo(bodyCenter.dx - 75, bodyCenter.dy + 40,
        bodyCenter.dx - 45, bodyCenter.dy + 85);
    path.quadraticBezierTo(bodyCenter.dx, bodyCenter.dy + 65,
        bodyCenter.dx + 45, bodyCenter.dy + 85);
    path.quadraticBezierTo(bodyCenter.dx + 75, bodyCenter.dy + 40,
        bodyCenter.dx + 65, bodyCenter.dy - 40);
    path.close();
    paint.color = BearColors.furWhite;
    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);
    paint.color = BearColors.bellyCream;
    canvas.drawOval(
        Rect.fromCenter(
            center: bodyCenter.translate(0, 30), width: 70, height: 55),
        paint);
  }

  void _drawFace(Canvas canvas, Offset center, Paint paint, Paint stroke) {
    paint.color = BearColors.blush;
    canvas.drawOval(
        Rect.fromCenter(
            center: center.translate(-90, 10), width: 45, height: 28),
        paint);
    canvas.drawOval(
        Rect.fromCenter(
            center: center.translate(90, 10), width: 45, height: 28),
        paint);
    _drawEye(canvas, center.translate(-55, -5), stroke, blinkValue);
    _drawEye(canvas, center.translate(55, -5), stroke, blinkValue);
    paint.color = BearColors.textDark;
    paint.style = PaintingStyle.fill;
    final noseCenter = center.translate(0, 10);
    final nosePath = Path()
      ..moveTo(noseCenter.dx - 12, noseCenter.dy - 6)
      ..quadraticBezierTo(noseCenter.dx, noseCenter.dy - 9, noseCenter.dx + 12,
          noseCenter.dy - 6)
      ..quadraticBezierTo(noseCenter.dx, noseCenter.dy + 10, noseCenter.dx - 12,
          noseCenter.dy - 6);
    canvas.drawPath(nosePath, paint);
    paint.style = PaintingStyle.stroke;
    stroke.strokeWidth = 4;
    final mouthY = noseCenter.dy + 10;
    if (talkValue > 0.1) {
      paint.style = PaintingStyle.fill;
      paint.color = BearColors.textDark;
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(center.dx, mouthY + 8),
              width: 18,
              height: 8.0 + (talkValue * 8.0)),
          paint);
    } else {
      final mouthPath = Path()
        ..moveTo(center.dx - 12, mouthY)
        ..quadraticBezierTo(center.dx - 6, mouthY + 10, center.dx, mouthY + 2)
        ..quadraticBezierTo(center.dx + 6, mouthY + 10, center.dx + 12, mouthY);
      canvas.drawPath(mouthPath, stroke);
    }
    stroke.strokeWidth = 6.0;
    paint.style = PaintingStyle.fill;
  }

  void _drawEye(Canvas canvas, Offset pos, Paint stroke, double blink) {
    if (blink > 0.1) {
      final p = Path()
        ..moveTo(pos.dx - 20, pos.dy + 5)
        ..quadraticBezierTo(pos.dx, pos.dy - 15, pos.dx + 20, pos.dy + 5);
      canvas.drawPath(p, stroke..strokeWidth = 5);
    } else {
      canvas.drawOval(Rect.fromCenter(center: pos, width: 30, height: 36),
          Paint()..color = BearColors.textDark);
      canvas.drawCircle(pos.translate(8, -8), 7, Paint()..color = Colors.white);
      canvas.drawCircle(pos.translate(-8, 8), 3,
          Paint()..color = Colors.white.withOpacity(0.8));
    }
  }

  void _drawArmWithDumbbell(
      Canvas canvas, Offset pos, bool isLeft, Paint stroke, Paint fill) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(isLeft ? 0.3 : -0.3);
    fill.color = BearColors.textSoft;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-20, -5, 40, 10), const Radius.circular(5)),
        fill);
    fill.color = BearColors.textDark;
    const wSize = Size(18, 40);
    _drawWeight(canvas, const Offset(-28, 0), wSize, fill, stroke);
    _drawWeight(canvas, const Offset(28, 0), wSize, fill, stroke);
    fill.color = BearColors.furWhite;
    canvas.drawCircle(Offset.zero, 20, fill);
    canvas.drawCircle(Offset.zero, 20, stroke);
    canvas.restore();
  }

  void _drawWeight(
      Canvas canvas, Offset center, Size size, Paint fill, Paint stroke) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: center, width: size.width, height: size.height),
            const Radius.circular(8)),
        fill);
  }

  @override
  bool shouldRepaint(_PolarBearPainter oldDelegate) => true;
}

// --- 5. LOGO & UTILS ---
class FittieLogo extends StatelessWidget {
  final double size;
  final Color color;
  const FittieLogo(
      {super.key, required this.size, this.color = AppColors.textDark});
  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(size, size), painter: _MascotLogoPainter(outlineColor: color));
}

class _MascotLogoPainter extends CustomPainter {
  final Color outlineColor;
  _MascotLogoPainter({required this.outlineColor});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center.translate(-size.width * 0.3, -size.width * 0.25),
        size.width * 0.15, paint);
    canvas.drawCircle(center.translate(-size.width * 0.3, -size.width * 0.25),
        size.width * 0.15, stroke);
    canvas.drawCircle(center.translate(size.width * 0.3, -size.width * 0.25),
        size.width * 0.15, paint);
    canvas.drawCircle(center.translate(size.width * 0.3, -size.width * 0.25),
        size.width * 0.15, stroke);
    canvas.drawOval(
        Rect.fromCenter(
            center: center, width: size.width * 0.9, height: size.height * 0.7),
        paint);
    canvas.drawOval(
        Rect.fromCenter(
            center: center, width: size.width * 0.9, height: size.height * 0.7),
        stroke);
    final eyePaint = Paint()..color = outlineColor;
    canvas.drawCircle(center.translate(-size.width * 0.18, -size.width * 0.05),
        size.width * 0.06, eyePaint);
    canvas.drawCircle(center.translate(size.width * 0.18, -size.width * 0.05),
        size.width * 0.06, eyePaint);
    canvas.drawOval(
        Rect.fromCenter(
            center: center.translate(0, size.height * 0.1),
            width: size.width * 0.12,
            height: size.width * 0.08),
        eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeroBadge extends StatelessWidget {
  const HeroBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.035,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: AppColors.accentYellow,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.borderBlack, width: 2.5),
            boxShadow: const [
              BoxShadow(color: AppColors.borderBlack, offset: Offset(3, 3))
            ]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryTeal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text("SOMA-LOGIC ENGINE V2",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: AppColors.textDark)),
        ]),
      ),
    );
  }
}

class PopBentoCard extends StatefulWidget {
  final String title, icon, desc;
  final Color? color;
  final bool isDark;
  final int flex;
  const PopBentoCard(
      {super.key,
      required this.title,
      required this.icon,
      required this.desc,
      this.color,
      this.isDark = false,
      this.flex = 1});
  @override
  State<PopBentoCard> createState() => _PopBentoCardState();
}

class _PopBentoCardState extends State<PopBentoCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : AppColors.textDark;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
            _hover ? (Matrix4.identity()..rotateZ(-0.012)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: widget.color ?? Colors.white,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
            border: Border.all(color: AppColors.borderBlack, width: 3),
            boxShadow: [
              BoxShadow(
                  color: AppColors.borderBlack,
                  offset: _hover ? const Offset(14, 14) : const Offset(8, 8))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Transform.rotate(
            angle: 0.05,
            child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderBlack, width: 3),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(3, 3))
                    ]),
                child: Text(widget.icon, style: const TextStyle(fontSize: 30))),
          ),
          const Spacer(),
          Text(widget.title,
              style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -1)),
          const SizedBox(height: 12),
          Text(widget.desc,
              style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class SquishyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLarge, isWhite, isSmall;
  const SquishyButton(
      {super.key,
      required this.label,
      this.onTap,
      this.isLarge = false,
      this.isWhite = false,
      this.isSmall = false});
  @override
  State<SquishyButton> createState() => _SquishyButtonState();
}

class _SquishyButtonState extends State<SquishyButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isWhite ? Colors.white : AppColors.primaryTeal;
    final txtColor = widget.isWhite ? AppColors.textDark : Colors.white;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: widget.isSmall ? 20 : 36,
              vertical: widget.isSmall ? 10 : 18),
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.borderBlack, width: 2.5),
              boxShadow: _pressed
                  ? []
                  : [
                      const BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(4, 4))
                    ]),
          child: Text(widget.label,
              style: GoogleFonts.inter(
                  color: txtColor,
                  fontWeight: FontWeight.w900,
                  fontSize: widget.isLarge ? 16 : 13,
                  letterSpacing: 1.0)),
        ),
      ),
    );
  }
}

class BackgroundBlobs extends StatelessWidget {
  final Animation<double> animation;
  const BackgroundBlobs({super.key, required this.animation});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final val = animation.value * 2 * math.pi;
        return Stack(children: [
          Positioned(
              top: -100 + (math.sin(val) * 30),
              right: -100 + (math.cos(val) * 30),
              child: const _Blob(size: 600, color: Color(0xFFE6FFFA))),
          Positioned(
              bottom: 100 + (math.cos(val) * 40),
              left: -50 + (math.sin(val) * 40),
              child: const _Blob(size: 500, color: Color(0xFFFFF5F7))),
        ]);
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: color.withOpacity(0.6), shape: BoxShape.circle),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(color: Colors.transparent)));
  }
}

class PopFloatingCard extends StatefulWidget {
  final String icon, label, value;
  const PopFloatingCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});
  @override
  State<PopFloatingCard> createState() => _PopFloatingCardState();
}

class _PopFloatingCardState extends State<PopFloatingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, child) {
        final val = Curves.easeInOut.transform(_floatCtrl.value);
        return Transform.translate(
          offset: Offset(0, -6 * val),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderBlack, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(5, 5))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textSoft,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(widget.value,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TapeStripDivider extends StatelessWidget {
  const _TapeStripDivider();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.015,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.accentYellow,
          border: Border.symmetric(
            horizontal: BorderSide(color: AppColors.borderBlack, width: 3),
          ),
          boxShadow: [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _TapeWord("ADAPTIVE"),
            _TapeStar(),
            _TapeWord("AI-NATIVE"),
            _TapeStar(),
            _TapeWord("BIO-AWARE"),
            _TapeStar(),
            _TapeWord("REAL-TIME"),
            _TapeStar(),
            _TapeWord("ZERO FRICTION"),
          ],
        ),
      ),
    );
  }
}

class _TapeWord extends StatelessWidget {
  final String text;
  const _TapeWord(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: 2)),
      );
}

class _TapeStar extends StatelessWidget {
  const _TapeStar();
  @override
  Widget build(BuildContext context) => const Text("\u2726",
      style: TextStyle(
          color: AppColors.borderBlack,
          fontSize: 14,
          fontWeight: FontWeight.w900));
}

class _StepItem extends StatelessWidget {
  final String num, title, desc;
  final Color color;
  const _StepItem(this.num, this.title, this.desc,
      {this.color = AppColors.primaryTeal});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderBlack, width: 3),
              boxShadow: const [
                BoxShadow(color: AppColors.borderBlack, offset: Offset(5, 5))
              ],
            ),
            child: Column(
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.textDark)),
                const SizedBox(height: 10),
                Text(desc,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.4)),
              ],
            ),
          ),
          Positioned(
            top: -18,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: -0.06,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(3, 3))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(num,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();
  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dashCount = (constraints.maxWidth / 14).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    dashCount,
                    (_) => Container(
                          width: 8,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.borderBlack.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )),
              );
            },
          ),
        ),
      );
}

class _StatRow extends StatelessWidget {
  const _StatRow();
  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 24, runSpacing: 16, children: const [
        _StatItem("2s", "Generation", accentColor: AppColors.primaryTeal),
        _StatItem("100%", "Biological", accentColor: AppColors.accentOrange),
        _StatItem("24/7", "Always On", accentColor: AppColors.accentPurple),
      ]);
}

class _StatItem extends StatelessWidget {
  final String val, label;
  final Color accentColor;
  const _StatItem(this.val, this.label,
      {this.accentColor = AppColors.primaryTeal});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderBlack, width: 2.5),
          boxShadow: const [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(val,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: accentColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSoft,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
        ]),
      );
}

class DotGridBackground extends StatelessWidget {
  const DotGridBackground({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DotPainter());
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textSoft.withOpacity(0.12);
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 4000; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      paint.color = AppColors.borderBlack.withOpacity(rng.nextDouble() * 0.025);
      canvas.drawCircle(Offset(x, y), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  final Map<String, Widget Function()>? routes;
  const _FooterColumn({required this.title, required this.links, this.routes});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5)),
        const SizedBox(height: 20),
        ...links.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
                onTap: () {
                  final builder = routes?[l];
                  if (builder != null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => builder()));
                  }
                },
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(l,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14))))))
      ]);
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderBlack, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(2, 2))
          ]),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 11,
              fontWeight: FontWeight.w900)));
}

class GoogleFonts {
  static TextStyle inter(
      {Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      double? letterSpacing,
      double? height,
      FontStyle? fontStyle}) {
    return TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
        fontFamily: 'Inter');
  }
}
