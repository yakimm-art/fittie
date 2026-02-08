import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/firebase_service.dart';
import '../widgets/kawaii_bear.dart';
import 'verify_email_page.dart';

// --- THEME (exported — used by other pages) ---
class AppColors {
  // New gradient palette
  static const mintGreen = Color(0xFFC4F7E5);
  static const limeYellow = Color(0xFFE8F5A3);
  static const cardSurface = Color(0xFFFFFEFC);
  
  static const bgCream = Color(0xFFFDFBF7);
  static const primaryTeal = Color(0xFF38B2AC);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const borderBlack = Color(0xFF1F2937);
  static const errorRed = Color(0xFFE53E3E);
}

// Step accent colors
const _stepColors = [
  AppColors.primaryTeal,
  Color(0xFF805AD5), // purple
  Color(0xFFE5793A), // orange
  Color(0xFFECC94B), // yellow
  Color(0xFFED64A6), // pink
];

const _stepIcons = ["01", "02", "03", "04", "05"];

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _mascotCtrl;
  late AnimationController _cardSlideCtrl;
  late AnimationController _pulseCtrl;

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isTalking = false;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  final _step5Key = GlobalKey<FormState>();

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
  final _extraNotesCtrl = TextEditingController();

  double _stressLevel = 50;
  String _activityLevel = 'Sedentary';
  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Very Active'
  ];

  final Set<String> _selectedEquipment = {};
  final Set<String> _selectedInjuries = {};
  final Set<String> _selectedGoals = {};

  final List<String> _equipmentOptions = [
    'None (Bodyweight)',
    'Dumbbells',
    'Yoga Mat',
    'Resistance Bands',
    'Pull-up Bar',
    'Kettlebell',
    'Full Gym'
  ];
  final List<String> _injuryOptions = [
    'None',
    'Back Pain',
    'Knee Pain',
    'Shoulder Issues',
    'Wrist Pain',
    'Ankle Injury'
  ];
  final List<String> _goalOptions = [
    'Lose Weight',
    'Build Muscle',
    'Flexibility',
    'Endurance',
    'Strength',
    'Better Posture'
  ];

  final List<Map<String, String>> _stepsData = [
    {
      "text": "Hi! I'm Fittie! Let's get your ID set up so we can start!",
      "audio": "signup_intro.mp3"
    },
    {
      "text":
          "Okay, Science time! I need your stats to calculate the perfect load.",
      "audio": "signup_step1.mp3"
    },
    {
      "text": "Help me calibrate! How stressed or active are you usually?",
      "audio": "signup_step2.mp3"
    },
    {
      "text": "Almost there! Tap your gear and goals so I can build your plan.",
      "audio": "signup_step3.mp3"
    },
    {
      "text": "Anything else? Tell me your preferences or special requests!",
      "audio": "signup_step3.mp3"
    }
  ];

  Color get _accent => _stepColors[_currentStep.clamp(0, 4)];

  @override
  void initState() {
    super.initState();
    _mascotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _cardSlideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _mascotCtrl.forward();
    _cardSlideCtrl.forward();

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isTalking = false);
    });

    if (_stepsData.isNotEmpty && !kIsWeb) {
      _playMascotAudio(_stepsData[0]['audio']!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _mascotCtrl.dispose();
    _cardSlideCtrl.dispose();
    _pulseCtrl.dispose();
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
    try {
      if (kIsWeb) {
        await _audioPlayer.play(UrlSource('assets/assets/audio/$fileName'));
      } else {
        await _audioPlayer.play(AssetSource('audio/$fileName'));
      }
    } catch (e) {
      if (mounted) setState(() => _isTalking = false);
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;
      if (_passCtrl.text != _confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Passwords do not match!"),
            backgroundColor: AppColors.errorRed));
        return;
      }
    }
    if (_currentStep == 1 && !_step2Key.currentState!.validate()) return;
    if (_currentStep == 2 && !_step3Key.currentState!.validate()) return;
    if (_currentStep == 3 && !_step4Key.currentState!.validate()) return;
    if (_currentStep == 3 && _selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select at least one goal!"),
          backgroundColor: AppColors.textDark));
      return;
    }

    _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic);

    setState(() => _currentStep++);
    if (_currentStep < _stepsData.length) {
      _playMascotAudio(_stepsData[_currentStep]['audio']!);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic);
      setState(() => _currentStep--);
      _playMascotAudio(_stepsData[_currentStep]['audio']!);
    } else {
      Navigator.pop(context);
    }
  }

  void _handleFinalSubmit() async {
    setState(() => _isLoading = true);
    try {
      final user = await _firebaseService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (user != null) {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: $e"), backgroundColor: AppColors.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =====================================================================
  // BUILD
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;

      return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.mintGreen, AppColors.limeYellow],
            ),
          ),
          child: Stack(
            children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    // --- TOP: MASCOT STAGE ---
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Row: Back + Progress
                            Row(
                              children: [
                                _BackBtn(onTap: _prevStep),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _AnimatedProgressBar(
                                      step: _currentStep, total: 5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Speech bubble
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: _SpeechBubble(
                                key: ValueKey(_currentStep),
                                text: _currentStep < _stepsData.length
                                    ? _stepsData[_currentStep]['text']!
                                    : "",
                                accent: _accent,
                                stepNum: _stepIcons[_currentStep.clamp(0, 4)],
                              ),
                            ),
                            // Bear
                            SlideTransition(
                              position: Tween<Offset>(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: _mascotCtrl,
                                      curve: Curves.elasticOut)),
                              child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child:
                                      KawaiiPolarBear(isTalking: _isTalking)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- BOTTOM: FORM CARD ---
                    Expanded(
                      child: SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, 0.3), end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: _cardSlideCtrl,
                                curve: Curves.easeOutCubic)),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28)),
                            border: const Border(
                              top: BorderSide(
                                  color: AppColors.borderBlack, width: 2.5),
                              left: BorderSide(
                                  color: AppColors.borderBlack, width: 2.5),
                              right: BorderSide(
                                  color: AppColors.borderBlack, width: 2.5),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                  color: AppColors.borderBlack,
                                  offset: Offset(0, -3)),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 14),
                              // Step accent bar
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: 60,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _accent,
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                      color: AppColors.borderBlack,
                                      width: 1.5),
                                ),
                              ),
                              Expanded(
                                child: PageView(
                                  controller: _pageController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _StepTransition(
                                        child: _buildStep1Identity()),
                                    _StepTransition(
                                        child: _buildStep2Biology()),
                                    _StepTransition(
                                        child: _buildStep3Lifestyle()),
                                    _StepTransition(
                                        child: _buildStep4AgentContext()),
                                    _StepTransition(
                                        child: _buildStep5OpenEnded()),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 0, 24, 20),
                                child: _ContinueButton(
                                  label: _currentStep == 4
                                      ? (_isLoading
                                          ? "ACTIVATING..."
                                          : "ACTIVATE AGENT")
                                      : "CONTINUE",
                                  accent: _accent,
                                  isLoading: _isLoading,
                                  step: _currentStep,
                                  total: 5,
                                  onTap: _isLoading
                                      ? null
                                      : (_currentStep == 4
                                          ? _handleFinalSubmit
                                          : _nextStep),
                                ),
                              ),
                              // "Already have an account?" link
                              if (_currentStep == 0)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text("Already have an account?",
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: AppColors.textSoft)),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(bottom: 1),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  color:
                                                      AppColors.primaryTeal,
                                                  width: 2),
                                            ),
                                          ),
                                          child: Text("Log in",
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AppColors.primaryTeal)),
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
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      );
    });
  }

  // =====================================================================
  // STEP BUILDERS
  // =====================================================================

  Widget _buildStep1Identity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _step1Key,
        child: Column(
          children: [
            _StepHeader(
                title: "Create Account",
                subtitle: "Your fitness journey starts here",
                accent: _stepColors[0]),
            const SizedBox(height: 18),
            _ReactivePopInput(
                label: "Full Name",
                controller: _nameCtrl,
                icon: Icons.person_rounded,
                accent: _stepColors[0],
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null),
            const SizedBox(height: 14),
            _ReactivePopInput(
                label: "Email",
                controller: _emailCtrl,
                icon: Icons.email_rounded,
                type: TextInputType.emailAddress,
                accent: _stepColors[0],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                }),
            const SizedBox(height: 14),
            _ReactivePopInput(
                label: "Password",
                controller: _passCtrl,
                icon: Icons.lock_rounded,
                isObscure: _obscurePass,
                accent: _stepColors[0],
                onSuffixTap: () =>
                    setState(() => _obscurePass = !_obscurePass),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'At least 6 characters';
                  return null;
                }),
            const SizedBox(height: 14),
            _ReactivePopInput(
                label: "Confirm Password",
                controller: _confirmPassCtrl,
                icon: Icons.lock_outline_rounded,
                isObscure: _obscureConfirm,
                accent: _stepColors[0],
                onSuffixTap: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please confirm password' : null),
            const SizedBox(height: 14),
            // Password strength indicator
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _passCtrl,
              builder: (context, value, _) => _PasswordStrengthBar(
                password: value.text,
                accent: _stepColors[0],
              ),
            ),
            const SizedBox(height: 20),
            // Trust badges
            _TrustBadges(accent: _stepColors[0]),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Biology() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _step2Key,
        child: Column(
          children: [
            _StepHeader(
                title: "Your Baseline",
                subtitle: "Help your AI coach understand your body",
                accent: _stepColors[1]),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child: _ReactivePopInput(
                        label: "Age",
                        controller: _ageCtrl,
                        type: TextInputType.number,
                        accent: _stepColors[1],
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null)),
                const SizedBox(width: 14),
                Expanded(
                    child: _ReactivePopInput(
                        label: "Weight (kg)",
                        controller: _weightCtrl,
                        type: TextInputType.number,
                        accent: _stepColors[1],
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null)),
              ],
            ),
            const SizedBox(height: 14),
            _ReactivePopInput(
                label: "Height (cm)",
                controller: _heightCtrl,
                type: TextInputType.number,
                accent: _stepColors[1],
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Lifestyle() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepHeader(
                title: "Lifestyle Calibration",
                subtitle: "Fine-tuning your AI coach",
                accent: _stepColors[2]),
            const SizedBox(height: 20),
            _SectionLabel("Typical Stress Level", _stepColors[2]),
            const SizedBox(height: 8),
            _StressSlider(
              value: _stressLevel,
              accent: _stepColors[2],
              onChanged: (val) => setState(() => _stressLevel = val),
            ),
            const SizedBox(height: 20),
            _SectionLabel("Daily Activity Level", _stepColors[2]),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activityLevels.map((level) {
                final isSelected = _activityLevel == level;
                return _SelectableChip(
                  label: level,
                  isSelected: isSelected,
                  accent: _stepColors[2],
                  onTap: () => setState(() => _activityLevel = level),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _step4Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepHeader(
                title: "Agent Intelligence",
                subtitle: "Equip your AI with context",
                accent: _stepColors[3]),
            const SizedBox(height: 18),
            _SectionLabel("Available Equipment", _stepColors[3]),
            const SizedBox(height: 8),
            _buildMultiSelectTags(
                _equipmentOptions, _selectedEquipment, _stepColors[3]),
            const SizedBox(height: 18),
            _SectionLabel("Injuries or Pain Points", _stepColors[3]),
            const SizedBox(height: 8),
            _buildMultiSelectTags(
                _injuryOptions, _selectedInjuries, _stepColors[3]),
            const SizedBox(height: 18),
            _SectionLabel("Primary Goals", _stepColors[3]),
            const SizedBox(height: 8),
            _buildMultiSelectTags(_goalOptions, _selectedGoals, _stepColors[3]),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5OpenEnded() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _step5Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepHeader(
                title: "Final Thoughts",
                subtitle: "Anything else your AI coach should know?",
                accent: _stepColors[4]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.borderBlack, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: AppColors.borderBlack, offset: Offset(2, 2)),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded,
                      size: 18, color: AppColors.textDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        "Preferences, fears, or favorite workouts -- it all helps.",
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ReactivePopInput(
              label: "e.g. I hate burpees, I love running at night...",
              controller: _extraNotesCtrl,
              maxLines: 5,
              icon: Icons.note_alt_outlined,
              accent: _stepColors[4],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // HELPERS
  // =====================================================================

  Widget _buildMultiSelectTags(
      List<String> options, Set<String> selectedSet, Color accent) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedSet.contains(option);
        return _SelectableChip(
          label: option,
          isSelected: isSelected,
          accent: accent,
          onTap: () {
            setState(() {
              isSelected ? selectedSet.remove(option) : selectedSet.add(option);
            });
          },
        );
      }).toList(),
    );
  }
}

