import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'signup_page.dart';
import 'verify_email_page.dart';
import 'dashboard_page.dart';

// --- SHARED THEME CONSTANTS ---
class AppColors {
  // New gradient palette
  static const mintGreen = Color(0xFFC4F7E5);
  static const limeYellow = Color(0xFFE8F5A3);
  static const cardSurface = Color(0xFFFFFEFC);

  static const bgCream = Color(0xFFFDFBF7);
  static const primaryTeal = Color(0xFF38B2AC);
  static const primaryLight = Color(0xFFB2F5EA);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const errorRed = Color(0xFFE53E3E);
  static const borderBlack = Color(0xFF1F2937);
  static const accentYellow = Color(0xFFF6E05E);
  static const accentPink = Color(0xFFFED7E2);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _rememberMe = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Set persistence based on Remember Me
      await FirebaseAuth.instance.setPersistence(
        _rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );

      final user = await _firebaseService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (user != null) {
        await user.reload();
        if (mounted) {
          if (!user.emailVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          }
        }
      }
    } catch (e) {
      String message = "An unexpected error occurred.";
      String errorStr = e.toString().toLowerCase();

      if (errorStr.contains('user-not-found') ||
          errorStr.contains('invalid-credential') ||
          errorStr.contains('wrong-password') ||
          errorStr.contains('no user record')) {
        message = "This user does not exist.";
      } else if (errorStr.contains('invalid-email')) {
        message = "Invalid email format.";
      } else if (errorStr.contains('too-many-requests')) {
        message = "Too many attempts. Try again later.";
      } else if (errorStr.contains('network-request-failed')) {
        message = "Check your internet connection.";
      } else {
        message = e.toString().replaceAll('Exception: ', '');
      }

      if (mounted) _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderBlack, width: 2),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mintGreen, AppColors.limeYellow],
          ),
        ),
        child: Stack(
          children: [
            if (isDesktop)
              // ===== DESKTOP: SPLIT LAYOUT =====
              Row(
                children: [
                  // --- LEFT BRANDING PANEL ---
                  Expanded(
                    flex: 5,
                    child: _BrandingPanel(),
                  ),
                  // --- RIGHT FORM PANEL ---
                  Expanded(
                    flex: 5,
                    child: _buildFormPanel(isDesktop),
                  ),
                ],
              )
            else
              // ===== MOBILE: FORM ONLY =====
              _buildFormPanel(false),

            // --- BACK BUTTON ---
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _BackButton(onTap: () => Navigator.pop(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPanel(bool isDesktop) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 56 : 24,
          vertical: 32,
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDesktop) ...[
                    Center(child: FittieLogo(size: 64)),
                    const SizedBox(height: 8),
                    Center(
                      child: Text("Fittie",
                          style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: -1)),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- HEADING ---
                  Text("Welcome back",
                      style: GoogleFonts.inter(
                          fontSize: isDesktop ? 36 : 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          letterSpacing: -1.2,
                          height: 1.1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("Pick up where you left off",
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textSoft,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // --- EMAIL FIELD ---
                  _FieldLabel("Email Address"),
                  const SizedBox(height: 8),
                  _PopTextField(
                      controller: _emailCtrl,
                      hint: "you@example.com",
                      icon: Icons.email_outlined),
                  const SizedBox(height: 20),

                  // --- PASSWORD FIELD ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FieldLabel("Password"),
                      GestureDetector(
                        onTap: () {},
                        child: Text("Forgot?",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _PopTextField(
                      controller: _passCtrl,
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      isPassword: true),

                  const SizedBox(height: 16),

                  // --- REMEMBER ME ---
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _rememberMe
                                ? AppColors.primaryTeal
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: _rememberMe
                                    ? AppColors.borderBlack
                                    : AppColors.textSoft,
                                width: 2),
                            boxShadow: _rememberMe
                                ? const [
                                    BoxShadow(
                                        color: AppColors.borderBlack,
                                        offset: Offset(1.5, 1.5))
                                  ]
                                : [],
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text("Remember me",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- LOG IN BUTTON ---
                  SquishyButton(
                    label: _isLoading ? "LOGGING IN..." : "LOG IN",
                    isLarge: true,
                    onTap: _isLoading ? null : _handleLogin,
                  ),

                  const SizedBox(height: 20),

                  // --- TRUST BADGES ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TrustBadge(
                          icon: Icons.lock_rounded, label: "256-bit SSL"),
                      const SizedBox(width: 16),
                      _TrustBadge(
                          icon: Icons.verified_user_rounded,
                          label: "GDPR Safe"),
                      const SizedBox(width: 16),
                      _TrustBadge(icon: Icons.block_rounded, label: "No Spam"),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- SIGN UP LINK ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.borderBlack.withOpacity(0.15),
                            width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("New to Fittie? ",
                              style: GoogleFonts.inter(
                                  color: AppColors.textSoft,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignUpPage())),
                            child: Text("Create Account →",
                                style: GoogleFonts.inter(
                                    color: AppColors.primaryTeal,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14)),
                          ),
                        ],
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

// ============================================================
// BRANDING PANEL (left side on desktop)
// ============================================================
class _BrandingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryTeal,
        border: Border(
          right: BorderSide(color: AppColors.borderBlack, width: 3),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BrandDotsPainter())),
          Positioned.fill(
              child: CustomPaint(painter: _DiagonalStripesPainter())),
          Positioned.fill(
              child: CustomPaint(painter: _LoginGrainPainter(opacity: 0.06))),

          // --- FLOATING STICKERS (percentage-positioned) ---
          const Positioned(
              top: 80, left: 40, child: _FloatingSticker("💪", 48, -6)),
          const Positioned(
              top: 200, right: 60, child: _FloatingSticker("🏋️", 40, 8)),
          const Positioned(
              bottom: 200, left: 80, child: _FloatingSticker("🧘", 44, -4)),
          const Positioned(
              bottom: 100, right: 40, child: _FloatingSticker("🔥", 38, 12)),

          // --- CONTENT: fills height, no scroll ---
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final compact = h < 700;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 28 : 40,
                    vertical: compact ? 16 : 28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // -- Logo + Brand (compact) --
                          Container(
                            padding: EdgeInsets.all(compact ? 10 : 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.borderBlack, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                    color: AppColors.borderBlack,
                                    offset: Offset(4, 4))
                              ],
                            ),
                            child: FittieLogo(size: compact ? 36 : 48),
                          ),
                          SizedBox(height: compact ? 10 : 16),
                          Text("Fittie",
                              style: GoogleFonts.inter(
                                  fontSize: compact ? 30 : 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -2)),
                          SizedBox(height: compact ? 6 : 8),
                          Transform.rotate(
                            angle: -0.03,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: compact ? 5 : 7),
                              decoration: BoxDecoration(
                                color: AppColors.accentYellow,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: AppColors.borderBlack, width: 2.5),
                                boxShadow: const [
                                  BoxShadow(
                                      color: AppColors.borderBlack,
                                      offset: Offset(3, 3))
                                ],
                              ),
                              child: Text("YOUR AI FITNESS BUDDY",
                                  style: GoogleFonts.inter(
                                      fontSize: compact ? 10 : 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                      letterSpacing: 2)),
                            ),
                          ),
                          SizedBox(height: compact ? 16 : 24),

                          // -- WORKOUT CARD (clips if tight) --
                          Flexible(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.borderBlack, width: 2.5),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: AppColors.borderBlack,
                                        offset: Offset(5, 5))
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Session Header
                                    Container(
                                      padding:
                                          EdgeInsets.all(compact ? 10 : 14),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryTeal
                                            .withOpacity(0.06),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(18)),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: compact ? 38 : 44,
                                            height: compact ? 38 : 44,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox.expand(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: 0.65,
                                                    strokeWidth: 3.5,
                                                    backgroundColor: AppColors
                                                        .textSoft
                                                        .withOpacity(0.15),
                                                    valueColor:
                                                        const AlwaysStoppedAnimation(
                                                            AppColors
                                                                .primaryTeal),
                                                  ),
                                                ),
                                                Text("65%",
                                                    style: GoogleFonts.inter(
                                                        fontSize:
                                                            compact ? 10 : 11,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: AppColors
                                                            .textDark)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: compact ? 10 : 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Full Body Power",
                                                    style: GoogleFonts.inter(
                                                        fontSize:
                                                            compact ? 14 : 15,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color:
                                                            AppColors.textDark,
                                                        letterSpacing: -0.3)),
                                                Text("4 of 6 exercises done",
                                                    style: GoogleFonts.inter(
                                                        fontSize:
                                                            compact ? 10 : 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .textSoft)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4ADE80)
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFF4ADE80),
                                                  width: 1.5),
                                            ),
                                            child: Text("LIVE",
                                                style: GoogleFonts.inter(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w900,
                                                    color:
                                                        const Color(0xFF22C55E),
                                                    letterSpacing: 1)),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Exercise List
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: compact ? 12 : 14,
                                          vertical: compact ? 4 : 8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _ExerciseRow("Goblet Squats",
                                              "3 × 12", true, "🏋️"),
                                          _ExerciseRow(
                                              "Push-ups", "4 × 15", true, "💪"),
                                          _ExerciseRow(
                                              "Lunges", "3 × 10", true, "🦵"),
                                          _ExerciseRow("Plank Hold", "3 × 45s",
                                              true, "🧘"),
                                        ],
                                      ),
                                    ),

                                    // UP NEXT bar
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          compact ? 10 : 14,
                                          0,
                                          compact ? 10 : 14,
                                          compact ? 8 : 12),
                                      padding:
                                          EdgeInsets.all(compact ? 10 : 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryTeal,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: AppColors.borderBlack,
                                            width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: AppColors.borderBlack,
                                              offset: Offset(3, 3))
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: compact ? 32 : 36,
                                            height: compact ? 32 : 36,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: compact ? 18 : 22),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("UP NEXT: Deadlifts",
                                                    style: GoogleFonts.inter(
                                                        fontSize:
                                                            compact ? 12 : 13,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.white)),
                                                Text(
                                                    "Set 1 of 4 · 8 reps · 60kg",
                                                    style: GoogleFonts.inter(
                                                        fontSize:
                                                            compact ? 10 : 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white
                                                            .withOpacity(0.8))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Stats footer
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: compact ? 8 : 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.textDark,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                bottom: Radius.circular(18)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _SessionStat(
                                              Icons.timer_outlined, "24:30"),
                                          _SessionStat(
                                              Icons
                                                  .local_fire_department_rounded,
                                              "320 cal"),
                                          _SessionStat(Icons.favorite_rounded,
                                              "142 bpm"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SMALL HELPER WIDGETS
// ============================================================

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: 0.3));
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryTeal),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSoft)),
      ],
    );
  }
}

