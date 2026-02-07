import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Help Center",
      subtitle: "Find answers fast — or reach a real human.",
      children: [
        _SearchBar(),
        const SizedBox(height: 56),
        _Categories(),
        const SizedBox(height: 56),
        _FAQ(),
        const SizedBox(height: 56),
        _Contact(),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderBlack, width: 3),
                boxShadow: const [
                  BoxShadow(
                      color: AppColors.borderBlack, offset: Offset(5, 5))
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: AppColors.textSoft, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.inter(
                          fontSize: 16, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: "Search for help articles...",
                        hintStyle: GoogleFonts.inter(
                            fontSize: 16, color: AppColors.textSoft),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
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

class _Categories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cats = [
      _Cat(Icons.play_circle_rounded, "Getting Started",
          "Set up your account and first workout.", AppColors.primaryTeal),
      _Cat(Icons.auto_awesome_rounded, "AI & Flows",
          "How adaptive workouts and Gemini AI work.", AppColors.accentPurple),
      _Cat(Icons.record_voice_over_rounded, "Voice Coach",
          "Troubleshoot audio, customise voice settings.", AppColors.accentOrange),
      _Cat(Icons.visibility_rounded, "Morphic UI",
          "Understanding how the interface adapts.", AppColors.accentYellow),
      _Cat(Icons.account_circle_rounded, "Account & Billing",
          "Manage your profile, subscription, data.", AppColors.accentPink),
      _Cat(Icons.devices_rounded, "Platform & Sync",
          "Cross-device sync, platform-specific tips.", AppColors.primaryTeal),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(child: const BrutalistTag(label: "CATEGORIES")),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 700;
                final items = cats
                    .asMap()
                    .entries
                    .map((e) => FadeSlideIn(
                          delayMs: e.key * 70,
                          child: _CatCard(cat: e.value),
                        ))
                    .toList();

                if (isMobile) {
                  return Column(
                    children: items
                        .map((w) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: w))
                        .toList(),
                  );
                }
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: items
                      .map((w) =>
                          SizedBox(width: (c.maxWidth - 40) / 3, child: w))
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

class _Cat {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  _Cat(this.icon, this.title, this.desc, this.color);
}

class _CatCard extends StatefulWidget {
  final _Cat cat;
  const _CatCard({required this.cat});
  @override
  State<_CatCard> createState() => _CatCardState();
}

class _CatCardState extends State<_CatCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final so = _hov ? 10.0 : 6.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform:
            Matrix4.translationValues(_hov ? -2 : 0, _hov ? -2 : 0, 0),
        padding: const EdgeInsets.all(22),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.cat.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderBlack, width: 2.5),
              ),
              child:
                  Icon(widget.cat.icon, size: 22, color: widget.cat.color),
            ),
            const SizedBox(height: 14),
            Text(widget.cat.title,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(widget.cat.desc,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSoft, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _FAQ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final faqs = [
      _FaqItem("Is Fittie really free?",
          "Yes — the core experience is completely free. No paywalls, no ads. Premium features may be offered later for advanced users, but the full AI coaching experience is free."),
      _FaqItem("How does the AI know my fitness level?",
          "During onboarding, you answer a few simple questions about your training history. From there, the AI adapts based on your performance data — no manual calibration needed."),
      _FaqItem("Does Voice Coach work with earbuds?",
          "Absolutely. Any Bluetooth or wired audio device works. The AI adjusts volume and speech cadence based on ambient noise."),
      _FaqItem("What wearables are supported?",
          "Currently we integrate with Apple Watch, Wear OS, and Polar devices. Garmin and Whoop support is on our roadmap."),
      _FaqItem("Can I export my data?",
          "Yes. You can export your full workout history as CSV or JSON from Settings → Data → Export at any time."),
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
                    label: "FAQ", color: AppColors.accentOrange),
              ),
              const SizedBox(height: 24),
              ...faqs.asMap().entries.map((e) => FadeSlideIn(
                    delayMs: e.key * 80,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _FaqCard(faq: e.value),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  _FaqItem(this.q, this.a);
}

class _FaqCard extends StatefulWidget {
  final _FaqItem faq;
  const _FaqCard({required this.faq});
  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderBlack, width: 3),
          boxShadow: [
            BoxShadow(
                color: AppColors.borderBlack,
                offset: Offset(_expanded ? 8 : 5, _expanded ? 8 : 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.faq.q,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.125 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.add_rounded,
                      size: 22, color: AppColors.primaryTeal),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(widget.faq.a,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSoft,
                        height: 1.6)),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: BrutalistCard(
              color: AppColors.primaryTeal,
              child: Column(
                children: [
                  Text("Still stuck?",
                      style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text("Reach out and we'll get back to you within 24 hours.",
                      style: GoogleFonts.inter(
                          fontSize: 15, color: Colors.white70, height: 1.5),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppColors.borderBlack, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.borderBlack,
                            offset: Offset(4, 4))
                      ],
                    ),
                    child: Text("hello@fittie.app",
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
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
