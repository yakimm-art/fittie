import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';
import 'blog_entry_page.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Blog",
      subtitle:
          "Read and share fitness stories, tips, and ideas with the Fittie community.",
      children: [
        _PostEntryButton(),
        const SizedBox(height: 56),
        _CommunityPosts(),
        const SizedBox(height: 80),
      ],
    );
  }
}

// --- POST ENTRY BUTTON ---
class _PostEntryButton extends StatefulWidget {
  @override
  State<_PostEntryButton> createState() => _PostEntryButtonState();
}

class _PostEntryButtonState extends State<_PostEntryButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final so = _hov ? 8.0 : 5.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: MouseRegion(
              onEnter: (_) => setState(() => _hov = true),
              onExit: (_) => setState(() => _hov = false),
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BlogEntryPage())),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(
                      _hov ? -2 : 0, _hov ? -2 : 0, 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.borderBlack,
                          offset: Offset(so, so))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 22, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("POST AN ENTRY",
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(
                              "Share your workout wins, tips, or ideas",
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 24, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- COMMUNITY POSTS (from Firestore) ---
class _CommunityPosts extends StatelessWidget {
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
                child: Row(
                  children: [
                    const BrutalistTag(
                        label: "COMMUNITY POSTS",
                        color: AppColors.accentPurple),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.people_rounded,
                          size: 18, color: AppColors.accentPurple),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('blog_posts')
                    .orderBy('createdAt', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.primaryTeal),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text("Loading posts...",
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: AppColors.textSoft)),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: "Couldn't load posts",
                      desc: "Check your internet connection and try again.",
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return _EmptyState(
                      icon: Icons.article_outlined,
                      title: "No posts yet",
                      desc:
                          "Be the first to share! Submit a post above and inspire the community.",
                    );
                  }

                  return LayoutBuilder(builder: (context, c) {
                    final isMobile = c.maxWidth < 700;
                    final cards = docs.asMap().entries.map((e) {
                      final data = e.value.data() as Map<String, dynamic>;
                      return FadeSlideIn(
                        delayMs: e.key * 80,
                        child: _PostCard(data: data),
                      );
                    }).toList();

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
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _EmptyState(
      {required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.borderBlack.withOpacity(0.15), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.textSoft.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSoft, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _PostCard({required this.data});
  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _hov = false;

  Color _categoryColor(String cat) {
    switch (cat) {
      case "Training Tips":
        return AppColors.primaryTeal;
      case "Nutrition":
        return AppColors.accentOrange;
      case "Progress Update":
        return AppColors.accentPurple;
      case "Feature Idea":
        return AppColors.accentYellow;
      case "Community":
        return AppColors.accentPink;
      default:
        return AppColors.textDark;
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return "Just now";
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${(diff.inDays / 7).floor()}w ago";
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] ?? 'Untitled';
    final content = widget.data['content'] ?? '';
    final author = widget.data['author'] ?? 'Anonymous';
    final category = widget.data['category'] ?? 'General';
    final createdAt = widget.data['createdAt'] as Timestamp?;
    final catColor = _categoryColor(category);
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
            // Top row: category + time
            Row(
              children: [
                BrutalistTag(label: category.toUpperCase(), color: catColor),
                const Spacer(),
                Text(_timeAgo(createdAt),
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSoft)),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: -0.3)),
            const SizedBox(height: 8),
            // Content preview (first 150 chars)
            Text(
              content.length > 150
                  ? '${content.substring(0, 150)}...'
                  : content,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSoft, height: 1.5),
            ),
            const SizedBox(height: 16),
            // Author
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    author.isNotEmpty ? author[0].toUpperCase() : "?",
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: catColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(author,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