class _FloatingSticker extends StatelessWidget {
  final String emoji;
  final double size;
  final double angle;
  const _FloatingSticker(this.emoji, this.size, this.angle);
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderBlack, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(3, 3))
          ],
        ),
        child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final String name;
  final String sets;
  final bool done;
  final String emoji;
  const _ExerciseRow(this.name, this.sets, this.done, this.emoji);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.primaryTeal.withOpacity(0.1)
                  : AppColors.textSoft.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                    color: done ? AppColors.textDark : AppColors.textSoft)),
          ),
          Text(sets,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSoft)),
          const SizedBox(width: 8),
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: done
                ? AppColors.primaryTeal
                : AppColors.textSoft.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}

class _SessionStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _SessionStat(this.icon, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryTeal),
        const SizedBox(width: 5),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
      ],
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});
  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderBlack, width: 2.5),
            boxShadow: _pressed
                ? []
                : const [
                    BoxShadow(
                        color: AppColors.borderBlack, offset: Offset(3, 3))
                  ],
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textDark, size: 20),
        ),
      ),
    );
  }
}

// --- FORM TEXT FIELD ---
class _PopTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _PopTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<_PopTextField> createState() => _PopTextFieldState();
}

class _PopTextFieldState extends State<_PopTextField> {
  late bool _obscureText;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? AppColors.primaryTeal : AppColors.borderBlack,
          width: _focused ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _focused
                ? AppColors.primaryTeal.withOpacity(0.3)
                : AppColors.borderBlack,
            offset: _focused ? const Offset(0, 0) : const Offset(3, 3),
            blurRadius: _focused ? 8 : 0,
          ),
        ],
      ),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: GoogleFonts.inter(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(
                color: AppColors.textSoft.withOpacity(0.5),
                fontWeight: FontWeight.w500,
                fontSize: 15),
            prefixIcon: Icon(widget.icon,
                color: _focused ? AppColors.primaryTeal : AppColors.textSoft,
                size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textSoft,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOM PAINTERS
// ============================================================

class _LoginGrainPainter extends CustomPainter {
  final double opacity;
  _LoginGrainPainter({this.opacity = 0.035});
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 6000; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      paint.color =
          (rng.nextBool() ? Colors.black : Colors.white).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BrandDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08);
    const step = 32.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke;
    const gap = 60.0;
    for (double i = -size.height; i < size.width + size.height; i += gap) {
      canvas.drawLine(
          Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// SHARED WIDGETS (kept for backward compatibility)
// ============================================================

class DotGridBackground extends StatelessWidget {
  const DotGridBackground({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: DotGridPainter());
}

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textSoft.withOpacity(0.1);
    const step = 40.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BackgroundBlobs extends StatelessWidget {
  const BackgroundBlobs({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: -100, right: -100, child: _Blob(500, const Color(0xFFE6FFFA))),
        Positioned(
            top: 300, left: -50, child: _Blob(400, const Color(0xFFFFF5F7))),
        Positioned(
            bottom: -50,
            right: 100,
            child: _Blob(300, const Color(0xFFEBF8FF))),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob(this.size, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: color.withOpacity(0.8), shape: BoxShape.circle),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent)));
  }
}

class FittieLogo extends StatelessWidget {
  final double size;
  final Color color;
  const FittieLogo(
      {super.key, required this.size, this.color = AppColors.textDark});
  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(size, size), painter: _FittieLogoPainter(outlineColor: color));
}

class _FittieLogoPainter extends CustomPainter {
  final Color outlineColor;
  _FittieLogoPainter({required this.outlineColor});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final headRadius = size.width * 0.45;
    final earRadius = size.width * 0.15;
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center.translate(-headRadius * 0.7, -headRadius * 0.6),
        earRadius, fillPaint);
    canvas.drawCircle(center.translate(-headRadius * 0.7, -headRadius * 0.6),
        earRadius, strokePaint);
    canvas.drawCircle(center.translate(headRadius * 0.7, -headRadius * 0.6),
        earRadius, fillPaint);
    canvas.drawCircle(center.translate(headRadius * 0.7, -headRadius * 0.6),
        earRadius, strokePaint);
    final headRect = Rect.fromCenter(
        center: center, width: size.width * 0.9, height: size.height * 0.75);
    canvas.drawOval(headRect, fillPaint);
    canvas.drawOval(headRect, strokePaint);
    final featurePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.fill;
    final eyeSize = size.width * 0.08;
    canvas.drawCircle(center.translate(-headRadius * 0.35, -headRadius * 0.05),
        eyeSize / 2, featurePaint);
    canvas.drawCircle(center.translate(headRadius * 0.35, -headRadius * 0.05),
        eyeSize / 2, featurePaint);
    canvas.drawOval(
        Rect.fromCenter(
            center: center.translate(0, headRadius * 0.2),
            width: size.width * 0.12,
            height: size.width * 0.08),
        featurePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SquishyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLarge;
  const SquishyButton(
      {super.key, required this.label, this.onTap, this.isLarge = false});
  @override
  State<SquishyButton> createState() => _SquishyButtonState();
}

class _SquishyButtonState extends State<SquishyButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.borderBlack, width: 2),
            boxShadow: _isPressed
                ? []
                : const [
                    BoxShadow(
                        color: AppColors.borderBlack, offset: Offset(4, 4))
                  ],
          ),
          child: Text(widget.label,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1)),
        ),
      ),
    );
  }
}

class GoogleFonts {
  static TextStyle inter(
      {Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      double? letterSpacing,
      double? height}) {
    return TextStyle(
        fontFamily: null,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height);
  }
}

// Added primaryLight for consistency with landing page
class AppColorsExt {
  static const primaryLight = Color(0xFFB2F5EA);
}
