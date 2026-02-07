import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/firebase_service.dart';
import '../widgets/kawaii_bear.dart'; 
import 'dashboard_page.dart'; 
import 'verify_email_page.dart'; // Make sure this import exists

// --- THEME ---
class AppColors {
  static const bgCream = Color(0xFFFDFBF7);
  static const primaryTeal = Color(0xFF38B2AC);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const borderBlack = Color(0xFF1F2937);
  static const errorRed = Color(0xFFE53E3E);
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Animation Controllers
  late AnimationController _mascotCtrl;
  late AnimationController _bubbleCtrl;

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isTalking = false;

  // --- FORM KEYS ---
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  // 🟢 NEW: Key for Step 5
  final _step5Key = GlobalKey<FormState>();

  // --- CONTROLLERS ---
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController(); 
  
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  final _equipmentCtrl = TextEditingController();
  final _injuriesCtrl = TextEditingController();
  final _goalsCtrl = TextEditingController();
  
  // 🟢 NEW: Controller for open-ended text
  final _extraNotesCtrl = TextEditingController();

  // --- DATA ---
  double _stressLevel = 50; 
  String _activityLevel = 'Sedentary'; 
  final List<String> _activityLevels = ['Sedentary', 'Lightly Active', 'Very Active'];

  final Set<String> _selectedEquipment = {};
  final Set<String> _selectedInjuries = {};
  final Set<String> _selectedGoals = {};

  final List<String> _equipmentOptions = ['None (Bodyweight)', 'Dumbbells', 'Yoga Mat', 'Resistance Bands', 'Pull-up Bar', 'Kettlebell', 'Full Gym'];
  final List<String> _injuryOptions = ['None', 'Back Pain', 'Knee Pain', 'Shoulder Issues', 'Wrist Pain', 'Ankle Injury'];
  final List<String> _goalOptions = ['Lose Weight', 'Build Muscle', 'Flexibility', 'Endurance', 'Strength', 'Better Posture'];

  // 🟢 UPDATED: Added 5th step
  final List<Map<String, String>> _stepsData = [
    {"text": "Hi! I'm Fittie! Let's get your ID set up so we can start!", "audio": "signup_intro.mp3"},
    {"text": "Okay, Science time! I need your stats to calculate the perfect load.", "audio": "signup_step1.mp3"},
    {"text": "Help me calibrate! How stressed or active are you usually?", "audio": "signup_step2.mp3"},
    {"text": "Almost there! Tap your gear and goals so I can build your plan.", "audio": "signup_step3.mp3"},
    {"text": "Anything else? Tell me your preferences or special requests!", "audio": "signup_step4.mp3"}
  ];

