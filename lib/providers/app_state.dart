import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/ai_service.dart';

enum FittieMode { power, zen, desk }

class AppState extends ChangeNotifier {
  // --- STATE VARIABLES ---
  FittieMode _mode = FittieMode.desk;
  int _energyLevel = 50; 
  
  // Settings State
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  // Chat History (persisted to Firestore)
  final List<Map<String, dynamic>> _chatMessages = [
    {"role": "fittie", "text": "Hi! I'm Fittie. Ask me anything about your workout or health! 🐻", "timestamp": ""}
  ];
  bool _chatLoaded = false;
  final FirebaseService _firebaseService = FirebaseService();
  final AiService _aiService = AiService();

  // --- GETTERS ---
  FittieMode get mode => _mode;
  int get energyLevel => _energyLevel;
  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  bool get chatLoaded => _chatLoaded;
  AiService get aiService => _aiService;
  
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;

  // --- DYNAMIC THEME ENGINE ---
  
  // 1. Background Color
  Color get backgroundColor {
    if (_isDarkMode) return const Color(0xFF121212); // Dark Theme Background
    
    // Morphic Light Theme Backgrounds
    switch (_mode) {
      case FittieMode.power: return const Color(0xFFFFF5F5); // Light Red Tint
      case FittieMode.zen: return const Color(0xFFF0FFF4);   // Light Green Tint
      case FittieMode.desk: return const Color(0xFFFDFBF7);  // Cream
    }
  }

  // 2. Card/Surface Color
  Color get surfaceColor {
    if (_isDarkMode) return const Color(0xFF1E1E1E); // Dark Grey
    return Colors.white;
  }

  // 3. Text/Icon Color
  Color get textColor {
    if (_isDarkMode) return const Color(0xFFF7FAFC); // Off-White
    return const Color(0xFF2D3748); // Dark Grey
  }

  // 4. Primary Accent Color (Stays mostly the same, but adapts intensity)
  Color get primaryColor {
    switch (_mode) {
      case FittieMode.power: return const Color(0xFFFF6B6B); 
      case FittieMode.zen: return const Color(0xFF88D8B0);   
      case FittieMode.desk: return const Color(0xFF38B2AC);  
    }
  }

  // 5. Gradient Colors for mood-based backgrounds
  Color get gradientStart {
    if (_isDarkMode) return const Color(0xFF1A1A2E);
    switch (_mode) {
      case FittieMode.power: return const Color(0xFFFFE5E5); // Soft pink-red
      case FittieMode.zen: return const Color(0xFFC4F7E5);   // Mint green
      case FittieMode.desk: return const Color(0xFFC4F7E5);  // Mint green (default)
    }
  }

  Color get gradientEnd {
    if (_isDarkMode) return const Color(0xFF16213E);
    switch (_mode) {
      case FittieMode.power: return const Color(0xFFFFD6A5); // Soft orange
      case FittieMode.zen: return const Color(0xFFD4FCDC);   // Light lime
      case FittieMode.desk: return const Color(0xFFE8F5A3);  // Lime yellow (default)
    }
  }

  String get mascotMessage {
    switch (_mode) {
      case FittieMode.power: return "LET'S CRUSH IT! 💪";
      case FittieMode.zen: return "Breathe in... relax... 🍃";
      case FittieMode.desk: return "Time for a quick stretch? 🧘";
    }
  }

  // --- ACTIONS ---

  // 🟢 FIX: This method name was causing errors in dashboard_page.dart
  void setEnergyLevel(int value) {
    _energyLevel = value;
    _autoMorph();
    notifyListeners();
  }

  // Compatibility method if you use setEnergy(double) elsewhere
  void setEnergy(double value) {
    _energyLevel = value.toInt();
    _autoMorph();
    notifyListeners();
  }

  void _autoMorph() {
    if (_energyLevel > 70) {
      _mode = FittieMode.power;
    } else if (_energyLevel < 30) {
      _mode = FittieMode.zen;
    } else {
      _mode = FittieMode.desk;
    }
  }
  
  void setMode(FittieMode newMode) {
    _mode = newMode;
    notifyListeners();
  }

  // ⚙️ Settings Actions
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleSound(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  // Chat Actions with Firebase persistence

  /// Load chat history from Firestore on first access
  Future<void> loadChatHistory() async {
    if (_chatLoaded) return;
    try {
      final saved = await _firebaseService.loadChatHistory();
      if (saved.isNotEmpty) {
        _chatMessages.clear();
        _chatMessages.addAll(saved);
      }
      _chatLoaded = true;
      notifyListeners();
    } catch (e) {
      print("Error loading chat history: $e");
      _chatLoaded = true;
    }
  }

  void addChatMessage(String role, String text) {
    _chatMessages.add({
      "role": role,
      "text": text,
      "timestamp": DateTime.now().toIso8601String(),
    });
    notifyListeners();

    // Persist to Firestore (debounced, non-blocking)
    _firebaseService.saveChatHistory(_chatMessages);
  }

  void clearChat() {
    _chatMessages.clear();
    _chatMessages.add({
      "role": "fittie",
      "text": "Hi! I'm Fittie. Ask me anything about your workout or health! 🐻",
      "timestamp": DateTime.now().toIso8601String(),
    });
    // Reset the AI chat session so it doesn't carry stale context
    _aiService.resetChatSession();
    notifyListeners();
    _firebaseService.saveChatHistory(_chatMessages);
  }
}