import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';
import '../services/firebase_service.dart';

class BlogDetailPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  const BlogDetailPage({super.key, required this.docId, required this.data});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  bool _isAdmin = false;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final admin = await FirebaseService().isAdmin();
    if (mounted) setState(() => _isAdmin = admin);
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post approved!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to approve: $e")),
        );
        setState(() => _acting = false);
      }
    }
  }

  Future<void> _reject() async {
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
            "This will remove the post permanently. The author won't be notified.",
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post rejected.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to reject: $e")),
        );
        setState(() => _acting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] ?? 'Untitled';
    final content = widget.data['content'] ?? '';
    final author = widget.data['author'] ?? 'Anonymous';
    final authorEmail = widget.data['authorEmail'] ?? '';
    final category = widget.data['category'] ?? 'General';
    final status = widget.data['status'] as String? ?? 'approved';
    final createdAt = widget.data['createdAt'] as Timestamp?;
    final tags =
        (widget.data['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final catColor = _categoryColor(category);
    final isPending = status == 'pending';

    return BrutalistPageShell(
      title: title,
      subtitle: "By $author",
      children: [
        _buildContent(
          context,
          title: title,
          content: content,
          author: author,
          authorEmail: authorEmail,
          category: category,
          catColor: catColor,
          createdAt: createdAt,
          tags: tags,
          isPending: isPending,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required String title,
    required String content,
    required String author,
    required String authorEmail,
    required String category,
    required Color catColor,
    required Timestamp? createdAt,
    required List<String> tags,
    required bool isPending,
  }) {
    final screenW = MediaQuery.of(context).size.width;
    final isMobile = screenW < 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Container(
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
                border: Border.all(color: AppColors.borderBlack, width: 3),
                boxShadow: const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(6, 6))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + status + time row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      BrutalistTag(
                          label: category.toUpperCase(), color: catColor),
                      if (isPending)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.accentYellow, width: 1.5),
                          ),
                          child: Text("PENDING REVIEW",
                              style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                  letterSpacing: 0.5)),
                        ),
                      Text(_timeAgo(createdAt),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSoft)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                          height: 1.2)),
                  const SizedBox(height: 24),

                  // Full content
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: AppColors.bgCream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.borderBlack.withOpacity(0.08),
                          width: 1.5),
                    ),
                    child: Text(content,
                        style: GoogleFonts.inter(
                            fontSize: isMobile ? 14 : 16,
                            color: AppColors.textDark,
                            height: 1.7)),
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  if (tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: catColor, width: 1.5),
                                ),
                                child: Text(t.toUpperCase(),
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: catColor,
                                        letterSpacing: 0.5)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Author info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.borderBlack.withOpacity(0.1),
                          width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.borderBlack, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            author.isNotEmpty ? author[0].toUpperCase() : "?",
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: catColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(author,
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark)),
                              if (authorEmail.isNotEmpty)
                                Text(authorEmail,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSoft)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Admin actions for pending posts
                  if (_isAdmin && isPending) ...[
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.accentYellow, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.admin_panel_settings_rounded,
                                  size: 20, color: AppColors.textDark),
                              const SizedBox(width: 8),
                              Text("ADMIN REVIEW",
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                      letterSpacing: 1)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_acting)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        AppColors.primaryTeal),
                                    strokeWidth: 2.5),
                              ),
                            )
                          else
                            isMobile
                                ? Column(
                                    children: [
                                      _actionButton(
                                        label: "APPROVE POST",
                                        icon: Icons.check_rounded,
                                        color: const Color(0xFF22C55E),
                                        onTap: _approve,
                                      ),
                                      const SizedBox(height: 10),
                                      _actionButton(
                                        label: "REJECT POST",
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
                                          label: "APPROVE POST",
                                          icon: Icons.check_rounded,
                                          color: const Color(0xFF22C55E),
                                          onTap: _approve,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _actionButton(
                                          label: "REJECT POST",
                                          icon: Icons.close_rounded,
                                          color: const Color(0xFFE53E3E),
                                          onTap: _reject,
                                        ),
                                      ),
                                    ],
                                  ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
            const SizedBox(width: 8),
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
