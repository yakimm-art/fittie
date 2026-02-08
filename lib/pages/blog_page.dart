import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';
import 'blog_entry_page.dart';
import 'blog_admin_page.dart';
import 'blog_detail_page.dart';
import '../services/firebase_service.dart';

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
        const SizedBox(height: 16),
        _AdminReviewButton(),
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
    final screenW = MediaQuery.of(context).size.width;
    final isMobile = screenW < 600;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: MouseRegion(
              onEnter: (_) => setState(() => _hov = true),
              onExit: (_) => setState(() => _hov = false),
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BlogEntryPage())),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(
                      _hov ? -2 : 0, _hov ? -2 : 0, 0),
                  padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 20 : 28,
                      horizontal: isMobile ? 20 : 32),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
                    border: Border.all(color: AppColors.borderBlack, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.borderBlack, offset: Offset(so, so))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.edit_rounded,
                            size: isMobile ? 20 : 22, color: Colors.white),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("POST AN ENTRY",
                                style: GoogleFonts.inter(
                                    fontSize: isMobile ? 15 : 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1)),
                            const SizedBox(height: 2),
                            Text("Share your workout wins, tips, or ideas",
                                style: GoogleFonts.inter(
                                    fontSize: isMobile ? 12 : 13,
                                    color: Colors.white.withOpacity(0.8)),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 16),
                      Icon(Icons.arrow_forward_rounded,
                          size: isMobile ? 20 : 24, color: Colors.white),
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

// --- ADMIN REVIEW BUTTON (only visible to admins) ---
class _AdminReviewButton extends StatefulWidget {
  @override
  State<_AdminReviewButton> createState() => _AdminReviewButtonState();
}

class _AdminReviewButtonState extends State<_AdminReviewButton> {
  bool _isAdmin = false;
  bool _hov = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final admin = await FirebaseService().isAdmin();
    if (mounted) setState(() => _isAdmin = admin);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) return const SizedBox.shrink();
    final screenW = MediaQuery.of(context).size.width;
    final isMobile = screenW < 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService().getPendingPostsStream(),
              builder: (context, snapshot) {
                final pendingCount = snapshot.data?.docs.length ?? 0;
                final so = _hov ? 8.0 : 5.0;

                return MouseRegion(
                  onEnter: (_) => setState(() => _hov = true),
                  onExit: (_) => setState(() => _hov = false),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BlogAdminPage()),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      transform: Matrix4.translationValues(
                          _hov ? -2 : 0, _hov ? -2 : 0, 0),
                      padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 14 : 18,
                          horizontal: isMobile ? 16 : 24),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.borderBlack, width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.borderBlack,
                              offset: Offset(so, so))
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isMobile ? 6 : 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.admin_panel_settings_rounded,
                                size: isMobile ? 18 : 20,
                                color: AppColors.textDark),
                          ),
                          SizedBox(width: isMobile ? 10 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    isMobile
                                        ? "REVIEW POSTS"
                                        : "ADMIN: REVIEW POSTS",
                                    style: GoogleFonts.inter(
                                        fontSize: isMobile ? 13 : 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textDark,
                                        letterSpacing: 1)),
                                const SizedBox(height: 2),
                                Text(
                                    "$pendingCount post${pendingCount == 1 ? '' : 's'} awaiting approval",
                                    style: GoogleFonts.inter(
                                        fontSize: isMobile ? 11 : 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark
                                            .withOpacity(0.7)),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          if (pendingCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53E3E),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.borderBlack, width: 2),
                              ),
                              child: Text("$pendingCount",
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white)),
                            ),
                          SizedBox(width: isMobile ? 4 : 8),
                          Icon(Icons.arrow_forward_rounded,
                              size: isMobile ? 18 : 20,
                              color: AppColors.textDark),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// --- COMMUNITY POSTS (from Firestore) ---
class _CommunityPosts extends StatefulWidget {
  @override
  State<_CommunityPosts> createState() => _CommunityPostsState();
}

class _CommunityPostsState extends State<_CommunityPosts> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final admin = await FirebaseService().isAdmin();
    if (mounted) setState(() => _isAdmin = admin);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isMobile = screenW < 600;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
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

                  var docs = snapshot.data?.docs ?? [];
                  // Non-admins only see approved posts
                  if (!_isAdmin) {
                    docs = docs
                        .where((d) =>
                            (d.data() as Map<String, dynamic>)['status'] ==
                            'approved')
                        .toList();
                  }
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
                        child: _PostCard(docId: e.value.id, data: data),
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
  final String docId;
  final Map<String, dynamic> data;
  const _PostCard({required this.docId, required this.data});
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
    final status = widget.data['status'] as String? ?? 'approved';
    final createdAt = widget.data['createdAt'] as Timestamp?;
    final catColor = _categoryColor(category);
    final isPending = status == 'pending';
    final so = _hov ? 10.0 : 6.0;

    final screenW = MediaQuery.of(context).size.width;
    final isMobile = screenW < 600;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BlogDetailPage(docId: widget.docId, data: widget.data),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hov = true),
        onExit: (_) => setState(() => _hov = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(_hov ? -2 : 0, _hov ? -2 : 0, 0),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                  if (isPending) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.accentYellow, width: 1.5),
                      ),
                      child: Text("PENDING",
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: 0.5)),
                    ),
                  ],
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
                      fontSize: isMobile ? 16 : 18,
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
      ),
    );
  }
}
