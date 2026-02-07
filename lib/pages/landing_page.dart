import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

// --- 1. THEME ENGINE ---
class AppColors {
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

// --- 2. LANDING PAGE ---

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _blobController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _scrollController.addListener(() {
      final isOffset = _scrollController.offset > 20;
      if (isOffset != _isScrolled) setState(() => _isScrolled = isOffset);
    });
  }

  @override
  void dispose() {
    _blobController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: AppColors.bgCream,
          body: Stack(
            children: [
              const Positioned.fill(child: DotGridBackground()),
              // FIX: Wrapped in Positioned.fill to ensure blobs render across the background
              Positioned.fill(child: BackgroundBlobs(animation: _blobController)),
              
              SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: isMobile ? 120 : 160), 
                    HeroSection(isMobile: isMobile),
                    const SizedBox(height: 100),
                    FeaturesSection(isMobile: isMobile),
                    const SizedBox(height: 100),
                    PhilosophySection(isMobile: isMobile),
                    const SizedBox(height: 100),
                    StepsSection(isMobile: isMobile),
                    const SizedBox(height: 80),
                    const CTASection(),
                    FooterSection(isMobile: isMobile),
                  ],
                ),
              ),
              
              Positioned(
                top: 0, left: 0, right: 0,
                child: PopHeader(isScrolled: _isScrolled, isMobile: isMobile),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- 3. SECTIONS ---

class PopHeader extends StatelessWidget {
  final bool isScrolled;
  final bool isMobile;
  const PopHeader({super.key, required this.isScrolled, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
        margin: EdgeInsets.only(top: isMobile ? 16 : 24, left: 16, right: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 8 : 12, 
            horizontal: isScrolled ? (isMobile ? 16 : 24) : 8
          ),
          decoration: isScrolled
              ? BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppColors.borderBlack, width: 2.5),
                  boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(0, 5))],
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FittieLogo(size: isMobile ? 32 : 40),
                  const SizedBox(width: 12),
                  Text(
                    "Fittie", 
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900, 
                      color: AppColors.textDark, 
                      fontSize: isMobile ? 22 : 26,
                      letterSpacing: -1,
                    )
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      isMobile ? "Log In" : "LOGIN", 
                      style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 13)
                    ),
                  ),
                  const SizedBox(width: 8),
                  SquishyButton(
                    label: isMobile ? "START" : "GET STARTED",
                    isSmall: true,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                    },
                  ),
                ],
              )
            ],
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
            ? Column(children: [const _HeroVisualContent(isMobile: true), const SizedBox(height: 40), _HeroTextContent(isMobile: true, center: true)])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: _HeroTextContent(isMobile: false, center: false)),
                  const SizedBox(width: 60),
                  const Expanded(flex: 4, child: _HeroVisualContent(isMobile: false)),
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
    final crossAlign = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        const HeroBadge(),
        const SizedBox(height: 24),
        RichText(
          textAlign: align,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: isMobile ? 42 : 82, 
              fontWeight: FontWeight.w900, 
              color: AppColors.textDark, 
              height: 0.95,
              letterSpacing: -2,
            ),
            children: [
              const TextSpan(text: "The Agent\nthat "),
              TextSpan(
                text: "Flows",
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                ),
              ),
              const TextSpan(text: " with You."),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Stop following static plans. Fittie adapts your routine to your energy, environment, and heart rate—real-time.",
          textAlign: align,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 18 : 22,
            color: AppColors.textSoft, 
            height: 1.5, 
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 40),
        SquishyButton(
          label: "START TRAINING FREE", 
          isLarge: !isMobile,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
          },
        ),
        const SizedBox(height: 48),
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
    final mascotSize = isMobile ? 280.0 : 400.0;

    return SizedBox(
      height: mascotSize + 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: mascotSize * 1.15,
            height: mascotSize * 1.15,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderBlack, width: 2),
            ),
          ),
          SizedBox(
            height: mascotSize, 
            width: mascotSize, 
            child: const KawaiiPolarBear(isTalking: false),
          ), 
          Positioned(
            top: 20, left: 0,
            child: const PopFloatingCard(icon: "⚡", label: "Recovery", value: "88%")
          ),
          Positioned(
            bottom: 40, right: 0,
            child: const PopFloatingCard(icon: "🔥", label: "Readiness", value: "Optimal")
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
              Text("THE ENGINE", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryTeal, letterSpacing: 2)),
              const SizedBox(height: 16),
              Text("Biological Logic.", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: isMobile ? 36 : 56, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -2)),
              const SizedBox(height: 64),
              
              if (isMobile)
                Column(
                  children: const [
                    // FIX: Wrapped in SizedBox to provide height constraints for internal Spacers
                    SizedBox(height: 280, child: PopBentoCard(
                      title: "Morphic UI",
                      icon: "🎨",
                      desc: "The interface reshapes based on your focus level.",
                      color: AppColors.primaryLight,
                    )),
                    SizedBox(height: 20),
                    SizedBox(height: 280, child: PopBentoCard(
                      title: "Voice Coach",
                      icon: "🎙️",
                      desc: "Real-time AI guidance that listens to your breath.",
                      color: AppColors.accentPink,
                    )),
                    SizedBox(height: 20),
                    SizedBox(height: 280, child: PopBentoCard(
                      title: "Safety Shield",
                      icon: "🛡️",
                      desc: "Biomechanical checks to prevent injury.",
                      color: AppColors.accentYellow,
                    )),
                  ],
                )
              else
                SizedBox(
                  height: 600,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: const PopBentoCard(
                          title: "Morphic UI",
                          icon: "🎨",
                          desc: "Interface reshapes based on your bio-feedback. Calm during rest, high-contrast during peak sets.",
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
                                desc: "Powered by ElevenLabs for natural tone.",
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
                          desc: "Real-time posture and load validation using local AI vision.",
                          color: AppColors.accentYellow,
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
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome, size: 64, color: AppColors.primaryTeal),
              const SizedBox(height: 40),
              Text(
                "Fittie isn't an app—it's a presence.", 
                textAlign: TextAlign.center, 
                style: GoogleFonts.inter(fontSize: isMobile ? 32 : 54, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)
              ),
              const SizedBox(height: 40),
              Text(
                "Lives at a URL. Scan a QR code at the gym and start your session instantly. No downloads. No friction. Just performance.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 18, color: Colors.white.withOpacity(0.7), height: 1.6, fontWeight: FontWeight.w500),
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
              Text("THE WORKFLOW", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textSoft, letterSpacing: 2)),
              const SizedBox(height: 16),
              Text("From Advice to Agency", style: GoogleFonts.inter(fontSize: isMobile ? 28 : 42, fontWeight: FontWeight.w900, color: AppColors.textDark)),
              const SizedBox(height: 80),
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _StepItem("01", "Scan & Sync", "Instant PWA load via QR."),
                  if (!isMobile) const _StepConnector(),
                  const _StepItem("02", "Report State", "Tell Fittie how you feel."),
                  if (!isMobile) const _StepConnector(),
                  const _StepItem("03", "Morph & Train", "UI adapts. You train."),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          padding: const EdgeInsets.all(60),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.borderBlack, width: 4),
            boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(12, 12))],
          ),
          child: Column(
            children: [
              Text("Ready to flow?", textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Text("Join 50,000+ athletes flowing with Fittie.", textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 48),
              SquishyButton(
                label: "START FREE TRIAL", 
                isWhite: true, 
                isLarge: true, 
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                },
              ),
            ],
          ),
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
                          Text("Fittie", style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text("The Agentic Fitness Companion\nthat Flows with You.", style: TextStyle(color: Colors.white.withOpacity(0.6), height: 1.5)),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          _Badge(label: "ElevenLabs for Fittie", color: AppColors.accentOrange),
                          SizedBox(width: 10),
                          _Badge(label: "Native Dreamflow", color: AppColors.accentPurple),
                        ],
                      )
                    ],
                  ),
                  if(isMobile) const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FooterColumn(title: "Product", links: ["Features", "Morphic UI", "Voice Coach"]),
                      const SizedBox(width: 40),
                      const _FooterColumn(title: "Company", links: ["About", "Blog", "Careers"]),
                      if(!isMobile) ...[
                        const SizedBox(width: 40),
                        const _FooterColumn(title: "Resources", links: ["Community", "Help Center"]),
                      ]
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 24),
              const Text("© 2026 Fittie. Built with 💖 for Dreamflow Buildathon.", style: TextStyle(color: Colors.white54, fontSize: 13)),
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