// =====================================================================
// SHARED WIDGETS
// =====================================================================

// --- PASSWORD STRENGTH BAR ---
class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  final Color accent;
  const _PasswordStrengthBar(
      {required this.password, required this.accent});

  int _getStrength() {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score.clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getStrength();
    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong', 'Excellent'];
    final colors = [
      Colors.grey,
      const Color(0xFFE53E3E),
      const Color(0xFFED8936),
      const Color(0xFFECC94B),
      const Color(0xFF48BB78),
      accent,
    ];

    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: List.generate(5, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color:
                      i < strength ? colors[strength] : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: AppColors.borderBlack,
                    width: 1.5,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              strength >= 4
                  ? Icons.shield_rounded
                  : Icons.info_outline_rounded,
              size: 14,
              color: colors[strength],
            ),
            const SizedBox(width: 6),
            Text(labels[strength],
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors[strength])),
          ],
        ),
      ],
    );
  }
}

// --- TRUST BADGES ---
class _TrustBadges extends StatelessWidget {
  final Color accent;
  const _TrustBadges({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.borderBlack, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.borderBlack, offset: Offset(3, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _trustItem(Icons.lock_rounded, "ENCRYPTED"),
          _divider(),
          _trustItem(Icons.shield_rounded, "SECURE"),
          _divider(),
          _trustItem(Icons.visibility_off_rounded, "PRIVATE"),
        ],
      ),
    );
  }

  Widget _trustItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textDark),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5)),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 2,
      height: 16,
      color: AppColors.borderBlack,
    );
  }
}

