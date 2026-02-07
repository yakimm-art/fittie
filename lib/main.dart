import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for User type
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/landing_page.dart';
import 'pages/dashboard_page.dart'; // Ensure this import exists
import 'pages/verify_email_page.dart'; // Ensure this import exists
import 'providers/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fittie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      // 🔴 CHANGED: We use AuthWrapper instead of LandingPage directly
      home: const AuthWrapper(),
    );
  }
}

// 🛡️ THE GATEKEEPER
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the auth state (Logged In vs Logged Out)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // 1. If Firebase is still loading, show a spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF38B2AC))),
          );
        }

        // 2. If NO user is logged in, show the Landing Page (Login/SignUp)
        if (!snapshot.hasData) {
          return const LandingPage(); 
        }

        // 3. If User IS logged in, check if verified
        final User user = snapshot.data!;
        
        // Reload the user to ensure we aren't using cached data (optional but safer)
        // Note: authStateChanges doesn't trigger on email verification changes, 
        // so the VerifyEmailPage handles the logic of "detecting" the change and pushing to Dashboard.
        // This check is mainly for App Restarts.
        if (user.emailVerified) {
          return const DashboardPage(); // ✅ ALLOW ACCESS
        } else {
          return const VerifyEmailPage(); // ⛔ BLOCK ACCESS
        }
      },
    );
  }
}