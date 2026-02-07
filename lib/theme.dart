import 'package:flutter/material.dart';

class AppColors {
  // Main Palette
  static const bgCream = Color(0xFFFDFBF7);
  static const primaryTeal = Color(0xFF38B2AC);
  static const primaryLight = Color(0xFFB2F5EA);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  
  // Accents
  static const blush = Color(0xFFFFB6C1);
  static const white = Colors.white;
  static const error = Color(0xFFE53E3E);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgCream,
      primaryColor: AppColors.primaryTeal,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryTeal,
        secondary: AppColors.primaryLight,
        surface: AppColors.white,
        onSurface: AppColors.textDark,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgCream,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryTeal,
        unselectedItemColor: AppColors.textSoft,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}