import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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

  // Cache for the loaded exercise database
  List<dynamic> _exerciseDb = [];
  List<String> _availableExercises = [];

  Future<void> _loadExerciseDb() async {
    if (_exerciseDb.isNotEmpty) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/exercises.json');
      _exerciseDb = jsonDecode(jsonString);
      
      // Filter for bodyweight/easy exercises to guide the AI
      _availableExercises = _exerciseDb
          .where((e) => e['equipment'] == 'body only' || e['equipment'] == null)
          .map((e) => e['name'].toString())
          .toList();
          
      // Shuffle to vary recommendations if we only take top N
      _availableExercises.shuffle();
      
    } catch (e) {
      print("Error loading exercise DB: $e");
    }
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
      - YOU MUST CHOOSE from the following AVAILABLE EXERCISES list to ensure we have visual demonstrations:
      [${_availableExercises.take(60).join(', ')}]
      - If you need others, use STANDARD names like: Push Up, Squat, Plank, Jumping Jack, Burpee.
      - Keep names EXACTLY as they appear in the list if possible.
      
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
      // Load DB first
      await _loadExerciseDb();
      return await _attachVisuals(exercises);

    } catch (e) {
      print("AI Error: $e");
      List<dynamic> fallback = _getFallbackRoutine(workoutCount);
      await _loadExerciseDb(); // Ensure DB is loaded for fallback too
      return await _attachVisuals(fallback);
    }
  }

  Future<List<dynamic>> _attachVisuals(List<dynamic> exercises) async {
    final List<dynamic> exercisesWithVisuals = await Future.wait(
      exercises.map((ex) async {
        String exerciseName = ex['name'] ?? "exercise";
        
        // 1. Try to find EXACT/CLOSE match in DB first
        Map<String, dynamic>? match = _findBestMatch(exerciseName);
        List<String> visuals = [];
        
        if (match != null) {
          // 🎉 Found a local match!
          // Overwrite name to ensure UI consistency with video/image
          ex['name'] = match['name']; 
          
          if (match['images'] != null && (match['images'] as List).isNotEmpty) {
             const String baseUrl = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises/";
             visuals = (match['images'] as List).map((path) => "$baseUrl$path").toList().cast<String>();
          }
        } 
        
        // 2. If no local visuals, try Giphy/Fallback
        if (visuals.isEmpty) {
           visuals = await _fetchFallbackVisuals(exerciseName);
        }
        
        ex['visual_url'] = visuals.isNotEmpty ? visuals.first : ""; 
        ex['visuals'] = visuals;
        return ex;
      }),
    );
    return exercisesWithVisuals;
  }
  
  Map<String, dynamic>? _findBestMatch(String inputName) {
    if (_exerciseDb.isEmpty) return null;
    String normalizedInput = inputName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    // 1. Exact Name Match (insensitive)
    try {
      return _exerciseDb.firstWhere((e) => 
        (e['name'] as String).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') == normalizedInput
      );
    } catch (e) {/*ignore*/}

    // 2. Contains Match (Forward/Backward)
    try {
      return _exerciseDb.firstWhere((e) {
        String dbName = (e['name'] as String).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        return dbName.contains(normalizedInput) || normalizedInput.contains(dbName);
      });
    } catch (e) {/*ignore*/}

    // 3. Token Intersection (handling "Pushups" vs "Push Up")
    // If input has "Push" and "Up", and DB has "Push Up", that's a match.
    List<String> inputTokens = inputName.toLowerCase().split(' ').where((s) => s.length > 2).toList();
    if (inputTokens.isEmpty) return null;

    try {
      // Sort candidates by number of matched tokens
      var candidates = _exerciseDb.where((e) {
        String dbName = (e['name'] as String).toLowerCase();
        int matches = 0;
        for (var token in inputTokens) {
          if (dbName.contains(token)) matches++;
        }
        return matches >= inputTokens.length; // strict match? or >= 1?
      }).toList();
      
      if (candidates.isNotEmpty) {
        // Return most generic name (shortest length usually implies "Squat" vs "Barbell Squat")
        candidates.sort((a, b) => (a['name'] as String).length.compareTo((b['name'] as String).length));
        return candidates.first;
      }
    } catch (e) {/*ignore*/}

    return null;
  }

  Future<List<String>> _fetchFallbackVisuals(String exerciseName) async {
    String normalizedName = exerciseName.toLowerCase().trim();
    
    // Check curated
    String? curatedGif = _findCuratedGif(normalizedName);
    if (curatedGif != null) return [curatedGif];

    // Giphy Search
    if (_giphyKey.isNotEmpty) {
      try {
        String? giphyGif = await _searchGiphyFitness(normalizedName);
        if (giphyGif != null) return [giphyGif];
      } catch (e) {
        print("Giphy Error: $e");
      }
    }

    return [_getFallbackGif()];
  }

  /// Fetches exercise visuals (List of URLs) from local DB, curated library, or Giphy
  Future<List<String>> _fetchExerciseVisuals(String exerciseName) async {
    String normalizedName = exerciseName.toLowerCase().trim();
    
    // 1. Check Local DB (Best quality - slideshows)
    final dbVisuals = _findInExerciseDb(normalizedName);
    if (dbVisuals.isNotEmpty) return dbVisuals;

    // 2. Check curated Giphy library
    String? curatedGif = _findCuratedGif(normalizedName);
    if (curatedGif != null) return [curatedGif];

    // 3. Try Giphy search
    if (_giphyKey.isNotEmpty) {
      try {
        String? giphyGif = await _searchGiphyFitness(normalizedName);
        if (giphyGif != null) return [giphyGif];
      } catch (e) {
        print("Giphy Error: $e");
      }
    }

    // 4. Fallback
    return [_getFallbackGif()];
  }

  /// Fuzzy search in local JSON database
  List<String> _findInExerciseDb(String name) {
    if (_exerciseDb.isEmpty) return [];

    // Base URL for the images
    const String baseUrl = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises/";

    // Direct match
    var match = _exerciseDb.firstWhere(
      (ex) => (ex['name'] as String).toLowerCase() == name,
      orElse: () => null
    );

    // Fuzzy match
    if (match == null) {
      try {
        match = _exerciseDb.firstWhere(
          (ex) {
            String dbName = (ex['name'] as String).toLowerCase();
            return dbName.contains(name) || name.contains(dbName);
          },
          orElse: () => null
        );
      } catch (e) {
        // ignore
      }
    }

    if (match != null && match['images'] != null) {
      List<dynamic> imgs = match['images'];
      return imgs.map((path) => "$baseUrl$path").toList().cast<String>();
    }

    return [];
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

  List<dynamic> _getFallbackRoutine(int count) {
    final List<Map<String, dynamic>> pool = [
      {
        "name": "Squats",
        "duration": 30,
        "calories": 8,
        "intensity": 5,
        "muscle_group": "Legs",
        "emoji": "🦵",
        "instruction": "Stand with feet shoulder-width apart, lower down like sitting in a chair! You got this! 🐻",
      },
      {
        "name": "Push Ups",
        "duration": 30,
        "calories": 6,
        "intensity": 6,
        "muscle_group": "Upper Body",
        "emoji": "💪",
        "instruction": "Start in plank position, lower your chest to the ground and push back up! Bear strong! 🐻",
      },
      {
        "name": "Jumping Jacks",
        "duration": 30,
        "calories": 10,
        "intensity": 7,
        "muscle_group": "Full Body",
        "emoji": "⭐",
        "instruction": "Jump and spread arms and legs wide, then jump back together! Keep the energy up! 🐻",
      },
      {
        "name": "Lunges",
        "duration": 30,
        "calories": 7,
        "intensity": 6,
        "muscle_group": "Legs",
        "emoji": "xz",
        "instruction": "Step forward with one leg and lower your hips. Keep your back straight! 🐻",
      },
      {
        "name": "Plank",
        "duration": 30,
        "calories": 5,
        "intensity": 8,
        "muscle_group": "Core",
        "emoji": "🧱",
        "instruction": "Hold your body in a straight line. Engage that core! You're a sturdy bear! 🐻",
      },
      {
        "name": "High Knees",
        "duration": 30,
        "calories": 11,
        "intensity": 8,
        "muscle_group": "Cardio",
        "emoji": "🏃",
        "instruction": "Run in place bringing your knees up high! Fast paws! 🐻",
      },
      {
        "name": "Burpees",
        "duration": 30,
        "calories": 15,
        "intensity": 9,
        "muscle_group": "Full Body",
        "emoji": "🔥",
        "instruction": "Drop, push up, jump! It's tough but you're tougher! 🐻",
      },
    ];

    List<dynamic> result = [];
    for (int i = 0; i < count; i++) {
      var ex = Map<String, dynamic>.from(pool[i % pool.length]);
      // Ensure visuals are populated for fallback too
      // We can use the async visual fetcher if we want, but synchronous fallback is safer
      // Let's just use empty visuals and let the UI handle it or pre-populate common ones
      // Actually, we can just leave 'visuals' empty and let the visualizer use the fallback gif or we can try to find them
      // But _getFallbackRoutine is synchronous. 
      // Let's add standard Giphy URLs for these common ones hardcoded if needed, or better, 
      // since the UI now uses AiService to fetch visuals, we should probably fetch visuals for fallback too?
      // No, generateWorkout returns the list with visuals. 
      // If we return raw fallback here, generateWorkout's try/catch block catches AI error.
      // But wait, the try/catch block WRAPS the AI generation.
      // If AI fails, it calls _getFallbackRoutine(count).
      // AND THEN it returns that result.
      // It DOES NOT fetch visuals for the fallback routine because the visual fetching is inside the try block (lines 151-158).
      
      // So we must manually populate visuals here or move visual fetching outside try/catch?
      // Moving visual fetching outside try/catch is better.
      result.add(ex);
    }
    
    // We should probably run visual fetching on the fallback result too
    // But since this method is synchronous, we can't await.
    // We will handle this by checking if visuals are missing in the UI? 
    // Or better: make _getFallbackRoutine async? No, simpler to just populate standard GIFs here if possible.
    // Or just let the caller (generateWorkout) handle visual fetching for fallback too.
    
    return result;
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
