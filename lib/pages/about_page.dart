import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "About",
      subtitle: "We're building the fitness software we always wished existed.",
      children: [
        _Mission(),
        const SizedBox(height: 56),
        _NumbersBanner(),
        const SizedBox(height: 56),
        _Values(),
        const SizedBox(height: 56),
        _Timeline(),
        const SizedBox(height: 56),
        _Team(),
        const SizedBox(height: 56),
        _WhatDrivesUs(),
        const SizedBox(height: 80),
      ],
    );
  }
}

// --- MISSION ---
class _Mission extends StatelessWidget {
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
                  Row(
                    children: [
                      const BrutalistTag(label: "OUR MISSION"),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.borderBlack, width: 2),
                        ),
                        child: const Icon(Icons.rocket_launch_rounded,
                            size: 22, color: AppColors.primaryTeal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Make intelligent training accessible to everyone — not just athletes with personal coaches.",
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
                    "We believe your workout app should be as smart as a great personal trainer: aware of your body, adaptive to your progress, and genuinely helpful — not just a glorified spreadsheet. Fittie combines cutting-edge AI with thoughtful design to create fitness software that actually makes you better.",
                    style: GoogleFonts.inter(
                        fontSize: 16, color: AppColors.textSoft, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MissionPill(Icons.psychology_rounded, "AI-native"),
                      _MissionPill(
                          Icons.accessibility_new_rounded, "Inclusive"),
                      _MissionPill(Icons.favorite_rounded, "Body-first"),
                      _MissionPill(Icons.visibility_rounded, "Transparent"),
                    ],
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

class _MissionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MissionPill(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderBlack, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.borderBlack, offset: Offset(2, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryTeal),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }
}

// --- NUMBERS BANNER ---
class _NumbersBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      _NumStat("1,200+", "Beta testers", AppColors.primaryTeal),
      _NumStat("6", "Countries", AppColors.accentPurple),
      _NumStat("50k+", "Workouts completed", AppColors.accentOrange),
      _NumStat("4.9", "Avg rating", AppColors.accentYellow),
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
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: stats
                        .map((s) => SizedBox(
                              width: (c.maxWidth - 48) / 2,
                              child: _NumStatCard(s: s),
                            ))
                        .toList(),
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: stats.map((s) => _NumStatCard(s: s)).toList(),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumStat {
  final String value, label;
  final Color color;
  _NumStat(this.value, this.label, this.color);
}

class _NumStatCard extends StatelessWidget {
  final _NumStat s;
  const _NumStatCard({required this.s});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(s.value,
            style: GoogleFonts.inter(
                fontSize: 36, fontWeight: FontWeight.w900, color: s.color)),
        const SizedBox(height: 4),
        Text(s.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
      ],
    );
  }
}