// --- STEP HEADER ---
class _StepHeader extends StatelessWidget {
  final String title, subtitle;
  final Color accent;
  const _StepHeader(
      {required this.title, required this.subtitle, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Brutalist subtitle tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppColors.borderBlack, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.borderBlack, offset: Offset(2, 2)),
            ],
          ),
          child: Text(subtitle.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8)),
        ),
        const SizedBox(height: 12),
        Text(title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: -0.8)),
      ],
    );
  }
}

// --- SPEECH BUBBLE ---
class _SpeechBubble extends StatelessWidget {
  final String text, stepNum;
  final Color accent;
  const _SpeechBubble(
      {super.key,
      required this.text,
      required this.accent,
      required this.stepNum});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderBlack, width: 2.5),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.borderBlack, offset: Offset(4, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderBlack, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(stepNum,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        height: 1.4)),
              ),
            ],
          ),
        ),
        // Pointer tail
        CustomPaint(
          size: const Size(20, 10),
          painter: _BubbleTailPainter(),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = AppColors.borderBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    // Cover the top stroke with white to blend with bubble
    canvas.drawLine(
        const Offset(-1, 0),
        Offset(size.width + 1, 0),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- ANIMATED PROGRESS BAR ---
class _AnimatedProgressBar extends StatelessWidget {
  final int step, total;
  const _AnimatedProgressBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = (step / (total - 1)).clamp(0.0, 1.0);
    final accent = _stepColors[step.clamp(0, total - 1)];
    return Column(
      children: [
        ClipRRect(
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: AppColors.borderBlack, width: 2.5),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "STEP ${step + 1} OF $total",
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: 0.8),
          ),
        ),
      ],
    );
  }
}

