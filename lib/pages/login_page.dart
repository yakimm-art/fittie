import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'signup_page.dart';
import 'verify_email_page.dart'; // 🟢 ADDED
import 'dashboard_page.dart';   // 🟢 ADDED

// --- SHARED THEME CONSTANTS ---
class AppColors {
  static const bgCream = Color(0xFFFDFBF7);
  static const primaryTeal = Color(0xFF38B2AC);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const errorRed = Color(0xFFE53E3E);
  static const borderBlack = Color(0xFF1F2937);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Attempt Sign In
      final user = await _firebaseService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (user != null) {
        // 2. CHECK VERIFICATION
        await user.reload(); // Get fresh status
        
        if (mounted) {
          if (!user.emailVerified) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => const VerifyEmailPage())
            );
          } else {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => const DashboardPage())
            );
          }
        }
      }
      
    } catch (e) {
      // 🟢 FIXED ERROR LOGIC: Handles both Exception objects and String errors from service
      String message = "An unexpected error occurred.";
      String errorStr = e.toString().toLowerCase();

      // Check for specific credential errors to show your custom message
      if (errorStr.contains('user-not-found') || 
          errorStr.contains('invalid-credential') || 
          errorStr.contains('wrong-password') ||
          errorStr.contains('no user record')) {
        message = "This user does not exist.";
      } 
      else if (errorStr.contains('invalid-email')) {
        message = "Invalid email format.";
      } 
      else if (errorStr.contains('too-many-requests')) {
        message = "Too many attempts. Try again later.";
      } 
      else if (errorStr.contains('network-request-failed')) {
        message = "Check your internet connection.";
      }
      else {
        // Use the raw error message if it's a specific string from Firebase
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
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: Stack(
        children: [
          const Positioned.fill(child: DotGridBackground()),
          const BackgroundBlobs(),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FittieLogo(size: 80),
                    const SizedBox(height: 32),
                    Text(
                      "Welcome Back!",
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your fitness journey continues here.",
                      style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSoft, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 48),
                    
                    _PopTextField(controller: _emailCtrl, label: "Email Address", icon: Icons.email_outlined),
                    const SizedBox(height: 20),
                    _PopTextField(controller: _passCtrl, label: "Password", icon: Icons.lock_outline, isPassword: true),
                    
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {}, 
                        child: Text("Forgot Password?", style: GoogleFonts.inter(color: AppColors.textSoft, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    SquishyButton(
                      label: _isLoading ? "LOGGING IN..." : "LOG IN",
                      isLarge: true,
                      onTap: _isLoading ? null : _handleLogin,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New to Fittie? ", style: GoogleFonts.inter(color: AppColors.textSoft, fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage())),
                          child: Text("Create Account", style: GoogleFonts.inter(color: AppColors.primaryTeal, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            top: 0, left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderBlack, width: 2),
                      boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))],
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _PopTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;

  const _PopTextField({required this.controller, required this.label, required this.icon, this.isPassword = false});

  @override
  State<_PopTextField> createState() => _PopTextFieldState();
}

class _PopTextFieldState extends State<_PopTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderBlack, width: 2),
        boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: GoogleFonts.inter(color: AppColors.textSoft.withOpacity(0.6), fontWeight: FontWeight.w500),
          prefixIcon: Icon(widget.icon, color: AppColors.textSoft),
          suffixIcon: widget.isPassword 
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSoft,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }
}

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
        Positioned(top: -100, right: -100, child: _Blob(500, const Color(0xFFE6FFFA))),
        Positioned(top: 300, left: -50, child: _Blob(400, const Color(0xFFFFF5F7))),
        Positioned(bottom: -50, right: 100, child: _Blob(300, const Color(0xFFEBF8FF))),
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
    return Container(width: size, height: size, decoration: BoxDecoration(color: color.withOpacity(0.8), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)));
  }
}

class FittieLogo extends StatelessWidget {
  final double size;
  final Color color;
  const FittieLogo({super.key, required this.size, this.color = AppColors.textDark});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(size, size), painter: _FittieLogoPainter(outlineColor: color));
}

class _FittieLogoPainter extends CustomPainter {
  final Color outlineColor;
  _FittieLogoPainter({required this.outlineColor});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final headRadius = size.width * 0.45;
    final earRadius = size.width * 0.15;
    final fillPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = size.width * 0.08..strokeCap = StrokeCap.round;
    canvas.drawCircle(center.translate(-headRadius * 0.7, -headRadius * 0.6), earRadius, fillPaint);
    canvas.drawCircle(center.translate(-headRadius * 0.7, -headRadius * 0.6), earRadius, strokePaint);
    canvas.drawCircle(center.translate(headRadius * 0.7, -headRadius * 0.6), earRadius, fillPaint);
    canvas.drawCircle(center.translate(headRadius * 0.7, -headRadius * 0.6), earRadius, strokePaint);
    final headRect = Rect.fromCenter(center: center, width: size.width * 0.9, height: size.height * 0.75);
    canvas.drawOval(headRect, fillPaint);
    canvas.drawOval(headRect, strokePaint);
    final featurePaint = Paint()..color = outlineColor..style = PaintingStyle.fill;
    final eyeSize = size.width * 0.08;
    canvas.drawCircle(center.translate(-headRadius * 0.35, -headRadius * 0.05), eyeSize / 2, featurePaint);
    canvas.drawCircle(center.translate(headRadius * 0.35, -headRadius * 0.05), eyeSize / 2, featurePaint);
    canvas.drawOval(Rect.fromCenter(center: center.translate(0, headRadius * 0.2), width: size.width * 0.12, height: size.width * 0.08), featurePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SquishyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLarge;
  const SquishyButton({super.key, required this.label, this.onTap, this.isLarge = false});
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
      child: AnimatedScale(scale: _isPressed ? 0.95 : 1.0, duration: const Duration(milliseconds: 100), child: Container(width: double.infinity, alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(color: AppColors.primaryTeal, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppColors.borderBlack, width: 2), boxShadow: _isPressed ? [] : [const BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))]), child: Text(widget.label, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)))),
    );
  }
}

class GoogleFonts {
  static TextStyle inter({Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing, double? height}) {
    return TextStyle(fontFamily: null, color: color, fontSize: fontSize, fontWeight: fontWeight, letterSpacing: letterSpacing, height: height);
  }
}