// --- VALUES ---
class _Values extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final values = [
      _V(
          "Body-first design",
          "Every pixel exists to serve the person training, not to impress designers on Dribbble.",
          AppColors.primaryTeal,
          Icons.fitness_center_rounded),
      _V(
          "AI as enabler",
          "Artificial intelligence should remove friction, not create dependency.",
          AppColors.accentPurple,
          Icons.auto_awesome_rounded),
      _V(
          "Radical transparency",
          "Open about what data we collect, how models work, and where revenue comes from.",
          AppColors.accentOrange,
          Icons.lock_open_rounded),
      _V(
          "Accessible by default",
          "High contrast, large touch targets, voice-driven — designed for any gym, any ability.",
          AppColors.accentYellow,
          Icons.accessibility_new_rounded),
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
                    label: "OUR VALUES", color: AppColors.accentOrange),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 700;
                final cards = values
                    .asMap()
                    .entries
                    .map((e) => FadeSlideIn(
                          delayMs: e.key * 100,
                          child: _ValueCard(v: e.value),
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
                          SizedBox(width: (c.maxWidth - 20) / 2, child: w))
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

class _V {
  final String title, desc;
  final Color color;
  final IconData icon;
  _V(this.title, this.desc, this.color, this.icon);
}

class _ValueCard extends StatefulWidget {
  final _V v;
  const _ValueCard({required this.v});
  @override
  State<_ValueCard> createState() => _ValueCardState();
}

class _ValueCardState extends State<_ValueCard> {
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderBlack, width: 3),
          boxShadow: [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(so, so))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.v.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderBlack, width: 2.5),
              ),
              child: Icon(widget.v.icon, size: 24, color: widget.v.color),
            ),
            const SizedBox(height: 18),
            Text(widget.v.title,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(widget.v.desc,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSoft, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// --- TIMELINE ---
class _Timeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final milestones = [
      _M(
          "Mar 2025",
          "Idea born",
          "Yakim sketches the first concept after frustration with existing fitness apps.",
          AppColors.primaryTeal),
      _M(
          "Jun 2025",
          "First prototype",
          "Core AI engine + neo-brutalist UI. 12 friends start testing on Discord.",
          AppColors.accentPurple),
      _M(
          "Sep 2025",
          "Beta launch",
          "500 beta testers across 4 countries. Voice Coach lands. Community explodes.",
          AppColors.accentOrange),
      _M(
          "Jan 2026",
          "1,200 testers",
          "Morphic UI, heart-rate rest timers, and progressive overload tracking ship.",
          AppColors.accentYellow),
      _M(
          "2026",
          "What's next",
          "Wearable integrations, group challenges, and open-sourcing the widget library.",
          AppColors.accentPink),
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
                    label: "OUR JOURNEY", color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 32),
              ...milestones.asMap().entries.map(
                    (e) => FadeSlideIn(
                      delayMs: e.key * 120,
                      child: _TimelineItem(
                        m: e.value,
                        isLast: e.key == milestones.length - 1,
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

class _M {
  final String date, title, desc;
  final Color color;
  _M(this.date, this.title, this.desc, this.color);
}

class _TimelineItem extends StatelessWidget {
  final _M m;
  final bool isLast;
  const _TimelineItem({required this.m, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: m.color,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(2, 2))
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: AppColors.borderBlack.withOpacity(0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: m.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: m.color, width: 1.5),
                    ),
                    child: Text(m.date,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: m.color,
                            letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 10),
                  Text(m.title,
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Text(m.desc,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSoft,
                          height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TEAM ---
class _Team extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final team = [
      _T(
          "Yakim",
          "Creator & Developer",
          "Built Fittie from scratch — design, engineering, and AI integration. Passionate about making fitness accessible through technology.",
          AppColors.primaryTeal,
          "🚀"),
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
                    label: "THE CREATOR", color: AppColors.accentPurple),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delayMs: 50,
                child: Text(
                  "Solo-built, community-driven.",
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
                final cards = team
                    .asMap()
                    .entries
                    .map((e) => FadeSlideIn(
                          delayMs: e.key * 100,
                          child: _TeamCard(t: e.value),
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
                          SizedBox(width: (c.maxWidth - 20) / 2, child: w))
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

class _T {
  final String name, role, bio;
  final Color color;
  final String emoji;
  _T(this.name, this.role, this.bio, this.color, this.emoji);
}

class _TeamCard extends StatefulWidget {
  final _T t;
  const _TeamCard({required this.t});
  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.t.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 2.5),
                  ),
                  child: Center(
                    child: Text(widget.t.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.t.name,
                          style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.t.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(widget.t.role,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: widget.t.color)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(widget.t.bio,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSoft, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// --- WHAT DRIVES US ---
class _WhatDrivesUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final principles = [
      _P("Ship fast, learn faster",
          "We release weekly. Every feature is a hypothesis — if it doesn't improve your training, it gets cut."),
      _P("Earn trust, don't demand it",
          "No dark patterns. No guilt-trip notifications. You come back because the product is good."),
      _P("Built in public",
          "Our roadmap is open. Our Discord is transparent. We share wins and failures equally."),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Container(
              padding: const EdgeInsets.all(36),
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
                        child: const Icon(Icons.bolt_rounded,
                            size: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Text("What drives us",
                          style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ...principles.asMap().entries.map((e) => Padding(
                        padding: EdgeInsets.only(
                            bottom: e.key < principles.length - 1 ? 24 : 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Text("${e.key + 1}",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.value.title,
                                      style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(e.value.desc,
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.75),
                                          height: 1.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _P {
  final String title, desc;
  _P(this.title, this.desc);
}