// --- BACK BUTTON ---
class _BackBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});
  @override
  State<_BackBtn> createState() => _BackBtnState();
}

class _BackBtnState extends State<_BackBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderBlack, width: 2.5),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(3, 3))
                ],
        ),
        child: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textDark, size: 20),
      ),
    );
  }
}

// --- CONTINUE BUTTON ---
class _ContinueButton extends StatefulWidget {
  final String label;
  final Color accent;
  final bool isLoading;
  final int step, total;
  final VoidCallback? onTap;
  const _ContinueButton({
    required this.label,
    required this.accent,
    required this.isLoading,
    required this.step,
    required this.total,
    this.onTap,
  });
  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: widget.accent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderBlack, width: 2.5),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))
                ],
        ),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white))),
                const SizedBox(width: 12),
              ],
              Text(widget.label,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1)),
              if (!widget.isLoading && widget.step < widget.total - 1) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- SECTION LABEL ---
class _SectionLabel extends StatelessWidget {
  final String text;
  final Color accent;
  const _SectionLabel(this.text, this.accent);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        const SizedBox(width: 10),
        Text(text,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.textDark)),
      ],
    );
  }
}

// --- SELECTABLE CHIP ---
class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;
  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.white,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
              color: AppColors.borderBlack, width: 2),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                      color: AppColors.borderBlack,
                      offset: Offset(3, 3)),
                ]
              : const [
                  BoxShadow(color: AppColors.borderBlack, offset: Offset(2, 2)),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
              ),
            Text(label,
                style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// --- STRESS SLIDER ---
class _StressSlider extends StatelessWidget {
  final double value;
  final Color accent;
  final ValueChanged<double> onChanged;
  const _StressSlider(
      {required this.value, required this.accent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.spa_rounded, size: 20, color: Color(0xFF48BB78)),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: accent,
                  inactiveTrackColor: Colors.grey[200],
                  thumbColor: AppColors.textDark,
                  trackHeight: 10,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 14),
                  overlayShape: SliderComponentShape.noOverlay,
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: value,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: value.round().toString(),
                  onChanged: onChanged,
                ),
              ),
            ),
            const Icon(Icons.bolt_rounded, size: 20, color: Color(0xFFE5793A)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Zen mode",
                style:
                    GoogleFonts.inter(fontSize: 11, color: AppColors.textSoft)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent, width: 1.5),
              ),
              child: Text("${value.round()}%",
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: accent)),
            ),
            Text("High gear",
                style:
                    GoogleFonts.inter(fontSize: 11, color: AppColors.textSoft)),
          ],
        ),
      ],
    );
  }
}

