import 'dart:ui'; 
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:intl/intl.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/app_state.dart';
import '../widgets/kawaii_bear.dart'; 
import '../services/firebase_service.dart';
import '../services/ai_service.dart';
import 'workout_session_page.dart';
import 'login_page.dart'; 
import '../widgets/weekly_activity_chart.dart'; 

// --- 1. SHARED THEME UTILS ---
class AppColors {
  // New gradient palette (mint → yellow)
  static const mintGreen = Color(0xFFC4F7E5);
  static const limeYellow = Color(0xFFE8F5A3);
  static const softPink = Color(0xFFFFF0F5);
  
  // Legacy colors (keeping for compatibility)
  static const bgCream = Color(0xFFFDFBF7);
  static const primaryTeal = Color(0xFF38B2AC);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const white = Colors.white;
  static const errorRed = Color(0xFFE53E3E);
  
  static const powerRed = Color(0xFFFF6B6B);
  static const zenGreen = Color(0xFF48BB78);
  static const streakGold = Color(0xFFFFC107);
  static const accentPurple = Color(0xFF805AD5);
  static const accentOrange = Color(0xFFED8936);
  
  static const cardSurface = Color(0xFFFFFEFC);
  static const blackAccent = Color(0xFF1F2937); 
  static const lightTeal = Color(0xFFE6FFFA);
  static const borderTeal = Color(0xFF2C7A7B);
  
  // Soft shadow for modern cards
  static const shadowColor = Color(0x15000000);
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = false; // Collapsible sidebar state

  static const List<Widget> _screens = <Widget>[
    HomePage(),      
    WorkoutsPage(),
    ChatPage(), 
    ProfilePage(),   
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 900;

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: false, 
          resizeToAvoidBottomInset: true, 
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  state.gradientStart,
                  state.gradientEnd,
                ],
              ),
            ),
            child: Row(
              children: [
                if (isWide) _buildImprovedWebSidebar(state),
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: isWide ? 1000 : 600),
                          child: _screens.elementAt(_selectedIndex),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isWide ? null : _buildMobileNavBar(state),
        );
      }
    );
  }

  Widget _buildImprovedWebSidebar(AppState state) {
    final sidebarWidth = _sidebarExpanded ? 220.0 : 80.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: sidebarWidth,
          margin: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.blackAccent, width: 2.5),
            boxShadow: [
              BoxShadow(color: AppColors.blackAccent, offset: const Offset(4, 4)),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Logo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: state.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.blackAccent, width: 2),
                ),
                child: const FittieLogo(size: 32),
              ),
              const SizedBox(height: 32),
              // Nav items
              _buildSidebarItem(0, 'Dashboard', Icons.dashboard_rounded, state),
              _buildSidebarItem(1, 'Workouts', Icons.bolt_rounded, state),
              _buildSidebarItem(2, 'Chat', Icons.chat_bubble_rounded, state),
              _buildSidebarItem(3, 'Profile', Icons.person_rounded, state),
              const Spacer(),
              // Settings
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildSidebarItem(-1, 'Settings', Icons.settings_outlined, state, isSettings: true),
              ),
            ],
          ),
        ),

        // Toggle arrow button on the right edge
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: _toggleSidebar,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                    border: Border.all(color: AppColors.blackAccent, width: 2),
                    boxShadow: const [
                      BoxShadow(color: AppColors.blackAccent, offset: Offset(2, 2)),
                    ],
                  ),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _sidebarExpanded ? 0.5 : 0.0,
                    child: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSoft),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(int index, String label, IconData icon, AppState state, {bool isSettings = false}) {
    bool isSelected = !isSettings && _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: isSettings ? null : () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? state.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected ? Border.all(color: AppColors.blackAccent, width: 2) : null,
            boxShadow: isSelected 
              ? [BoxShadow(color: AppColors.blackAccent, offset: const Offset(2, 2))]
              : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textSoft, size: 24),
              if (_sidebarExpanded) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _sidebarExpanded ? 1.0 : 0.0,
                    child: Text(label, 
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMobileNavBar(AppState state) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.blackAccent, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.blackAccent,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.bolt_rounded), label: 'Flows'),
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: AppColors.primaryTeal,
              unselectedItemColor: AppColors.textSoft,
              backgroundColor: Colors.transparent,
              elevation: 0,
              showUnselectedLabels: false,
              showSelectedLabels: false,
              type: BottomNavigationBarType.fixed,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 🏠 HOME TAB
