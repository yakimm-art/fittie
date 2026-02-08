import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';
import 'signup_page.dart'
    hide AppColors, GoogleFonts, SquishyButton, DotGridBackground;

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Features",
      subtitle:
          "Powered by Gemini 3 Flash — every feature is designed to make your training smarter, not harder.",
      children: [
        _HowItWorks(),
        const SizedBox(height: 56),
        _FeaturesList(),
        const SizedBox(height: 56),
        _TechStack(),
        const SizedBox(height: 56),
        _ComparisonSection(),
        const SizedBox(height: 56),
        _FeaturesCTA(),
        const SizedBox(height: 80),
      ],
    );
  }
}

// --- HOW IT WORKS ---
class _HowItWorks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step(
          "1",
          "Tell us about you",
          "Age, goals, equipment, injuries — a quick calibration so AI knows your body.",
          Icons.person_search_rounded,
          AppColors.primaryTeal),
      _Step(
          "2",
          "Get your plan",
          "Gemini 3 Flash builds a unique workout from your profile, energy, and 50-session history.",
          Icons.auto_awesome_rounded,
          AppColors.accentPurple),
      _Step(
          "3",
          "Train with AI",
          "Chat with an AI coach that remembers every conversation, or scan your gym for equipment-matched routines.",
          Icons.smart_toy_rounded,
          AppColors.accentOrange),
      _Step(
          "4",
          "Watch yourself grow",
          "Progressive overload tracking, analytics, and AI-adjusted plans week over week.",
          Icons.trending_up_rounded,
          AppColors.accentYellow),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: const BrutalistTag(
                    label: "HOW IT WORKS", color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delayMs: 50,
                child: Text(
                  "From sign-up to gains in four steps.",
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.5),
                ),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 700;
                final cards = steps
                    .asMap()
                    .entries
                    .map((e) => FadeSlideIn(
                          delayMs: e.key * 100,
                          child: _StepCard(step: e.value),
                        ))
                    .toList();

                if (isMobile) {
                  return Column(
                    children: cards
                        .map((w) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: w))
                        .toList(),
                  );
                }
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: cards
                      .map((w) =>
                          SizedBox(width: (c.maxWidth - 60) / 4, child: w))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step {
  final String num, title, desc;
  final IconData icon;
  final Color color;
  _Step(this.num, this.title, this.desc, this.icon, this.color);
}

