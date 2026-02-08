import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';
import '../services/firebase_service.dart';

class BlogAdminPage extends StatelessWidget {
  const BlogAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Admin Review",
      subtitle: "Approve or reject community blog post submissions.",
      children: [
        _AdminGuard(),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ADMIN GUARD — verifies admin access before showing panel
// ---------------------------------------------------------------------------
class _AdminGuard extends StatefulWidget {
  @override
  State<_AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<_AdminGuard> {
  bool _loading = true;
  bool _isAdmin = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _isLoggedIn = false;
      });
      return;
    }
    final admin = await FirebaseService().isAdmin();
    setState(() {
      _loading = false;
      _isLoggedIn = true;
      _isAdmin = admin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _loadingCard();
    }
    if (!_isLoggedIn || !_isAdmin) {
      return _accessDenied();
    }
    return _AdminPanel();
  }

  Widget _loadingCard() {
    return LayoutBuilder(builder: (context, _) {
      final isMobile = MediaQuery.of(context).size.width < 600;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 32 : 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
                border: Border.all(color: AppColors.borderBlack, width: 3),
                boxShadow: const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(6, 6))
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryTeal),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _accessDenied() {
    return LayoutBuilder(builder: (context, _) {
      final isMobile = MediaQuery.of(context).size.width < 600;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
            child: FadeSlideIn(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 36 : 56,
                    horizontal: isMobile ? 20 : 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
                  border: Border.all(color: AppColors.borderBlack, width: 3),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.borderBlack, offset: Offset(6, 6))
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53E3E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFE53E3E).withOpacity(0.3),
                            width: 2),
                      ),
                      child: const Icon(Icons.admin_panel_settings_outlined,
                          size: 36, color: Color(0xFFE53E3E)),
                    ),
                    const SizedBox(height: 20),
                    Text("Admin Access Required",
                        style: GoogleFonts.inter(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text(
                        "Only the admin account can review and approve blog posts.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: isMobile ? 13 : 15,
                            color: AppColors.textSoft,
                            height: 1.5)),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.textDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.borderBlack, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                                color: AppColors.borderBlack,
                                offset: Offset(3, 3))
                          ],
                        ),
                        child: Text("GO BACK",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// ADMIN PANEL — pending posts stream + approve / reject
// ---------------------------------------------------------------------------
class _AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin setup hint
              _AdminSetupCard(),
              const SizedBox(height: 32),

              // Section header
              FadeSlideIn(
                child: Row(
                  children: [
                    const BrutalistTag(
                        label: "PENDING REVIEW", color: Color(0xFFE53E3E)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53E3E).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.hourglass_top_rounded,
                          size: 18, color: Color(0xFFE53E3E)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pending posts stream
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService().getPendingPostsStream(),
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
                            Text("Loading pending posts...",
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: AppColors.textSoft)),
                          ],
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return _emptyQueue();
                  }

                  return Column(
                    children: docs.asMap().entries.map((e) {
                      final doc = e.value;
                      final data = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: FadeSlideIn(
                          delayMs: e.key * 80,
                          child: _PendingPostCard(
                            docId: doc.id,
                            data: data,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyQueue() {
    return FadeSlideIn(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E).withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF22C55E).withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 48, color: Color(0xFF22C55E)),
            const SizedBox(height: 16),
            Text("All caught up!",
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text("No pending posts to review. Check back later.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSoft, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ADMIN SETUP CARD — claim admin if none exists
// ---------------------------------------------------------------------------
class _AdminSetupCard extends StatefulWidget {
  @override
  State<_AdminSetupCard> createState() => _AdminSetupCardState();
}

class _AdminSetupCardState extends State<_AdminSetupCard> {
  bool _checked = false;
  bool _hasAdmin = true; // assume true until checked

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final has = await FirebaseService().hasAnyAdmin();
    if (mounted) {
      setState(() {
        _checked = true;
        _hasAdmin = has;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show this card if no admin exists (shouldn't happen normally since
    // the user is already admin to see this page, but useful for first-time setup)
    if (!_checked || _hasAdmin) return const SizedBox.shrink();

    return FadeSlideIn(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.accentYellow.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentYellow, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 20, color: AppColors.accentYellow),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  "No admin account found. The admin role is assigned via the Firestore console.",
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PENDING POST CARD with approve / reject actions
// ---------------------------------------------------------------------------
class _PendingPostCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _PendingPostCard({required this.docId, required this.data});

  @override
  State<_PendingPostCard> createState() => _PendingPostCardState();
}

class _PendingPostCardState extends State<_PendingPostCard> {
  bool _acting = false;

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

  Future<void> _approve() async {
    setState(() => _acting = true);
    try {
      await FirebaseService().approveBlogPost(widget.docId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to approve: $e")),
        );
      }
    }
    if (mounted) setState(() => _acting = false);
  }

  Future<void> _reject() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderBlack, width: 3),
        ),
        title: Text("Reject Post?",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w900, color: AppColors.textDark)),
        content: Text(
            "This will remove the post from the review queue. The author won't be notified.",
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSoft, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("CANCEL",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSoft,
                    letterSpacing: 0.5)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("REJECT",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE53E3E),
                    letterSpacing: 0.5)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _acting = true);
    try {
      await FirebaseService().rejectBlogPost(widget.docId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to reject: $e")),
        );
      }
    }
    if (mounted) setState(() => _acting = false);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] ?? 'Untitled';
    final content = widget.data['content'] ?? '';
    final author = widget.data['author'] ?? 'Anonymous';
    final authorEmail = widget.data['authorEmail'] ?? '';
    final category = widget.data['category'] ?? 'General';
    final createdAt = widget.data['createdAt'] as Timestamp?;
    final catColor = _categoryColor(category);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(color: AppColors.borderBlack, width: 3),
        boxShadow: [
          BoxShadow(
              color: AppColors.borderBlack,
              offset: Offset(isMobile ? 4 : 6, isMobile ? 4 : 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: category + time + pending badge
          isMobile
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    BrutalistTag(
                        label: category.toUpperCase(), color: catColor),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.accentYellow.withOpacity(0.5),
                            width: 1.5),
                      ),
                      child: Text("PENDING",
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentOrange,
                              letterSpacing: 0.5)),
                    ),
                    Text(_timeAgo(createdAt),
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSoft)),
                  ],
                )
              : Row(
                  children: [
                    BrutalistTag(
                        label: category.toUpperCase(), color: catColor),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.accentYellow.withOpacity(0.5),
                            width: 1.5),
                      ),
                      child: Text("PENDING",
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentOrange,
                              letterSpacing: 0.5)),
                    ),
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
          const SizedBox(height: 10),

          // Full content (admin sees everything)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColors.bgCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.borderBlack.withOpacity(0.1), width: 1.5),
            ),
            child: Text(content,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textDark, height: 1.6)),
          ),
          const SizedBox(height: 16),

          // Author info
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderBlack, width: 1.5),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(author,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  if (authorEmail.isNotEmpty)
                    Text(authorEmail,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSoft)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action buttons
          if (_acting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryTeal),
                  strokeWidth: 2.5,
                ),
              ),
            )
          else
            isMobile
                ? Column(
                    children: [
                      _actionButton(
                        label: "APPROVE",
                        icon: Icons.check_rounded,
                        color: const Color(0xFF22C55E),
                        onTap: _approve,
                      ),
                      const SizedBox(height: 10),
                      _actionButton(
                        label: "REJECT",
                        icon: Icons.close_rounded,
                        color: const Color(0xFFE53E3E),
                        onTap: _reject,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          label: "APPROVE",
                          icon: Icons.check_rounded,
                          color: const Color(0xFF22C55E),
                          onTap: _approve,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          label: "REJECT",
                          icon: Icons.close_rounded,
                          color: const Color(0xFFE53E3E),
                          onTap: _reject,
                        ),
                      ),
                    ],
                  ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderBlack, width: 2.5),
          boxShadow: const [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(3, 3))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