// ==========================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firebaseService = FirebaseService();
  final _aiService = AiService();

  // Prevent the mood popup from firing twice (widget can rebuild)
  static bool _moodPopupShownThisSession = false;
  
  int _currentStreak = 0;
  String _userName = "Friend";
  bool _isQuickLoading = false;
  double _localEnergyLevel = 50.0; 
  
  List<int> _loggedWeekdays = <int>[]; 
  double _todayCalories = 0;
  List<double> _weeklyCalories = [];
  
  List<Map<String, dynamic>> _todaysBreakdown = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = Provider.of<AppState>(context, listen: false);
      setState(() => _localEnergyLevel = state.energyLevel.toDouble());
      _checkMoodLogging();
    });
  }

  Future<void> _checkMoodLogging() async {
    if (_moodPopupShownThisSession) return; // already shown this session
    bool hasLogged = await _firebaseService.hasLoggedToday();
    if (!hasLogged && mounted) {
      _moodPopupShownThisSession = true;
      _showMoodPopup();
    }
  }

  void _showMoodPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Emoji face based on energy level
          String _face() {
            if (_localEnergyLevel >= 80) return "😁";
            if (_localEnergyLevel >= 60) return "😊";
            if (_localEnergyLevel >= 40) return "😐";
            if (_localEnergyLevel >= 20) return "😔";
            return "😴";
          }

          Color _barColor() {
            if (_localEnergyLevel >= 70) return AppColors.primaryTeal;
            if (_localEnergyLevel >= 40) return AppColors.streakGold;
            return const Color(0xFFE53E3E);
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: AppColors.blackAccent, width: 3),
            ),
            backgroundColor: AppColors.bgCream,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.blackAccent, width: 2),
                        boxShadow: const [
                          BoxShadow(color: AppColors.blackAccent, offset: Offset(2, 2)),
                        ],
                      ),
                      child: Text("DAILY CHECK-IN",
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2)),
                    ),
                    const SizedBox(height: 20),
                    Text("How are you feeling?",
                        style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                    const SizedBox(height: 6),
                    Text("This helps Fittie tailor your workout intensity.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft)),
                    const SizedBox(height: 28),

                    // Big emoji face
                    Text(_face(), style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),

                    // Energy value
                    Text("${_localEnergyLevel.toInt()}%",
                        style: GoogleFonts.inter(
                            fontSize: 36, fontWeight: FontWeight.w900, color: _barColor())),
                    Text("ENERGY",
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSoft,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 20),

                    // Slider track
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.blackAccent, width: 2),
                        boxShadow: const [
                          BoxShadow(color: AppColors.blackAccent, offset: Offset(3, 3)),
                        ],
                      ),
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 10,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
                          activeTrackColor: _barColor(),
                          inactiveTrackColor: AppColors.blackAccent.withOpacity(0.08),
                          thumbColor: _barColor(),
                          overlayColor: _barColor().withOpacity(0.15),
                        ),
                        child: Slider(
                          value: _localEnergyLevel,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          onChanged: (val) {
                            setDialogState(() => _localEnergyLevel = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Low", style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSoft)),
                        Text("High", style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSoft)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Log button
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () async {
                          final state = ctx.read<AppState>();
                          state.setEnergyLevel(_localEnergyLevel.toInt());
                          await _firebaseService.logDailyCheckIn(_localEnergyLevel, state.mode.name);
                          if (mounted) {
                            Navigator.pop(ctx);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.blackAccent, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: AppColors.blackAccent, offset: Offset(4, 4)),
                            ],
                          ),
                          child: Center(
                            child: Text("LET'S GO 🐻",
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _fetchDashboardData() async {
    final streak = await _firebaseService.getStreak();
    final user = _firebaseService.currentUser;
    
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && mounted) {
        final data = userDoc.data()!;
        setState(() => _userName = data['name'] ?? "Friend");
        
        final todayStr = DateFormat('yyyy-M-d').format(DateTime.now());
        final logDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('daily_logs')
            .doc(todayStr)
            .get();
            
        if (logDoc.exists && mounted) {
          double fetchedEnergy = (logDoc.data()?['energy'] ?? 50.0).toDouble();
          setState(() => _localEnergyLevel = fetchedEnergy);
          context.read<AppState>().setEnergyLevel(fetchedEnergy.toInt());
        }
      }
    }

    final weeklyData = await _firebaseService.getWeeklyCalories();
    List<int> loggedDays = [];
    DateTime today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      if (weeklyData[i] > 0) {
        int daysAgo = 6 - i;
        DateTime date = today.subtract(Duration(days: daysAgo));
        loggedDays.add(date.weekday);
      }
    }

    final breakdown = await _firebaseService.getTodaysBreakdown();

    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _loggedWeekdays = loggedDays;
        _weeklyCalories = weeklyData;
        _todayCalories = weeklyData.isNotEmpty ? weeklyData.last : 0;
        _todaysBreakdown = breakdown;
      });

    }
  }

  void _onQuickAction() async {
    final state = context.read<AppState>(); 

    setState(() => _isQuickLoading = true);
    try {
      final user = _firebaseService.currentUser;
      Map<String, dynamic> userContext = {};
      
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          final agentData = data['agentContext'] as Map<String, dynamic>? ?? {};
          userContext = {
            'equipment': agentData['equipment'] ?? "None",
            'injuries': agentData['injuries'] ?? "None",
            'goals': agentData['goals'] ?? "General Fitness",
            'stress_baseline': agentData['stress_baseline'] ?? 50,
            'activity_level': agentData['activity_level'] ?? "Sedentary",
            'user_notes': agentData['user_notes'] ?? "None",
          };
        }
      }

      // Navigate to workout session with generation parameters
      // Let user select count first, then AI generates that many exercises
      if (mounted) {
        setState(() => _isQuickLoading = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutSessionPage(
          themeColor: AppColors.primaryTeal,
          userContext: userContext,
          mode: state.mode.name,
          energyLevel: _localEnergyLevel.toInt(),
        )));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isQuickLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not start: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          _buildHeader(state),
          const SizedBox(height: 24),

          // --- DUOLINGO-STYLE STREAK ---
          _buildStreakCard(state),
          const SizedBox(height: 24),

          // --- ENERGY ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("YOUR ENERGY",
                  style: GoogleFonts.inter(
                      color: AppColors.textDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5)),
              GestureDetector(
                onTap: _showMoodPopup,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryTeal, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit, size: 12, color: AppColors.primaryTeal),
                      const SizedBox(width: 4),
                      Text("EDIT",
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEnergyDisplay(state),
          const SizedBox(height: 24),

          // --- STAT BOXES ---
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  title: "CALORIES",
                  value: "${_todayCalories.toInt()}",
                  unit: "kcal",
                  icon: Icons.local_fire_department_rounded,
                  accent: Colors.orange,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildStatBox(
                  title: "STREAK",
                  value: "$_currentStreak",
                  unit: "days",
                  icon: Icons.bolt_rounded,
                  accent: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildActionAndMascot(state),
          const SizedBox(height: 28),



          // --- WEEKLY CHART ---
          WeeklyActivityChart(
            weeklyData: _weeklyCalories,
            primaryColor: state.primaryColor,
          ),
          const SizedBox(height: 28),

          Text("TODAY'S BREAKDOWN",
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: 1.5)),
          const SizedBox(height: 14),
          _todaysBreakdown.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.blackAccent, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: AppColors.blackAccent, offset: Offset(4, 4))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryTeal, width: 2),
                        ),
                        child: const Icon(Icons.directions_run_rounded,
                            color: AppColors.primaryTeal, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text("No workouts yet today. Let's go!",
                            style: GoogleFonts.inter(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: _todaysBreakdown.length,
                    itemBuilder: (context, index) {
                      final item = _todaysBreakdown[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 14, bottom: 6),
                        child: _buildActivityCard(
                          item['name'] ?? "Exercise",
                          "${item['duration']}",
                          item['emoji'] ?? "⚡",
                          "${item['calories']} kcal",
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEnergyDisplay(AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blackAccent, width: 2.5),
        boxShadow: [
          BoxShadow(color: AppColors.blackAccent, offset: const Offset(4, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: AppColors.primaryTeal, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${state.energyLevel}% ENERGY",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.textDark,
                        letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primaryTeal, width: 1.5),
                  ),
                  child: Text("MODE: ${state.mode.name.toUpperCase()}",
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: state.energyLevel / 100,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryTeal),
                ),
                Text("${state.energyLevel}",
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primaryTeal, width: 1.5),
                ),
                child: Text("HELLO, ${_userName.toUpperCase()}",
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0)),
              ),
              const SizedBox(height: 8),
              Text("Let's Flow.",
                  style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: state.textColor,
                      letterSpacing: -1)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.blackAccent, width: 2.5),
            boxShadow: const [
              BoxShadow(color: AppColors.blackAccent, offset: Offset(3, 3))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: Colors.orange, size: 24),
              const SizedBox(width: 6),
              Text("$_currentStreak",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      fontSize: 20)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(AppState state) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    String motivText;
    if (_currentStreak >= 7) {
      motivText = "Unstoppable! A full week!";
    } else if (_currentStreak >= 3) {
      motivText = "You're on fire! Keep pushing!";
    } else if (_currentStreak >= 1) {
      motivText = "Great start — don't break the chain!";
    } else {
      motivText = "Start your streak today!";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blackAccent, width: 2.5),
        boxShadow: [
          BoxShadow(color: AppColors.blackAccent, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        children: [
          // Top: flame + streak count
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.orange, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$_currentStreak DAY STREAK",
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 2),
                    Text(motivText,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSoft)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Divider
          Container(
            height: 2.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Week days row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              DateTime dayDate = startOfWeek.add(Duration(days: index));
              bool isLogged = _loggedWeekdays.contains(dayDate.weekday);
              bool isToday = dayDate.day == now.day &&
                  dayDate.month == now.month &&
                  dayDate.year == now.year;
              bool isFuture =
                  dayDate.isAfter(DateTime(now.year, now.month, now.day));
              return _buildStreakDay(
                  dayLabels[index], isLogged, isToday, isFuture);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDay(
      String label, bool isLogged, bool isToday, bool isFuture) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isFuture
                    ? AppColors.textSoft.withOpacity(0.35)
                    : AppColors.textSoft,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isLogged
                ? AppColors.streakGold
                : (isToday
                    ? AppColors.primaryTeal.withOpacity(0.08)
                    : (isFuture ? Colors.grey.shade50 : Colors.grey.shade100)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isLogged
                  ? AppColors.blackAccent
                  : (isToday
                      ? AppColors.primaryTeal
                      : (isFuture
                          ? Colors.grey.shade200
                          : Colors.grey.shade300)),
              width: isLogged || isToday ? 2.5 : 1.5,
            ),
            boxShadow: isLogged
                ? const [
                    BoxShadow(
                        color: AppColors.blackAccent, offset: Offset(2, 2))
                  ]
                : [],
          ),
          child: Center(
            child: isLogged
                ? const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 20)
                : (isToday
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: AppColors.primaryTeal,
                            borderRadius: BorderRadius.circular(4)))
                    : null),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blackAccent, width: 2.5),
        boxShadow: [
          BoxShadow(color: AppColors.blackAccent, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark)),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(unit,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSoft)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionAndMascot(AppState state) {
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _isQuickLoading ? null : _onQuickAction,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [state.primaryColor, state.primaryColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.blackAccent, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: AppColors.blackAccent, offset: const Offset(4, 4)),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(Icons.play_circle_filled,
                          size: 80,
                          color: Colors.white.withOpacity(0.15)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isQuickLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 3))
                              : Text("Start",
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900)),
                          Text("QUICK FLOW",
                              style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.blackAccent, width: 2.5),
                boxShadow: [
                  BoxShadow(color: AppColors.blackAccent, offset: const Offset(4, 4)),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: -10,
                    child: const SizedBox(
                      height: 100,
                      width: 100,
                      child: KawaiiPolarBear(),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.primaryTeal, width: 1.5),
                      ),
                      child: Text("FITTIE",
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryTeal,
                              letterSpacing: 1)),
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

  Widget _buildActivityCard(
      String title, String duration, String emoji, String calories) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blackAccent, width: 2.5),
        boxShadow: const [
          BoxShadow(color: AppColors.blackAccent, offset: Offset(3, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryTeal, width: 1.5),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 10),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: AppColors.textDark)),
          Text(duration,
              style: GoogleFonts.inter(
                  color: AppColors.textSoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primaryTeal, width: 1.5),
            ),
            child: Text(calories,
                style: GoogleFonts.inter(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ⚡ WORKOUTS PAGE - YOUR FLOWS UI
// ==========================================

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});
  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  final _aiService = AiService();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _isScanning = false;

  void _startAiSession(BuildContext context, AppState state) async {
    setState(() => _isLoading = true);
    
    try {
      int todayCount = await _firebaseService.getTodayWorkoutCount();
      if (todayCount >= 3) {
        setState(() => _isLoading = false);
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("Whoa there! 🐻", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: Text("You've done 3 flows today! Rest is just as important as movement. Come back tomorrow!", style: GoogleFonts.inter()),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Okay"))],
            )
          );
        }
        return; 
      }

      final user = _firebaseService.currentUser;
      Map<String, dynamic> userContext = {};
      
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          final agentData = data['agentContext'] as Map<String, dynamic>? ?? {};
          userContext = {
            'equipment': agentData['equipment'] ?? "None",
            'injuries': agentData['injuries'] ?? "None",
            'goals': agentData['goals'] ?? "General Fitness",
            'extraNotes': data['extraNotes'] ?? "None",
          };
        }
      }

      // Navigate to workout session with generation parameters
      // Let user select count first, then AI generates that many exercises
      if (mounted) {
        setState(() => _isLoading = false);
        Color themeColor = AppColors.primaryTeal;
        if (state.energyLevel > 70) themeColor = AppColors.powerRed;
        if (state.energyLevel < 30) themeColor = AppColors.zenGreen;
        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutSessionPage(
          themeColor: themeColor,
          userContext: userContext,
          mode: state.mode.name,
          energyLevel: state.energyLevel.toInt(),
        )));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  /// Scan a photo of the user's gym/equipment using Gemini Vision
  void _scanGymPhoto(BuildContext context, AppState state) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 80);
    if (image == null) return;

    setState(() => _isScanning = true);

    try {
      final Uint8List imageBytes = await image.readAsBytes();

      // Show analysis dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.blackAccent, width: 2.5),
          ),
          title: Text("SCANNING YOUR GYM...", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryTeal),
              const SizedBox(height: 16),
              Text("Gemini is analyzing your equipment", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSoft)),
            ],
          ),
        ),
      );

      final analysis = await _aiService.analyzeGymPhoto(imageBytes);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      final equipment = analysis['equipment_list'] as List? ?? [];
      final summary = analysis['summary'] as String? ?? 'Equipment detected';

      if (!mounted) return;

      // Show detected equipment and offer to start workout
      final shouldStart = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.blackAccent, width: 2.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.camera_alt, color: AppColors.primaryTeal),
              const SizedBox(width: 8),
              Text("EQUIPMENT FOUND", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSoft, fontSize: 13)),
              const SizedBox(height: 12),
              ...equipment.take(8).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.primaryTeal),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.toString(), style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13))),
                ]),
              )),
              if (equipment.length > 8)
                Text("+ ${equipment.length - 8} more", style: GoogleFonts.inter(color: AppColors.textSoft, fontWeight: FontWeight.w600)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text("CLOSE", style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.textSoft)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("BUILD FLOW", style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        ),
      );

      if (shouldStart == true && mounted) {
        // Build workout from the photo analysis 
        Color themeColor = AppColors.primaryTeal;
        if (state.energyLevel > 70) themeColor = AppColors.powerRed;
        if (state.energyLevel < 30) themeColor = AppColors.zenGreen;

        final userContext = {
          'equipment': equipment.join(', '),
          'injuries': 'None',
          'goals': 'General Fitness',
          'scannedGym': true,
          'gymSummary': summary,
        };

        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutSessionPage(
          themeColor: themeColor,
          userContext: userContext,
          mode: state.mode.name,
          energyLevel: state.energyLevel.toInt(),
        )));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Scan failed: $e"), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    Color activeColor = AppColors.primaryTeal;
    if (state.energyLevel > 70) activeColor = AppColors.powerRed;
    if (state.energyLevel < 30) activeColor = AppColors.zenGreen;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.blackAccent, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.blackAccent, offset: Offset(2, 2)),
                ],
              ),
              child: Text("AI GENERATOR",
                  style: GoogleFonts.inter(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.0)),
            ),
            const SizedBox(height: 8),
            Text("Your Flows",
                style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: state.textColor,
                    letterSpacing: -1)),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.blackAccent, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                      color: AppColors.blackAccent, offset: Offset(6, 6))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.blackAccent, width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: AppColors.blackAccent, offset: Offset(3, 3))
                      ],
                    ),
                    child:
                        const Icon(Icons.auto_awesome, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Text("CREATE NEW FLOW",
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    child: Text(
                        "${state.mode.name.toUpperCase()} MODE / ${state.energyLevel}% ENERGY",
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8)),
                  ),
                  const SizedBox(height: 24),
                  SquishyButton(
                    text: _isLoading ? "CALCULATING..." : "START FLOW",
                    onTap: _isLoading
                        ? null
                        : () => _startAiSession(context, state),
                    color: Colors.white,
                    textColor: activeColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- SCAN MY GYM BUTTON (Gemini Vision) ---
            GestureDetector(
              onTap: _isScanning ? null : () => _scanGymPhoto(context, state),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.blackAccent, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: AppColors.blackAccent, offset: Offset(4, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.blackAccent, width: 2),
                        boxShadow: const [
                          BoxShadow(color: AppColors.blackAccent, offset: Offset(2, 2))
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 22, color: AppColors.primaryTeal),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_isScanning ? "SCANNING..." : "SCAN MY GYM",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: AppColors.textDark,
                                  letterSpacing: 0.3)),
                          const SizedBox(height: 2),
                          Text("Upload a photo — AI detects your equipment",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: AppColors.textSoft)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primaryTeal, width: 1.5),
                      ),
                      child: Text("VISION",
                          style: GoogleFonts.inter(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.8)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text("HISTORY (PAST 7 DAYS)",
                style: GoogleFonts.inter(
                    color: AppColors.textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5)),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseService.getWorkoutHistoryStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No flows yet. Create one!", style: GoogleFonts.inter(color: AppColors.textSoft, fontWeight: FontWeight.bold)));
                  }
                  
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final timestamp = (doc.data() as Map)['timestamp'] as Timestamp?;
                    if (timestamp == null) return false;
                    return timestamp.toDate().isAfter(DateTime.now().subtract(const Duration(days: 7)));
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(child: Text("No flows in the past 7 days.", style: GoogleFonts.inter(color: AppColors.textSoft, fontWeight: FontWeight.bold)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data = filteredDocs[index].data() as Map<String, dynamic>;
                      final int durationSecs = data['totalDuration'] ?? 0;
                      final int durationMins = (durationSecs / 60).ceil();
                      final int caloriesBurned = (durationMins * 7).toInt();
                      final List routine = data['routine'] ?? [];
                      final String dateStr = data['formattedDate'] ?? "";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.blackAccent, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                                color: AppColors.blackAccent, offset: Offset(4, 4))
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            iconColor: AppColors.textDark,
                            collapsedIconColor: AppColors.textDark,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primaryTeal, width: 2),
                              ),
                              child: const Icon(Icons.history_rounded, color: AppColors.primaryTeal, size: 20),
                            ),
                            title: Text(dateStr, style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.textDark, fontSize: 15)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  _buildHistoryPill(Icons.timer, "${durationMins}m", AppColors.textSoft),
                                  const SizedBox(width: 8),
                                  _buildHistoryPill(Icons.local_fire_department, "$caloriesBurned", Colors.orange),
                                ],
                              ),
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCream.withOpacity(0.5),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...routine.map((ex) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Text(ex['emoji'] ?? "⚡", style: const TextStyle(fontSize: 16)),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(ex['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14))),
                                          Text("${ex['duration']}s", style: GoogleFonts.inter(color: AppColors.textSoft, fontSize: 12)),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: color)),
        ],
      ),
    );
  }
}

