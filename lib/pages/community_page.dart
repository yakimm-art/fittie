import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Community",
      subtitle: "Train alone, grow together. No toxicity, no gatekeeping.",
      children: [
        _Stats(),
        const SizedBox(height: 56),
        _Channels(),
        const SizedBox(height: 56),
        _Events(),
        const SizedBox(height: 56),
        _Spotlight(),
        const SizedBox(height: 56),
        _ContributeSection(),
        const SizedBox(height: 56),
        _FAQ(),
        const SizedBox(height: 80),
      ],
    );
  }
}

// --- STATS BANNER ---
class _Stats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat("1,200+", "Beta testers", "🏋️"),
      _Stat("6", "Countries", "🌍"),
      _Stat("300+", "Feature ideas", "💡"),
      _Stat("24/7", "Active Discord", "💬"),
      _Stat("50+", "Contributors", "🛠️"),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.textDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderBlack, width: 3),
                boxShadow: const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(6, 6))
                ],
              ),
              child: LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 600;
                if (isMobile) {
                  return Wrap(
                    spacing: 20,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: stats
                        .map((s) => SizedBox(
                              width: (c.maxWidth - 44) / 2,
                              child: _StatItem(s: s),
                            ))
                        .toList(),
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: stats.map((s) => _StatItem(s: s)).toList(),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat {
  final String value, label, emoji;
  _Stat(this.value, this.label, this.emoji);
}

class _StatItem extends StatelessWidget {
  final _Stat s;
  const _StatItem({required this.s});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(s.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(s.value,
            style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryTeal)),
        const SizedBox(height: 2),
        Text(s.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

// --- CHANNELS ---
class _Channels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final channels = [
      _Ch(
          icon: Icons.chat_bubble_rounded,
          title: "Discord",
          desc:
              "Real-time chat with 1,000+ lifters. Ask questions, share wins, find training partners.",
          color: AppColors.accentPurple,
          cta: "Join Discord",
          members: "1,200+",
          emoji: "💬"),
      _Ch(
          icon: Icons.article_rounded,
          title: "Forum",
          desc:
              "Long-form discussions about training methodology, AI in fitness, and feature requests.",
          color: AppColors.primaryTeal,
          cta: "Browse Forum",
          members: "800+",
          emoji: "📝"),
      _Ch(
          icon: Icons.code_rounded,
          title: "Open Source",
          desc:
              "Contribute to Fittie. Our widget library and ML pipeline tools are open on GitHub.",
          color: AppColors.accentOrange,
          cta: "View on GitHub",
          members: "50+",
          emoji: "🛠️"),
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
                child: const BrutalistTag(label: "GET INVOLVED"),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delayMs: 50,
                child: Text(
                  "Find your crew.",
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.5),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 700;
                final cards = channels
                    .asMap()
                    .entries
                    .map((e) => FadeSlideIn(
                          delayMs: e.key * 100,
                          child: _ChannelCard(ch: e.value),
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
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards
                      .map((w) => Expanded(
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: w),
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

class _Ch {
  final IconData icon;
  final String title, desc, cta, members, emoji;
  final Color color;
  _Ch({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.cta,
    required this.members,
    required this.emoji,
  });
}

class _ChannelCard extends StatefulWidget {
  final _Ch ch;
  const _ChannelCard({required this.ch});
  @override
  State<_ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<_ChannelCard> {
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
        padding: const EdgeInsets.all(26),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.ch.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                  ),
                  child: Icon(widget.ch.icon, size: 26, color: widget.ch.color),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.ch.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("${widget.ch.members} members",
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.ch.color)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(widget.ch.title,
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(widget.ch.desc,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSoft, height: 1.5)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.ch.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderBlack, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(3, 3))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.ch.cta,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- EVENTS ---
class _Events extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final events = [
      _Ev(
          "Weekly Lift-Off",
          "Every Monday 7 PM UTC",
          "Community workout session — follow along live on Discord with voice coaching.",
          AppColors.primaryTeal,
          Icons.fitness_center_rounded),
      _Ev(
          "Build & Ship Friday",
          "Every Friday 6 PM UTC",
          "Open-source contributors meet to hack on Fittie. Newbies welcome!",
          AppColors.accentOrange,
          Icons.code_rounded),
      _Ev(
          "Monthly Challenge",
          "1st of each month",
          "30-day fitness challenge with leaderboards and community accountability.",
          AppColors.accentPurple,
          Icons.emoji_events_rounded),
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
                    label: "RECURRING EVENTS", color: AppColors.accentOrange),
              ),
              const SizedBox(height: 24),
              ...events.asMap().entries.map((e) => FadeSlideIn(
                    delayMs: e.key * 100,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _EventCard(ev: e.value),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ev {
  final String title, schedule, desc;
  final Color color;
  final IconData icon;
  _Ev(this.title, this.schedule, this.desc, this.color, this.icon);
}

class _EventCard extends StatelessWidget {
  final _Ev ev;
  const _EventCard({required this.ev});

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ev.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderBlack, width: 2),
            ),
            child: Icon(ev.icon, size: 24, color: ev.color),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ev.title,
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ev.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(ev.schedule,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ev.color)),
                ),
                const SizedBox(height: 8),
                Text(ev.desc,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSoft, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- SPOTLIGHT ---
class _Spotlight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spotlights = [
      _Spot(
          "@ironmaya",
          "Training Tips",
          "Shared a 12-week progressive overload guide that became our most-referenced community resource.",
          "🏆"),
      _Spot(
          "@codelifter",
          "Open Source",
          "Built the community leaderboard widget from scratch. Now ships in the main app.",
          "⚡"),
      _Spot(
          "@zenrunner",
          "Community",
          "Organized the first virtual Fittie meetup — 80 attendees from 12 countries.",
          "🌟"),
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
                    label: "COMMUNITY SPOTLIGHT",
                    color: AppColors.accentYellow),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delayMs: 50,
                child: Text(
                  "Standout members making a difference.",
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.5),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 700;
                final cards = spotlights
                    .asMap()
                    .entries
                    .map((e) => FadeSlideIn(
                          delayMs: e.key * 100,
                          child: _SpotCard(s: e.value),
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
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards
                      .map((w) => Expanded(
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: w),
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

class _Spot {
  final String handle, category, desc, emoji;
  _Spot(this.handle, this.category, this.desc, this.emoji);
}

class _SpotCard extends StatefulWidget {
  final _Spot s;
  const _SpotCard({required this.s});
  @override
  State<_SpotCard> createState() => _SpotCardState();
}

class _SpotCardState extends State<_SpotCard> {
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
            Text(widget.s.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 14),
            Text(widget.s.handle,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(widget.s.category,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentYellow)),
            ),
            const SizedBox(height: 12),
            Text(widget.s.desc,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSoft, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// --- CONTRIBUTE ---
class _ContributeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ways = [
      _Way("Report bugs", "Found something weird? File an issue on GitHub.",
          Icons.bug_report_rounded, AppColors.accentOrange),
      _Way("Suggest features", "Drop ideas in Discord or the forum.",
          Icons.lightbulb_rounded, AppColors.accentYellow),
      _Way("Write code", "PRs welcome. Check 'good first issue' labels.",
          Icons.code_rounded, AppColors.primaryTeal),
      _Way("Spread the word", "Share Fittie with a gym buddy.",
          Icons.share_rounded, AppColors.accentPink),
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
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderBlack, width: 3),
                boxShadow: const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(6, 6))
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
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.handshake_rounded,
                            size: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Text("How to contribute",
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(builder: (context, c) {
                    final isMobile = c.maxWidth < 500;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: ways
                          .map((w) => SizedBox(
                                width: isMobile
                                    ? c.maxWidth
                                    : (c.maxWidth - 16) / 2,
                                child: _WayCard(w: w),
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

class _Way {
  final String title, desc;
  final IconData icon;
  final Color color;
  _Way(this.title, this.desc, this.icon, this.color);
}

class _WayCard extends StatelessWidget {
  final _Way w;
  const _WayCard({required this.w});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
      ),
      child: Row(
        children: [
          Icon(w.icon, size: 22, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.title,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(w.desc,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- FAQ ---
class _FAQ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final faqs = [
      _QA("Is Fittie free to join?",
          "Yes — the beta is completely free. We'll always have a generous free tier."),
      _QA("Do I need to code to contribute?",
          "Not at all! Bug reports, feature ideas, community moderation, and content creation all count."),
      _QA("How do I become a beta tester?",
          "Sign up on our website or join the Discord and grab the Beta Tester role. You'll get early access to new features."),
      _QA("Can I use Fittie data in my research?",
          "We're exploring anonymised data partnerships. Reach out to us on Discord or email for details."),
      _QA("What tech stack does Fittie use?",
          "Flutter for the app, Firebase for backend, Gemini AI for intelligence, and ElevenLabs for voice coaching."),
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
                child: const BrutalistTag(label: "FAQ"),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delayMs: 50,
                child: Text(
                  "Got questions? We've got answers.",
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.5),
                ),
              ),
              const SizedBox(height: 24),
              ...faqs.asMap().entries.map((e) => FadeSlideIn(
                    delayMs: e.key * 80,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _FAQItem(qa: e.value),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _QA {
  final String q, a;
  _QA(this.q, this.a);
}

class _FAQItem extends StatefulWidget {
  final _QA qa;
  const _FAQItem({required this.qa});
  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderBlack, width: 2.5),
          boxShadow: [
            BoxShadow(
                color: AppColors.borderBlack,
                offset: Offset(_expanded ? 6 : 4, _expanded ? 6 : 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.qa.q,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more_rounded,
                      size: 22, color: AppColors.textSoft),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(widget.qa.a,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSoft, height: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
