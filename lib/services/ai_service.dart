import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_service.dart';

class AiService {
  static String get _geminiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  late final GenerativeModel _model;
  late final GenerativeModel _chatModel;
  late final GenerativeModel _visionModel;
  final FirebaseService _firebaseService = FirebaseService();

  // Persistent chat session with memory
  ChatSession? _chatSession;
  bool _chatInitialized = false;

  /// Maps common AI-generated exercise names → exact free-exercise-db names.
  /// This bridges the gap between what Gemini outputs and what the DB contains.
  static const Map<String, String> _exerciseSynonyms = {
    // Push variations
    'push up': 'Pushups',
    'push ups': 'Pushups',
    'push-up': 'Pushups',
    'push-ups': 'Pushups',
    'pushup': 'Pushups',
    'wide push up': 'Push-Up Wide',
    'wide push-up': 'Push-Up Wide',
    'wide push ups': 'Push-Up Wide',
    'close grip push up': 'Push-Ups - Close Triceps Position',
    'diamond push up': 'Push-Ups - Close Triceps Position',
    'diamond push-up': 'Push-Ups - Close Triceps Position',
    'decline push up': 'Decline Push-Up',
    'decline push-up': 'Decline Push-Up',
    'incline push up': 'Incline Push-Up',
    'incline push-up': 'Incline Push-Up',

    // Squat variations
    'squat': 'Bodyweight Squat',
    'squats': 'Bodyweight Squat',
    'bodyweight squat': 'Bodyweight Squat',
    'body weight squat': 'Bodyweight Squat',
    'air squat': 'Bodyweight Squat',
    'jump squat': 'Freehand Jump Squat',
    'jump squats': 'Freehand Jump Squat',
    'split squat': 'Split Squats',
    'split squats': 'Split Squats',
    'barbell squat': 'Barbell Squat',
    'back squat': 'Barbell Squat',
    'front squat': 'Front Barbell Squat',
    'goblet squat': 'Goblet Squat',
    'sumo squat': 'Sumo Deadlift',
    'sit squat': 'Sit Squats',

    // Lunge variations
    'lunge': 'Bodyweight Walking Lunge',
    'lunges': 'Bodyweight Walking Lunge',
    'walking lunge': 'Bodyweight Walking Lunge',
    'walking lunges': 'Bodyweight Walking Lunge',
    'reverse lunge': 'Crossover Reverse Lunge',
    'reverse lunges': 'Crossover Reverse Lunge',
    'barbell lunge': 'Barbell Lunge',
    'dumbbell lunge': 'Dumbbell Lunges',
    'dumbbell lunges': 'Dumbbell Lunges',

    // Core / Abs
    'crunch': 'Crunches',
    'crunches': 'Crunches',
    'sit up': 'Sit-Up',
    'sit ups': 'Sit-Up',
    'sit-up': 'Sit-Up',
    'sit-ups': 'Sit-Up',
    'plank': 'Plank',
    'mountain climber': 'Mountain Climbers',
    'mountain climbers': 'Mountain Climbers',
    'russian twist': 'Russian Twist',
    'russian twists': 'Russian Twist',
    'bicycle crunch': 'Cross-Body Crunch',
    'bicycle crunches': 'Cross-Body Crunch',
    'leg raise': 'Flat Bench Lying Leg Raise',
    'leg raises': 'Flat Bench Lying Leg Raise',
    'hanging leg raise': 'Hanging Leg Raise',
    'flutter kick': 'Flutter Kicks',
    'flutter kicks': 'Flutter Kicks',
    'reverse crunch': 'Reverse Crunch',
    'oblique crunch': 'Oblique Crunches - On The Floor',
    'dead bug': 'Dead Bug',
    'superman': 'Superman',

    // Pull / Back
    'pull up': 'Pullups',
    'pull ups': 'Pullups',
    'pull-up': 'Pullups',
    'pull-ups': 'Pullups',
    'pullup': 'Pullups',
    'pullups': 'Pullups',
    'chin up': 'Chin-Up',
    'chin ups': 'Chin-Up',
    'chin-up': 'Chin-Up',
    'inverted row': 'Inverted Row',
    'barbell row': 'Bent Over Barbell Row',
    'bent over row': 'Bent Over Barbell Row',
    'dumbbell row': 'Dumbbell Bent Over Row',

    // Chest
    'bench press': 'Barbell Bench Press - Medium Grip',
    'barbell bench press': 'Barbell Bench Press - Medium Grip',
    'incline bench press': 'Barbell Incline Bench Press - Medium Grip',
    'dumbbell bench press': 'Dumbbell Bench Press',
    'dumbbell fly': 'Dumbbell Flyes',
    'dumbbell flye': 'Dumbbell Flyes',
    'chest fly': 'Dumbbell Flyes',
    'chest dip': 'Dips - Chest Version',
    'dip': 'Dips - Triceps Version',
    'dips': 'Dips - Triceps Version',
    'tricep dip': 'Bench Dips',
    'tricep dips': 'Bench Dips',
    'bench dip': 'Bench Dips',
    'bench dips': 'Bench Dips',

    // Arms
    'bicep curl': 'Dumbbell Bicep Curl',
    'bicep curls': 'Dumbbell Bicep Curl',
    'dumbbell curl': 'Dumbbell Bicep Curl',
    'hammer curl': 'Hammer Curls',
    'hammer curls': 'Hammer Curls',
    'tricep extension': 'Dumbbell One-Arm Triceps Extension',
    'tricep kickback': 'Dumbbell Kickback',
    'skull crusher': 'EZ-Bar Skullcrusher',

    // Shoulders
    'shoulder press': 'Dumbbell Shoulder Press',
    'overhead press': 'Standing Military Press',
    'military press': 'Standing Military Press',
    'lateral raise': 'Side Lateral Raise',
    'lateral raises': 'Side Lateral Raise',
    'front raise': 'Front Dumbbell Raise',
    'front raises': 'Front Dumbbell Raise',
    'arnold press': 'Arnold Dumbbell Press',
    'shoulder shrug': 'Barbell Shrug',
    'shrug': 'Barbell Shrug',
    'shrugs': 'Barbell Shrug',

    // Legs
    'calf raise': 'Standing Calf Raises',
    'calf raises': 'Standing Calf Raises',
    'glute bridge': 'Butt Lift (Bridge)',
    'hip bridge': 'Butt Lift (Bridge)',
    'bridge': 'Butt Lift (Bridge)',
    'hip thrust': 'Butt Lift (Bridge)',
    'step up': 'Step-up with Knee Raise',
    'step ups': 'Step-up with Knee Raise',
    'glute kickback': 'Glute Kickback',
    'donkey kick': 'Glute Kickback',
    'donkey kicks': 'Glute Kickback',
    'wall sit': 'Sit Squats',
    'leg curl': 'Seated Leg Curl',
    'leg extension': 'Leg Extensions',
    'romanian deadlift': 'Romanian Deadlift With Dumbbells',
    'rdl': 'Romanian Deadlift With Dumbbells',

    // Deadlift
    'deadlift': 'Barbell Deadlift',
    'barbell deadlift': 'Barbell Deadlift',
    'sumo deadlift': 'Sumo Deadlift',

    // Cardio / Plyometric
    'jumping jack': 'Star Jump',
    'jumping jacks': 'Star Jump',
    'burpee': 'Frog Hops',
    'burpees': 'Frog Hops',
    'high knees': 'Double Leg Butt Kick',
    'high knee': 'Double Leg Butt Kick',
    'box jump': 'Bench Jump',
    'box jumps': 'Bench Jump',
    'jump rope': 'Fast Skipping',
    'skipping': 'Fast Skipping',
    'broad jump': 'Standing Long Jump',
    'tuck jump': 'Knee Tuck Jump',
    'tuck jumps': 'Knee Tuck Jump',
    'frog jump': 'Frog Hops',
    'frog jumps': 'Frog Hops',
    'scissor jump': 'Scissors Jump',
    'scissor jumps': 'Scissors Jump',

    // Stretches
    'hamstring stretch': 'Hamstring Stretch',
    'quad stretch': 'All Fours Quad Stretch',
    'hip flexor stretch': 'Kneeling Hip Flexor',
    'shoulder stretch': 'Shoulder Stretch',
    'chest stretch': 'Dynamic Chest Stretch',
    'back stretch': 'Dynamic Back Stretch',
    'calf stretch': 'Calf Stretch Hands Against Wall',
    'groin stretch': 'Side Lying Groin Stretch',
    'child pose': "Child's Pose",
    "child's pose": "Child's Pose",
    'cat stretch': 'Cat Stretch',
    'cat cow': 'Cat Stretch',
    'arm circles': 'Arm Circles',
    'neck stretch': 'Side Neck Stretch',
    'tricep stretch': 'Triceps Stretch',

    // Misc
    'inchworm': 'Inchworm',
    'bear crawl': 'Spider Crawl',
    'spider crawl': 'Spider Crawl',
    'handstand push up': 'Handstand Push-Ups',
    'pike push up': 'Handstand Push-Ups',
    'ab roller': 'Ab Roller',
    'plyo push up': 'Plyo Push-up',
    'side plank': 'Side Bridge',
    'side bridge': 'Side Bridge',
    'kettlebell swing': 'One-Arm Kettlebell Swings',
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

    // Vision model for gym equipment recognition
    _visionModel = GenerativeModel(
      model: 'gemini-3-flash',
      apiKey: _geminiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  // Cache for the loaded exercise database
  List<dynamic> _exerciseDb = [];
  List<String> _availableExercises = [];

  Future<void> _loadExerciseDb() async {
    if (_exerciseDb.isNotEmpty) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/exercises.json');
      _exerciseDb = jsonDecode(jsonString);
      _exerciseDb.shuffle(); // Shuffle so the AI gets varied suggestions
      
      // Build available exercise names for the AI prompt
      _availableExercises = _exerciseDb
          .where((e) => e['images'] != null && (e['images'] as List).isNotEmpty)
          .map((e) => e['name'].toString())
          .toList();
          
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

    // LONG CONTEXT: Fetch entire workout history for progression analysis
    String workoutHistory = "No prior history available.";
    try {
      workoutHistory = await _firebaseService.getWorkoutHistorySummary(maxWorkouts: 50);
    } catch (e) {
      print("Could not load workout history for context: $e");
    }

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
      
      📊 LONG-TERM WORKOUT HISTORY (Use this for intelligent progression):
      $workoutHistory
      
      🧠 PROGRESSION RULES (Based on workout history above):
      - If user has been doing the same exercises repeatedly, introduce new variations to prevent plateaus.
      - If intensity trends show improvement, slightly increase difficulty.
      - If a muscle group is overworked (high frequency), suggest exercises for underworked groups.
      - If user missed several days, ease them back in with lower intensity.
      - Factor in the total sessions completed for progressive overload.
      
      TASK: Create a $workoutCount-step workout routine with exactly $workoutCount exercises.
      
      ⚠️ CRITICAL — EXERCISE NAME RULES:
      - You MUST pick exercise names from this database. These are the ONLY names that have visual demonstrations:
      [${_availableExercises.take(100).join(', ')}]
      - Use the EXACT spelling from the list above (e.g. "Pushups" not "Push Up", "Bodyweight Squat" not "Squat").
      - If user has specific equipment, pick exercises from the list that match.
      - Do NOT invent exercise names. Only use names from the list above.
      - Prioritize exercises that are common and well-known.
      
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
          "instruction": "Specific bear-themed advice based on their stats and history."
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

      // Fetch visuals from ExerciseDB for the generated exercises
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
    const String baseUrl = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/";

    final List<dynamic> exercisesWithVisuals = await Future.wait(
      exercises.map((ex) async {
        String exerciseName = ex['name'] ?? "exercise";
        List<String> visuals = [];

        // Find best match in the exercise DB using synonym map + fuzzy scoring
        Map<String, dynamic>? match = _findBestMatch(exerciseName);

        if (match != null) {
          // Overwrite name with DB name for UI consistency
          ex['name'] = match['name'];

          if (match['images'] != null && (match['images'] as List).isNotEmpty) {
            visuals = (match['images'] as List)
                .map((path) => "$baseUrl$path")
                .toList()
                .cast<String>();
          }
        }

        // If no direct match, try muscle-group fallback from the DB
        if (visuals.isEmpty) {
          visuals = _getMuscleGroupFallbackVisuals(
            ex['muscle_group'] ?? '',
            exerciseName,
          );
        }

        ex['visual_url'] = visuals.isNotEmpty ? visuals.first : "";
        ex['visuals'] = visuals;
        return ex;
      }),
    );
    return exercisesWithVisuals;
  }
  
  /// Robust exercise matching: synonym map → exact → normalized contains → scored token match.
  Map<String, dynamic>? _findBestMatch(String inputName) {
    if (_exerciseDb.isEmpty) return null;
    final String lowerInput = inputName.toLowerCase().trim();

    // ── 1. Synonym map (highest priority — handles "push up" → "Pushups" etc.) ──
    final String? synonymTarget = _exerciseSynonyms[lowerInput];
    if (synonymTarget != null) {
      try {
        return _exerciseDb.firstWhere(
          (e) => (e['name'] as String).toLowerCase() == synonymTarget.toLowerCase(),
        );
      } catch (_) {}
    }

    // Also check if any synonym key is a substring of the input (e.g. "close grip push up" contains "push up")
    // But only do this after checking the full input as a key above.
    for (final entry in _exerciseSynonyms.entries) {
      if (lowerInput.contains(entry.key) && entry.key.length >= 4) {
        try {
          return _exerciseDb.firstWhere(
            (e) => (e['name'] as String).toLowerCase() == entry.value.toLowerCase(),
          );
        } catch (_) {}
      }
    }

    // ── 2. Exact normalized match (strip non-alphanumeric) ──
    final String normalizedInput = lowerInput.replaceAll(RegExp(r'[^a-z0-9 ]'), '').trim();
    try {
      return _exerciseDb.firstWhere((e) {
        final String dbName = (e['name'] as String).toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').trim();
        return dbName == normalizedInput;
      });
    } catch (_) {}

    // ── 3. Substring match (input inside DB name or DB name inside input) ──
    try {
      return _exerciseDb.firstWhere((e) {
        final String dbName = (e['name'] as String).toLowerCase();
        return dbName.contains(lowerInput) || lowerInput.contains(dbName);
      });
    } catch (_) {}

    // ── 4. Scored token intersection — rank all DB entries by match quality ──
    final List<String> inputTokens = normalizedInput
        .split(' ')
        .where((s) => s.length > 2)
        .toList();
    if (inputTokens.isEmpty) return null;

    int bestScore = 0;
    Map<String, dynamic>? bestCandidate;

    for (final ex in _exerciseDb) {
      final String dbName = (ex['name'] as String).toLowerCase();
      int score = 0;
      for (final token in inputTokens) {
        if (dbName.contains(token)) score += token.length; // longer token matches score higher
      }
      // Bonus: penalize overly long DB names (prefer "Crunches" over "Cross-Body Crunch on Stability Ball")
      if (score > 0) {
        // Normalize by input token coverage
        final int totalInputChars = inputTokens.fold(0, (sum, t) => sum + t.length);
        final double coverage = score / totalInputChars;
        if (coverage >= 0.5 && score > bestScore) {
          bestScore = score;
          bestCandidate = ex;
        }
      }
    }

    return bestCandidate;
  }

  /// When no name match is found, find an exercise in the DB with the same muscle group.
  List<String> _getMuscleGroupFallbackVisuals(String muscleGroup, String exerciseName) {
    if (_exerciseDb.isEmpty) return [];
    const String baseUrl = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/";

    // Map UI muscle groups to DB primaryMuscles values
    final Map<String, List<String>> muscleMap = {
      'legs': ['quadriceps', 'hamstrings', 'glutes', 'calves', 'adductors', 'abductors'],
      'core': ['abdominals', 'abductors'],
      'abs': ['abdominals'],
      'arms': ['biceps', 'triceps', 'forearms'],
      'upper body': ['chest', 'shoulders', 'triceps', 'biceps'],
      'chest': ['chest'],
      'back': ['lats', 'middle back', 'lower back', 'traps'],
      'shoulders': ['shoulders'],
      'full body': ['quadriceps', 'chest', 'shoulders', 'abdominals'],
      'glutes': ['glutes'],
      'cardio': ['quadriceps', 'hamstrings', 'calves'],
    };

    final String groupLower = muscleGroup.toLowerCase();
    final List<String> targetMuscles = muscleMap[groupLower] ?? [];

    if (targetMuscles.isEmpty) return [];

    // Find first DB exercise matching the muscle group that has images
    for (final ex in _exerciseDb) {
      final List<dynamic> primaryMuscles = ex['primaryMuscles'] ?? [];
      final bool muscleMatch = primaryMuscles.any(
        (m) => targetMuscles.contains((m as String).toLowerCase()),
      );
      if (muscleMatch && ex['images'] != null && (ex['images'] as List).isNotEmpty) {
        return (ex['images'] as List)
            .map((path) => "$baseUrl$path")
            .toList()
            .cast<String>();
      }
    }

    return [];
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
      // We leave 'visuals' empty and let _attachVisuals handle DB matching
      // since the UI now uses the ExerciseDB images.
      // If we return raw fallback here, generateWorkout's try/catch block catches AI error.
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

  /// Initialize chat session with full user context and conversation history.
  /// Uses Gemini's long context window to maintain memory across sessions.
  Future<void> _initializeChatSession(List<Map<String, dynamic>> previousMessages) async {
    if (_chatInitialized) return;

    // Fetch user profile and workout history for deep context
    String userProfile = "";
    String workoutHistory = "";
    try {
      userProfile = await _firebaseService.getUserProfileSummary();
      workoutHistory = await _firebaseService.getWorkoutHistorySummary(maxWorkouts: 30);
    } catch (e) {
      print("Error loading context for chat: $e");
    }

    final systemPrompt = '''
$_personaPrompt

$userProfile

📊 USER'S COMPLETE WORKOUT HISTORY:
$workoutHistory

IMPORTANT MEMORY RULES:
- You have access to the user's ENTIRE workout history above. Reference it when giving advice.
- If the user mentions past workouts, you can see exactly what they did and when.
- Track their progression and congratulate improvements.
- Notice patterns (overtraining specific muscles, skipping days, intensity changes).
- Suggest long-term programming adjustments based on their history.
- Remember what was discussed earlier in this conversation.
- Be specific: "Last Tuesday you did 8 intensity squats, let's try 9 today!" 
''';

    // Build conversation history from previous messages
    List<Content> history = [];
    
    // Add system context as first message
    history.add(Content.text(systemPrompt));
    history.add(Content.model([TextPart("I understand! I'm Fittie, your fitness bear coach. I have your complete workout history loaded and I'm ready to give you personalized advice based on your progress! 🐻")]));

    // Replay previous conversation messages (up to last 40 for context window)
    final recentMessages = previousMessages.length > 40 
        ? previousMessages.sublist(previousMessages.length - 40) 
        : previousMessages;
    
    for (var msg in recentMessages) {
      if (msg['role'] == 'user') {
        history.add(Content.text(msg['text'] ?? ''));
      } else {
        history.add(Content.model([TextPart(msg['text'] ?? '')]));
      }
    }

    _chatSession = _chatModel.startChat(history: history);
    _chatInitialized = true;
  }

  /// Reset the chat session (called when user clears chat)
  void resetChatSession() {
    _chatSession = null;
    _chatInitialized = false;
  }

  Future<String> chatWithFittie(String userMessage, {List<Map<String, dynamic>> previousMessages = const []}) async {
    try {
      // Initialize session with full context if not already done
      await _initializeChatSession(previousMessages);

      // Send message through the persistent chat session
      final response = await _chatSession!.sendMessage(Content.text(userMessage));
      return response.text ?? "Let's workout! 🐻";
    } catch (e) {
      print("Chat error: $e");
      // Fallback to stateless call if session fails
      try {
        final prompt = '''$_personaPrompt \nUSER: "$userMessage"\nREPLY (Short):''';
        final content = [Content.text(prompt)];
        final response = await _chatModel.generateContent(content);
        return response.text ?? "Let's workout! 🐻";
      } catch (e2) {
        return "I'm having trouble connecting! Keep moving! 🐻";
      }
    }
  }

  // ===========================================================================
  // MULTIMODAL VISION: Gym Equipment Recognition
  // ===========================================================================

  /// Analyzes a photo of the user's gym/home setup and identifies equipment.
  /// Uses Gemini 3's vision capabilities.
  Future<Map<String, dynamic>> analyzeGymPhoto(Uint8List imageBytes) async {
    final prompt = '''
You are Fittie, a fitness AI bear with expert knowledge of gym equipment.

Analyze this photo of the user's workout space / home gym and identify ALL exercise equipment visible.

For each piece of equipment found, provide:
1. The equipment name (standard fitness terminology)
2. Approximate count/quantity if applicable
3. Any notable details (weight range, brand, condition)

Also assess the workout space:
- Available floor space (small/medium/large)
- Indoor or outdoor
- Any safety concerns

RETURN JSON ONLY:
{
  "equipment_list": ["Dumbbells", "Resistance Bands", "Yoga Mat", ...],
  "equipment_details": [
    {"name": "Dumbbells", "quantity": "2 pairs", "details": "Adjustable, 5-25 lbs"},
    ...
  ],
  "space_assessment": {
    "floor_space": "medium",
    "environment": "indoor",
    "safety_notes": "Clear space, good lighting"
  },
  "summary": "A friendly 1-sentence summary of their setup as Fittie the bear."
}
''';

    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      final response = await _visionModel.generateContent(content);
      String cleanText = response.text ?? "{}";
      cleanText = cleanText.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleanText);
    } catch (e) {
      print("Vision analysis error: $e");
      return {
        "equipment_list": ["Body only"],
        "equipment_details": [],
        "space_assessment": {"floor_space": "unknown", "environment": "unknown"},
        "summary": "I couldn't quite see the equipment, but no worries - bodyweight exercises are amazing! 🐻"
      };
    }
  }

  /// Generates a workout based on equipment identified from a photo.
  /// Combines vision results with user context for maximum personalization.
  Future<List<dynamic>> generateWorkoutFromPhoto(
    Uint8List imageBytes,
    String mode,
    int energy,
    Map<String, dynamic> userContext, {
    int workoutCount = 5,
  }) async {
    // Step 1: Analyze the photo
    final equipmentAnalysis = await analyzeGymPhoto(imageBytes);
    final detectedEquipment = (equipmentAnalysis['equipment_list'] as List<dynamic>?)?.join(', ') ?? 'Body only';
    final spaceAssessment = equipmentAnalysis['space_assessment'] ?? {};

    // Step 2: Override equipment in user context with detected equipment
    final enrichedContext = Map<String, dynamic>.from(userContext);
    enrichedContext['equipment'] = detectedEquipment;
    enrichedContext['extraNotes'] = 
      "DETECTED FROM PHOTO: $detectedEquipment. "
      "Space: ${spaceAssessment['floor_space'] ?? 'unknown'}. "
      "Environment: ${spaceAssessment['environment'] ?? 'unknown'}. "
      "${spaceAssessment['safety_notes'] ?? ''}. "
      "${userContext['extraNotes'] ?? ''}";

    // Step 3: Generate workout with the enriched context
    await _loadExerciseDb();
    return await generateWorkout(mode, energy, enrichedContext, workoutCount: workoutCount);
  }
}