// ==========================================
// 💬 CHAT PAGE - MOBILE OPTIMIZED
// ==========================================

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Load persisted chat history from Firestore on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      state.loadChatHistory();
    });
  }

  void _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;

    final userText = _msgCtrl.text.trim();
    _msgCtrl.clear();

    final state = context.read<AppState>();
    state.addChatMessage("user", userText);

    setState(() => _isTyping = true);
    _scrollToBottom();

    // Pass full chat history so Gemini has context of previous conversations
    String fittieReply = await state.aiService.chatWithFittie(
      userText,
      previousMessages: state.chatMessages,
    );

    if (mounted) {
      setState(() => _isTyping = false);
      state.addChatMessage("fittie", fittieReply);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>(); 
    final chatMessages = state.chatMessages;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.blackAccent, width: 2.5),
          boxShadow: const [
            BoxShadow(color: AppColors.blackAccent, offset: Offset(5, 5))
          ],
        ),
        clipBehavior: Clip.none,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                border: const Border(
                    bottom:
                        BorderSide(color: AppColors.blackAccent, width: 2.5)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgCream,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.blackAccent, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.blackAccent,
                            offset: Offset(2, 2))
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: KawaiiPolarBear(isTalking: false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("FITTIE AGENT",
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 6),
                            Text("ACTIVE",
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppColors.primaryTeal,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => state.clearChat(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.errorRed.withOpacity(0.3),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.errorRed),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: AppColors.bgCream.withOpacity(0.4),
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = chatMessages[index];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primaryTeal
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isUser ? 14 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 14),
                          ),
                          border: Border.all(
                              color: AppColors.blackAccent, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                                color: AppColors.blackAccent,
                                offset: Offset(3, 3))
                          ],
                        ),
                        child: Text(
                          msg['text'],
                          style: GoogleFonts.inter(
                              color: isUser ? Colors.white : AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Fittie is typing...",
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSoft,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic))),
              ),

            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: const Border(
                    top:
                        BorderSide(color: AppColors.blackAccent, width: 2.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCream,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.blackAccent, width: 2),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: InputDecoration(
                            hintText: "Need advice?",
                            border: InputBorder.none,
                            hintStyle: GoogleFonts.inter(
                                color: AppColors.textSoft,
                                fontWeight: FontWeight.w600)),
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, fontSize: 14),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.blackAccent, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                              color: AppColors.blackAccent,
                              offset: Offset(2, 2))
                        ],
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 👤 PROFILE TAB 
// ==========================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firebaseService = FirebaseService();
  String _name = "Loading...";
  String _email = "";
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _name = doc.data()?['name'] ?? "Fittie User";
          _email = user.email ?? "";
          _streak = doc.data()?['streak'] ?? 0;
        });
      }
    }
  }

  void _handleLogout() async {
    context.read<AppState>().clearChat();
    await _firebaseService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), 
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.blackAccent, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: AppColors.blackAccent, offset: Offset(4, 4))
                    ],
                  ),
                  child: const Icon(Icons.person, size: 50, color: AppColors.textDark),
                ),
                const SizedBox(height: 16),
                Text(_name, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(_email, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSoft, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildStatCard("STREAK", "$_streak Days", Icons.local_fire_department_rounded, Colors.orange, state)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("WORKOUTS", "Active", Icons.fitness_center_rounded, AppColors.primaryTeal, state)),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgCream,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.blackAccent, width: 1.5),
            ),
            child: Text("SETTINGS", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            Icons.person_outline, 
            "Edit Profile", 
            state,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())).then((_) => _loadProfile()),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            Icons.settings_outlined, 
            "App Settings", 
            state,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            Icons.help_outline, 
            "Help & Support", 
            state,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage())),
          ),
          const SizedBox(height: 40),
          SquishyButton(
            text: "LOG OUT",
            color: AppColors.errorRed,
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blackAccent, width: 2.5),
        boxShadow: const [BoxShadow(color: AppColors.blackAccent, offset: Offset(4, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blackAccent, width: 1.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSoft, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, AppState state, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.blackAccent, width: 2.5),
          boxShadow: const [
            BoxShadow(color: AppColors.blackAccent, offset: Offset(3, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.blackAccent, width: 1.5),
              ),
              child: Icon(icon, color: AppColors.primaryTeal, size: 18),
            ),
            const SizedBox(width: 14),
            Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 0.5)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.blackAccent, width: 1.5),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ✏️ EDIT PROFILE PAGE