class _KawaiiPolarBearState extends State<KawaiiPolarBear> with TickerProviderStateMixin {
  late AnimationController _idleCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _talkCtrl; 

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _talkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    if (widget.isTalking) _talkCtrl.repeat(reverse: true);
    _startBlinking();
  }

  @override
  void didUpdateWidget(KawaiiPolarBear oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTalking != oldWidget.isTalking) {
      if (widget.isTalking) _talkCtrl.repeat(reverse: true);
      else _talkCtrl.reset(); 
    }
  }

  void _startBlinking() async {
    if (!mounted) return;
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)));
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

  _PolarBearPainter({required this.idleValue, required this.blinkValue, required this.talkValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10); 
    final floatY = -5.0 * idleValue; 
    _drawShadow(canvas, center, idleValue);
    canvas.save();
    canvas.translate(center.dx, center.dy + floatY);
    canvas.translate(-center.dx, -center.dy);
    final paint = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()..style = PaintingStyle.stroke..color = BearColors.textDark..strokeWidth = 6.0..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    _drawEar(canvas, center.translate(-95, -60), paint, stroke);
    _drawEar(canvas, center.translate(95, -60), paint, stroke);
    _drawCuteBody(canvas, center, paint, stroke);
    final headRect = Rect.fromCenter(center: center, width: 280, height: 190);
    paint.color = BearColors.furWhite;
    canvas.drawOval(headRect, paint);
    canvas.drawOval(headRect, stroke);
    _drawFace(canvas, center, paint, stroke);
    _drawArmWithDumbbell(canvas, center.translate(-90, 80), true, stroke, paint);
    _drawArmWithDumbbell(canvas, center.translate(90, 80), false, stroke, paint);
    canvas.restore();
  }

  void _drawShadow(Canvas canvas, Offset center, double lift) {
    final shadowPaint = Paint()..color = const Color(0xFFCBD5E0).withOpacity(0.3 - (0.1 * lift))..style = PaintingStyle.fill;
    final width = 140.0 - (15.0 * lift);
    canvas.drawOval(Rect.fromCenter(center: center.translate(0, 165), width: width, height: 20), shadowPaint);
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
    path.quadraticBezierTo(bodyCenter.dx - 75, bodyCenter.dy + 40, bodyCenter.dx - 45, bodyCenter.dy + 85);
    path.quadraticBezierTo(bodyCenter.dx, bodyCenter.dy + 65, bodyCenter.dx + 45, bodyCenter.dy + 85);
    path.quadraticBezierTo(bodyCenter.dx + 75, bodyCenter.dy + 40, bodyCenter.dx + 65, bodyCenter.dy - 40);
    path.close();
    paint.color = BearColors.furWhite;
    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);
    paint.color = BearColors.bellyCream;
    canvas.drawOval(Rect.fromCenter(center: bodyCenter.translate(0, 30), width: 70, height: 55), paint);
  }

  void _drawFace(Canvas canvas, Offset center, Paint paint, Paint stroke) {
    paint.color = BearColors.blush;
    canvas.drawOval(Rect.fromCenter(center: center.translate(-90, 10), width: 45, height: 28), paint);
    canvas.drawOval(Rect.fromCenter(center: center.translate(90, 10), width: 45, height: 28), paint);
    _drawEye(canvas, center.translate(-55, -5), stroke, blinkValue);
    _drawEye(canvas, center.translate(55, -5), stroke, blinkValue);
    paint.color = BearColors.textDark; paint.style = PaintingStyle.fill;
    final noseCenter = center.translate(0, 10);
    final nosePath = Path()..moveTo(noseCenter.dx - 12, noseCenter.dy - 6)..quadraticBezierTo(noseCenter.dx, noseCenter.dy - 9, noseCenter.dx + 12, noseCenter.dy - 6)..quadraticBezierTo(noseCenter.dx, noseCenter.dy + 10, noseCenter.dx - 12, noseCenter.dy - 6);
    canvas.drawPath(nosePath, paint);
    paint.style = PaintingStyle.stroke; stroke.strokeWidth = 4;
    final mouthY = noseCenter.dy + 10;
    if (talkValue > 0.1) {
      paint.style = PaintingStyle.fill; paint.color = BearColors.textDark; 
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, mouthY + 8), width: 18, height: 8.0 + (talkValue * 8.0)), paint);
    } else {
      final mouthPath = Path()..moveTo(center.dx - 12, mouthY)..quadraticBezierTo(center.dx - 6, mouthY + 10, center.dx, mouthY + 2)..quadraticBezierTo(center.dx + 6, mouthY + 10, center.dx + 12, mouthY);
      canvas.drawPath(mouthPath, stroke);
    }
    stroke.strokeWidth = 6.0; paint.style = PaintingStyle.fill;
  }

  void _drawEye(Canvas canvas, Offset pos, Paint stroke, double blink) {
    if (blink > 0.1) {
      final p = Path()..moveTo(pos.dx - 20, pos.dy + 5)..quadraticBezierTo(pos.dx, pos.dy - 15, pos.dx + 20, pos.dy + 5);
      canvas.drawPath(p, stroke..strokeWidth = 5);
    } else {
      canvas.drawOval(Rect.fromCenter(center: pos, width: 30, height: 36), Paint()..color = BearColors.textDark);
      canvas.drawCircle(pos.translate(8, -8), 7, Paint()..color = Colors.white);
      canvas.drawCircle(pos.translate(-8, 8), 3, Paint()..color = Colors.white.withOpacity(0.8));
    }
  }

  void _drawArmWithDumbbell(Canvas canvas, Offset pos, bool isLeft, Paint stroke, Paint fill) {
    canvas.save(); canvas.translate(pos.dx, pos.dy); canvas.rotate(isLeft ? 0.3 : -0.3);
    fill.color = BearColors.textSoft; canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-20, -5, 40, 10), const Radius.circular(5)), fill);
    fill.color = BearColors.textDark; const wSize = Size(18, 40);
    _drawWeight(canvas, const Offset(-28, 0), wSize, fill, stroke); _drawWeight(canvas, const Offset(28, 0), wSize, fill, stroke);
    fill.color = BearColors.furWhite; canvas.drawCircle(Offset.zero, 20, fill); canvas.drawCircle(Offset.zero, 20, stroke);
    canvas.restore();
  }

  void _drawWeight(Canvas canvas, Offset center, Size size, Paint fill, Paint stroke) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size.width, height: size.height), const Radius.circular(8)), fill);
  }

  @override bool shouldRepaint(_PolarBearPainter oldDelegate) => true;
}

