import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';

class CareersPage extends StatelessWidget {
  const CareersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Careers",
      subtitle: "Build the future of fitness tech with a team that actually lifts.",
      children: [
        _OpenRoles(),
        const SizedBox(height: 56),
        _Perks(),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _OpenRoles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final roles = [
      _Role("Senior Flutter Engineer", "Engineering", "Remote · Full-time",
          AppColors.primaryTeal),
      _Role("ML Engineer — Biomechanics", "AI/ML", "Remote · Full-time",
          AppColors.accentPurple),
      _Role("Product Designer", "Design", "Remote · Full-time",
          AppColors.accentOrange),
      _Role("Developer Advocate", "Community", "Remote · Full-time",
          AppColors.accentYellow),
      _Role("iOS Platform Engineer", "Engineering", "Remote · Full-time",
          AppColors.primaryTeal),
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
                      label: "OPEN ROLES", color: AppColors.accentOrange)),
              const SizedBox(height: 24),
              ...roles.asMap().entries.map((e) => FadeSlideIn(
                    delayMs: e.key * 80,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _RoleCard(role: e.value),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Role {
  final String title;
  final String dept;
  final String meta;
  final Color color;
  _Role(this.title, this.dept, this.meta, this.color);
}

class _RoleCard extends StatefulWidget {
  final _Role role;
  const _RoleCard({required this.role});
  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderBlack, width: 3),
          boxShadow: [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(so, so))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 44,
              decoration: BoxDecoration(
                color: widget.role.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.role.title,
                      style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      BrutalistTag(
                          label: widget.role.dept, color: widget.role.color),
                      const SizedBox(width: 12),
                      Text(widget.role.meta,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textSoft)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: AppColors.textSoft, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Perks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final perks = [
      _Perk(Icons.fitness_center_rounded, "Gym membership",
          "We cover your gym fees worldwide."),
      _Perk(Icons.laptop_mac_rounded, "Top-tier gear",
          "MacBook Pro, 4K display, your choice of peripherals."),
      _Perk(Icons.flight_rounded, "Annual retreat",
          "Team gathering in a cool location once a year."),
      _Perk(Icons.schedule_rounded, "Flex hours",
          "Train when you want. We care about output, not hours."),
      _Perk(Icons.school_rounded, "Learning budget",
          "\$2,000/yr for courses, conferences, or certifications."),
      _Perk(Icons.favorite_rounded, "Health coverage",
          "Comprehensive health and dental for you + family."),
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
                      label: "PERKS", color: AppColors.accentPurple)),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 700;
                final items = perks
                    .asMap()
                    .entries
                    .map((e) => FadeSlideIn(
                          delayMs: e.key * 70,
                          child: _PerkCard(p: e.value),
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

class _Perk {
  final IconData icon;
  final String title;
  final String desc;
  _Perk(this.icon, this.title, this.desc);
}

class _PerkCard extends StatelessWidget {
  final _Perk p;
  const _PerkCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(p.icon, size: 28, color: AppColors.primaryTeal),
          const SizedBox(height: 14),
          Text(p.title,
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(p.desc,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSoft, height: 1.4)),
        ],
      ),
    );
  }
}
