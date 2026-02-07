import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';

class MorphicUiPage extends StatelessWidget {
  const MorphicUiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Morphic UI",
      subtitle: "An interface that responds to your body — not the other way around.",
      children: [
        _Intro(),
        const SizedBox(height: 56),
        _HowItWorks(),
        const SizedBox(height: 56),
        _States(),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: BrutalistCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrutalistTag(label: "THE CONCEPT", color: AppColors.accentPurple),
                  const SizedBox(height: 20),
                  Text(
                    "An interface that responds to your body — not the other way around.",
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Morphic UI watches your biometrics in real time. When intensity rises, it strips the interface to essentials — bigger buttons, less text, zero cognitive load. When you're resting, it expands back to show analytics and recommendations.",
                    style: GoogleFonts.inter(
                        fontSize: 16, color: AppColors.textSoft, height: 1.6),
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

class _HowItWorks extends StatelessWidget {
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
              FadeSlideIn(
                child: const BrutalistTag(label: "HOW IT WORKS"),
              ),
              const SizedBox(height: 24),
              ..._steps.asMap().entries.map((e) => FadeSlideIn(
                    delayMs: e.key * 120,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _StepRow(
                          number: e.key + 1, step: e.value),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  static final _steps = [
    _Step("Biometric input",
        "Heart rate, movement cadence, and fatigue indicators stream in from wearables or the device camera."),
    _Step("State classification",
        "Gemini AI classifies your current state: resting, warming up, mid-set, peak exertion, or cooldown."),
    _Step("UI transformation",
        "Layout, typography, colour, and input targets morph to match — automatically and seamlessly."),
    _Step("Feedback loop",
        "User interactions are fed back into the model to fine-tune thresholds over time."),
  ];
}

class _Step {
  final String title;
  final String desc;
  _Step(this.title, this.desc);
}

class _StepRow extends StatelessWidget {
  final int number;
  final _Step step;
  const _StepRow({required this.number, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderBlack, width: 2.5),
            boxShadow: const [
              BoxShadow(color: AppColors.borderBlack, offset: Offset(3, 3))
            ],
          ),
          child: Center(
            child: Text("$number",
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title,
                  style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(step.desc,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSoft,
                      height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}

class _States extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final states = [
      _UIState("Resting", "Full dashboard with analytics, history, and recommendations.",
          AppColors.primaryTeal, Icons.self_improvement_rounded),
      _UIState("Mid-Set", "Large rep counter, single-tap logging, voice cues active.",
          AppColors.accentOrange, Icons.fitness_center_rounded),
      _UIState("Peak Exertion", "Minimal UI — only a stop button and live encouragement.",
          Color(0xFFE53E3E), Icons.local_fire_department_rounded),
      _UIState("Cooldown", "Stretch suggestions, session summary emerging.",
          AppColors.accentPurple, Icons.nightlight_round),
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
                    label: "UI STATES", color: AppColors.accentPurple),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 700;
                if (isMobile) {
                  return Column(
                    children: states
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: FadeSlideIn(
                                  delayMs: e.key * 100,
                                  child: _StateCard(s: e.value)),
                            ))
                        .toList(),
                  );
                }
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: states
                      .asMap()
                      .entries
                      .map((e) => SizedBox(
                            width: (c.maxWidth - 20) / 2,
                            child: FadeSlideIn(
                                delayMs: e.key * 100,
                                child: _StateCard(s: e.value)),
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

class _UIState {
  final String title;
  final String desc;
  final Color color;
  final IconData icon;
  _UIState(this.title, this.desc, this.color, this.icon);
}

class _StateCard extends StatelessWidget {
  final _UIState s;
  const _StateCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: s.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderBlack, width: 2.5),
            ),
            child: Icon(s.icon, size: 24, color: s.color),
          ),
          const SizedBox(height: 16),
          Text(s.title,
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(s.desc,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSoft, height: 1.5)),
        ],
      ),
    );
  }
}
