import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/kawaii_bear.dart'; 
import 'dashboard_page.dart'; 

class AppColors {
  static const bgCream = Color(0xFFFDFBF7);
  static const primaryTeal = Color(0xFF38B2AC);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const borderBlack = Color(0xFF1F2937); 
}

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      // 🟢 FIXED: Removed sendVerificationEmail() from here.
      // The signup process already sends the first email. 
      // Calling it here causes the "Too Many Requests" error.
      
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );

      // Start the cooldown for the manual resend button immediately
      _startResendCooldown();
    }
  }

  // 🟢 ADDED: Helper to manage the button cooldown state
  void _startResendCooldown() async {
    setState(() => canResendEmail = false);
    await Future.delayed(const Duration(seconds: 30));
    if (mounted) setState(() => canResendEmail = true);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    
    if (mounted) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      });
    }

    if (isEmailVerified) {
      timer?.cancel();
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const DashboardPage())
        );
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      _startResendCooldown();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) return const DashboardPage();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("SECURITY CHECK", 
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => FirebaseAuth.instance.signOut(), 
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 220, 
                width: 220, 
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: KawaiiPolarBear(),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.borderBlack, width: 3),
                  boxShadow: const [
                    BoxShadow(color: AppColors.borderBlack, offset: Offset(8, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Verify your email',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.1),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSoft, height: 1.5),
                        children: [
                          const TextSpan(text: "We sent a magic link to\n"),
                          TextSpan(
                            text: '${FirebaseAuth.instance.currentUser?.email}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryTeal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryTeal, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Listening for verification...',
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: canResendEmail ? 1.0 : 0.6,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.borderBlack, width: 2.5),
                      ),
                    ).copyWith(
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: canResendEmail ? [
                          const BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))
                        ] : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh_rounded),
                          const SizedBox(width: 8),
                          Text(canResendEmail ? "RESEND EMAIL" : "COOLDOWN (30s)", 
                            style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: Text("CANCEL & LOGOUT", 
                  style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleFonts {
  static TextStyle inter({
    Color? color, 
    double? fontSize, 
    FontWeight? fontWeight, 
    double? letterSpacing, 
    double? height, 
    FontStyle? fontStyle
  }) {
    return TextStyle(
      color: color, 
      fontSize: fontSize, 
      fontWeight: fontWeight, 
      letterSpacing: letterSpacing, 
      height: height, 
      fontStyle: fontStyle,
      fontFamily: 'Inter',
    );
  }
}