import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // 1. AUTHENTICATION
  // ---------------------------------------------------------------------------

  Future<User?> signUp(
      {required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null && !credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
      }
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An unknown error occurred.";
    } catch (e) {
      throw "Sign up failed. Please try again.";
    }
  }

  Future<User?> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Invalid email or password.";
    } catch (e) {
      throw "Login failed. Please try again.";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  /// Check if the current user has admin role
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;
      final data = doc.data()!;
      return data['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Set a user role (for admin setup)
  Future<void> setUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
  }

  // ---------------------------------------------------------------------------
  // 2. USER PROFILE
  // ---------------------------------------------------------------------------

  Future<void> calibrateUser({
    required String uid,
    required String name,
    required int age,
    required String weight,
    required String height,
    required double stressBaseline,
    required String activityLevel,
    required String equipment,
    required String injuries,
    required String specificGoals,
    String? extraNotes,
  }) async {
    try {
      double w = double.tryParse(weight) ?? 70;
      double h = double.tryParse(height) ?? 170;
      double bmr = (10 * w) + (6.25 * h) - (5 * age) + 5;

      double multiplier = 1.2;
      if (activityLevel == 'Lightly Active') multiplier = 1.375;
      if (activityLevel == 'Very Active') multiplier = 1.55;

      int dailyCalorieGoal = (bmr * multiplier).round();

      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': _auth.currentUser?.email,
        'age': age,
        'weight': weight,
        'height': height,
        'dailyCalorieGoal': dailyCalorieGoal,
        'agentContext': {
          'equipment': equipment,
          'injuries': injuries,
          'goals': specificGoals,
          'stress_baseline': stressBaseline,
          'activity_level': activityLevel,
          'user_notes': extraNotes ?? "None",
        },
        'streak': 0,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'hasLoggedToday': false,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving user data: $e");
      throw "Failed to save profile.";
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update(data);
  }

  /// Save profile picture as base64 string in Firestore
  Future<void> saveProfilePicture(Uint8List imageBytes) async {
    final user = currentUser;
    if (user == null) return;
    final base64Image = base64Encode(imageBytes);
    await _firestore.collection('users').doc(user.uid).update({
      'profilePicture': base64Image,
    });
  }

  /// Get profile picture as Uint8List (decoded from base64)
  Future<Uint8List?> getProfilePicture() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data()?['profilePicture'] != null) {
      return base64Decode(doc.data()!['profilePicture']);
    }
    return null;
  }

  /// Stream user profile data for real-time updates
  Stream<DocumentSnapshot> getUserProfileStream() {
    final user = currentUser;
    if (user == null) return const Stream.empty();
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // ---------------------------------------------------------------------------
  // 3. STREAK & LOGGING
  // ---------------------------------------------------------------------------

  Future<int> getStreak() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc.data()?['streak'] ?? 0;
    }
    return 0;
  }

  Future<bool> hasLoggedToday() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final lastCheckIn = data['lastCheckIn'] as Timestamp?;

    if (lastCheckIn == null) return false;

    final now = DateTime.now();
    final lastDate = lastCheckIn.toDate();

    return now.year == lastDate.year &&
        now.month == lastDate.month &&
        now.day == lastDate.day;
  }

  /// Log mood / energy check-in. Does NOT update streak — streak is only
  /// incremented when the user completes a valid workout.
  Future<void> logDailyCheckIn(double energyLevel, String mode) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final today = DateTime.now();
    final String dateId = "${today.year}-${today.month}-${today.day}";

    try {
      final logRef = userRef.collection('daily_logs').doc(dateId);
      await logRef.set({
        'energy': energyLevel,
        'mode': mode,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'check-in',
      }, SetOptions(merge: true));

      await userRef.update({
        'lastCheckIn': FieldValue.serverTimestamp(),
        'hasLoggedToday': true,
      });
    } catch (e) {
      print("Check-in Error: $e");
    }
  }

  /// Increment the streak when the user completes a valid workout.
  Future<int> updateStreakOnWorkout() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final userRef = _firestore.collection('users').doc(user.uid);
    final today = DateTime.now();

    try {
      return await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final data =
            userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};

        int currentStreak = data['streak'] ?? 0;
        Timestamp? lastWorkoutTs = data['lastWorkoutDate'];

        int newStreak = currentStreak;
        if (lastWorkoutTs != null) {
          final lastDate = lastWorkoutTs.toDate();
          final lastDateOnly =
              DateTime(lastDate.year, lastDate.month, lastDate.day);
          final todayOnly = DateTime(today.year, today.month, today.day);
          final difference = todayOnly.difference(lastDateOnly).inDays;

          if (difference == 0) {
            // Already worked out today — streak unchanged
          } else if (difference == 1) {
            newStreak++;
          } else {
            newStreak = 1; // gap → reset
          }
        } else {
          newStreak = 1; // first ever workout
        }

        transaction.update(userRef, {
          'streak': newStreak,
          'lastWorkoutDate': FieldValue.serverTimestamp(),
        });

        return newStreak;
      });
    } catch (e) {
      print("Streak Error: $e");
      return 0;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. WORKOUT HISTORY & CALORIES
  // ---------------------------------------------------------------------------

  Stream<QuerySnapshot> getWorkoutHistoryStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<int> getTodayWorkoutCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startTimestamp = Timestamp.fromDate(startOfDay);

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .get();

    return snapshot.docs.length;
  }

  Future<int> saveCompletedWorkout(
      List<dynamic> routine, int durationSecs) async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final now = DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy').format(now);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .add({
      'timestamp': FieldValue.serverTimestamp(),
      'routine': routine,
      'totalDuration': durationSecs,
      'completed': true,
      'formattedDate': formattedDate,
    });

    // Update streak only on valid completed workout
    return await updateStreakOnWorkout();
  }

  Future<List<double>> getWeeklyCalories() async {
    final user = _auth.currentUser;
    if (user == null) return List.filled(7, 0.0);

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final startOfWindow =
        DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWindow))
          .get();

      List<double> weeklyData = List.filled(7, 0.0);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final routine = data['routine'] as List<dynamic>? ?? [];
        final totalDuration = data['totalDuration'] as int? ?? 0;

        double calories = 0;
        bool foundSpecificCalories = false;

        for (var ex in routine) {
          if (ex['calories'] != null) {
            calories += (ex['calories'] as num).toDouble();
            foundSpecificCalories = true;
          }
        }

        if (!foundSpecificCalories || calories == 0) {
          calories = (totalDuration / 60) * 7;
        }

        final workoutDate =
            DateTime(timestamp.year, timestamp.month, timestamp.day);
        final todayDate = DateTime(now.year, now.month, now.day);
        final diff = todayDate.difference(workoutDate).inDays;

        if (diff >= 0 && diff < 7) {
          int index = 6 - diff;
          weeklyData[index] += calories;
        }
      }
      return weeklyData;
    } catch (e) {
      print("Error fetching weekly calories: $e");
      return List.filled(7, 0.0);
    }
  }

  Future<List<Map<String, dynamic>>> getTodaysBreakdown() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startTimestamp = Timestamp.fromDate(startOfDay);

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .get();

      List<Map<String, dynamic>> breakdown = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final routine = data['routine'] as List<dynamic>? ?? [];

        for (var ex in routine) {
          int duration = ex['duration'] ?? 45;
          breakdown.add({
            'name': ex['name'] ?? 'Workout',
            'duration':
                duration < 60 ? "${duration}s" : "${(duration / 60).ceil()}m",
            'calories': ex['calories'] ?? 5,
            'emoji': ex['emoji'] ?? '⚡',
          });
        }
      }
      return breakdown;
    } catch (e) {
      print("Error fetching breakdown: $e");
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 5. EMAIL VERIFICATION UTILS
  // ---------------------------------------------------------------------------

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // 6. WORKOUT HISTORY SUMMARY (Long Context for Gemini)
  // ---------------------------------------------------------------------------

  /// Fetches the user's full workout history as a structured text summary
  /// for Gemini's long context window. Includes exercise names, muscle groups,
  /// intensities, dates, and progression patterns.
  Future<String> getWorkoutHistorySummary({int maxWorkouts = 50}) async {
    final user = _auth.currentUser;
    if (user == null) return "No workout history available.";

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .orderBy('timestamp', descending: true)
          .limit(maxWorkouts)
          .get();

      if (snapshot.docs.isEmpty) return "User has no prior workout history.";

      final buffer = StringBuffer();
      buffer.writeln(
          "=== WORKOUT HISTORY (${snapshot.docs.length} sessions) ===");

      // Track muscle group frequency and progression
      Map<String, int> muscleGroupFrequency = {};
      Map<String, List<int>> exerciseIntensityOverTime = {};
      int totalCalories = 0;
      int totalSessions = snapshot.docs.length;

      for (int i = 0; i < snapshot.docs.length; i++) {
        final data = snapshot.docs[i].data();
        final date = data['formattedDate'] ?? 'Unknown date';
        final routine = data['routine'] as List<dynamic>? ?? [];
        final duration = data['totalDuration'] as int? ?? 0;

        buffer.writeln("\n--- Session ${i + 1} ($date) ---");
        buffer.writeln("Total Duration: ${(duration / 60).ceil()} minutes");

        for (var ex in routine) {
          final name = ex['name'] ?? 'Unknown';
          final calories = ex['calories'] ?? 0;
          final intensity = ex['intensity'] ?? 5;
          final muscleGroup = ex['muscle_group'] ?? 'General';
          final exDuration = ex['duration'] ?? 45;

          buffer.writeln(
              "  - $name | ${exDuration}s | $calories kcal | Intensity: $intensity/10 | Muscle: $muscleGroup");

          totalCalories += (calories as num).toInt();
          muscleGroupFrequency[muscleGroup] =
              (muscleGroupFrequency[muscleGroup] ?? 0) + 1;

          if (!exerciseIntensityOverTime.containsKey(name)) {
            exerciseIntensityOverTime[name] = [];
          }
          exerciseIntensityOverTime[name]!.add((intensity as num).toInt());
        }
      }

      // Add analytics summary
      buffer.writeln("\n=== PROGRESSION ANALYTICS ===");
      buffer.writeln("Total Sessions: $totalSessions");
      buffer.writeln("Total Calories Burned: $totalCalories kcal");

      buffer.writeln("\nMuscle Group Distribution:");
      final sortedGroups = muscleGroupFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (var entry in sortedGroups) {
        buffer.writeln("  - ${entry.key}: ${entry.value} exercises");
      }

      buffer.writeln("\nExercise Intensity Trends:");
      for (var entry in exerciseIntensityOverTime.entries) {
        if (entry.value.length >= 2) {
          final first = entry.value.last; // oldest
          final last = entry.value.first; // newest
          final trend = last > first
              ? "IMPROVING"
              : (last < first ? "DECREASING" : "STABLE");
          buffer.writeln("  - ${entry.key}: $first -> $last ($trend)");
        }
      }

      return buffer.toString();
    } catch (e) {
      print("Error fetching workout history summary: $e");
      return "Error loading workout history.";
    }
  }

  // ---------------------------------------------------------------------------
  // 7. CHAT HISTORY PERSISTENCE (Firestore-backed memory)
  // ---------------------------------------------------------------------------

  /// Saves the current chat messages to Firestore
  Future<void> saveChatHistory(List<Map<String, dynamic>> messages) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'chatHistory': messages
            .map((m) => {
                  'role': m['role'],
                  'text': m['text'],
                  'timestamp':
                      m['timestamp'] ?? DateTime.now().toIso8601String(),
                })
            .toList(),
        'chatUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving chat history: $e");
    }
  }

  /// Loads chat history from Firestore
  Future<List<Map<String, dynamic>>> loadChatHistory() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return [];

      final data = doc.data()!;
      final history = data['chatHistory'] as List<dynamic>? ?? [];

      return history
          .map((m) => {
                'role': (m['role'] ?? 'fittie') as String,
                'text': (m['text'] ?? '') as String,
                'timestamp': (m['timestamp'] ?? '') as String,
              })
          .toList()
          .cast<Map<String, dynamic>>();
    } catch (e) {
      print("Error loading chat history: $e");
      return [];
    }
  }

  /// Gets user profile summary for chat context
  Future<String> getUserProfileSummary() async {
    final user = _auth.currentUser;
    if (user == null) return "";

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return "";

      final data = doc.data()!;
      final agentContext = data['agentContext'] as Map<String, dynamic>? ?? {};

      return '''
USER PROFILE:
- Name: ${data['name'] ?? 'Unknown'}
- Age: ${data['age'] ?? 'Unknown'}
- Weight: ${data['weight'] ?? 'Unknown'}
- Height: ${data['height'] ?? 'Unknown'}
- Daily Calorie Goal: ${data['dailyCalorieGoal'] ?? 'Unknown'}
- Current Streak: ${data['streak'] ?? 0} days
- Equipment: ${agentContext['equipment'] ?? 'None'}
- Injuries: ${agentContext['injuries'] ?? 'None'}
- Goals: ${agentContext['goals'] ?? 'General Fitness'}
- Activity Level: ${agentContext['activity_level'] ?? 'Sedentary'}
- Stress Baseline: ${agentContext['stress_baseline'] ?? 50}
''';
    } catch (e) {
      return "";
    }
  }

  // ---------------------------------------------------------------------------
  // 8. BLOG APPROVAL SYSTEM
  // ---------------------------------------------------------------------------

  /// Check if any admin account exists in the system
  Future<bool> hasAnyAdmin() async {
    try {
      final snap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Claim admin role (only works if no admin exists yet)
  Future<bool> claimAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final existing = await hasAnyAdmin();
      if (existing) return false;
      await _firestore.collection('users').doc(user.uid).update({
        'role': 'admin',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Approve a pending blog post
  Future<void> approveBlogPost(String docId) async {
    await _firestore.collection('blog_posts').doc(docId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': _auth.currentUser?.uid,
    });
  }

  /// Reject a pending blog post
  Future<void> rejectBlogPost(String docId) async {
    await _firestore.collection('blog_posts').doc(docId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectedBy': _auth.currentUser?.uid,
    });
  }

  /// Stream of pending blog posts (for admin review)
  Stream<QuerySnapshot> getPendingPostsStream() {
    return _firestore
        .collection('blog_posts')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get current user's display name from Firestore
  Future<String> getCurrentUserName() async {
    final user = _auth.currentUser;
    if (user == null) return '';
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return user.displayName ?? '';
      return (doc.data()?['name'] as String?) ?? user.displayName ?? '';
    } catch (e) {
      return user.displayName ?? '';
    }
  }
}
