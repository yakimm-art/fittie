import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../widgets/kawaii_bear.dart';
import '../services/firebase_service.dart';
import '../services/voice_service.dart'; 
import '../services/ai_service.dart';
import '../providers/app_state.dart'; 

class AppColors {
  static const textDark = Color(0xFF2D3748);
  static const textLight = Color(0xFFF7FAFC);
  static const surfaceWhite = Colors.white;
  static const borderBlack = Color(0xFF1F2937);
}

class WorkoutSessionPage extends StatefulWidget {
  final List<dynamic>? routine; // Optional - if null, will generate dynamically
  final Color themeColor;
  // Parameters for dynamic workout generation
  final Map<String, dynamic>? userContext;
  final String? mode;
  final int? energyLevel;

  const WorkoutSessionPage({
    super.key, 
    this.routine, 
    required this.themeColor,
    this.userContext,
    this.mode,
    this.energyLevel,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  final _firebaseService = FirebaseService();
  final _voiceService = VoiceService();
  final _aiService = AiService();

  // Workout count selection state
  bool _isSelectingCount = true;
  int _selectedWorkoutCount = 5;
  List<dynamic> _activeRoutine = [];
  bool _isGenerating = false;
  String _generatingMessage = "Generating your workout...";

  // Preview phase state
  bool _isPreviewPhase = true;
  int _previewTimeLeft = 10;
  Timer? _previewTimer;

  // Exercise state
  int _currentIndex = 0;
  int _timeLeft = 30;
  int _totalDuration = 0; 
  Timer? _timer;
  bool _isPaused = false;

  // 🟢 QUIRKY ADDITION: Meme messages for the disclaimer
  final List<String> _quirkyMessages = [
    "FITTIE CURATED GIF",
    "EXERCISE DEMO",
    "FORM GUIDE",
    "WATCH & LEARN",
    "FOLLOW ALONG"
  ];

  @override
  void initState() {
    super.initState();
    // If routine is already provided (backward compatibility), use it
    if (widget.routine != null && widget.routine!.isNotEmpty) {
      _activeRoutine = List.from(widget.routine!);
    }
  }

  Future<void> _generateAndStartWorkout() async {
    if (widget.userContext == null || widget.mode == null || widget.energyLevel == null) {
      // Use existing routine if generation params not provided
      _startWorkoutWithExistingRoutine();
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatingMessage = "Fittie is creating $_selectedWorkoutCount exercises for you... 🐻";
    });

    try {
      List<dynamic> routine = await _aiService.generateWorkout(
        widget.mode!,
        widget.energyLevel!,
        widget.userContext!,
        workoutCount: _selectedWorkoutCount,
      );
      
      if (mounted) {
        setState(() {
          _activeRoutine = routine;
          _isGenerating = false;
          _isSelectingCount = false;
          _currentIndex = 0;
        });
        
        if (_activeRoutine.isNotEmpty) {
          _startPreviewPhase();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to generate workout: $e")),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startWorkoutWithExistingRoutine() {
    // Take only the selected number of exercises from existing routine
    if (widget.routine != null) {
      if (_selectedWorkoutCount >= widget.routine!.length) {
        _activeRoutine = List.from(widget.routine!);
      } else {
        _activeRoutine = widget.routine!.take(_selectedWorkoutCount).toList();
      }
    }
    
    setState(() {
      _isSelectingCount = false;
      _currentIndex = 0;
    });
    
    if (_activeRoutine.isNotEmpty) {
      _startPreviewPhase();
    }
  }

  void _startWorkoutSession() {
    // Check if we need to generate or use existing
    if (widget.userContext != null && widget.mode != null && widget.energyLevel != null) {
      _generateAndStartWorkout();
    } else {
      _startWorkoutWithExistingRoutine();
    }
  }

  void _startPreviewPhase() {
    setState(() {
      _isPreviewPhase = true;
      _previewTimeLeft = 10;
    });
    
    // Speak the exercise name during preview
    final exercise = _activeRoutine[_currentIndex];
    _speakPreview(exercise);
    
    _previewTimer?.cancel();
    _previewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      
      setState(() {
        if (_previewTimeLeft > 1) {
          _previewTimeLeft--;
        } else {
          _previewTimer?.cancel();
          _startExercise();
        }
      });
    });
  }

  void _speakPreview(Map<String, dynamic> exercise) async {
    final name = exercise['name'] ?? "Next movement";
    String textToSpeak = "Get ready for $name";
    
    FittieMode mode = FittieMode.power;
    if (widget.themeColor == const Color(0xFF88D8B0)) { 
      mode = FittieMode.zen;
    }

    await _voiceService.speak(textToSpeak, mode);
  }

  void _startExercise() {
    final exercise = _activeRoutine[_currentIndex];
    int duration = 45;
    if (exercise != null && exercise['duration'] != null) {
      duration = int.tryParse(exercise['duration'].toString()) ?? 45;
    }

    setState(() {
      _isPreviewPhase = false;
      _timeLeft = duration;
      _isPaused = false;
    });

    _speakInstruction(exercise);
    _startTimer();
  }

  void _speakInstruction(Map<String, dynamic> exercise) async {
    final instruction = exercise['instruction'] ?? "Let's go!";
    final name = exercise['name'] ?? "Next movement";
    String textToSpeak = "$name. $instruction";
    
    FittieMode mode = FittieMode.power;
    if (widget.themeColor == const Color(0xFF88D8B0)) { 
      mode = FittieMode.zen;
    }

    await _voiceService.speak(textToSpeak, mode);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          _totalDuration++;
        } else {
          _nextExercise();
        }
      });
    });
  }

  void _nextExercise() {
    _timer?.cancel();
    _previewTimer?.cancel();
    if (_currentIndex < _activeRoutine.length - 1) {
      setState(() => _currentIndex++);
      _startPreviewPhase(); // Start with preview for next exercise
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() async {
    _timer?.cancel();
    _previewTimer?.cancel();
    await _voiceService.speak("Workout complete! You did amazing.", FittieMode.zen);
    await _firebaseService.saveCompletedWorkout(_activeRoutine, _totalDuration);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: const BorderSide(color: AppColors.textDark, width: 3),
          ),
          title: Text("🎉 WELL DONE!", style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
          content: Text("You completed the flow! Session saved to your history.", style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx); 
                  Navigator.pop(context); 
                },
                child: Text("FINISH", style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _previewTimer?.cancel();
    super.dispose();
  }

  String _getSafeUrl(Map<String, dynamic> exercise) {
    final String? rawUrl = exercise['visual_url'];
    if (rawUrl == null || rawUrl.trim().isEmpty || !rawUrl.startsWith('http')) {
      return ""; // No fallback — the UI handles empty URLs gracefully
    }
    return rawUrl;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while generating workout
    if (_isGenerating) {
      return _buildGeneratingScreen();
    }

    // Show workout count selection screen first (unless already have active routine from generation)
    if (_isSelectingCount) {
      return _buildWorkoutCountSelection();
    }

    // Safety check - if no active routine, show error
    if (_activeRoutine.isEmpty) {
      return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black)),
        body: Center(child: Text("No exercises found.", style: GoogleFonts.inter())),
      );
    }

    final exercise = _activeRoutine[_currentIndex];
    final String emoji = exercise['emoji'] ?? "⚡";
    final String name = exercise['name'] ?? "Exercise";
    final String instruction = exercise['instruction'] ?? "Keep moving!";
    final String gifUrl = _getSafeUrl(exercise);
    // 🟢 Pick a quirky message based on index
    final String quirkyTag = _quirkyMessages[_currentIndex % _quirkyMessages.length];

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 900;
          bool isShortMobile = constraints.maxHeight < 720;

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [widget.themeColor.withOpacity(0.4), Colors.white],
                      stops: const [0.0, 0.6],
                    ),
                  ),
                ),
              ),
              
              SafeArea(
                child: Column(
                  children: [
                    // 1. HEADER
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWeb ? 900 : 600),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: _buildHeaderIcon(Icons.close),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isPreviewPhase ? "GET READY" : "NOW FLOWING", 
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 10, color: AppColors.textDark.withOpacity(0.5), letterSpacing: 1.2)
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.textDark, width: 2),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: LinearProgressIndicator(
                                          value: (_currentIndex + 1) / _activeRoutine.length,
                                          backgroundColor: Colors.white,
                                          color: widget.themeColor,
                                          minHeight: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              _buildHeaderCounter(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 2. SCROLLABLE MAIN CONTENT
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: isWeb ? 900 : 600),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),

                                  // MAIN DISPLAY (TV SCREEN)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(color: AppColors.textDark, width: 4),
                                      boxShadow: const [
                                        BoxShadow(color: AppColors.textDark, offset: Offset(6, 6), blurRadius: 0),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: AspectRatio(
                                        aspectRatio: isWeb ? 16 / 9 : 1.3, 
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ExerciseVisualizer(
                                              visuals: exercise['visuals'] != null 
                                                  ? (exercise['visuals'] as List).map((e) => e.toString()).toList()
                                                  : [gifUrl],
                                            ),
                                            
                                            // 🟢 QUIRKY DISCLAIMER BADGE
                                            Positioned(
                                              top: 12, right: 12,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.textDark.withOpacity(0.85),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.auto_awesome, size: 12, color: Colors.amber),
                                                    const SizedBox(width: 6),
                                                    Text(quirkyTag, style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // Preview overlay
                                            if (_isPreviewPhase)
                                              Container(
                                                color: Colors.black.withOpacity(0.5),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        "GET READY",
                                                        style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: isWeb ? 32 : 24,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: 2,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        "$emoji $name",
                                                        style: GoogleFonts.inter(
                                                          color: widget.themeColor,
                                                          fontSize: isWeb ? 20 : 16,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                            Positioned(
                                              bottom: 0, left: 0, right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(emoji, style: const TextStyle(fontSize: 24)),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(name.toUpperCase(), 
                                                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: isWeb ? 24 : 18, letterSpacing: 0.5)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // TIMER SECTION
                                  Column(
                                    children: [
                                      if (_isPreviewPhase)
                                        Column(
                                          children: [
                                            Text(
                                              "STARTING IN",
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w800, 
                                                fontSize: 12, 
                                                color: widget.themeColor,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            Text(
                                              "$_previewTimeLeft",
                                              style: GoogleFonts.inter(
                                                color: widget.themeColor, 
                                                fontSize: isWeb ? 100 : (isShortMobile ? 55 : 75), 
                                                fontWeight: FontWeight.w900, 
                                                fontFeatures: [const FontFeature.tabularFigures()],
                                                letterSpacing: -2,
                                              ),
                                            ),
                                            Text("SECONDS", 
                                              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 10, color: AppColors.textDark.withOpacity(0.4))),
                                          ],
                                        )
                                      else
                                        Column(
                                          children: [
                                            Text(
                                              "00:${_timeLeft.toString().padLeft(2, '0')}",
                                              style: GoogleFonts.inter(
                                                color: AppColors.textDark, 
                                                fontSize: isWeb ? 100 : (isShortMobile ? 55 : 75), 
                                                fontWeight: FontWeight.w900, 
                                                fontFeatures: [const FontFeature.tabularFigures()],
                                                letterSpacing: -2,
                                              ),
                                            ),
                                            Text("REMAINING SECONDS", 
                                              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 10, color: AppColors.textDark.withOpacity(0.4))),
                                          ],
                                        ),
                                    ],
                                  ),

                                  SizedBox(height: isShortMobile ? 15 : 30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. COACH & CONTROLS FOOTER (fixed at bottom)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                        border: Border(
                          top: const BorderSide(color: AppColors.textDark, width: 3),
                          left: isWeb ? const BorderSide(color: AppColors.textDark, width: 3) : BorderSide.none,
                          right: isWeb ? const BorderSide(color: AppColors.textDark, width: 3) : BorderSide.none,
                        ),
                        boxShadow: const [
                          BoxShadow(color: AppColors.textDark, offset: Offset(0, -4), blurRadius: 0),
                        ],
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: isWeb ? 900 : double.infinity),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              24, 24, 24, 
                              MediaQuery.of(context).padding.bottom + 20 
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // --- MAINTAINED FITTIE PROFILE ---
                                    Container(
                                      height: isWeb ? 80 : 60,
                                      width: isWeb ? 80 : 60,
                                      decoration: BoxDecoration(
                                        color: widget.themeColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.textDark, width: 2.5),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: const FittedBox(
                                        fit: BoxFit.contain,
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: KawaiiPolarBear(isTalking: false),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        constraints: BoxConstraints(maxHeight: isWeb ? 160 : 95),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                                        ),
                                        child: SingleChildScrollView(
                                          physics: const BouncingScrollPhysics(),
                                          child: Text(
                                            _isPreviewPhase 
                                              ? "Watch the exercise above. The workout will begin in $_previewTimeLeft seconds!"
                                              : instruction,
                                            style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: isWeb ? 15 : 13, height: 1.4)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildPopButton(
                                      icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                      onTap: () => setState(() {
                                        _isPaused = !_isPaused;
                                        if (!_isPaused) {
                                          if (_isPreviewPhase) {
                                            // Resume preview timer
                                          } else {
                                            _startTimer();
                                          }
                                        }
                                      }),
                                      color: Colors.white,
                                      iconColor: AppColors.textDark,
                                      isSmall: !isWeb,
                                    ),
                                    _buildPopButton(
                                      icon: Icons.skip_next_rounded,
                                      onTap: _nextExercise,
                                      color: widget.themeColor,
                                      iconColor: Colors.white,
                                      isBig: true,
                                      isSmall: !isWeb,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGeneratingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [widget.themeColor.withOpacity(0.3), Colors.white],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: widget.themeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.textDark, width: 3),
                      boxShadow: const [
                        BoxShadow(color: AppColors.textDark, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const FittedBox(
                      fit: BoxFit.contain,
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: KawaiiPolarBear(isTalking: true),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(widget.themeColor),
                    strokeWidth: 4,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _generatingMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Powered by Gemini 3",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColors.textDark.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCountSelection() {
    // Provide flexible count options - user can pick any count
    final countOptions = [3, 5, 7, 10];
    countOptions.sort();

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 900;

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [widget.themeColor.withOpacity(0.3), Colors.white],
                      stops: const [0.0, 0.5],
                    ),
                  ),
                ),
              ),
              
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isWeb ? 600 : 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Back button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: _buildHeaderIcon(Icons.arrow_back),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Mascot
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: widget.themeColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.textDark, width: 3),
                              boxShadow: const [
                                BoxShadow(color: AppColors.textDark, offset: Offset(4, 4), blurRadius: 0),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: const FittedBox(
                              fit: BoxFit.contain,
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: KawaiiPolarBear(isTalking: false),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Title
                          Text(
                            "HOW MANY EXERCISES?",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              color: AppColors.textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Choose how many exercises you want to complete today",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.textDark.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Count options
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: countOptions.map((count) {
                              bool isSelected = _selectedWorkoutCount == count;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedWorkoutCount = count),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: isSelected ? widget.themeColor : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.textDark, 
                                      width: isSelected ? 3 : 2
                                    ),
                                    boxShadow: isSelected 
                                      ? [const BoxShadow(color: AppColors.textDark, offset: Offset(4, 4), blurRadius: 0)]
                                      : [const BoxShadow(color: AppColors.textDark, offset: Offset(2, 2), blurRadius: 0)],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$count",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 24,
                                          color: isSelected ? Colors.white : AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        "exercises",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 8,
                                          color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textDark.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 40),

                          // Start button
                          GestureDetector(
                            onTap: _startWorkoutSession,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: widget.themeColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.textDark, width: 3),
                                boxShadow: const [
                                  BoxShadow(color: AppColors.textDark, offset: Offset(4, 4), blurRadius: 0),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                                  const SizedBox(width: 8),
                                  Text(
                                    "START WORKOUT",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Info text
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: widget.themeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: widget.themeColor.withOpacity(0.3), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: widget.themeColor, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Each exercise will have a 10-second preview before starting",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: AppColors.textDark.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textDark, width: 2),
      ),
      child: Icon(icon, size: 20, color: AppColors.textDark),
    );
  }

  Widget _buildHeaderCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textDark, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.textDark, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Text("${_currentIndex + 1}/${_activeRoutine.length}", 
        style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
    );
  }

  Widget _buildPopButton({required IconData icon, required VoidCallback onTap, required Color color, required Color iconColor, bool isBig = false, bool isSmall = false}) {
    double padding = isBig ? (isSmall ? 18 : 24) : (isSmall ? 14 : 18);
    double iconSize = isBig ? (isSmall ? 32 : 40) : (isSmall ? 26 : 30);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textDark, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.textDark, offset: Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}

class ExerciseVisualizer extends StatefulWidget {
  final List<String> visuals;
  final BoxFit fit;

  const ExerciseVisualizer({super.key, required this.visuals, this.fit = BoxFit.cover});

  @override
  State<ExerciseVisualizer> createState() => _ExerciseVisualizerState();
}

class _ExerciseVisualizerState extends State<ExerciseVisualizer> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.visuals.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
        if (mounted) {
          setState(() {
            _index = (_index + 1) % widget.visuals.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visuals.isEmpty) {
      return Container(color: Colors.grey[200]);
    }
    
    return Image.network(
      widget.visuals[_index],
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (ctx, err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image, color: Colors.grey, size: 40),
            const SizedBox(height: 8),
            Text("No visual", style: GoogleFonts.inter(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                  loadingProgress.expectedTotalBytes!
                : null,
            color: AppColors.textDark,
          ),
        );
      },
    );
  }
}