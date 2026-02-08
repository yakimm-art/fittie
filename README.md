# 🐻 Fittie — AI-Powered Adaptive Fitness Coach

[![Flutter](https://img.shields.io/badge/Flutter-3.6.0-02569B?logo=flutter)](https://flutter.dev)
[![Gemini](https://img.shields.io/badge/Gemini-3.0%20Flash-4285F4?logo=google)](https://ai.google.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![ElevenLabs](https://img.shields.io/badge/ElevenLabs-Voice%20AI-000000?logo=elevenlabs)](https://elevenlabs.io)
[![License](https://img.shields.io/badge/License-Hackathon%20Project-green)](https://gemini3.devpost.com)

> **Google DeepMind Gemini 3 Hackathon — February 2026**

Fittie is an intelligent fitness companion that generates **personalized workout routines in real-time** using Google Gemini 3. Unlike traditional fitness apps with static workout templates, Fittie adapts every session to your current energy levels, physical capabilities, stress state, and available equipment — all wrapped in a bold **neo-brutalist** design language with a custom kawaii polar bear mascot.

**Inclusive by design** — Fittie supports wheelchair users, 11 chronic conditions (fibromyalgia, MS, CFS, POTS, and more), Spoon Theory energy tracking, and voice-first hands-free coaching for screen-free workouts.

<div align="center">

**No two workouts are ever the same.**

</div>

---

## Table of Contents

- [Overview](#overview)
- [Gemini 3 Integration](#gemini-3-integration)
- [Key Features](#key-features)
- [App Walkthrough](#app-walkthrough)
- [Architecture](#architecture)
- [Design Philosophy](#design-philosophy)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [Acknowledgments](#acknowledgments)

---

## Overview

Fittie addresses a fundamental problem in fitness: **one-size-fits-all workout plans don't account for daily fluctuations in energy, stress, and motivation.**

### The Problem

- Traditional fitness apps provide static routines that don't adapt to how you feel today
- Generic plans ignore individual physical differences, injuries, and equipment constraints
- Lack of real-time personalization leads to burnout or injury
- Fitness advice often feels robotic and disconnected from your actual progress

### Our Solution

Fittie introduces an **energy-based adaptation system** — users log their current energy level (0–100%), and Gemini 3 generates a contextually appropriate workout matched to their exact capacity that day. The app uses three Gemini models simultaneously:

1. **Workout Generator** (JSON mode) — Structured exercise generation with MET-based calorie math
2. **Chat Coach** (conversational) — Persistent AI companion with full workout history context
3. **Vision Analyzer** (multimodal) — Photograph your gym, get equipment-aware workouts

---

## Gemini 3 Integration

Fittie leverages **five distinct Gemini 3 capabilities** across its feature set:

### 1. Long Context Window — Workout History Intelligence

Before each workout generation, Fittie loads the user's **entire workout history** (up to 50 past sessions) from Firestore and feeds it into Gemini as structured context:

- **Muscle group frequency analysis** — Identifies overtrained or neglected muscle groups
- **Exercise intensity trends** — Tracks IMPROVING, STABLE, or DECREASING patterns
- **Plateau prevention** — Detects stagnation and injects variation automatically
- **Missed day handling** — Adjusts intensity after rest periods
- **Progressive overload** — Gradually increases difficulty based on historical trends

```dart
final workoutHistory = await _firebaseService.getWorkoutHistorySummary(maxWorkouts: 50);
final prompt = '''
WORKOUT HISTORY:
$workoutHistory

PROGRESSION RULES:
- If a muscle group was trained 3+ times this week, reduce its volume
- If intensity has been DECREASING, introduce easier variations
- If user missed 3+ days, start with a lighter warm-up session
''';
```

Every workout builds on what came before — the AI coach genuinely tracks your progress over weeks and months.

### 2. Multimodal Vision — Gym Equipment Scanner

Users upload a photo of their gym or workout space, and Gemini Vision identifies all available equipment and generates a workout around it:

1. User photographs their gym/equipment
2. Gemini Vision returns structured JSON with detected equipment, confidence scores, and space assessment
3. Equipment list feeds directly into the workout generator as additional context
4. A fully personalized routine uses **only** the detected equipment

```json
{
  "equipment_list": ["Adjustable Dumbbells", "Pull-up Bar", "Yoga Mat", "Resistance Bands"],
  "equipment_details": [
    {"name": "Adjustable Dumbbells", "confidence": "high", "notes": "5-50lb range visible"},
    {"name": "Pull-up Bar", "confidence": "high", "notes": "Door-mounted"}
  ],
  "space_assessment": "Small home gym, approximately 8x10ft"
}
```

### 3. Persistent Chat Memory with Context Replay

The Fittie AI chatbot **remembers previous conversations** across sessions:

- **Chat history saved to Firestore** — Messages persist across app restarts
- **Context replay** — Last 40 messages replayed into each new Gemini ChatSession
- **User profile injection** — Every session starts with the user's name, age, weight, goals, injuries, and streak
- **Workout-aware advice** — The chatbot references your actual recent training data

```
User: "My knees have been sore since Tuesday's workout"
Fittie: "I noticed Tuesday's session had 3 leg-focused exercises at high
intensity. Let's skip lower body today and focus on upper body and core.
I'll also reduce squat volume in your next 2 sessions."
```

### 4. Structured JSON Output — Dynamic Workout Generation

Every workout request returns strictly structured JSON, parsed and validated by the app:

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

Calorie calculations use **MET (Metabolic Equivalent of Task) values** combined with the user's weight for scientifically accurate estimates.

### 5. Adaptive Energy Modes

Gemini categorizes daily energy into three workout modes:

| Mode | Energy | Style |
|------|--------|-------|
| **Power** 🔴 | 70–100% | High-intensity cardio and strength training |
| **Zen** 🟢 | 30–69% | Moderate yoga, stretching, balanced workouts |
| **Desk** 🔵 | 0–29% | Gentle stretches and desk-friendly mobility work |

The entire UI dynamically morphs — colors, gradients, mascot messages, and voice tone all adapt to the active mode.

---

## Key Features

### 🏋️ AI Workout Engine
- **Real-time generation** — No templates, every workout is uniquely generated by Gemini 3
- **800+ exercise database** — Matched with visual GIF demonstrations from [free-exercise-db](https://github.com/yuhonas/free-exercise-db)
- **Multi-tier exercise matching** — Synonym map (200+ entries) → exact match → substring → token intersection scoring
- **Fallback safety** — Curated offline routines if API calls fail
- **Daily limit** — Max 3 workouts per day to prevent overtraining

### 📸 Gym Photo Scanner (Gemini Vision)
- **Photo-based equipment detection** with confidence scoring
- **Space assessment** — AI evaluates available floor space from the image
- **End-to-end pipeline** — Photo → equipment list → personalized workout in one flow

### 💬 Persistent AI Chat Coach
- **Cross-session memory** — Chat history persisted to Firestore
- **40-message context replay** into each new Gemini session
- **Profile-aware** — Knows your name, goals, injuries, streak, and recent workouts
- **"Fittie the Bear" persona** — Energetic, supportive, emoji-rich coaching style

### 🎙️ Voice Coach (ElevenLabs + Gemini)
- **ElevenLabs TTS** (`eleven_turbo_v2_5`) for natural voice narration during workouts
- **Mode-adaptive voice** — Energetic (Power), calm (Zen), balanced (Desk)
- **In-memory audio cache** to minimize API calls
- **Automatic fallback** to browser/native TTS if quota is exceeded
- Exercise preview announcements: *"Get ready for Push Ups!"*

### 🔥 Gamification & Motivation
- **Duolingo-style streak calendar** — 7-day tracker with gold squares for logged days
- **Daily mood/energy check-in** — Emoji face slider for accountability
- **Calorie burn tracking** — Session totals and historical stats
- **Custom kawaii polar bear mascot** — Animated (`CustomPaint`), blinks, breathes, talks with mouth animation during signup audio

### 📝 Community Blog System
- **User blog submissions** — Title, rich content, category tags (Training Tips, Nutrition, Progress Update, Feature Idea, Community)
- **Admin approval workflow** — Posts submit as "pending", admins approve/reject with confirmation
- **Blog detail pages** — Full-content view with author info, timestamps, tag chips
- **Role-based visibility** — Non-admins see only approved posts; admins see all including pending with yellow badges

### ♿ Inclusivity & Accessibility
- **Seated/Wheelchair Mode** — 6 mobility options: Full Mobility, Wheelchair User, Limited Lower Body, Limited Upper Body, Seated Only, Crutches/Walker
- **11 chronic conditions supported** — Fibromyalgia, MS, CFS, Arthritis, POTS, Cerebral Palsy, Spinal Cord Injury, Amputation, Visual Impairment, Hearing Impairment
- **Spoonie Scale** — Energy measured in spoons (1–5) instead of percentages for users with chronic fatigue conditions (Spoon Theory)
- **Voice-First Coaching** — Hands-free workout control via `speech_to_text`; say "pause", "resume", "next", "skip", "help", or "quit"
- **Voice exercise explanations** — Say "help" or "how do I do this?" and Gemini explains the exercise aloud for screen-free use
- **Adaptive AI rules** — Wheelchair users get seated-only exercises; limited mobility reduces volume; chronic conditions reduce intensity 30%; POTS avoids sudden position changes; visual impairment gets extra-detailed verbal instructions
- **Accessibility step in signup** — Dedicated Step 3b collects mobility status, conditions, Spoonie preference, and voice-first preference
- **Mobility badge** on dashboard energy display for non-full-mobility users

### 🔐 Authentication & Onboarding
- **6-step animated signup wizard** with mascot audio narration at each step:
  1. Name, email, password
  2. Age, weight, height
  3. Stress level slider, activity level
  3b. ♿ Accessibility (mobility status, chronic conditions, Spoonie Scale, Voice-First)
  4. Equipment, injuries, goals (multi-select)
  5. Extra notes/preferences
- **Email verification** with auto-polling (3s interval) and resend cooldown
- **Remember Me** toggle — Firebase persistence switches between `LOCAL` and `SESSION`
- **Role-based access** — Users get `role: 'user'` on signup; admins set via Firestore

### 🖥️ Marketing Landing Site
- **8 public pages** with shared `BrutalistPageShell` layout:
  - **Landing** — Animated hero, feature cards, philosophy section, step-by-step flow, CTA, footer
  - **Features** — How it works (4-step), full feature list, tech stack comparison
  - **About** — Mission, numbers banner (1,200+ beta testers, 6 countries), values, timeline, team
  - **Blog** — Community posts feed with approval workflow
  - **Community** — Open source focus, 6 ways to contribute, FAQ
  - **Careers** — Open roles (Flutter Engineer, ML Engineer, Designer, etc.), perks
  - **Help Center** — Searchable categories (Getting Started, AI & Flows, Voice Coach, etc.)
  - **Voice Coach** / **Morphic UI** — Concept pages for voice AI and biometric-adaptive UI

---

## App Walkthrough

### 1. Onboarding

New users complete a **6-step animated wizard** guided by the kawaii polar bear mascot (with audio narration). Each step collects progressively more detailed fitness data — from basics (name, email) through physical stats (age, weight, height) and accessibility preferences (mobility status, chronic conditions, Spoonie Scale, Voice-First mode) to fitness context (equipment, injuries, goals). Accent colors cycle through teal → purple → orange → blue → yellow → pink per step.

### 2. Dashboard

The main app has **4 tabs** with a responsive layout (sidebar on web, bottom nav on mobile):

| Tab | Purpose |
|-----|---------|
| **Home** | Greeting, mood check-in, streak calendar, energy slider, calorie stats, weekly activity chart, today's workout breakdown |
| **Workouts** | "Start Flow" (AI workout), "Scan My Gym" (Gemini Vision), workout history (last 7 days) |
| **Chat** | Persistent AI chat with Fittie Agent, typing indicators, message history |
| **Profile** | Avatar (editable), stats, Edit Profile / Settings / Help sub-pages, logout |

### 3. Workout Session

When a user starts a workout:

1. **Exercise count selection** — Choose number of exercises (default 5)
2. **AI generation** — Loading screen while Gemini creates the routine
3. **Preview phase** — 10-second countdown per exercise with voice announcement and GIF demo
4. **Active phase** — Timed execution with progress bar, exercise visual, calorie counter
5. **Controls** — Pause/play, skip to next, voice commands (pause, resume, next, help, quit)
6. **Voice-First mode** — Mic auto-listens; say "help" for Gemini verbal exercise explanation
7. **Completion** — Total duration, total calories, exercise count logged to Firestore with celebration dialog

### 4. Progress Tracking

- **7-day streak calendar** with gold/grey squares
- **Calorie burn history** across all sessions
- **Workout history** with intensity levels and timestamps
- **AI chat** that references your actual progress data

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Flutter App                          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │  UI Layer    │  │  State Mgmt  │  │   Services      │   │
│  │  (27 files)  │  │  (Provider)  │  │   Layer         │   │
│  │  Pages +     │  │  AppState    │  │  AI, Firebase,  │   │
│  │  Widgets     │  │  (Morphic)   │  │  Voice          │   │
│  └──────┬───────┘  └──────┬───────┘  └────┬───┬────┬──┘   │
│         │                 │                │   │    │      │
│         └─────────────────┴────────────────┘   │    │      │
│                                                │    │      │
└────────────────────────────────────────────────┼────┼──────┘
                                                 │    │
              ┌──────────────────────────────────┘    │
              │                    ┌──────────────────┘
              ▼                    ▼
   ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐
   │  Gemini 3 Flash  │  │  Firebase        │  │  ElevenLabs    │
   │  ─────────────   │  │  ─────────────   │  │  ─────────────  │
   │  • Workout Gen   │  │  • Auth          │  │  • TTS Voice   │
   │  • Chat Coach    │  │  • Firestore DB  │  │  • Mode-aware  │
   │  • Vision (Gym)  │  │  • User Profiles │  │  • Audio Cache │
   │  • JSON Output   │  │  • Chat History  │  │  • Fallback    │
   │  • Long Context  │  │  • Workout Logs  │  │    to native   │
   └──────────────────┘  │  • Blog Posts    │  └────────────────┘
                         │  • Role Mgmt     │
                         └──────────────────┘
```

### Data Flow

1. **User Input** → Energy level, mood, preferences, physical stats, accessibility profile
2. **Context Building** → AppState aggregates profile + 50-workout history + equipment
3. **Gemini Request** → Structured prompt with full context sent to Gemini 3 Flash
4. **Response Processing** → JSON parsed → exercises matched to visual DB (multi-tier matching)
5. **UI Rendering** → Neo-brutalist workout cards with GIF demos and animations
6. **Voice Narration** → ElevenLabs TTS announces each exercise preview
7. **Firebase Sync** → Session results, streak, chat history persisted to Firestore

---

## Design Philosophy

### Neo-Brutalism

Fittie's entire UI follows the **neo-brutalist design movement**:

| Element | Specification |
|---------|---------------|
| Borders | 2.5–3px solid black on all cards and buttons |
| Shadows | Hard offset (4–8px), **zero blur** |
| Radius | 14px corners (never fully rounded pills) |
| Typography | Inter font, weight 700–900, uppercase headers |
| Background | Cream `#FDFBF7` with subtle dot-grid patterns |
| Accent Colors | Teal `#38B2AC`, Orange, Purple, Pink, Gold `#FBBF24` |
| Texture | Grain overlay on all pages for depth |

### Morphic Engine

The UI dynamically morphs based on the user's energy mode:
- **Power Mode** — Red-tinged gradients, energetic mascot messages, fast voice
- **Zen Mode** — Green-tinged gradients, calm mascot, slow stable voice  
- **Desk Mode** — Teal-tinged, balanced mascot, moderate voice

### Accessibility
- High contrast ratios (WCAG AAA targets)
- Clear visual hierarchy with bold typography
- Touch targets minimum 44×44px
- Scroll-triggered `FadeSlideIn` entrance animations
- `ClipRect` / `Clip.hardEdge` to prevent overflow during animations
- **Seated/Wheelchair Mode** — Mobility-aware workout generation
- **Spoonie Scale** — Spoon Theory energy system for chronic conditions
- **Voice-First Coaching** — Screen-free workout control via speech recognition
- **11 chronic conditions** with tailored AI exercise rules
- **Adaptive intensity** — AI auto-reduces intensity for fatigue conditions

### Custom Mascot — Kawaii Polar Bear

A fully hand-drawn `CustomPaint` animated polar bear that:
- **Breathes** (idle bounce animation)
- **Blinks** randomly
- **Talks** (mouth opens/closes when `isTalking: true` during signup audio)
- Holds dumbbells, has blush cheeks and teal accents
- Appears across: signup, dashboard, verify email, workout completion, chat header

---

## Technology Stack

### Frontend
| Package | Version | Purpose |
|---------|---------|---------|
| Flutter | 3.6.0 | Cross-platform framework |
| Provider | 6.1.2 | State management |
| go_router | 14.0.0 | Declarative routing with auth guards |
| fl_chart | 0.66.0 | Weekly activity charts |
| google_fonts | 6.2.1 | Inter typography |

### AI & Services
| Package | Version | Purpose |
|---------|---------|---------|
| google_generative_ai | 0.4.0 | Gemini 3 Flash (workout gen, chat, vision) |
| http | 1.2.0 | ElevenLabs TTS API calls |
| flutter_tts | 4.2.5 | Native TTS fallback |
| speech_to_text | 7.0.0 | Voice commands during workouts |
| audioplayers | 6.0.0 | Audio playback (mascot voice, TTS) |
| flutter_dotenv | 5.2.1 | Secure API key management |

### Backend
| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | 3.1.0 | Firebase initialization |
| firebase_auth | 5.1.0 | Auth with email verification |
| cloud_firestore | 5.0.0 | User profiles, workouts, chat, blog |

### Additional
| Package | Purpose |
|---------|---------|
| image_picker | Gym photo capture for Gemini Vision |
| url_launcher | External links |
| intl | Date formatting |

### Assets
- **Exercise Database** — 800+ exercises from [free-exercise-db](https://github.com/yuhonas/free-exercise-db)
- **Exercise Visuals** — GIF demonstrations matched via multi-tier name resolution
- **Mascot Audio** — Step-by-step narration files for signup wizard

---

## Project Structure

```
fittie/
├── lib/
│   ├── main.dart                        # App entry point + AuthWrapper
│   ├── nav.dart                         # GoRouter config with auth redirects
│   ├── theme.dart                       # Material 3 theme, AppSpacing, AppRadius
│   │
│   ├── pages/
│   │   ├── landing_page.dart            # Marketing hero, features, philosophy, CTA
│   │   ├── features_page.dart           # How it works, full feature list
│   │   ├── about_page.dart              # Mission, stats, values, timeline, team
│   │   ├── community_page.dart          # Open source, contribute, FAQ
│   │   ├── careers_page.dart            # Open roles & perks
│   │   ├── help_center_page.dart        # Search, categories, FAQ, contact
│   │   ├── voice_coach_page.dart        # Voice AI feature showcase
│   │   ├── morphic_ui_page.dart         # Biometric-adaptive UI concept
│   │   ├── brutalist_page_shell.dart    # Shared layout (header, footer, dots, grain)
│   │   │
│   │   ├── login_page.dart              # Auth + Remember Me toggle
│   │   ├── signup_page.dart             # 6-step wizard with mascot audio + accessibility
│   │   ├── verify_email_page.dart       # Auto-polling email verification
│   │   │
│   │   ├── dashboard_page.dart          # 4-tab dashboard (Home/Workouts/Chat/Profile)
│   │   ├── workout_session_page.dart    # Active workout: preview → active → complete
│   │   │
│   │   ├── blog_page.dart               # Blog feed with role-based visibility
│   │   ├── blog_entry_page.dart         # Blog post submission form
│   │   ├── blog_detail_page.dart        # Full post view + admin approve/reject
│   │   └── blog_admin_page.dart         # Admin review panel for pending posts
│   │
│   ├── services/
│   │   ├── ai_service.dart              # 3 Gemini models + exercise matching
│   │   ├── firebase_service.dart        # Auth, Firestore, blog, roles
│   │   └── voice_service.dart           # ElevenLabs TTS + native fallback
│   │
│   ├── providers/
│   │   └── app_state.dart               # Morphic engine, mode management, settings
│   │
│   └── widgets/
│       ├── kawaii_bear.dart              # CustomPaint animated polar bear mascot
│       └── weekly_activity_chart.dart   # fl_chart weekly workout visualization
│
├── assets/
│   ├── data/exercises.json              # 800+ exercise database
│   ├── audio/                           # Mascot voice narration files
│   └── app_icon.png                     # App icon
│
├── android/                             # Android platform
├── ios/                                 # iOS platform
├── web/                                 # Web platform
├── linux/                               # Linux desktop platform
├── macos/                               # macOS desktop platform
├── windows/                             # Windows desktop platform
│
├── pubspec.yaml                         # Dependencies & assets
├── analysis_options.yaml                # Lint rules
└── README.md                            # This file
```

---

## Getting Started

### Prerequisites

- **Flutter SDK** 3.6.0+
- **Firebase project** with Auth (Email/Password) and Firestore enabled
- **Gemini API Key** from [Google AI Studio](https://ai.google.dev/)
- **ElevenLabs API Key** *(optional)* from [elevenlabs.io](https://elevenlabs.io) for voice coaching

### Installation

```bash
# 1. Clone
git clone https://github.com/yakimm-art/fittie.git
cd fittie

# 2. Install dependencies
flutter pub get

# 3. Configure environment
cp .env.example .env
# Edit .env:
#   GEMINI_API_KEY=your_key_here
#   ELEVENLABS_API_KEY=your_key_here (optional)

# 4. Firebase setup
# - Create project at console.firebase.google.com
# - Enable Email/Password auth + Firestore
# - Add google-services.json (Android) and/or GoogleService-Info.plist (iOS)

# 5. Run
flutter run -d chrome --web-port 8080   # Web
flutter run -d android                   # Android
flutter run -d ios                       # iOS
```

### Admin Setup

To grant admin access (for blog approval, etc.):
1. Open Firebase Console → Firestore → `users` collection
2. Find the user document by UID
3. Add/set field: `role` = `"admin"`

---

## Contributing

This project was created for the **Google DeepMind Gemini 3 Hackathon** (February 2026). Suggestions and feedback are welcome!

1. Follow the [Getting Started](#getting-started) instructions
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make changes and test thoroughly
4. Commit with clear messages: `git commit -m "feat: add new feature"`
5. Push and create a pull request

---

## Acknowledgments

**Built With:**
- [Google Gemini 3 Flash](https://ai.google.dev/) — Core AI (workouts, chat, vision)
- [Flutter](https://flutter.dev/) — Cross-platform framework
- [Firebase](https://firebase.google.com/) — Auth, Firestore, hosting
- [ElevenLabs](https://elevenlabs.io/) — Natural voice synthesis
- [free-exercise-db](https://github.com/yuhonas/free-exercise-db) — Exercise dataset (800+ exercises)

**Design Inspiration:**
- Neo-brutalism design movement
- Duolingo's streak gamification
- Modern fitness coaching methodologies

---

## License

This project is a hackathon submission and is provided as-is for educational and demonstration purposes.

---

<div align="center">
  <strong>🐻 Powered by Google Gemini 3 Flash</strong>
  <br/>
  Built with Flutter • Firebase • ElevenLabs • Neo-Brutalism
  <br/><br/>
  <em>Google DeepMind Gemini 3 Hackathon — February 2026</em>
</div>