// ==========================================

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameCtrl.text = data['name'] ?? "";
        _ageCtrl.text = (data['age'] ?? "").toString();
        _weightCtrl.text = data['weight'] ?? "";
        _heightCtrl.text = data['height'] ?? "";
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _firebaseService.updateUserData({
        'name': _nameCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text) ?? 0,
        'weight': _weightCtrl.text.trim(),
        'height': _heightCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text("EDIT PROFILE", style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 0.5)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField("NAME", _nameCtrl),
                  const SizedBox(height: 16),
                  _buildTextField("AGE", _ageCtrl, isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField("WEIGHT (KG)", _weightCtrl),
                  const SizedBox(height: 16),
                  _buildTextField("HEIGHT (CM)", _heightCtrl),
                  const SizedBox(height: 32),
                  SquishyButton(
                    text: "SAVE CHANGES",
                    onTap: _saveProfile,
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textDark, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.blackAccent, width: 2.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.blackAccent, width: 2.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.errorRed, width: 2.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.errorRed, width: 2.5)),
          ),
          validator: (val) => val == null || val.isEmpty ? "Required" : null,
        ),
      ],
    );
  }
}

// ==========================================
// ⚙️ SETTINGS PAGE
// ==========================================

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text("APP SETTINGS", style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 0.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildToggle(
            "PUSH NOTIFICATIONS", 
            state.notificationsEnabled, 
            (val) => context.read<AppState>().toggleNotifications(val),
            state
          ),
          const SizedBox(height: 16),
          _buildToggle(
            "SOUND EFFECTS", 
            state.soundEnabled, 
            (val) => context.read<AppState>().toggleSound(val),
            state
          ),
          const SizedBox(height: 16),
          _buildToggle(
            "DARK MODE", 
            state.isDarkMode, 
            (val) => context.read<AppState>().toggleDarkMode(val),
            state
          ),
          const SizedBox(height: 40),
          Center(child: Text("FITTIE V1.0.0", style: GoogleFonts.inter(color: AppColors.textSoft, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, bool val, Function(bool) onChanged, AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blackAccent, width: 2.5),
        boxShadow: const [
          BoxShadow(color: AppColors.blackAccent, offset: Offset(3, 3))
        ],
      ),
      child: SwitchListTile(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.textDark, fontSize: 13, letterSpacing: 0.5)),
        value: val,
        activeColor: AppColors.primaryTeal,
        onChanged: onChanged,
      ),
    );
  }
}

