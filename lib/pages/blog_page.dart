import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Blog",
      subtitle:
          "Share your fitness journey, tips, and ideas with the Fittie community.",
      children: [
        _SubmitSection(),
        const SizedBox(height: 56),
        _CommunityPosts(),
        const SizedBox(height: 80),
      ],
    );
  }
}

// --- BLOG SUBMISSION FORM ---
class _SubmitSection extends StatefulWidget {
  @override
  State<_SubmitSection> createState() => _SubmitSectionState();
}

class _SubmitSectionState extends State<_SubmitSection> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  String _selectedCategory = "General";
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  final _categories = [
    "General",
    "Training Tips",
    "Nutrition",
    "Progress Update",
    "Feature Idea",
    "Community",
  ];

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      setState(() => _error = "Title and content are required.");
      return;
    }
    if (_authorCtrl.text.trim().isEmpty) {
      setState(() => _error = "Please enter your name or handle.");
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('blog_posts').add({
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'author': _authorCtrl.text.trim(),
        'authorUid': user?.uid ?? 'anonymous',
        'authorEmail': user?.email ?? 'anonymous',
        'category': _selectedCategory,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
      });

      _titleCtrl.clear();
      _contentCtrl.clear();
      _authorCtrl.clear();
      setState(() {
        _submitting = false;
        _submitted = true;
        _selectedCategory = "General";
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _submitted = false);
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = "Failed to submit. Please try again.";
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
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
                          color: AppColors.accentYellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.borderBlack, width: 2),
                        ),
                        child: const Icon(Icons.edit_note_rounded,
                            size: 24, color: AppColors.accentYellow),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Submit a Post",
                                style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                    letterSpacing: -0.5)),
                            Text(
                                "Share your workout wins, tips, or ideas with the community.",
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: AppColors.textSoft)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Author field
                  _FieldLabel("YOUR NAME / HANDLE"),
                  const SizedBox(height: 8),
                  _BlogTextField(
                    controller: _authorCtrl,
                    hint: "e.g. FitBear123",
                    maxLines: 1,
                  ),
                  const SizedBox(height: 20),

                  // Title field
                  _FieldLabel("POST TITLE"),
                  const SizedBox(height: 8),
                  _BlogTextField(
                    controller: _titleCtrl,
                    hint: "Give your post a catchy title...",
                    maxLines: 1,
                  ),
                  const SizedBox(height: 20),

                  // Category
                  _FieldLabel("CATEGORY"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final sel = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primaryTeal : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.borderBlack, width: 2),
                            boxShadow: sel
                                ? const [
                                    BoxShadow(
                                        color: AppColors.borderBlack,
                                        offset: Offset(3, 3))
                                  ]
                                : const [
                                    BoxShadow(
                                        color: AppColors.borderBlack,
                                        offset: Offset(2, 2))
                                  ],
                          ),
                          child: Text(cat,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      sel ? Colors.white : AppColors.textDark)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Content
                  _FieldLabel("CONTENT"),
                  const SizedBox(height: 8),
                  _BlogTextField(
                    controller: _contentCtrl,
                    hint:
                        "Write your post here... Share your experience, tips, or ideas.",
                    maxLines: 8,
                  ),
                  const SizedBox(height: 24),

                  // Error / success
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53E3E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFE53E3E), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_rounded,
                                size: 18, color: Color(0xFFE53E3E)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE53E3E))),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_submitted)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF22C55E), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 18, color: Color(0xFF22C55E)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text("Post submitted successfully! 🎉",
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF22C55E))),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _submitting ? null : _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _submitting
                              ? AppColors.textSoft
                              : AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.borderBlack, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                                color: AppColors.borderBlack,
                                offset: Offset(4, 4))
                          ],
                        ),
                        child: Center(
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text("SUBMIT POST",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text("Posts are reviewed before being visible.",
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSoft)),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: 1));
  }
}

class _BlogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _BlogTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderBlack, width: 2),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSoft),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