  @override
  void initState() {
    super.initState();
    
    // Setup Animations
    _mascotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _bubbleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    
    // Start Entrance
    _mascotCtrl.forward();
    _bubbleCtrl.forward();

    if (_stepsData.isNotEmpty) {
      _playMascotAudio(_stepsData[0]['audio']!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _mascotCtrl.dispose();
    _bubbleCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _equipmentCtrl.dispose();
    _injuriesCtrl.dispose();
    _goalsCtrl.dispose();
    _extraNotesCtrl.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  void _playMascotAudio(String fileName) async {
    await _audioPlayer.stop();
    if (!mounted) return;
    setState(() => _isTalking = true); 
    
    // Pop the bubble animation
    _bubbleCtrl.reset();
    _bubbleCtrl.forward();

    try {
      await _audioPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      setState(() => _isTalking = false);
    }
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isTalking = false);
    });
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;
      if (_passCtrl.text != _confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!"), backgroundColor: AppColors.errorRed));
        return;
      }
    }
    if (_currentStep == 1 && !_step2Key.currentState!.validate()) return;
    if (_currentStep == 3 && (_selectedGoals.isEmpty)) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one goal!"), backgroundColor: AppColors.textDark));
       return;
    }

    _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubicEmphasized);
    setState(() => _currentStep++);

    if (_currentStep < _stepsData.length) {
      _playMascotAudio(_stepsData[_currentStep]['audio']!);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubicEmphasized);
      setState(() => _currentStep--);
      _playMascotAudio(_stepsData[_currentStep]['audio']!);
    } else {
      Navigator.pop(context);
    }
  }

  void _handleFinalSubmit() async {
    setState(() => _isLoading = true);
    try {
      // 1. Create User
      final user = await _firebaseService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (user != null) {
        // 2. Save Data (Calibrate)
        await _firebaseService.calibrateUser(
          uid: user.uid,
          name: _nameCtrl.text.trim(),
          age: int.tryParse(_ageCtrl.text.trim()) ?? 0, 
          weight: _weightCtrl.text.trim(), 
          height: _heightCtrl.text.trim(),
          stressBaseline: _stressLevel, 
          activityLevel: _activityLevel,
          equipment: _selectedEquipment.join(', '), 
          injuries: _selectedInjuries.join(', '),
          specificGoals: _selectedGoals.join(', '),
          
          // 🟢 NEW: Pass the extra notes. 
          // ⚠️ NOTE: Update your FirebaseService.calibrateUser to accept this named parameter!
          extraNotes: _extraNotesCtrl.text.trim(),
        );

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const VerifyEmailPage()), 
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.errorRed)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        return Scaffold(
          backgroundColor: AppColors.bgCream,
          resizeToAvoidBottomInset: true, 
          body: Stack(
            children: [
              const Positioned.fill(child: DotGridBackground()),
              const BackgroundBlobs(),
              if (isWide) const _ImprovedWebDecorations(),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500), 
                  child: Column(
                    children: [
                      // --- TOP STAGE ---
                      Expanded(
                        flex: 4, 
                        child: SafeArea(
                          child: Stack(
                            children: [
                              Positioned(
                                top: 16, left: 16,
                                child: GestureDetector(
                                  onTap: _prevStep,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.borderBlack, width: 2),
                                      boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(2, 2))],
                                    ),
                                    child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
                                  ),
                                ),
                              ),
                              
                              // Progress Dashes
                              Positioned(
                                top: 20, left: 0, right: 0,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    // 🟢 UPDATED: 5 dashes
                                    children: List.generate(5, (index) => _buildProgressDash(index)),
                                  ),
                                ),
                              ),

                              // Mascot Stage
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Bouncing Speech Bubble
                                    ScaleTransition(
                                      scale: CurvedAnimation(parent: _bubbleCtrl, curve: Curves.elasticOut),
                                      child: Container(
                                        key: ValueKey<int>(_currentStep),
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(color: AppColors.borderBlack, width: 2),
                                          boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))],
                                        ),
                                        child: Text(
                                          _currentStep < _stepsData.length ? _stepsData[_currentStep]['text']! : "", 
                                          textAlign: TextAlign.center, 
                                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w600, height: 1.4)
                                        ),
                                      ),
                                    ),
                                    // Sliding Bear
                                    SlideTransition(
                                      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: _mascotCtrl, curve: Curves.elasticOut)),
                                      child: SizedBox(width: 160, height: 160, child: KawaiiPolarBear(isTalking: _isTalking)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- FORM CARD ---
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                            border: Border(
                              top: BorderSide(color: AppColors.borderBlack, width: 2),
                              left: BorderSide(color: AppColors.borderBlack, width: 2),
                              right: BorderSide(color: AppColors.borderBlack, width: 2),
                            ), 
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                              
                              Expanded(
                                child: PageView(
                                  controller: _pageController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _StepTransition(child: _buildStep1Identity()), 
                                    _StepTransition(child: _buildStep2Biology()),
                                    _StepTransition(child: _buildStep3Lifestyle()),
                                    _StepTransition(child: _buildStep4AgentContext()),
                                    // 🟢 NEW: Added Step 5
                                    _StepTransition(child: _buildStep5OpenEnded()),
                                  ],
                                ),
                              ),
                              
                              Padding(
                                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                                child: SquishyButton(
                                  // 🟢 UPDATED: Change logic to check for step 4 (index 4 is the 5th step)
                                  label: _currentStep == 4 ? (_isLoading ? "ACTIVATING..." : "ACTIVATE AGENT") : "CONTINUE",
                                  onTap: _isLoading ? null : (_currentStep == 4 ? _handleFinalSubmit : _nextStep),
                                  isLarge: true,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  // --- STEPS ---

  Widget _buildStep1Identity() { 
      return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Form(
        key: _step1Key,
        child: Column(children: [
            Text("Create Account", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const SizedBox(height: 24),
            _ReactivePopInput(label: "Full Name", controller: _nameCtrl, icon: Icons.person_rounded),
            const SizedBox(height: 16),
            _ReactivePopInput(label: "Email", controller: _emailCtrl, icon: Icons.email_rounded, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _ReactivePopInput(label: "Password", controller: _passCtrl, icon: Icons.lock_rounded, isObscure: _obscurePass, onSuffixTap: () => setState(() => _obscurePass = !_obscurePass)),
            const SizedBox(height: 16),
            _ReactivePopInput(label: "Confirm Password", controller: _confirmPassCtrl, icon: Icons.lock_outline_rounded, isObscure: _obscureConfirm, onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm)),
        ]),
      ),
    );
  }
  
  Widget _buildStep2Biology() {
      return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Form(
        key: _step2Key,
        child: Column(children: [
            Text("Your Baseline", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _ReactivePopInput(label: "Age", controller: _ageCtrl, type: TextInputType.number)), 
              const SizedBox(width: 16), 
              Expanded(child: _ReactivePopInput(label: "Weight (kg)", controller: _weightCtrl, type: TextInputType.number))
            ]),
            const SizedBox(height: 16),
            _ReactivePopInput(label: "Height (cm)", controller: _heightCtrl, type: TextInputType.number),
        ]),
      ),
    );
  }

  Widget _buildStep3Lifestyle() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lifestyle Calibration", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const SizedBox(height: 32),
            _label("Typical Stress Level"),
            Row(
              children: [
                const Icon(Icons.spa, size: 20, color: Colors.green),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primaryTeal,
                      inactiveTrackColor: Colors.grey[200],
                      thumbColor: AppColors.textDark,
                      trackHeight: 12,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: _stressLevel,
                      min: 0, max: 100, divisions: 10,
                      label: _stressLevel.round().toString(),
                      onChanged: (val) => setState(() => _stressLevel = val),
                    ),
                  ),
                ),
                const Icon(Icons.bolt, size: 20, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 24),
            _label("Daily Activity Level"),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _activityLevels.map((level) {
                final isSelected = _activityLevel == level;
                return ChoiceChip(
                  label: Text(level),
                  selected: isSelected,
                  selectedColor: AppColors.primaryTeal,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                  shape: StadiumBorder(side: BorderSide(color: AppColors.borderBlack, width: 2)),
                  onSelected: (val) {
                    if (val) setState(() => _activityLevel = level);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4AgentContext() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Form(
        key: _step4Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Agent Intelligence", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const SizedBox(height: 24),
            _label("Available Equipment"),
            _buildMultiSelectTags(_equipmentOptions, _selectedEquipment),
            const SizedBox(height: 24),
            _label("Injuries or Pain Points"),
            _buildMultiSelectTags(_injuryOptions, _selectedInjuries),
            const SizedBox(height: 24),
            _label("Primary Goals"),
            _buildMultiSelectTags(_goalOptions, _selectedGoals),
          ],
        ),
      ),
    );
  }

  // 🟢 NEW: Step 5 Widget
  Widget _buildStep5OpenEnded() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Form(
        key: _step5Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Final Thoughts", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const SizedBox(height: 16),
            Text(
              "Is there anything else I should know? Preferences, fears, or favorite workouts?", 
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSoft, height: 1.5)
            ),
            const SizedBox(height: 24),
            
            // Large text area for input
            _ReactivePopInput(
              label: "e.g. I hate burpees, I love running at night...", 
              controller: _extraNotesCtrl, 
              maxLines: 5,
              icon: Icons.note_alt_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)));

  Widget _buildMultiSelectTags(List<String> options, Set<String> selectedSet) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedSet.contains(option);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? selectedSet.remove(option) : selectedSet.add(option);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryTeal : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderBlack, width: 1.5),
              boxShadow: isSelected 
                ? [const BoxShadow(color: AppColors.borderBlack, offset: Offset(2, 2))]
                : [const BoxShadow(color: Colors.transparent, offset: Offset(0, 0))],
            ),
            child: Text(
              option,
              style: GoogleFonts.inter(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildProgressDash(int index) {
    bool isActive = index <= _currentStep;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6, 
      width: isActive ? 40 : 32, // Grow active dash slightly
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryTeal : Colors.grey.shade200, 
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isActive ? AppColors.borderBlack : Colors.transparent, width: 1.5)
      ),
    );
  }
}