// --- 5. LOGO & UTILS ---
class FittieLogo extends StatelessWidget {
  final double size;
  final Color color;
  const FittieLogo({super.key, required this.size, this.color = AppColors.textDark});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(size, size), painter: _MascotLogoPainter(outlineColor: color));
}

class _MascotLogoPainter extends CustomPainter {
  final Color outlineColor;
  _MascotLogoPainter({required this.outlineColor});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final stroke = Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = size.width * 0.08..strokeCap = StrokeCap.round;
    canvas.drawCircle(center.translate(-size.width * 0.3, -size.width * 0.25), size.width * 0.15, paint);
    canvas.drawCircle(center.translate(-size.width * 0.3, -size.width * 0.25), size.width * 0.15, stroke);
    canvas.drawCircle(center.translate(size.width * 0.3, -size.width * 0.25), size.width * 0.15, paint);
    canvas.drawCircle(center.translate(size.width * 0.3, -size.width * 0.25), size.width * 0.15, stroke);
    canvas.drawOval(Rect.fromCenter(center: center, width: size.width * 0.9, height: size.height * 0.7), paint);
    canvas.drawOval(Rect.fromCenter(center: center, width: size.width * 0.9, height: size.height * 0.7), stroke);
    final eyePaint = Paint()..color = outlineColor;
    canvas.drawCircle(center.translate(-size.width * 0.18, -size.width * 0.05), size.width * 0.06, eyePaint);
    canvas.drawCircle(center.translate(size.width * 0.18, -size.width * 0.05), size.width * 0.06, eyePaint);
    canvas.drawOval(Rect.fromCenter(center: center.translate(0, size.height * 0.1), width: size.width * 0.12, height: size.width * 0.08), eyePaint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeroBadge extends StatelessWidget {
  const HeroBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.borderBlack, width: 2), boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(3, 3))]),
      child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryTeal), SizedBox(width: 8), Text("SOMA-LOGIC ENGINE V2", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))]),
    );
  }
}

