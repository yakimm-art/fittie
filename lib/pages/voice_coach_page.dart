import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';

class VoiceCoachPage extends StatelessWidget {
  const VoiceCoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Voice Coach",
      subtitle: "A spotter that talks back — real-time audible cues powered by AI.",
      children: [
        _Intro(),
        const SizedBox(height: 56),
        _Capabilities(),
        const SizedBox(height: 56),
        _TechStack(),
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
                  const BrutalistTag(
                      label: "VOICE AI", color: AppColors.accentOrange),
                  const SizedBox(height: 20),
                  Text(
                    "A spotter that talks back.",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Voice Coach combines Gemini's biomechanical analysis with ElevenLabs' natural speech to deliver real-time audible cues. You hear form corrections, rep counts, and motivational nudges — hands-free, mid-set, exactly when they matter.",
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

class _Capabilities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final caps = [
      _Cap(Icons.mic_rounded, "Form corrections",
          "Detects postural drift and calls it out before it becomes a problem."),
      _Cap(Icons.timer_rounded, "Smart rep counting",
          "Audio confirmation for every completed rep — never lose count again."),
      _Cap(Icons.emoji_events_rounded, "Motivational cues",
          "Contextual encouragement that adapts to your performance and fatigue."),
      _Cap(Icons.music_note_rounded, "Natural voice",
          "ElevenLabs TTS with a warm, natural tone — not a robotic announcement."),
      _Cap(Icons.hearing_rounded, "Ambient-aware",
          "Volume and cadence adjust for gym noise levels."),
      _Cap(Icons.psychology_rounded, "Learning engine",
          "Remembers your weak spots and emphasises relevant cues over time."),
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
                  child: const BrutalistTag(label: "CAPABILITIES")),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 700;
                final items = caps
                    .asMap()
                    .entries
                    .map((e) => FadeSlideIn(
                          delayMs: e.key * 80,
                          child: _CapCard(cap: e.value),
                        ))
                    .toList();

                if (isMobile) {
                  return Column(
                    children: items
                        .map((w) =>
                            Padding(padding: const EdgeInsets.only(bottom: 20), child: w))
                        .toList(),
                  );
                }
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: items
                      .map((w) => SizedBox(
                          width: (c.maxWidth - 40) / 3,
                          child: w))
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

class _Cap {
  final IconData icon;
  final String title;
  final String desc;
  _Cap(this.icon, this.title, this.desc);
}

class _CapCard extends StatelessWidget {
  final _Cap cap;
  const _CapCard({required this.cap});

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderBlack, width: 2.5),
            ),
            child: Icon(cap.icon, size: 22, color: AppColors.accentOrange),
          ),
          const SizedBox(height: 16),
          Text(cap.title,
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(cap.desc,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSoft, height: 1.5)),
        ],
      ),
    );
  }
}

class _TechStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: BrutalistCard(
              color: AppColors.textDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrutalistTag(
                      label: "TECH UNDER THE HOOD",
                      color: AppColors.accentOrange),
                  const SizedBox(height: 20),
                  _TechRow("Gemini AI",
                      "Analysing form, detecting fatigue, generating coaching scripts."),
                  const SizedBox(height: 14),
                  _TechRow("ElevenLabs TTS",
                      "Ultra-realistic voice synthesis with sub-200ms latency."),
                  const SizedBox(height: 14),
                  _TechRow("Firebase",
                      "Real-time sync, session persistence, and user preferences across devices."),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final String label;
  final String desc;
  const _TechRow(this.label, this.desc);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: "$label  ",
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                TextSpan(
                    text: desc,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
