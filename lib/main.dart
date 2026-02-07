import 'package:flutter/material.dart';
import 'theme.dart';  // Import theme
import 'nav.dart';    // Import nav

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fittie',
      theme: AppTheme.lightTheme, // Use the custom theme
      home: const NavBar(),       // Start with the Navigation Bar
    );
  }
}