class PopBentoCard extends StatefulWidget {
  final String title, icon, desc;
  final Color? color;
  final bool isDark;
  final int flex;
  const PopBentoCard({super.key, required this.title, required this.icon, required this.desc, this.color, this.isDark = false, this.flex = 1});
  @override State<PopBentoCard> createState() => _PopBentoCardState();
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
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: widget.color ?? Colors.white, borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge), border: Border.all(color: AppColors.borderBlack, width: 2.5), boxShadow: [BoxShadow(color: AppColors.borderBlack, offset: _hover ? const Offset(8, 8) : const Offset(5, 5))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.borderBlack, width: 2)), child: Text(widget.icon, style: const TextStyle(fontSize: 28))),
          const Spacer(),
          Text(widget.title, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1)),
          const SizedBox(height: 12),
          Text(widget.desc, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 15, height: 1.4, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class SquishyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLarge, isWhite, isSmall;
  const SquishyButton({super.key, required this.label, this.onTap, this.isLarge = false, this.isWhite = false, this.isSmall = false});
  @override State<SquishyButton> createState() => _SquishyButtonState();
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
          padding: EdgeInsets.symmetric(horizontal: widget.isSmall ? 20 : 36, vertical: widget.isSmall ? 10 : 18),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppColors.borderBlack, width: 2.5), boxShadow: _pressed ? [] : [const BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))]),
          child: Text(widget.label, style: GoogleFonts.inter(color: txtColor, fontWeight: FontWeight.w900, fontSize: widget.isLarge ? 16 : 13, letterSpacing: 1.0)),
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
          Positioned(top: -100 + (math.sin(val) * 30), right: -100 + (math.cos(val) * 30), child: const _Blob(size: 600, color: Color(0xFFE6FFFA))),
          Positioned(bottom: 100 + (math.cos(val) * 40), left: -50 + (math.sin(val) * 40), child: const _Blob(size: 500, color: Color(0xFFFFF5F7))),
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
    return Container(width: size, height: size, decoration: BoxDecoration(color: color.withOpacity(0.6), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90), child: Container(color: Colors.transparent)));
  }
}