// ==========================================
// 🆘 HELP PAGE
// ==========================================

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text("HELP & SUPPORT", style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 0.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildFaqItem("How do I earn streaks?", "Log your energy every day via the 'Edit' button in the Energy section. If you miss a 24-hour window, your streak resets to 1."),
          const SizedBox(height: 12),
          _buildFaqItem("How are calories calculated?", "Fittie estimates energy expenditure at approximately 7 calories burned per minute of active workout time."),
          const SizedBox(height: 12),
          _buildFaqItem("Can I change my physical profile?", "Yes! Navigate to Profile > Edit Profile to update your name, age, weight, and height at any time."),
          const SizedBox(height: 12),
          _buildFaqItem("What are the different modes?", "Modes (Power, Zen, Desk) morph automatically based on your daily energy level to provide the best workout type."),
          const SizedBox(height: 30),
          SquishyButton(text: "CONTACT SUPPORT", onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blackAccent, width: 2.5),
        boxShadow: const [
          BoxShadow(color: AppColors.blackAccent, offset: Offset(3, 3))
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(question, style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.textDark, fontSize: 14)),
          iconColor: AppColors.textDark,
          collapsedIconColor: AppColors.textDark,
          children: [
            Text(answer, style: GoogleFonts.inter(color: AppColors.textSoft, fontWeight: FontWeight.w600, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// DECORATIONS & HELPERS
// ==========================================

class _WebBackgroundDecorations extends StatelessWidget {
  const _WebBackgroundDecorations();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(left: 50, top: 100, child: _PopIcon(Icons.fitness_center, Colors.orange, 60)),
        Positioned(right: 80, bottom: 150, child: _PopIcon(Icons.bolt, Colors.yellow, 80)),
        Positioned(left: 100, bottom: 80, child: _PopShape(Colors.pinkAccent, 40)),
        Positioned(right: 40, top: 50, child: _PopShape(AppColors.primaryTeal, 30)),
      ],
    );
  }
}

class _PopIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _PopIcon(this.icon, this.color, this.size);
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.2,
      child: Icon(icon, size: size, color: color.withOpacity(0.2)),
    );
  }
}

