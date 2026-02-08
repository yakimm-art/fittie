import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landing_page.dart';
import 'brutalist_page_shell.dart';
import '../services/firebase_service.dart';

class BlogEntryPage extends StatelessWidget {
  const BlogEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageShell(
      title: "Write a Post",
      subtitle: "Share your fitness journey with the Fittie community.",
      children: [
        _AdminGate(),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _AdminGate extends StatefulWidget {
  @override
  State<_AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<_AdminGate> {
  bool _loading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _loading = false;
      _isLoggedIn = user != null;
    });
  }

  Widget _loadingWidget(bool isMobile) {
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
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isMobile = screenW < 600;

    if (_loading) {
      return _loadingWidget(isMobile);
    }

    if (!_isLoggedIn) {
      return _AccessDenied(
        icon: Icons.lock_outline_rounded,
        title: "Login Required",
        desc: "You need to be logged in to submit a post.",
        isMobile: isMobile,
      );
    }

    return _BlogForm(isMobile: isMobile);
  }
}

class _AccessDenied extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool isMobile;
  const _AccessDenied(
      {required this.icon,
      required this.title,
      required this.desc,
      this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxWidth),
          child: FadeSlideIn(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 36 : 56, horizontal: isMobile ? 20 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderBlack, width: 3),
                boxShadow: const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(6, 6))
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
                    child: Icon(icon, size: 36, color: const Color(0xFFE53E3E)),
                  ),
                  const SizedBox(height: 20),
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(desc,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 15,
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
  }
}

class _BlogForm extends StatefulWidget {
  final bool isMobile;
  const _BlogForm({this.isMobile = false});
  @override
  State<_BlogForm> createState() => _BlogFormState();
}

class _BlogFormState extends State<_BlogForm> {
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

  @override
  void initState() {
    super.initState();
    _loadAuthorName();
  }

  Future<void> _loadAuthorName() async {
    final name = await FirebaseService().getCurrentUserName();
    if (name.isNotEmpty && mounted) {
      _authorCtrl.text = name;
    }
  }

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
        'status': 'pending',
      });

      _titleCtrl.clear();
      _contentCtrl.clear();
      setState(() {
        _submitting = false;
        _submitted = true;
        _selectedCategory = "General";
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
    final isMobile = widget.isMobile;

    if (_submitted) {
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
                  borderRadius: BorderRadius.circular(24),
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
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF22C55E).withOpacity(0.3),
                            width: 2),
                      ),
                      child: const Icon(Icons.hourglass_top_rounded,
                          size: 40, color: Color(0xFF22C55E)),
                    ),
                    const SizedBox(height: 20),
                    Text("Post Submitted!",
                        style: GoogleFonts.inter(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text(
                        "Your post has been submitted for review. An admin will approve it before it goes live.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textSoft,
                            height: 1.5)),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.borderBlack, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                                color: AppColors.borderBlack,
                                offset: Offset(4, 4))
                          ],
                        ),
                        child: Text("BACK TO BLOG",
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
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
    }

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
                            Text("New Blog Post",
                                style: GoogleFonts.inter(
                                    fontSize: isMobile ? 18 : 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                    letterSpacing: -0.5)),
                            Text("Submit a post for admin review.",
                                style: GoogleFonts.inter(
                                    fontSize: isMobile ? 12 : 13,
                                    color: AppColors.textSoft)),
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
                    hint: "e.g. Yakim",
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
                    maxLines: 12,
                  ),
                  const SizedBox(height: 24),

                  // Error
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
                              : Text("SUBMIT FOR REVIEW",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1)),
                        ),
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