class PopFloatingCard extends StatelessWidget {
  final String icon, label, value;
  const PopFloatingCard({super.key, required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.borderBlack, width: 2), boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(5, 5))]), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(icon, style: const TextStyle(fontSize: 24)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSoft)), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark, fontSize: 16))])]));
  }
}

class _StepItem extends StatelessWidget {
  final String num, title, desc;
  const _StepItem(this.num, this.title, this.desc);
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 220, child: Column(children: [Container(width: 70, height: 70, decoration: BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle, border: Border.all(color: AppColors.borderBlack, width: 3), boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(5, 5))]), alignment: Alignment.center, child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900))), const SizedBox(height: 24), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textDark)), const SizedBox(height: 12), Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w600))]));
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();
  @override
  Widget build(BuildContext context) => Expanded(child: Container(height: 3, margin: const EdgeInsets.only(bottom: 100), decoration: BoxDecoration(color: AppColors.borderBlack.withOpacity(0.1), borderRadius: BorderRadius.circular(10))));
}

class _StatRow extends StatelessWidget {
  const _StatRow();
  @override
  Widget build(BuildContext context) => Wrap(spacing: 32, runSpacing: 20, children: const [_StatItem("2s", "Generation"), _StatItem("100%", "Biological"), _StatItem("Zero", "Friction")]);
}

class _StatItem extends StatelessWidget {
  final String val, label;
  const _StatItem(this.val, this.label);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.textDark)), Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSoft, fontWeight: FontWeight.w700))]);
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
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  const _FooterColumn({required this.title, required this.links});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)), const SizedBox(height: 20), ...links.map((l) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(l, style: const TextStyle(color: Colors.white, fontSize: 14))))]);
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.5))), child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)));
}

class GoogleFonts {
  static TextStyle inter({Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing, double? height}) {
    return TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight, letterSpacing: letterSpacing, height: height, fontFamily: 'Inter');
  }
}