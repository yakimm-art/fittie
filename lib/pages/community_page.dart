import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  static const _repoUrl = 'https://github.com/yakimm-art/fittie';

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Community",
      subtitle: "Fittie is open source. Built by Yakim, improved by everyone.",
      children: [
        _GitHubHero(repoUrl: _repoUrl),
        const SizedBox(height: 56),
        _HowToContribute(repoUrl: _repoUrl),
        const SizedBox(height: 56),
        _TechStack(),
        const SizedBox(height: 56),
        _FAQ(),
        const SizedBox(height: 80),
      ],
    );
  }
}

// --- GITHUB HERO ---
class _GitHubHero extends StatelessWidget {
  final String repoUrl;
  const _GitHubHero({required this.repoUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.textDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderBlack, width: 3),
                boxShadow: const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(8, 8))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
                    ),
                    child: const Icon(Icons.code_rounded, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text("OPEN SOURCE",
                      style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1)),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Text(
                      "Fittie is fully open source. Explore the code, report bugs, suggest features, or submit pull requests. Every contribution matters.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.75),
                          height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => _openUrl(repoUrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderBlack, width: 2.5),
                        boxShadow: const [
                          BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textDark),
                          const SizedBox(width: 10),
                          Text("VIEW ON GITHUB",
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    'github.com/yakimm-art/fittie',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w600),
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

// --- HOW TO CONTRIBUTE ---
class _HowToContribute extends StatelessWidget {
  final String repoUrl;
  const _HowToContribute({required this.repoUrl});

  @override
  Widget build(BuildContext context) {
    final ways = [
      _Way(
        "Star the repo",
        "Show your support and help others discover Fittie.",
        Icons.star_rounded,
        AppColors.accentYellow,
        "1",
      ),
      _Way(
        "Report bugs",
        "Found something broken? Open an issue on GitHub with steps to reproduce.",
        Icons.bug_report_rounded,
        AppColors.accentOrange,
        "2",
      ),
      _Way(
        "Suggest features",
        "Have an idea? Open an issue with the 'enhancement' label. All ideas welcome.",
        Icons.lightbulb_rounded,
        AppColors.accentPurple,
        "3",
      ),
      _Way(
        "Submit a PR",
        "Fork the repo, make your changes, and open a pull request. Check the README for setup instructions.",
        Icons.merge_rounded,
        AppColors.primaryTeal,
        "4",
      ),
      _Way(
        "Improve docs",
        "Spotted a typo or missing guide? Documentation PRs are just as valuable as code.",
        Icons.description_rounded,
        AppColors.accentPink,
        "5",
      ),
      _Way(
        "Spread the word",
        "Share Fittie with friends, on social media, or write about your experience with it.",
        Icons.share_rounded,
        const Color(0xFF22C55E),
        "6",
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
                child: const BrutalistTag(label: "CONTRIBUTE", color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delayMs: 50,
                child: Text(
                  "6 ways to help Fittie grow.",
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.5),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 600;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: ways
                      .asMap()
                      .entries
                      .map((e) => FadeSlideIn(
                            delayMs: e.key * 80,
                            child: SizedBox(
                              width: isMobile ? c.maxWidth : (c.maxWidth - 32) / 3,
                              child: _WayCard(w: e.value),
                            ),
                          ))
                      .toList(),
                );
              }),
              const SizedBox(height: 32),
              FadeSlideIn(
                delayMs: 500,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _openUrl('$repoUrl/issues'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderBlack, width: 2.5),
                        boxShadow: const [
                          BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Text("VIEW OPEN ISSUES",
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
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

class _Way {
  final String title, desc, step;
  final IconData icon;
  final Color color;
  _Way(this.title, this.desc, this.icon, this.color, this.step);
}

class _WayCard extends StatefulWidget {
  final _Way w;
  const _WayCard({required this.w});
  @override
  State<_WayCard> createState() => _WayCardState();
}

class _WayCardState extends State<_WayCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final so = _hov ? 8.0 : 5.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_hov ? -2 : 0, _hov ? -2 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderBlack, width: 2.5),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.w.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderBlack, width: 2),
                  ),
                  child: Center(
                    child: Icon(widget.w.icon, size: 18, color: widget.w.color),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: widget.w.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(widget.w.step,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: widget.w.color)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(widget.w.title,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(widget.w.desc,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSoft, height: 1.5)),
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
      _Tech("Flutter", "Cross-platform UI framework", Icons.phone_android_rounded, AppColors.primaryTeal),
      _Tech("Gemini 3 Flash", "AI workout generation & vision", Icons.auto_awesome_rounded, AppColors.accentPurple),
      _Tech("Firebase", "Auth, Firestore, hosting", Icons.cloud_rounded, AppColors.accentOrange),
      _Tech("Provider", "State management", Icons.settings_rounded, AppColors.accentYellow),
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
                child: const BrutalistTag(label: "TECH STACK", color: AppColors.accentOrange),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delayMs: 50,
                child: Text(
                  "What powers Fittie under the hood.",
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.5),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 600;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: techs
                      .asMap()
                      .entries
                      .map((e) => FadeSlideIn(
                            delayMs: e.key * 80,
                            child: SizedBox(
                              width: isMobile ? c.maxWidth : (c.maxWidth - 16) / 2,
                              child: _TechCard(t: e.value),
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

class _Tech {
  final String name, desc;
  final IconData icon;
  final Color color;
  _Tech(this.name, this.desc, this.icon, this.color);
}

class _TechCard extends StatelessWidget {
  final _Tech t;
  const _TechCard({required this.t});

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: t.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderBlack, width: 2),
            ),
            child: Icon(t.icon, size: 22, color: t.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(t.desc,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSoft)),
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
      _QA("Is Fittie free?",
          "Yes \u2014 Fittie is open source and free to use. You can clone and run it yourself or use the hosted version."),
      _QA("Do I need to know Flutter to contribute?",
          "Not at all! Bug reports, feature ideas, documentation fixes, and design feedback all count as contributions."),
      _QA("How do I set up the project locally?",
          "Clone the repo, run 'flutter pub get', add your Gemini API key to a .env file, set up Firebase, and run 'flutter run -d web-server'. Full instructions in the README."),
      _QA("What tech stack does Fittie use?",
          "Flutter for the app, Firebase for backend, Gemini 3 Flash for AI (workouts, chat, and vision), and Provider for state management."),
      _QA("Can I use Fittie's code in my own project?",
          "Check the license in the repository. It's a hackathon project \u2014 feel free to learn from it and build on it."),
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

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
