import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import all your pages
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/verify_email_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/workout_session_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verify = '/verify';
  static const String dashboard = '/dashboard';
  static const String workout = '/workout';
}

class AppRouter {
  // 1. Listen to Firebase Auth Changes
  // This notifies the router to re-evaluate redirects whenever the user logs in/out
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    
    // 2. Define All Routes
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.verify,
        name: 'verify',
        builder: (context, state) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.workout,
        name: 'workout',
        builder: (context, state) {
          // 3. Handle Parameter Passing (Routine & Color)
          // We expect these to be passed via the 'extra' object
          final Map<String, dynamic> args = state.extra as Map<String, dynamic>? ?? {};
          return WorkoutSessionPage(
            routine: args['routine'] ?? [],
            themeColor: args['themeColor'] ?? const Color(0xFF38B2AC),
          );
        },
      ),
    ],

    // 4. The Gatekeeper Logic (Replaces AuthWrapper)
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final bool isLoggedIn = user != null;
      final bool isVerified = user?.emailVerified ?? false;

      final String location = state.uri.toString();
      
      // Define public routes that don't require login
      final bool isPublicRoute = location == AppRoutes.home || 
                                 location == AppRoutes.login || 
                                 location == AppRoutes.signup;

      if (!isLoggedIn) {
        // If not logged in and trying to access private route, go to Home
        return isPublicRoute ? null : AppRoutes.home;
      }

      if (isLoggedIn && !isVerified) {
        // If logged in but NOT verified, force them to Verify Page
        // (Unless they are already there)
        return location == AppRoutes.verify ? null : AppRoutes.verify;
      }

      if (isLoggedIn && isVerified) {
        // If fully authenticated, prevent them from seeing Public pages
        // Send them straight to Dashboard
        if (isPublicRoute || location == AppRoutes.verify) {
          return AppRoutes.dashboard;
        }
      }

      return null; // No redirect needed
    },
  );
}

// 5. Helper Class to convert Stream to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}