class _StepCard extends StatefulWidget {
  final _Step step;
  const _StepCard({required this.step});
  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final so = _hov ? 10.0 : 6.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_hov ? -2 : 0, _hov ? -2 : 0, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderBlack, width: 3),
          boxShadow: [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(so, so))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.step.color,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(2, 2))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(widget.step.num,
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.step.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.step.icon,
                      size: 22, color: widget.step.color),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(widget.step.title,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(widget.step.desc,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSoft, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// --- FEATURES LIST ---
class _FeaturesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      _F(
        icon: Icons.auto_awesome_rounded,
        tag: "AI-NATIVE",
        tagColor: AppColors.primaryTeal,
        title: "Gemini 3 workout generation",
        desc:
            "Every workout is uniquely generated by Gemini 3 Flash using your profile, energy level, equipment, and full 50-session history. No two sessions repeat.",
        highlight: "Powered by Gemini 3 Flash",
      ),
      _F(
        icon: Icons.camera_alt_rounded,
        tag: "VISION",
        tagColor: AppColors.accentPurple,
        title: "Gym equipment scanner",
        desc:
            "Take a photo of your gym and Gemini Vision identifies every piece of equipment, then generates a workout matched to what's available.",
        highlight: "Multimodal AI",
      ),
      _F(
        icon: Icons.smart_toy_rounded,
        tag: "AI COACH",
        tagColor: AppColors.accentOrange,
        title: "Persistent chat memory",
        desc:
            "Chat with an AI fitness coach that remembers every conversation. It knows your history, preferences, and goals across sessions.",
        highlight: "Context-aware coaching",
      ),
      _F(
        icon: Icons.timeline_rounded,
        tag: "LONG CONTEXT",
        tagColor: const Color(0xFFE53E3E),
        title: "50-session progression analysis",
        desc:
            "Gemini analyzes your last 50 workouts to detect plateaus, muscle imbalances, and volume trends — then adjusts your next session accordingly.",
        highlight: "Deep history analysis",
      ),
      _F(
        icon: Icons.insights_rounded,
        tag: "ANALYTICS",
        tagColor: AppColors.accentYellow,
        title: "Real-time workout analytics",
        desc:
            "Track volume, streaks, and progress with interactive charts. See your training patterns and celebrate milestones.",
        highlight: "Visual dashboards",
      ),
      _F(
        icon: Icons.devices_rounded,
        tag: "CROSS-PLATFORM",
        tagColor: AppColors.accentPink,
        title: "Runs everywhere",
        desc:
            "Built with Flutter for iOS, Android, and web. Firebase syncs your data across all devices seamlessly.",
        highlight: "Flutter + Firebase",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: const BrutalistTag(label: "ALL FEATURES"),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                if (isMobile) {
                  return Column(
                    children: features
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: FadeSlideIn(
                                delayMs: e.key * 80,
                                child: _FeatureCard(f: e.value),
                              ),
                            ))
                        .toList(),
                  );
                }
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: features
                      .asMap()
                      .entries
                      .map((e) => SizedBox(
                            width: (constraints.maxWidth - 24) / 2,
                            child: FadeSlideIn(
                              delayMs: e.key * 80,
                              child: _FeatureCard(f: e.value),
                            ),
                          ))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _F {
  final IconData icon;
  final String tag;
  final Color tagColor;
  final String title;
  final String desc;
  final String highlight;
  _F({
    required this.icon,
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.desc,
    required this.highlight,
  });
}

class _FeatureCard extends StatefulWidget {
  final _F f;
  const _FeatureCard({required this.f});
  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final so = _hov ? 10.0 : 6.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_hov ? -2 : 0, _hov ? -2 : 0, 0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderBlack, width: 3),
          boxShadow: [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(so, so))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.f.tagColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                  ),
                  child:
                      Icon(widget.f.icon, size: 24, color: widget.f.tagColor),
                ),
                const SizedBox(width: 14),
                BrutalistTag(label: widget.f.tag, color: widget.f.tagColor),
              ],
            ),
            const SizedBox(height: 20),
            Text(widget.f.title,
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: -0.5)),
            const SizedBox(height: 10),
            Text(widget.f.desc,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSoft, height: 1.6)),
            const SizedBox(height: 16),
            // Highlight badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.f.tagColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: widget.f.tagColor.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, size: 14, color: widget.f.tagColor),
                  const SizedBox(width: 4),
                  Text(widget.f.highlight,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.f.tagColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TECH STACK ---
class _TechStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final techs = [
      _Tech("Flutter", "Cross-platform UI", "📱", AppColors.primaryTeal),
      _Tech("Gemini 3", "AI workout engine", "🧠", AppColors.accentPurple),
      _Tech("Gemini Vision", "Equipment scanner", "📷", AppColors.accentOrange),
      _Tech("Firebase", "Auth & Firestore", "🔥", AppColors.accentYellow),
      _Tech("Dart", "Type-safe logic", "🎯", AppColors.accentPink),
      _Tech("Cloud AI", "Google DeepMind", "☁️", const Color(0xFFE53E3E)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.textDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderBlack, width: 3),
                boxShadow: const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(6, 6))
                ],
              ),
              child: Column(
                children: [
                  const BrutalistTag(
                      label: "TECH STACK", color: AppColors.primaryTeal),
                  const SizedBox(height: 8),
                  Text("Built on the best.",
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 28),
                  LayoutBuilder(builder: (context, c) {
                    final isMobile = c.maxWidth < 500;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: techs
                          .map((t) => SizedBox(
                                width: isMobile
                                    ? (c.maxWidth - 16) / 2
                                    : (c.maxWidth - 48) / 3,
                                child: _TechBadge(t: t),
                              ))
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tech {
  final String name, desc, emoji;
  final Color color;
  _Tech(this.name, this.desc, this.emoji, this.color);
}

class _TechBadge extends StatelessWidget {
  final _Tech t;
  const _TechBadge({required this.t});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 2),
      ),
      child: Column(
        children: [
          Text(t.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(t.name,
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w800, color: t.color)),
          const SizedBox(height: 2),
          Text(t.desc,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
        ],
      ),
    );
  }
}

// --- COMPARISON ---
class _ComparisonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = [
      _CRow("Gemini 3 AI workouts", true, false),
      _CRow("Gym photo equipment scan", true, false),
      _CRow("Persistent chat memory", true, false),
      _CRow("50-session context window", true, false),
      _CRow("Progressive overload tracking", true, true),
      _CRow("Cross-platform sync", true, true),
      _CRow("Workout logging", true, true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrutalistTag(
                    label: "VS THE REST", color: AppColors.accentOrange),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderBlack, width: 3),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(6, 6))
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCream,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(17)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text("Feature",
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textSoft))),
                            Expanded(
                                child: Center(
                                    child: Text("Fittie",
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryTeal)))),
                            Expanded(
                                child: Center(
                                    child: Text("Others",
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textSoft)))),
                          ],
                        ),
                      ),
                      ...rows.map((r) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: AppColors.borderBlack
                                          .withOpacity(0.08))),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text(r.feature,
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark))),
                                Expanded(
                                    child: Center(
                                        child: Icon(
                                            r.fittie
                                                ? Icons.check_circle_rounded
                                                : Icons.remove_circle_outline,
                                            color: r.fittie
                                                ? AppColors.primaryTeal
                                                : AppColors.textSoft,
                                            size: 22))),
                                Expanded(
                                    child: Center(
                                        child: Icon(
                                            r.others
                                                ? Icons.check_circle_rounded
                                                : Icons.remove_circle_outline,
                                            color: r.others
                                                ? AppColors.textSoft
                                                : AppColors.textSoft
                                                    .withOpacity(0.4),
                                            size: 22))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CRow {
  final String feature;
  final bool fittie;
  final bool others;
  _CRow(this.feature, this.fittie, this.others);
}

// --- CTA ---
class _FeaturesCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderBlack, width: 3),
                boxShadow: const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(6, 6))
                ],
              ),
              child: Column(
                children: [
                  Text("Ready to train smarter?",
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 10),
                  Text("All features. No cost. No catch. Just better workouts.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5)),
                  const SizedBox(height: 28),
                  SquishyButton(
                    label: "GET STARTED FREE",
                    isWhite: true,
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
          ),
        ),
      ),
    );
  }
}