class _PopShape extends StatelessWidget {
  final Color color;
  final double size;
  const _PopShape(this.color, this.size);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
    );
  }
}

class FittieLogo extends StatelessWidget {
  final double size;
  final Color color;
  const FittieLogo({super.key, required this.size, this.color = AppColors.textDark});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(size, size), painter: _FittieLogoPainter(outlineColor: color));
}

class _FittieLogoPainter extends CustomPainter {
  final Color outlineColor;
  _FittieLogoPainter({required this.outlineColor});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final headRadius = size.width * 0.45;
    final earRadius = size.width * 0.15;
    final fillPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = size.width * 0.08..strokeCap = StrokeCap.round;
    canvas.drawCircle(center.translate(-headRadius * 0.7, -headRadius * 0.6), earRadius, fillPaint);
    canvas.drawCircle(center.translate(-headRadius * 0.7, -headRadius * 0.6), earRadius, strokePaint);
    canvas.drawCircle(center.translate(headRadius * 0.7, -headRadius * 0.6), earRadius, fillPaint);
    canvas.drawCircle(center.translate(headRadius * 0.7, -headRadius * 0.6), earRadius, strokePaint);
    final headRect = Rect.fromCenter(center: center, width: size.width * 0.9, height: size.height * 0.75);
    canvas.drawOval(headRect, fillPaint);
    canvas.drawOval(headRect, strokePaint);
    final featurePaint = Paint()..color = outlineColor..style = PaintingStyle.fill;
    final eyeSize = size.width * 0.08;
    canvas.drawCircle(center.translate(-headRadius * 0.35, -headRadius * 0.05), eyeSize / 2, featurePaint);
    canvas.drawCircle(center.translate(headRadius * 0.35, -headRadius * 0.05), eyeSize / 2, featurePaint);
    canvas.drawOval(Rect.fromCenter(center: center.translate(0, headRadius * 0.2), width: size.width * 0.12, height: size.width * 0.08), featurePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SquishyButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isSmall;
  final Color? color;
  final Color? textColor;
  const SquishyButton({super.key, required this.text, this.onTap, this.isSmall = false, this.color, this.textColor});
  @override
  State<SquishyButton> createState() => _SquishyButtonState();
}

class _SquishyButtonState extends State<SquishyButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    final bgColor = widget.color ?? AppColors.primaryTeal;
    final txtColor = widget.textColor ?? Colors.white;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: widget.isSmall ? 20 : 40, vertical: widget.isSmall ? 10 : 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.blackAccent, width: 2.5), 
            boxShadow: _isPressed ? [] : const [BoxShadow(color: AppColors.blackAccent, offset: Offset(0, 4))],
          ),
          child: Text(widget.text.toUpperCase(), style: GoogleFonts.inter(color: txtColor, fontWeight: FontWeight.w900, fontSize: widget.isSmall ? 12 : 16, letterSpacing: 1.0)),
        ),
      ),
    );
  }
}

class GoogleFonts {
  static TextStyle inter({Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing, double? height, FontStyle? fontStyle, List<FontFeature>? fontFeatures, List<Shadow>? shadows}) {
    return TextStyle(fontFamily: null, color: color, fontSize: fontSize, fontWeight: fontWeight, letterSpacing: letterSpacing, height: height, fontStyle: fontStyle, fontFeatures: fontFeatures, shadows: shadows);
  }
}