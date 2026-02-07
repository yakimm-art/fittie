import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'features_page.dart';
import 'blog_page.dart';
import 'about_page.dart';

/// Shared neo-brutalist page shell used by all sub-pages.
/// Provides: dot-grid background, grain texture, sticky header, footer, and scrollable body.
class BrutalistPageShell extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Widget> slivers;
  final List<Widget>? children;
  const BrutalistPageShell({
    super.key,
    required this.title,
    this.subtitle,
    this.slivers = const [],
    this.children,
  });

  @override
  State<BrutalistPageShell> createState() => _BrutalistPageShellState();
}

class _BrutalistPageShellState extends State<BrutalistPageShell> {
  final ScrollController _scroll = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.offset != _scrollOffset) {
        setState(() => _scrollOffset = _scroll.offset);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 900;
      final body = widget.children ?? [];

      return Scaffold(
        backgroundColor: AppColors.bgCream,
        body: Stack(
          children: [
            const Positioned.fill(child: DotGridBackground()),
            SingleChildScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 80 : 100),
                  // Page title hero
                  _PageHero(
                    title: widget.title,
                    subtitle: widget.subtitle,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 60),
                  ...body,
                  _ShellFooter(isMobile: isMobile),
                ],
              ),
            ),
            // Grain texture
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ShellGrainPainter(),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PopHeader(scrollOffset: _scrollOffset, isMobile: isMobile),
            ),
          ],
        ),
      );
    });
  }
}

class _PageHero extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isMobile;
  const _PageHero({required this.title, this.subtitle, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.borderBlack, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.borderBlack, offset: Offset(3, 3))
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_rounded,
                            size: 18, color: AppColors.textDark),
                        const SizedBox(width: 6),
                        Text("Back",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Decorative bar
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 36 : 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -2,
                  height: 1.1,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 16),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 16 : 18,
                    color: AppColors.textSoft,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellFooter extends StatelessWidget {
  final bool isMobile;
  const _ShellFooter({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textDark,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      FittieLogo(size: 28, color: Colors.white),
                      const SizedBox(width: 10),
                      Text("Fittie",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                  if (!isMobile)
                    Row(
                      children: [
                        _FooterLink("Home", () => Navigator.of(context).popUntil((r) => r.isFirst)),
                        _FooterLink("Features", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeaturesPage()))),
                        _FooterLink("Blog", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlogPage()))),
                        _FooterLink("About", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()))),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("© 2026 Fittie. All rights reserved.",
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Built with ",
                          style: TextStyle(color: Colors.white38, fontSize: 12)),
                      const FlutterLogo(size: 14),
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

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink(this.label, this.onTap);
  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(widget.label,
              style: GoogleFonts.inter(
                color: _hov ? AppColors.primaryTeal : Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }
}

/// Brutalist section card — a white card container with thick border and shadow.
class BrutalistCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  const BrutalistCard({super.key, required this.child, this.color, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderBlack, width: 3),
        boxShadow: const [
          BoxShadow(color: AppColors.borderBlack, offset: Offset(6, 6))
        ],
      ),
      child: child,
    );
  }
}

/// Brutalist section label tag (e.g. "THE ENGINE", "OUR STORY")
class BrutalistTag extends StatelessWidget {
  final String label;
  final Color color;
  const BrutalistTag(
      {super.key, required this.label, this.color = AppColors.primaryTeal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderBlack, width: 2.5),
        boxShadow: const [
          BoxShadow(color: AppColors.borderBlack, offset: Offset(3, 3))
        ],
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2)),
    );
  }
}

class _ShellGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint();
    for (int i = 0; i < 3000; i++) {
      paint.color = Colors.black.withOpacity(rng.nextDouble() * 0.025);
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Horizontal tape-strip divider for sub-pages.
class TapeStripDivider extends StatelessWidget {
  final List<String> words;
  final Color color;
  const TapeStripDivider({
    super.key,
    this.words = const ["ADAPTIVE", "AI-NATIVE", "BIO-AWARE", "REAL-TIME"],
    this.color = AppColors.accentYellow,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.018,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          border: Border.symmetric(
            horizontal: BorderSide(color: AppColors.borderBlack, width: 2.5),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: List.generate(
              8,
              (i) => Row(
                children: [
                  Text(
                    words[i % words.length],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("✦",
                        style: TextStyle(
                            fontSize: 12, color: AppColors.borderBlack)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