// --- STEP TRANSITION ---
class _StepTransition extends StatelessWidget {
  final Widget child;
  const _StepTransition({required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// --- REACTIVE INPUT ---
class _ReactivePopInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool isObscure;
  final TextInputType? type;
  final int maxLines;
  final VoidCallback? onSuffixTap;
  final Color accent;
  final String? Function(String?)? validator;

  const _ReactivePopInput({
    required this.label,
    required this.controller,
    this.icon,
    this.isObscure = false,
    this.type,
    this.maxLines = 1,
    this.onSuffixTap,
    this.accent = AppColors.primaryTeal,
    this.validator,
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused ? widget.accent : AppColors.borderBlack,
          width: _isFocused ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? widget.accent.withOpacity(0.3)
                : AppColors.borderBlack,
            offset: _isFocused ? const Offset(0, 0) : const Offset(3, 3),
            blurRadius: _isFocused ? 8 : 0,
          )
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isObscure,
        keyboardType: widget.type,
        maxLines: widget.maxLines,
        validator: widget.validator,
        style: GoogleFonts.inter(
            fontWeight: FontWeight.w600, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: GoogleFonts.inter(
              color: AppColors.textSoft.withOpacity(0.6),
              fontWeight: FontWeight.w500),
          prefixIcon: widget.icon != null
              ? Icon(widget.icon,
                  color: _isFocused ? widget.accent : AppColors.textSoft)
              : null,
          suffixIcon: widget.onSuffixTap != null
              ? IconButton(
                  icon: Icon(
                      widget.isObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSoft),
                  onPressed: widget.onSuffixTap,
                )
              : null,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorStyle: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.errorRed),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}

// =====================================================================
// WEB DECORATIONS
// =====================================================================
class _WebDecorations extends StatelessWidget {
  const _WebDecorations();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            left: 80,
            top: 120,
            child: _FloatingCard(
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFFE5793A),
                delay: 0)),
        Positioned(
            left: 140, top: 100, child: _PopDot(color: Colors.cyan, size: 18)),
        Positioned(
            left: 60, top: 180, child: _PopDot(color: Colors.amber, size: 14)),
        Positioned(
            left: 100,
            bottom: 180,
            child: _FloatingCard(
                icon: Icons.favorite_rounded, color: Colors.pink, delay: 1500)),
        Positioned(
            left: 60,
            bottom: 140,
            child: _PopDot(color: Colors.purpleAccent, size: 22)),
        Positioned(
            right: 120,
            top: 150,
            child: _FloatingCard(
                icon: Icons.water_drop_rounded,
                color: Colors.blue,
                delay: 500)),
        Positioned(
            right: 80, top: 120, child: _PopDot(color: Colors.amber, size: 16)),
        Positioned(
            right: 100,
            bottom: 120,
            child: _FloatingCard(
                icon: Icons.local_fire_department_rounded,
                color: Colors.red,
                delay: 2000)),
        Positioned(
            right: 160,
            bottom: 160,
            child: _PopDot(color: Colors.green, size: 14)),
        Positioned(
            right: 60,
            bottom: 200,
            child: _PopDot(color: Colors.teal, size: 18)),
      ],
    );
  }
}

