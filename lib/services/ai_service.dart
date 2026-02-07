import 'dart:convert';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static String get _geminiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _giphyKey => dotenv.env['GIPHY_API_KEY'] ?? '';

  late final GenerativeModel _model;
  late final GenerativeModel _chatModel;

  static const String _personaPrompt = '''
    You are Fittie, a fitness AI bear. 
    1. Your "instruction" text should be friendly and supportive. 
    2. Your replies should be detailed but in 2-3 sentences, no bullet points or bold texts. 
    3. You should embody "Fittie", a cute bear that guides with exercise, very energetic, supportive and use emoji.
    4. HOWEVER, your "data" (Exercise Names) must be GENERIC and STANDARD.
  ''';

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    _chatModel = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _geminiKey);
  }

  Future<List<dynamic>> generateWorkout(
    String mode,
    int energy,
    Map<String, dynamic> userContext,
  ) async {
    final String equipment = userContext['equipment'] ?? "None";
    final String injuries = userContext['injuries'] ?? "None";
    final String notes = userContext['extraNotes'] ?? "None";
    final String stress = (userContext['stress_baseline'] ?? 50).toString();

    // Physical stats for accurate AI calorie calculation
    final String weight = userContext['weight'] ?? "70kg";
    final String height = userContext['height'] ?? "170cm";
    final String age = (userContext['age'] ?? 25).toString();

    final prompt =
        '''
      $_personaPrompt
      
      📋 USER PROFILE:
      - Energy: $energy% | Mode: $mode
      - Physicals: Age $age, Weight $weight, Height $height
      - Stress Level (0-100): $stress
      - Injuries: $injuries
      - Equipment: $equipment
      - SPECIAL NOTES: "$notes"
      
      TASK: Create a 3-step workout routine.
      
      ⚠️ CALORIE COMPUTATION RULES:
      - Use the user's weight ($weight) and the MET (Metabolic Equivalent of Task) values for the specific exercises to calculate burned calories.
      - Be realistic. A 45-second stretch is ~3-5 kcal, while 45 seconds of squats is ~8-12 kcal.
      
      ⚠️ DASHBOARD DATA RULES:
      - Assign an "intensity" level (1-10).
      - Identify the "muscle_group" (Core, Legs, Arms, Full Body, etc.).
      
      RETURN JSON ONLY:
      [
        {
          "name": "Standard Exercise Name", 
          "duration": 45,
          "calories": 12, 
          "intensity": 7,
          "muscle_group": "Legs",
          "emoji": "💪", 
          "instruction": "Specific bear-themed advice based on their stats.",
          "giphy_search_term": "clean search term" 
        }
      ]
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      String cleanText = response.text ?? "[]";
      cleanText = cleanText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      List<dynamic> exercises = jsonDecode(cleanText);

      // 🟢 FETCH VISUALS
      final List<dynamic> exercisesWithVisuals = await Future.wait(
        exercises.map((ex) async {
          String searchTerm = ex['giphy_search_term'] ?? "fitness";
          String gifUrl = await _fetchGiphyUrl(searchTerm);
          ex['visual_url'] = gifUrl;
          return ex;
        }),
      );

      return exercisesWithVisuals;
    } catch (e) {
      print("AI Error: $e");
      return _getFallbackRoutine();
    }
  }

  Future<String> _fetchGiphyUrl(String query) async {
    if (_giphyKey.isEmpty) return _getFallbackGif();

    try {
      // Prioritize ArcUNSW because they often include the exercise name text in the GIF
      String primarySearch = "$query ArcUNSW fitness";
      String? bestUrl = await _performSearch(primarySearch);

      if (bestUrl != null) return bestUrl;

      // Backup with high-quality creators
      List<String> backupUsers = [
        "8fit",
        "equinox",
        "YourHouseFitness",
        "o2fitnessclubs",
      ];
      String randomUser = backupUsers[Random().nextInt(backupUsers.length)];
      String? betterUrl = await _performSearch("$query $randomUser");

      if (betterUrl != null) return betterUrl;

      // Generic fallback
      String? fallbackUrl = await _performSearch(
        "$query exercise fitness guide",
      );
      return fallbackUrl ?? _getFallbackGif();
    } catch (e) {
      print("Giphy Error: $e");
    }
    return _getFallbackGif();
  }

  Future<String?> _performSearch(String searchQuery) async {
    try {
      final uri = Uri.parse(
        'https://api.giphy.com/v1/gifs/search?api_key=$_giphyKey&q=$searchQuery&limit=1&rating=pg&lang=en&type=gifs',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['images']['original']['url'];
        }
      }
    } catch (e) {}
    return null;
  }

  String _getFallbackGif() {
    return "https://media.giphy.com/media/26AHu1WhTobTLy89y/giphy.gif";
  }

  List<dynamic> _getFallbackRoutine() {
    return [
      {
        "name": "Bear Stretch",
        "duration": 30,
        "calories": 4,
        "intensity": 2,
        "muscle_group": "Full Body",
        "emoji": "🐻",
        "instruction":
            "Reach for the sky! Big bear stretch! You're doing great!",
        "visual_url": _getFallbackGif(),
      },
    ];
  }

  Future<String> chatWithFittie(String userMessage) async {
    final prompt = '''$_personaPrompt \nUSER: "$userMessage"\nREPLY (Short):''';
    try {
      final content = [Content.text(prompt)];
      final response = await _chatModel.generateContent(content);
      return response.text ?? "Let's workout! 🐻";
    } catch (e) {
      return "I'm having trouble connecting! Keep moving! 🐻";
    }
  }
}
