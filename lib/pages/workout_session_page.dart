import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../widgets/kawaii_bear.dart';
import '../services/firebase_service.dart';
import '../services/voice_service.dart'; 
import '../providers/app_state.dart'; 

class AppColors {
  static const textDark = Color(0xFF2D3748);
  static const textLight = Color(0xFFF7FAFC);
  static const surfaceWhite = Colors.white;
  static const borderBlack = Color(0xFF1F2937);
}

class WorkoutSessionPage extends StatefulWidget {
  final List<dynamic> routine;
  final Color themeColor;

  const WorkoutSessionPage({
    super.key, 
    required this.routine, 
    required this.themeColor
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  final _firebaseService = FirebaseService();
  final _voiceService = VoiceService();

  int _currentIndex = 0;
  int _timeLeft = 30;
  int _totalDuration = 0; 
  Timer? _timer;
  bool _isPaused = false;

  // 🟢 QUIRKY ADDITION: Meme messages for the disclaimer
  final List<String> _quirkyMessages = [
    "GUIDE OR MEME? SURPRISE!",
    "GIPHY IS FEELING CHAOTIC",
    "ACTUAL GUIDE (PROBABLY)",
    "TRUST THE PROCESS, NOT THE GIF",
    "EVERY ROUTINE IS AN ADVENTURE"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.routine.isNotEmpty) {
      _startExercise();
    }
  }

  void _startExercise() {
    final exercise = widget.routine[_currentIndex];
    int duration = 45;
    if (exercise != null && exercise['duration'] != null) {
      duration = int.tryParse(exercise['duration'].toString()) ?? 45;
    }

    setState(() {
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
    if (_currentIndex < widget.routine.length - 1) {
      setState(() => _currentIndex++);
      _startExercise();
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() async {
    _timer?.cancel();
    await _voiceService.speak("Workout complete! You did amazing.", FittieMode.zen);
    await _firebaseService.saveCompletedWorkout(widget.routine, _totalDuration);

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
    super.dispose();
  }

  String _getSafeUrl(Map<String, dynamic> exercise) {
    final String? rawUrl = exercise['visual_url'];
    if (rawUrl == null || rawUrl.trim().isEmpty || !rawUrl.startsWith('http')) {
      return "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExazNlYnZqYnZqYnZqYnZqYnZqYnZqYnZqYnZqYnZq/1000/giphy.gif"; 
    }
    return rawUrl;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routine.isEmpty) {
      return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black)),
        body: Center(child: Text("No exercises found.", style: GoogleFonts.inter())),
      );
    }

    final exercise = widget.routine[_currentIndex];
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
              
              Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Center(
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
                                    Text("NOW FLOWING", style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 10, color: AppColors.textDark.withOpacity(0.5), letterSpacing: 1.2)),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: LinearProgressIndicator(
                                        value: (_currentIndex + 1) / widget.routine.length,
                                        backgroundColor: Colors.black.withOpacity(0.05),
                                        color: widget.themeColor,
                                        minHeight: 12,
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
                  ),

                  const SizedBox(height: 20),

                  // 2. MAIN DISPLAY (TV SCREEN)
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isWeb ? 900 : 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
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
                                  Image.network(gifUrl, fit: BoxFit.cover),
                                  
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
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 3. TIMER SECTION
                  Center(
                    child: Column(
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
                  ),

                  const Spacer(),

                  // 4. COACH & CONTROLS FOOTER
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
                                        child: Text(instruction,
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
                                      if (!_isPaused) _startTimer();
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
      ),
      child: Text("${_currentIndex + 1}/${widget.routine.length}", 
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