// 🚀 TRANSITION WRAPPER
class _StepTransition extends StatelessWidget {
  final Widget child;
  const _StepTransition({required this.child});
  @override
  Widget build(BuildContext context) {
    // Basic slide-fade entry
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// 🚀 IMPROVED REACTIVE INPUT
class _ReactivePopInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool isObscure;
  final TextInputType? type;
  final int maxLines;
  final VoidCallback? onSuffixTap;

  const _ReactivePopInput({
    required this.label, 
    required this.controller, 
    this.icon, 
    this.isObscure = false, 
    this.type, 
    this.maxLines = 1,
    this.onSuffixTap,
  });

  @override
  State<_ReactivePopInput> createState() => _ReactivePopInputState();
}

class _ReactivePopInputState extends State<_ReactivePopInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? AppColors.primaryTeal : AppColors.borderBlack, 
          width: _isFocused ? 2.5 : 2
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused ? AppColors.primaryTeal.withOpacity(0.3) : AppColors.borderBlack, 
            offset: _isFocused ? const Offset(6, 6) : const Offset(4, 4),
            blurRadius: _isFocused ? 0 : 0, // Hard shadow always
          )
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isObscure,
        keyboardType: widget.type,
        maxLines: widget.maxLines,
        // Optional validation logic if needed
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: GoogleFonts.inter(color: AppColors.textSoft.withOpacity(0.6), fontWeight: FontWeight.w500),
          prefixIcon: widget.icon != null ? Icon(widget.icon, color: _isFocused ? AppColors.primaryTeal : AppColors.textSoft) : null,
          suffixIcon: widget.onSuffixTap != null 
            ? IconButton(
                icon: Icon(widget.isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textSoft),
                onPressed: widget.onSuffixTap,
              ) 
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}

