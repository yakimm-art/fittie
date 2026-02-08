# Fittie - AI-Powered Adaptive Fitness Coach

[![Flutter](https://img.shields.io/badge/Flutter-3.6.0-02569B?logo=flutter)](https://flutter.dev)
[![Gemini](https://img.shields.io/badge/Gemini-3.0%20Flash-4285F4?logo=google)](https://ai.google.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Hackathon%20Project-green)](https://gemini3.devpost.com)

Fittie is an intelligent fitness companion that generates personalized workout routines in real-time using Google Gemini 3. Unlike traditional fitness apps with static workout templates, Fittie adapts every session to your current energy levels, physical capabilities, stress state, and available equipment.

---

## Table of Contents

- [Overview](#overview)
- [Gemini 3 Integration](#gemini-3-integration)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [How It Works](#how-it-works)
- [Design Philosophy](#design-philosophy)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [Acknowledgments](#acknowledgments)

---

## Overview

Fittie addresses a fundamental problem in fitness: **one-size-fits-all workout plans don't account for daily fluctuations in energy, stress, and motivation.** The app introduces an energy-based adaptation system where users input their current state (0-100% energy level), and Gemini 3 generates a contextually appropriate workout that matches their capacity for that specific day.

### The Problem We Solve

- Traditional fitness apps provide static routines that don't adapt to how you feel
- Generic plans ignore individual physical differences, injuries, and equipment constraints
- Lack of real-time personalization leads to burnout or injury
- Fitness advice often feels robotic and disconnected

### Our Solution

Fittie uses Gemini 3's advanced language understanding and structured output capabilities to:

1. **Analyze user context** - Age, weight, height, energy level, stress, injuries, and equipment
2. **Generate dynamic workouts** - Every session is uniquely tailored with accurate calorie calculations using MET (Metabolic Equivalent of Task) values
3. **Provide intelligent coaching** - Conversational AI that remembers your history and adapts advice over time
4. **Ensure safety and progression** - Respects injuries and physical limitations while promoting growth

---

## Gemini 3 Integration

Fittie is built entirely around Gemini 3 Flash, leveraging its capabilities across multiple features:

### 1. Dynamic Workout Generation

Every workout request triggers a Gemini API call that processes:

**Input Context:**
- User physicals: age, weight, height
- Current state: energy percentage (0-100%), stress level
- Constraints: injuries, available equipment, special notes
- History: past workouts, preferences

**Gemini Processing:**
- Analyzes user profile using advanced language understanding
- Selects appropriate exercises from an 800+ exercise knowledge base
- Calculates realistic calorie burns using MET values and user weight
- Assigns intensity levels (1-10) and muscle group targeting
- Generates motivational instructions in the "Fittie bear" personality

**Structured Output:**
```json
[
  {
    "name": "Push Up",
    "duration": 45,
    "calories": 12,
    "intensity": 7,
    "muscle_group": "Chest",
    "emoji": "💪",
    "instruction": "Great energy today! Let's channel that into explosive push-ups."
  }
]
```

Gemini's JSON output mode ensures consistent, parseable responses that integrate seamlessly with the app's UI.

### 2. Conversational AI Coaching

The chat feature uses Gemini to provide:

- Real-time fitness advice and form corrections
- Motivational support tailored to user personality
- Contextual responses based on conversation history
- Biomechanical explanations in accessible language

**Example Interaction:**
```
User: "My shoulder hurts after yesterday's workout"
Fittie (Gemini): "Oh no! 🐻 Let's take care of that shoulder. Avoid overhead 
movements for 2-3 days. Try gentle arm circles and ice for 15 mins. Want me 
to generate a lower-body focused workout today instead?"
```

### 3. Adaptive Mode Selection

Gemini assists in categorizing daily energy into three modes:

- **Power Mode** (70-100% energy): High-intensity cardio and strength training
- **Zen Mode** (40-69% energy): Moderate yoga, stretching, and balanced workouts
- **Desk Mode** (0-39% energy): Gentle stretches and mobility work suitable for desk breaks

---

## Key Features

### Adaptive Workout Engine
- **Real-time generation:** No pre-built templates, every workout is fresh
- **MET-based calorie calculations:** Accurate energy expenditure estimates based on user weight and exercise intensity
- **Exercise database integration:** 800+ exercises with visual demonstrations
- **Fallback safety:** Curated fallback routines if API calls fail

### Intelligent User Profiling
- **Physical stats tracking:** Age, weight, height for personalized calculations
- **Injury awareness:** Gemini excludes contraindicated movements
- **Equipment adaptation:** Workouts adjust based on available equipment (bodyweight, dumbbells, resistance bands, etc.)
- **Stress monitoring:** Baseline stress tracking influences workout intensity

### Gamification & Motivation
- **Duolingo-style streaks:** Visual 7-day streak calendar with gold squares for logged days
- **Energy logging:** Daily check-ins create accountability
- **Progress visualization:** Calorie burn history and workout completion tracking
- **Mascot personality:** "Fittie the bear" provides encouragement and guidance

### Neo-Brutalist Design System
- **Accessibility-first:** High contrast, bold borders, and clear typography
- **No blur shadows:** Hard offset shadows for depth without visual clutter
- **Consistent spacing:** 14px border radius across all UI elements
- **Uppercase headers:** Strong visual hierarchy with bold (w900) typography

---

## Architecture

### System Design

```
┌─────────────────────────────────────────────────────────────┐
│                         Flutter App                          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │              │  │              │  │                 │   │
│  │  UI Layer    │  │  State Mgmt  │  │   Services      │   │
│  │  (Widgets)   │  │  (Provider)  │  │   Layer         │   │
│  │              │  │              │  │                 │   │
│  └──────┬───────┘  └──────┬───────┘  └────┬───┬────┬──┘   │
│         │                 │                │   │    │      │
│         └─────────────────┴────────────────┘   │    │      │
│                                                │    │      │
└────────────────────────────────────────────────┼────┼──────┘
                                                 │    │
                        ┌────────────────────────┘    │
                        │                             │
                        ▼                             ▼
              ┌──────────────────┐         ┌──────────────────┐
              │  Gemini 3 API    │         │  Firebase        │
              │  ─────────────   │         │  ─────────────   │
              │  - Workout Gen   │         │  - Auth          │
              │  - Chat Coach    │         │  - Firestore     │
              │  - JSON Output   │         │  - User Data     │
              └──────────────────┘         └──────────────────┘
```

### Data Flow

1. **User Input** → Energy level, preferences, physical stats
2. **Context Building** → App state aggregates user profile
3. **Gemini Request** → Structured prompt with context sent to Gemini 3 Flash
4. **Response Processing** → JSON parsed, validated, and enhanced with visuals
5. **UI Rendering** → Workout cards displayed with animations
6. **Firebase Sync** → User progress saved to Firestore

---

## Getting Started

### Prerequisites

- **Flutter SDK:** Version 3.6.0 or higher
- **Firebase Account:** For authentication and database
- **Gemini API Key:** Obtain from [Google AI Studio](https://ai.google.dev/)
- **Platform:** Web (Chrome), Android, iOS, or desktop

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yakimm-art/fittie.git
   cd fittie
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your API keys:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   GIPHY_API_KEY=your_giphy_api_key_here (optional)
   ```

4. **Set up Firebase:**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Download configuration files:
     - `google-services.json` for Android → `/android/app/`
     - `GoogleService-Info.plist` for iOS → `/ios/Runner/`

5. **Run the app:**
   ```bash
   # Web
   flutter run -d chrome --web-port 8080
   
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   ```

---

## How It Works

### 1. User Onboarding

New users complete a signup flow that collects:
- **Name and email** for authentication
- **Age, weight, height** for calorie calculations
- **Fitness goals** and preferences
- **Injury history** and equipment availability

This data is stored in Firebase Firestore and used by Gemini for personalized workout generation.

### 2. Daily Energy Check-In

Each day, users log their energy level on a 0-100% scale:

- **0-39%:** Desk Mode - Gentle stretches, mobility work
- **40-69%:** Zen Mode - Moderate yoga, balanced training
- **70-100%:** Power Mode - High-intensity cardio, strength training

This energy value is the primary input for Gemini's workout algorithm.

### 3. AI Workout Generation

When a user requests a workout:

**Step 1:** App constructs a detailed prompt for Gemini
```dart
final prompt = '''
USER PROFILE:
- Energy: 85% | Mode: Power
- Physicals: Age 28, Weight 70kg, Height 175cm
- Stress Level: 45/100
- Injuries: Lower back sensitivity
- Equipment: Dumbbells, Resistance Bands

TASK: Create a 6-exercise workout routine.
RULES: 
- Avoid exercises that strain the lower back
- Use available equipment where appropriate
- Calculate calories using MET values and user weight
- Assign intensity levels 1-10
''';
```

**Step 2:** Gemini processes the request and returns structured JSON

**Step 3:** App validates response and fetches visual demonstrations from the exercise database

**Step 4:** Workout is displayed with:
- Exercise previews (10-second demo phase)
- Duration timers
- Calorie counters
- Instruction overlays

### 4. Workout Execution

During the workout session:
- **Preview phase:** 10 seconds to view exercise demonstration
- **Active phase:** Timed execution with visual progress
- **Rest periods:** Countdown between exercises
- **Completion:** Calories burned and stats logged to Firebase

### 5. Progress Tracking

The dashboard displays:
- **Streak calendar:** Last 7 days with gold squares for logged days
- **Total calories:** Sum of all burned calories
- **Workout history:** Past sessions with intensity levels
- **AI chat:** Conversational coaching and advice

---

## Design Philosophy

### Neo-Brutalism Principles

Fittie's UI is inspired by the neo-brutalist design movement, characterized by:

**Visual Elements:**
- **Hard shadows:** Offset shadows with no blur (e.g., `BoxShadow(offset: Offset(4, 4), blurRadius: 0)`)
- **Thick borders:** 2.5px black borders on all cards and buttons
- **Consistent radius:** 14px corner rounding (never fully rounded pills)
- **Bold typography:** Font weight 900 (w900) for headers and labels

**Color Palette:**
```dart
class AppColors {
  static const bgCream = Color(0xFFFDFBF7);      // Background
  static const primaryTeal = Color(0xFF38B2AC);  // Primary actions
  static const textDark = Color(0xFF2D3748);     // Primary text
  static const blackAccent = Color(0xFF000000);  // Borders & shadows
  static const streakGold = Color(0xFFFBBF24);   // Streak indicators
  static const errorRed = Color(0xFFEF4444);     // Errors & warnings
}
```

**Accessibility:**
- High contrast ratios (WCAG AAA compliant)
- Clear visual hierarchy
- Touch targets minimum 44x44px
- Screen reader support

---

## Technology Stack

### Frontend
- **Framework:** Flutter 3.6.0
- **Language:** Dart
- **State Management:** Provider
- **Routing:** go_router 14.0.0
- **Charts:** fl_chart 0.66.0

### Backend & Services
- **AI:** google_generative_ai 0.4.0 (Gemini 3 Flash)
- **Authentication:** firebase_auth 5.1.0
- **Database:** cloud_firestore 5.0.0
- **Environment:** flutter_dotenv 5.2.1

### UI & Media
- **Typography:** google_fonts 6.2.1
- **Audio:** audioplayers 6.0.0
- **HTTP:** http 1.2.0

### Assets
- **Exercise Database:** 800+ exercises from [free-exercise-db](https://github.com/yuhonas/free-exercise-db)
- **Visual Demos:** Curated Giphy library + local JSON database

---

## Project Structure

```
fittie/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── pages/                       # UI screens
│   │   ├── landing_page.dart        # Marketing landing page
│   │   ├── login_page.dart          # Authentication
│   │   ├── signup_page.dart         # Multi-step onboarding
│   │   ├── dashboard_page.dart      # Main app dashboard
│   │   ├── workout_session_page.dart # Active workout UI
│   │   └── ...                      # Feature pages
│   ├── services/                    # Business logic
│   │   ├── ai_service.dart          # Gemini 3 integration
│   │   ├── firebase_service.dart    # Firebase operations
│   │   └── app_state.dart           # Global state management
│   └── widgets/                     # Reusable components
├── assets/
│   ├── data/
│   │   └── exercises.json           # Exercise database
│   ├── audio/                       # Mascot audio files
│   └── app_icon.png                 # App icon
├── android/                         # Android platform files
├── ios/                             # iOS platform files
├── web/                             # Web platform files
├── .env.example                     # Environment template
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

---

## Contributing

This project was created for the Google DeepMind Gemini 3 Hackathon (February 2026). While it's primarily a hackathon submission, suggestions and feedback are welcome.

### Development Setup

1. Follow the [Getting Started](#getting-started) instructions
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make changes and test thoroughly
4. Commit with clear messages: `git commit -m "feat: add new feature"`
5. Push and create a pull request

---

## Acknowledgments

**Built With:**
- [Google Gemini 3 Flash API](https://ai.google.dev/) - Core AI intelligence
- [Flutter](https://flutter.dev/) - Cross-platform framework
- [Firebase](https://firebase.google.com/) - Backend infrastructure
- [free-exercise-db](https://github.com/yuhonas/free-exercise-db) - Exercise dataset
- [Giphy API](https://developers.giphy.com/) - Exercise visual demonstrations

**Inspiration:**
- Duolingo's streak system for gamification patterns
- Neo-brutalism design movement for UI aesthetics
- Modern fitness coaching methodologies

**Submitted to:**
- Google DeepMind Gemini 3 Hackathon (February 2026)

---

## License

This project is a hackathon submission and is provided as-is for educational and demonstration purposes.

**Contact:** For questions about this project, please open an issue on GitHub.

---

<div align="center">
  <strong>Powered by Google Gemini 3 Flash</strong>
  <br/>
  Built with Flutter • Deployed with Firebase • Designed with Care
</div>
