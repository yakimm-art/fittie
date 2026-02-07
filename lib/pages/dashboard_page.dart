import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:intl/intl.dart'; 

import '../providers/app_state.dart';
import '../widgets/kawaii_bear.dart'; 
import '../services/firebase_service.dart';
import '../services/ai_service.dart';
import 'workout_session_page.dart';
import 'login_page.dart'; 

// --- 1. SHARED THEME UTILS ---
class AppColors {
  static const bgCream = Color(0xFFFDFBF7);
  static const primaryTeal = Color(0xFF38B2AC);
  static const textDark = Color(0xFF2D3748);
  static const textSoft = Color(0xFF718096);
  static const white = Colors.white;
  static const errorRed = Color(0xFFE53E3E);
  
  static const powerRed = Color(0xFFFF6B6B);
  static const zenGreen = Color(0xFF88D8B0);
  static const streakGold = Color(0xFFFFC107);
  
  static const cardSurface = Colors.white;
  static const blackAccent = Color(0xFF000000); 
  static const lightTeal = Color(0xFFE6FFFA);
  static const borderTeal = Color(0xFF2C7A7B);
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; 

  static const List<Widget> _screens = <Widget>[
    HomePage(),      
    WorkoutsPage(),
    ChatPage(), 
    ProfilePage(),   
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 900;

        return Scaffold(
          backgroundColor: state.backgroundColor,
          extendBody: false, 
          resizeToAvoidBottomInset: true, 
          body: Row(
            children: [
              if (isWide) _buildImprovedWebSidebar(state),
              Expanded(
                child: Stack(
                  children: [
                    if (isWide) const _WebBackgroundDecorations(),
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
          bottomNavigationBar: isWide ? null : _buildMobileNavBar(state),
        );
      }
    );
  }

  Widget _buildImprovedWebSidebar(AppState state) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: state.surfaceColor,
        border: Border(right: BorderSide(color: state.textColor, width: 3)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const FittieLogo(size: 40),
                const SizedBox(width: 12),
                Text("FITTIE", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1, color: state.textColor)),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildSidebarItem(0, "Dashboard", Icons.dashboard_rounded, state),
          _buildSidebarItem(1, "Your Flows", Icons.bolt_rounded, state),
          _buildSidebarItem(2, "Fittie Chat", Icons.chat_bubble_rounded, state),
          _buildSidebarItem(3, "My Profile", Icons.person_rounded, state),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryTeal, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primaryTeal, size: 20),
                  const SizedBox(width: 12),
                  Text(state.mode.name.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.primaryTeal, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, String label, IconData icon, AppState state) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? state.textColor : Colors.transparent, width: 2),
            boxShadow: isSelected ? [BoxShadow(color: state.textColor, offset: const Offset(4, 4))] : [],
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textSoft, size: 24),
              const SizedBox(width: 16),
              Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: isSelected ? Colors.white : state.textColor, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavBar(AppState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: state.surfaceColor, 
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: state.textColor, width: 2),
        boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.bolt_rounded), label: 'Flows'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primaryTeal,
          unselectedItemColor: Colors.grey[400],
          backgroundColor: state.surfaceColor, 
          elevation: 0,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
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
  
  int _currentStreak = 0;
  String _userName = "Friend";
  bool _isQuickLoading = false;
  double _localEnergyLevel = 50.0; 
  
  List<int> _loggedWeekdays = <int>[]; 
  double _todayCalories = 0;
  
  List<Map<String, dynamic>> _todaysBreakdown = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      setState(() => _localEnergyLevel = state.energyLevel.toDouble());
      _checkMoodLogging();
    });
  }

  Future<void> _checkMoodLogging() async {
    bool hasLogged = await _firebaseService.hasLoggedToday();
    if (!hasLogged && mounted) {
      _showMoodPopup();
    }
  }

  void _showMoodPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), 
              side: const BorderSide(color: AppColors.textDark, width: 2),
            ),
            backgroundColor: AppColors.bgCream,
            title: Text("Log Your Mood", style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("How are you feeling today?", style: GoogleFonts.inter()),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Text("${_localEnergyLevel.toInt()}% Energy", 
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                    Slider(
                      value: _localEnergyLevel,
                      min: 0,
                      max: 100,
                      activeColor: AppColors.primaryTeal,
                      onChanged: (val) {
                        setDialogState(() => _localEnergyLevel = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final state = context.read<AppState>();
                  state.setEnergyLevel(_localEnergyLevel.toInt());
                  int newStreak = await _firebaseService.logDailyCheckIn(_localEnergyLevel, state.mode.name);
                  if (mounted) {
                    setState(() {
                      _currentStreak = newStreak;
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text("LOG ENERGY", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
              ),
            ],
          );
        }
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
        _todayCalories = weeklyData.isNotEmpty ? weeklyData.last : 0.0;
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

      List<dynamic> routine = await _aiService.generateWorkout(
        state.mode.name, 
        _localEnergyLevel.toInt(), 
        userContext 
      );
      
      if (mounted) {
        setState(() => _isQuickLoading = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutSessionPage(
          routine: routine, 
          themeColor: AppColors.primaryTeal
        )));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isQuickLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not generate: $e")));
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
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("YOUR ENERGY", style: GoogleFonts.inter(color: AppColors.textSoft, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
              TextButton.icon(
                onPressed: _showMoodPopup,
                icon: const Icon(Icons.edit, size: 14, color: AppColors.primaryTeal),
                label: Text("Edit", style: GoogleFonts.inter(fontSize: 12, color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),
          _buildEnergyDisplay(state),
          const SizedBox(height: 24),
          
          Text("YOUR STREAK", style: GoogleFonts.inter(color: AppColors.textSoft, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          _buildWeeklyCalendar(state),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  context,
                  title: "Calories",
                  value: "${_todayCalories.toInt()}",
                  unit: "kcal",
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.lightTeal,
                  textColor: AppColors.borderTeal,
                  isHighlighted: true,
                  borderColor: AppColors.primaryTeal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatBox(
                  context,
                  title: "Streak",
                  value: "$_currentStreak",
                  unit: "Days",
                  icon: Icons.bolt_rounded,
                  color: AppColors.white,
                  textColor: state.textColor,
                  isHighlighted: false,
                  borderColor: state.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildActionAndMascot(state),
          const SizedBox(height: 30),

          Text("TODAY'S BREAKDOWN", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSoft)),
          const SizedBox(height: 16),
          _todaysBreakdown.isEmpty 
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.surfaceColor, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: state.textColor, width: 2),
                  boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(4, 4), blurRadius: 0)],
                ),
                child: Text("No workouts yet today. Let's start!", style: GoogleFonts.inter(color: AppColors.textSoft, fontWeight: FontWeight.bold)),
              )
            : SizedBox(
                height: 190, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _todaysBreakdown.length,
                  itemBuilder: (context, index) {
                    final item = _todaysBreakdown[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: _buildActivityCard(
                        item['name'] ?? "Exercise",
                        "${item['duration']}", 
                        item['emoji'] ?? "⚡",
                        "${item['calories']} kcal",
                        state.textColor,
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
        color: state.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryTeal, width: 2),
        boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(4, 4), blurRadius: 0)], 
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primaryTeal.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.bolt_rounded, color: AppColors.primaryTeal, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${state.energyLevel}% Energy", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.borderTeal)),
                Text("Mode: ${state.mode.name}", style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSoft, fontWeight: FontWeight.w600)),
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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("HELLO, ${_userName.toUpperCase()}", style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            Text("Let's Flow.", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: state.textColor)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: state.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryTeal, width: 2),
            boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(2, 2), blurRadius: 0)], 
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 24),
              const SizedBox(width: 4),
              Text("$_currentStreak", style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: state.textColor, fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar(AppState state) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: state.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: state.textColor, width: 2),
        boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
           DateTime dayDate = startOfWeek.add(Duration(days: index));
           int weekdayIndex = dayDate.weekday;
           bool isLogged = _loggedWeekdays.contains(weekdayIndex);
           bool isToday = weekdayIndex == now.weekday;
           bool isFuture = dayDate.isAfter(now);
           return _buildCalendarDay(DateFormat('E').format(dayDate)[0], isLogged, isToday, isFuture, state);
        }),
      ),
    );
  }

  Widget _buildCalendarDay(String label, bool isLogged, bool isToday, bool isFuture, AppState state) {
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.grey.shade300;
    Widget? icon;
    
    if (isLogged) {
      bgColor = AppColors.primaryTeal;
      borderColor = state.textColor;
      icon = const Icon(Icons.check, size: 16, color: Colors.white);
    } else if (isToday) {
      borderColor = AppColors.primaryTeal;
    }

    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSoft)),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isFuture ? Colors.transparent : borderColor, 
              width: isToday && !isLogged ? 2 : (isLogged ? 2 : 1)
            ),
          ),
          child: Center(
            child: isLogged 
              ? icon 
              : (isToday ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle)) : null),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, {
    required String title, required String value, required String unit, 
    required IconData icon, required Color color, required Color textColor, required bool isHighlighted, required Color borderColor
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: textColor),
              if (isHighlighted) 
                Icon(Icons.trending_up_rounded, size: 16, color: textColor.withOpacity(0.5))
            ],
          ),
          const SizedBox(height: 24),
          Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
          Text(unit, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: textColor.withOpacity(0.7))),
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
                  color: AppColors.blackAccent,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.primaryTeal, width: 2),
                  boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(4, 4), blurRadius: 0)], 
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10, bottom: -10,
                      child: Icon(Icons.play_circle_filled, size: 80, color: AppColors.primaryTeal.withOpacity(0.2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isQuickLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text("Start", style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                          Text("Quick Flow", style: GoogleFonts.inter(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.primaryTeal, width: 2),
                boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(4, 4), blurRadius: 0)], 
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: -10, 
                    child: const SizedBox(
                      height: 100, width: 100, 
                      child: KawaiiPolarBear(), 
                    ),
                  ),
                  Positioned(
                    top: 16,
                    child: Text("Fittie", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.borderTeal)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String duration, String emoji, String calories, Color borderColor) {
    return Container(
      width: 140,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryTeal, width: 2),
        boxShadow: [BoxShadow(color: AppColors.textDark, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.1), 
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryTeal, width: 1.5)
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 8),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textDark)),
          Text(duration, style: GoogleFonts.inter(color: AppColors.textSoft, fontSize: 12, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(calories, style: GoogleFonts.inter(color: AppColors.primaryTeal, fontWeight: FontWeight.w900, fontSize: 12)),
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

      List<dynamic> routine = await _aiService.generateWorkout(
        state.mode.name, 
        state.energyLevel.toInt(), 
        userContext 
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Color themeColor = AppColors.primaryTeal;
        if (state.energyLevel > 70) themeColor = AppColors.powerRed;
        if (state.energyLevel < 30) themeColor = AppColors.zenGreen;
        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutSessionPage(routine: routine, themeColor: themeColor)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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
            Text("AI GENERATOR", style: GoogleFonts.inter(color: AppColors.textSoft, fontWeight: FontWeight.w800, fontSize: 12)),
            Text("Your Flows", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: state.textColor)),
            const SizedBox(height: 20),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: state.textColor, width: 3),
                boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(8, 8), blurRadius: 0)],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text("Create New Flow", style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text("Dynamic routine based on ${state.mode.name.toLowerCase()} mode and ${state.energyLevel}% energy.", 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 32),
                  SquishyButton(
                    text: _isLoading ? "CALCULATING..." : "START FLOW",
                    onTap: _isLoading ? null : () => _startAiSession(context, state),
                    color: Colors.white,
                    textColor: activeColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text("HISTORY (PAST 7 DAYS)", style: GoogleFonts.inter(color: AppColors.textSoft, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const SizedBox(height: 16),
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
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: state.surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: state.textColor, width: 2),
                          boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(4, 4), blurRadius: 0)],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            iconColor: state.textColor,
                            collapsedIconColor: state.textColor,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primaryTeal, width: 2),
                              ),
                              child: const Icon(Icons.history_rounded, color: AppColors.primaryTeal),
                            ),
                            title: Text(dateStr, style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: state.textColor, fontSize: 16)),
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
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCream.withOpacity(0.5),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
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
  final _aiService = AiService();
  bool _isTyping = false;

  void _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;

    final userText = _msgCtrl.text.trim();
    _msgCtrl.clear();

    final state = context.read<AppState>();
    state.addChatMessage("user", userText);

    setState(() => _isTyping = true);
    _scrollToBottom();

    String fittieReply = await _aiService.chatWithFittie(userText);

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
          color: state.surfaceColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: state.textColor, width: 2.5),
          boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(6, 6))], 
        ),
        clipBehavior: Clip.none, 
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: state.surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(bottom: BorderSide(color: state.textColor, width: 2)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48, width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.bgCream,
                      shape: BoxShape.circle,
                      border: Border.all(color: state.textColor, width: 2),
                    ),
                    // 🟢 FIXED: Mascot inside circle is now very small and centered using Padding and FittedBox
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
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
                        Text("Fittie Agent", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: state.textColor)),
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text("Active", style: GoogleFonts.inter(fontSize: 12, color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => state.clearChat(), icon: const Icon(Icons.delete_outline, size: 20))
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = chatMessages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.primaryTeal : AppColors.bgCream,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 20),
                        ),
                        border: Border.all(color: state.textColor, width: 2.5),
                        boxShadow: [BoxShadow(color: state.textColor.withOpacity(0.1), offset: const Offset(4, 4))],
                      ),
                      child: Text(
                        msg['text'],
                        style: GoogleFonts.inter(
                          color: isUser ? Colors.white : state.textColor,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          fontSize: 15
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            if (_isTyping)
               Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8),
                child: Align(alignment: Alignment.centerLeft, child: Text("Fittie is typing...", style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft, fontStyle: FontStyle.italic))),
              ),
              
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: state.surfaceColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                border: Border(top: BorderSide(color: state.textColor, width: 2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCream,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: state.textColor, width: 2),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(hintText: "Need advice?", border: InputBorder.none),
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
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
                        shape: BoxShape.circle,
                        border: Border.all(color: state.textColor, width: 2),
                        boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(3, 3))],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
                    color: state.surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: state.textColor, width: 3),
                  ),
                  child: Icon(Icons.person, size: 50, color: state.textColor),
                ),
                const SizedBox(height: 16),
                Text(_name, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: state.textColor)),
                Text(_email, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSoft)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildStatCard("Streak", "$_streak Days", Icons.local_fire_department_rounded, Colors.orange, state)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Workouts", "Active", Icons.fitness_center_rounded, AppColors.primaryTeal, state)),
            ],
          ),
          const SizedBox(height: 32),
          Text("SETTINGS", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSoft, letterSpacing: 1.2)),
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
        color: state.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: state.textColor, width: 2),
        boxShadow: [BoxShadow(color: state.textColor, offset: const Offset(2, 2), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: state.textColor)),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, AppState state, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: state.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: state.isDarkMode ? Colors.grey[700]! : Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: state.textColor, size: 20),
            const SizedBox(width: 16),
            Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: state.textColor)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSoft),
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
        title: Text("Edit Profile", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField("Name", _nameCtrl),
                  const SizedBox(height: 16),
                  _buildTextField("Age", _ageCtrl, isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField("Weight (kg)", _weightCtrl),
                  const SizedBox(height: 16),
                  _buildTextField("Height (cm)", _heightCtrl),
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
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.textDark, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.grey, width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
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
      backgroundColor: state.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: state.textColor),
        title: Text("App Settings", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: state.textColor)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildToggle(
            "Push Notifications", 
            state.notificationsEnabled, 
            (val) => context.read<AppState>().toggleNotifications(val),
            state
          ),
          const SizedBox(height: 16),
          _buildToggle(
            "Sound Effects", 
            state.soundEnabled, 
            (val) => context.read<AppState>().toggleSound(val),
            state
          ),
          const SizedBox(height: 16),
          _buildToggle(
            "Dark Mode", 
            state.isDarkMode, 
            (val) => context.read<AppState>().toggleDarkMode(val),
            state
          ),
          const SizedBox(height: 40),
          Center(child: Text("Fittie v1.0.0", style: GoogleFonts.inter(color: AppColors.textSoft))),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, bool val, Function(bool) onChanged, AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: state.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: state.isDarkMode ? Colors.grey[700]! : Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: state.textColor)),
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
        title: Text("Help & Support", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildFaqItem("How do I earn streaks?", "Log your energy every day via the 'Edit' button in the Energy section. If you miss a 24-hour window, your streak resets to 1."),
          _buildFaqItem("How are calories calculated?", "Fittie estimates energy expenditure at approximately 7 calories burned per minute of active workout time."),
          _buildFaqItem("Can I change my physical profile?", "Yes! Navigate to Profile > Edit Profile to update your name, age, weight, and height at any time."),
          _buildFaqItem("What are the different modes?", "Modes (Power, Zen, Desk) morph automatically based on your daily energy level to provide the best workout type."),
          const SizedBox(height: 30),
          SquishyButton(text: "CONTACT SUPPORT", onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textDark)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: GoogleFonts.inter(color: AppColors.textSoft)),
        )
      ],
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
    final state = context.watch<AppState>(); 
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
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: state.textColor, width: 2), 
            boxShadow: _isPressed ? [] : [BoxShadow(color: state.textColor, offset: const Offset(0, 4), blurRadius: 0)],
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