// 🌟 IMPROVED WEB DECORATIONS (High Quality Pop Art Clusters)
class _ImprovedWebDecorations extends StatelessWidget {
  const _ImprovedWebDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(left: 80, top: 120, child: _AnimatedSticker(icon: Icons.fitness_center_rounded, color: Colors.orange, size: 48, delay: 0)),
        Positioned(left: 140, top: 100, child: _PopShape(type: 'circle', color: Colors.cyan, size: 20)),
        Positioned(left: 60, top: 180, child: _PopShape(type: 'cross', color: Colors.yellow, size: 24)),
        Positioned(left: 100, bottom: 180, child: _AnimatedSticker(icon: Icons.favorite_rounded, color: Colors.pink, size: 56, delay: 1500)),
        Positioned(left: 60, bottom: 140, child: _PopShape(type: 'donut', color: Colors.purpleAccent, size: 30)),
        Positioned(right: 120, top: 150, child: _AnimatedSticker(icon: Icons.water_drop_rounded, color: Colors.blue, size: 42, delay: 500)),
        Positioned(right: 80, top: 120, child: _PopShape(type: 'star', color: Colors.amber, size: 28)),
        Positioned(right: 100, bottom: 120, child: _AnimatedSticker(icon: Icons.local_fire_department_rounded, color: Colors.red, size: 52, delay: 2000)),
        Positioned(right: 160, bottom: 160, child: _PopShape(type: 'circle', color: Colors.green, size: 18)),
        Positioned(right: 60, bottom: 200, child: _PopShape(type: 'cross', color: Colors.teal, size: 24)),
      ],
    );
  }
}

// A "Sticker" is a floating, rocking icon card
class _AnimatedSticker extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final int delay;
  const _AnimatedSticker({required this.icon, required this.color, required this.size, required this.delay});

  @override
  State<_AnimatedSticker> createState() => _AnimatedStickerState();
}

class _AnimatedStickerState extends State<_AnimatedSticker> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay), () { if(mounted) _ctrl.forward(); });
  }
  
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) {
        return Transform.translate(
          offset: Offset(0, -15 * _ctrl.value), 
          child: Transform.rotate(
            angle: 0.1 * math.sin(_ctrl.value * math.pi), // Rocking
            child: child
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderBlack, width: 2.5),
          boxShadow: const [BoxShadow(color: AppColors.borderBlack, offset: Offset(5, 5))],
        ),
        child: Icon(widget.icon, size: widget.size, color: widget.color),
      ),
    );
  }
}

class _PopShape extends StatelessWidget {
  final String type;
  final Color color;
  final double size;
  const _PopShape({required this.type, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'circle': return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
      case 'donut': return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 4)));
      case 'cross': return Icon(Icons.add_rounded, size: size, color: color);
      case 'star': return Icon(Icons.star_rounded, size: size, color: color);
      default: return const SizedBox();
    }
  }
}

class SquishyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLarge;
  const SquishyButton({super.key, required this.label, this.onTap, this.isLarge = false});
  @override
  State<SquishyButton> createState() => _SquishyButtonState();
}

class _SquishyButtonState extends State<SquishyButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(scale: _isPressed ? 0.95 : 1.0, duration: const Duration(milliseconds: 100), child: Container(width: double.infinity, alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(color: AppColors.primaryTeal, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppColors.borderBlack, width: 2), boxShadow: _isPressed ? [] : [const BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))]), child: Text(widget.label, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)))),
    );
  }
}

class DotGridBackground extends StatelessWidget {
  const DotGridBackground({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: DotGridPainter());
}

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textSoft.withOpacity(0.1);
    const step = 40.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BackgroundBlobs extends StatelessWidget {
  const BackgroundBlobs({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -100, right: -100, child: _Blob(500, const Color(0xFFE6FFFA))),
        Positioned(top: 300, left: -50, child: _Blob(400, const Color(0xFFFFF5F7))),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob(this.size, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color.withOpacity(0.8), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)));
  }
}

class GoogleFonts {
  static TextStyle inter({Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing, double? height}) {
    return TextStyle(fontFamily: 'Roboto', color: color, fontSize: fontSize, fontWeight: fontWeight, letterSpacing: letterSpacing, height: height);
  }
}