class _FloatingCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int delay;
  const _FloatingCard(
      {required this.icon, required this.color, required this.delay});
  @override
  State<_FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<_FloatingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) {
        return Transform.translate(
          offset: Offset(0, -12 * _ctrl.value),
          child: Transform.rotate(
            angle: 0.08 * math.sin(_ctrl.value * math.pi),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderBlack, width: 2.5),
          boxShadow: const [
            BoxShadow(color: AppColors.borderBlack, offset: Offset(4, 4))
          ],
        ),
        child: Icon(widget.icon, size: 32, color: widget.color),
      ),
    );
  }
}

class _PopDot extends StatelessWidget {
  final Color color;
  final double size;
  const _PopDot({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// =====================================================================
// EXPORTED SHARED WIDGETS (used by other pages)
// =====================================================================

class SquishyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLarge;
  const SquishyButton(
      {super.key, required this.label, this.onTap, this.isLarge = false});
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
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.borderBlack, width: 2),
            boxShadow: _isPressed
                ? []
                : const [
                    BoxShadow(
                        color: AppColors.borderBlack, offset: Offset(4, 4))
                  ],
          ),
          child: Text(widget.label,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1)),
        ),
      ),
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
        Positioned(
            top: -100, right: -100, child: _Blob(500, const Color(0xFFE6FFFA))),
        Positioned(
            top: 300, left: -50, child: _Blob(400, const Color(0xFFFFF5F7))),
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
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(color: color.withOpacity(0.8), shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class GoogleFonts {
  static TextStyle inter(
      {Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      double? letterSpacing,
      double? height}) {
    return TextStyle(
        fontFamily: 'Roboto',
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height);
  }
}
