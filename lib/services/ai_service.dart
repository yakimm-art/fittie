import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static String get _geminiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _giphyKey => dotenv.env['GIPHY_API_KEY'] ?? '';

  late final GenerativeModel _model;
  late final GenerativeModel _chatModel;

  // Curated fallback library using reliable Giphy fitness GIFs
  // These are direct links to fitness-specific GIFs from verified fitness accounts
  static const Map<String, String> _curatedExerciseGifs = {
    // Upper Body
    'push up': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNDg5OTlkMDg4YWU2OGE4OGI5YjY5NjIxZjg5NzQxNjQwMGI5ZjRhZSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/7YCC7lbXAoOVy/giphy.gif',
    'push ups': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNDg5OTlkMDg4YWU2OGE4OGI5YjY5NjIxZjg5NzQxNjQwMGI5ZjRhZSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/7YCC7lbXAoOVy/giphy.gif',
    'pushup': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNDg5OTlkMDg4YWU2OGE4OGI5YjY5NjIxZjg5NzQxNjQwMGI5ZjRhZSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/7YCC7lbXAoOVy/giphy.gif',
    'pushups': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNDg5OTlkMDg4YWU2OGE4OGI5YjY5NjIxZjg5NzQxNjQwMGI5ZjRhZSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/7YCC7lbXAoOVy/giphy.gif',
    'plank': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNzAzMjY1NTMwYWZhMjVhMjJlZTZlNDdkZDNjMjNmNmZlMzdhMDRjYSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xT8qBeEqnpdMbIbtVS/giphy.gif',
    'bicep curl': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNmU0Y2Q3ZjExMjRlZjQwNzVkMmQ1NzAzMjQ5ZTVkZTllMTVjMzVjMSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3o6ZsZKbgw4QVWEbzq/giphy.gif',
    'tricep dip': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExYTdiNmQxZDdjNjk3YjRlMGQ2YTIxN2UwMGIxZjgxOTg3ZDY2ZTQyYSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3o7btNhMBytxAM6YBa/giphy.gif',
    'shoulder press': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExY2QxMmM4ZjAxNjg4ZmNmMjE4MjExMjZhODc4NjVjMDE0YjU5NjBkNCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xUNd9IMywss6NTIghO/giphy.gif',
    
    // Lower Body  
    'squat': 'https://media.giphy.com/media/1qfKN8Dt0CRdCRxz9q/giphy.gif',
    'squats': 'https://media.giphy.com/media/1qfKN8Dt0CRdCRxz9q/giphy.gif',
    'lunge': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWQzNWI5ZTFjNmE1ZjM2MTI2ZDY4ZmE3NTY2NjYyNDUxMTc1ZjdiMCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/1n4FT4KRQkDvK0IO4X/giphy.gif',
    'lunges': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWQzNWI5ZTFjNmE1ZjM2MTI2ZDY4ZmE3NTY2NjYyNDUxMTc1ZjdiMCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/1n4FT4KRQkDvK0IO4X/giphy.gif',
    'calf raise': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExODEyNjZmMzg4YTQ5MjRiNmY1NmRmYjQxNjRmOGYzNjU0ZjU0NmE2NCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3oriO04qxVReM5rJEA/giphy.gif',
    'glute bridge': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMzhjNTA4ZjQ2ZDcwMGMzMjEyZDg2OGI4Y2E0Y2JlY2UxNjg0Y2Y5ZiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xT8qBhrlNooHBYR9f2/giphy.gif',
    'leg raise': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExY2U3YjgyODI0MGRhZDg5OTI1NWI4ZGU4YmQ1ZDQ0MzE3NTdlYmMyMyZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xT8qBvH1pAhtfSx52U/giphy.gif',
    
    // Core
    'crunch': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExYzM4OWQ2OTExMWUxMjA2YmRjMjkxYWM2OTJhMzU2MjU5YTMzMzIxYiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xT8qBit7YomT80d0M8/giphy.gif',
    'crunches': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExYzM4OWQ2OTExMWUxMjA2YmRjMjkxYWM2OTJhMzU2MjU5YTMzMzIxYiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xT8qBit7YomT80d0M8/giphy.gif',
    'sit up': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMGEzZDE0MjI5NmYxMjhlZTgyZWQ0Y2E0NjQ1YmUyZWI3Y2Y2ZWI1YyZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3o6ozh46EbuWRRYMxy/giphy.gif',
    'sit ups': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMGEzZDE0MjI5NmYxMjhlZTgyZWQ0Y2E0NjQ1YmUyZWI3Y2Y2ZWI1YyZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3o6ozh46EbuWRRYMxy/giphy.gif',
    'mountain climber': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMDY1MTZhNGU3YjRjOTc0MTBjNDNkODU4MjkzMjBmZjQyYWRiNTg1OCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/5t9IcXoBn9jvGvjbMr/giphy.gif',
    'mountain climbers': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMDY1MTZhNGU3YjRjOTc0MTBjNDNkODU4MjkzMjBmZjQyYWRiNTg1OCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/5t9IcXoBn9jvGvjbMr/giphy.gif',
    'russian twist': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExZjM5NjUwN2Q0YmRmZjM4OTU5NmE5ZTNhNmZlMjIzZjc3N2VhMjNjNyZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xT8qBgvOUl9mj2fe6c/giphy.gif',
    'bicycle crunch': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExN2M5YjY0NTVjMDU1YzU2MTNhZmRkYTA3ZDgyZjVjODQ5OGYyMmRhNyZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xT8qBvgKeMvMGSJNgA/giphy.gif',
    
    // Cardio & Full Body
    'jumping jack': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExN2RhMDJjZWM5NjI0NmE4M2RjYWQ5M2JlODQ1YTcyOWFmMTAyMDU3MSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/l0MYyEsjhIXdzv9PG/giphy.gif',
    'jumping jacks': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExN2RhMDJjZWM5NjI0NmE4M2RjYWQ5M2JlODQ1YTcyOWFmMTAyMDU3MSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/l0MYyEsjhIXdzv9PG/giphy.gif',
    'burpee': 'https://media.giphy.com/media/23hPPMRgPxbNBlPQe3/giphy.gif',
    'burpees': 'https://media.giphy.com/media/23hPPMRgPxbNBlPQe3/giphy.gif',
    'high knees': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExOTY5YjY1ZmE2YjM0YWM0YjAwMzMxZjNhMTU5MGRjNTRmNjc0ZTU4OSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3o7btNRptqBgLSKR2w/giphy.gif',
    'jump rope': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMzUzODdhYjQ1MWMzOWI1ZjgxZmM0YjE3YjE4ZWY0YzEyNDhkMDY2MSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/1n4FT4KRQkDvK0IO4X/giphy.gif',
    'box jump': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExZTcwMmU1MDZmMzJiZjgyYmI1ODA5YTViNzhmMGNiY2MxYTQwN2JmZSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/l0MYw6Cu1TfY3gsWk/giphy.gif',
    
    // Stretches
    'stretch': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExYWY2MTJhMjJhNDhmMTJlZTcxZTM4Y2E4YTE5OWNmZmY5MjhkMGQ5YSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/12UlfHpF05ielO/giphy.gif',
    'arm stretch': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExYWY2MTJhMjJhNDhmMTJlZTcxZTM4Y2E4YTE5OWNmZmY5MjhkMGQ5YSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/12UlfHpF05ielO/giphy.gif',
    'leg stretch': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNmUxZjZlM2Y2MTk3ZDU4YTM2Y2M0ZDkwY2Q5MTkxMjE5ZmZkMGFjNiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xT8qBsOjMOcdeGJIU8/giphy.gif',
    'shoulder stretch': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExZmRhNjBiMjY1Y2Y2ZjY5NjM4MjY2Y2Q2MDNmYzk1YTI3NjkxMjBjYiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/l46CbAuxFk2Cz0s2A/giphy.gif',
  };

  static const String _personaPrompt = '''
    You are Fittie, a fitness AI bear. 
    1. Your "instruction" text should be friendly and supportive. 
    2. Your replies should be detailed but in 2-3 sentences, no bullet points or bold texts. 
    3. You should embody "Fittie", a cute bear that guides with exercise, very energetic, supportive and use emoji.
    4. HOWEVER, your "data" (Exercise Names) must be GENERIC and STANDARD.
  ''';

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash',
      apiKey: _geminiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    _chatModel = GenerativeModel(model: 'gemini-3-flash', apiKey: _geminiKey);
  }

  Future<List<dynamic>> generateWorkout(
    String mode,
    int energy,
    Map<String, dynamic> userContext, {
    int workoutCount = 5,
  }) async {
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
      
      TASK: Create a $workoutCount-step workout routine with exactly $workoutCount exercises.
      
      ⚠️ EXERCISE NAME RULES:
      - Use STANDARD, COMMON exercise names from this list when possible:
        Push Ups, Squats, Lunges, Plank, Jumping Jacks, Burpees, 
        Crunches, Sit Ups, Mountain Climbers, High Knees, 
        Bicep Curl, Tricep Dip, Leg Raise, Glute Bridge, Russian Twist
      - Keep names simple and recognizable
      
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
          "instruction": "Specific bear-themed advice based on their stats."
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

      // 🟢 FETCH VISUALS - prioritize curated library, then Giphy search
      final List<dynamic> exercisesWithVisuals = await Future.wait(
        exercises.map((ex) async {
          String exerciseName = ex['name'] ?? "exercise";
          String gifUrl = await _fetchExerciseGif(exerciseName);
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

  /// Fetches exercise GIF from curated library or Giphy search
  Future<String> _fetchExerciseGif(String exerciseName) async {
    // Normalize the exercise name for matching
    String normalizedName = exerciseName.toLowerCase().trim();
    
    // 1. First check curated library for instant reliable results
    String? curatedGif = _findCuratedGif(normalizedName);
    if (curatedGif != null) {
      return curatedGif;
    }

    // 2. Try Giphy search with fitness-focused terms
    if (_giphyKey.isNotEmpty) {
      try {
        String? giphyGif = await _searchGiphyFitness(normalizedName);
        if (giphyGif != null) {
          return giphyGif;
        }
      } catch (e) {
        print("Giphy Error: $e");
      }
    }

    // 3. Return default fallback
    return _getFallbackGif();
  }

  /// Search curated library with fuzzy matching
  String? _findCuratedGif(String exerciseName) {
    // Direct match
    if (_curatedExerciseGifs.containsKey(exerciseName)) {
      return _curatedExerciseGifs[exerciseName];
    }
    
    // Partial match - check if any key is contained in the exercise name
    for (var entry in _curatedExerciseGifs.entries) {
      if (exerciseName.contains(entry.key) || entry.key.contains(exerciseName)) {
        return entry.value;
      }
    }
    
    // Word-based match - check if key words match
    List<String> nameWords = exerciseName.split(' ');
    for (var entry in _curatedExerciseGifs.entries) {
      List<String> keyWords = entry.key.split(' ');
      for (var word in nameWords) {
        if (word.length > 3 && keyWords.any((k) => k.contains(word) || word.contains(k))) {
          return entry.value;
        }
      }
    }
    
    return null;
  }

  /// Search Giphy for fitness-specific GIFs
  Future<String?> _searchGiphyFitness(String exerciseName) async {
    try {
      // Add fitness keywords to avoid memes
      final searchQuery = Uri.encodeComponent("$exerciseName exercise fitness workout");
      final uri = Uri.parse(
        'https://api.giphy.com/v1/gifs/search?api_key=$_giphyKey&q=$searchQuery&limit=5&rating=g&lang=en',
      );
      
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          // Try to find a GIF from a fitness-related source
          for (var gif in data['data']) {
            String? username = gif['username']?.toString().toLowerCase() ?? '';
            // Prefer verified fitness accounts
            if (username.contains('fit') || 
                username.contains('gym') || 
                username.contains('workout') ||
                username.contains('exercise') ||
                username.contains('health')) {
              return gif['images']['original']['url'];
            }
          }
          // Fallback to first result
          return data['data'][0]['images']['original']['url'];
        }
      }
    } catch (e) {
      print("Giphy search error: $e");
    }
    return null;
  }

  String _getFallbackGif() {
    // Generic workout GIF as ultimate fallback
    return "https://media.giphy.com/media/1qfKN8Dt0CRdCRxz9q/giphy.gif";
  }

  List<dynamic> _getFallbackRoutine() {
    return [
      {
        "name": "Squats",
        "duration": 30,
        "calories": 8,
        "intensity": 5,
        "muscle_group": "Legs",
        "emoji": "🦵",
        "instruction":
            "Stand with feet shoulder-width apart, lower down like sitting in a chair! You got this! 🐻",
        "visual_url": _curatedExerciseGifs['squat'],
      },
      {
        "name": "Push Ups",
        "duration": 30,
        "calories": 6,
        "intensity": 6,
        "muscle_group": "Upper Body",
        "emoji": "💪",
        "instruction":
            "Start in plank position, lower your chest to the ground and push back up! Bear strong! 🐻",
        "visual_url": _curatedExerciseGifs['push up'],
      },
      {
        "name": "Jumping Jacks",
        "duration": 30,
        "calories": 10,
        "intensity": 7,
        "muscle_group": "Full Body",
        "emoji": "⭐",
        "instruction":
            "Jump and spread arms and legs wide, then jump back together! Keep the energy up! 🐻",
        "visual_url": _curatedExerciseGifs['jumping jack'],
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
