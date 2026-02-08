# 🐻 Fittie - AI-Powered Fitness Coach

**Fittie** is a personalized fitness companion powered by **Google Gemini 3** that adapts workouts to your energy levels, physical stats, and lifestyle in real-time.

## 🎯 Gemini 3 Integration

Fittie uses **Gemini 3 Flash** to deliver intelligent, context-aware fitness coaching:

- **🏋️ Dynamic Workout Generation**: Gemini analyzes your age, weight, height, energy level (0-100%), stress baseline, injuries, and available equipment to generate fully personalized workout routines with accurate calorie calculations
- **💬 AI Chat Coaching**: Conversational fitness advice with the "Fittie bear" personality that remembers context and builds a relationship over time
- **📊 Structured Data Output**: Uses Gemini's JSON output mode to generate workout plans with exercise names, durations, intensities, muscle groups, and personalized instructions
- **🎯 Adaptive Intelligence**: Every workout is generated fresh - no templates, just pure AI-driven personalization based on real-time user state

## ✨ Features

- **Neo-brutalist UI Design**: Bold, accessible interface with hard shadows and thick borders
- **Duolingo-style Streak System**: Daily energy logging with visual streak tracking
- **3 Adaptive Modes**: Power, Zen, and Desk modes that morph based on your energy
- **800+ Exercise Database**: Gemini selects from a curated library with visual demonstrations
- **Real-time Chat**: Get instant fitness advice, form corrections, and motivation from Fittie
- **Firebase Backend**: Secure user authentication and data persistence

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.6.0
- Firebase account
- Gemini API key from [AI Studio](https://ai.google.dev/)

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yakimm-art/fittie.git
cd fittie
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY
```

4. Run the app:
```bash
flutter run -d chrome --web-port 8080
```

## 🛠️ Tech Stack

- **Frontend**: Flutter
- **AI**: Google Gemini 3 Flash API
- **Backend**: Firebase (Auth, Firestore)
- **State Management**: Provider
- **UI**: Custom neo-brutalist design system

## 📱 How It Works

1. **Profile Setup**: Users enter physical stats (age, weight, height) and preferences
2. **Energy Tracking**: Daily energy level input (0-100%) determines workout intensity
3. **AI Generation**: Gemini 3 analyzes user context and generates personalized workouts
4. **Workout Execution**: Visual demonstrations guide users through each exercise
5. **Progress Tracking**: Streak system and calorie tracking motivate consistency

## 🎨 Design Philosophy

Fittie embraces **neo-brutalism** - a design trend characterized by:
- 14px border radius (never pill-shaped)
- 2.5px black borders on all cards
- Hard offset shadows (no blur)
- Uppercase bold typography (w900 weight)
- High-contrast cream/teal/dark color palette

## 📄 License

This project is submitted to the Google DeepMind Gemini 3 Hackathon (February 2026).

## 🙏 Acknowledgments

- Powered by Google Gemini 3 Flash
- Exercise database from [free-exercise-db](https://github.com/yuhonas/free-exercise-db)
- Built with Flutter and Firebase
