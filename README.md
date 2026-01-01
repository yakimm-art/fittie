# 🏋️ Fittie

**The Agentic Fitness Companion that Flows with You**

> A Dreamflow Buildathon submission by AWS Cloud Club Captain

[![PWA](https://img.shields.io/badge/PWA-Enabled-blue)](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)
[![AWS](https://img.shields.io/badge/AWS-Powered-orange)](https://aws.amazon.com/)
[![Dreamflow](https://img.shields.io/badge/Dreamflow-Agentic-purple)](https://dreamflow.ai/)

---

## 💡 The Idea

**Fittie** is an autonomous, mobile-first Progressive Web App (PWA) that manages your physical health as a **dynamic system**. Unlike traditional fitness apps that offer static, one-size-fits-all routines, Fittie treats your biological state as real-time data input.

Through an **agentic feedback loop**, Fittie observes human physical constraints—such as injury, fatigue, or environment—and autonomously reconfigures the application. When you report a physical "bottleneck" (e.g., *"My lower back is tight from coding"*), Fittie doesn't just suggest a fix; it **morphs the UI** and **re-engineers the workout logic** on the fly, transitioning from a high-intensity dashboard to a therapeutic recovery environment instantly.

### From Advice to Agency

Most fitness apps tell you what to do (**Advice**). Fittie changes the app to adapt to you (**Agency**). It's a proactive partner, not a reactive library.

---

## 🎯 Core Features & Functionalities

### 1. 🎨 Agentic UI Morphing *(Dreamflow Exclusive)*

**Dynamic Surface Adaptation**: The app interface physically changes based on the agent's reasoning.

- **Power Mode**: High-contrast, data-heavy UI for intense workouts
- **Zen Mode**: Calming pastels, simplified interface for recovery
- **Desk Mode**: Compact, non-intrusive for office stretches
- **Gym Mode**: Large touch targets, progress-focused for active sessions

**Example**: In "Power Mode," the UI is aggressive and metric-focused. If the agent detects high stress or pain, it triggers a **Visual State Transition** to "Zen Mode," emphasizing recovery movements with smooth animations (<200ms).

---

### 2. 🎙️ Hands-Free "Voice-to-Action" Coaching

**ElevenLabs Integration**: Fittie uses high-fidelity, empathetic voice synthesis to provide real-time coaching.

- **Active Listening**: Talk to Fittie mid-workout. Say *"This is too hard"* or *"My knee is clicking"* and the agent pauses the timer, analyzes the input, and swaps the current exercise for a safer alternative.
- **Contextual Responses**: Voice coaching adapts tone based on your state (encouraging in Power Mode, calming in Zen Mode)
- **Sub-500ms Latency**: Fast enough to feel like a real conversation

---

### 3. 🧠 On-Demand Routine Generation

**Constraint-Aware Planning**: Fittie builds custom routines based on:
- Available equipment (e.g., "chair only", "dumbbells + resistance bands")
- Current physical state (e.g., "lower back pain", "energy level 2/5")
- Time available (15-60 minutes)
- Fitness goals (strength, cardio, mobility, recovery)

**Biomechanical Validation**: Uses a RAG (Retrieval-Augmented Generation) system powered by **Amazon Bedrock** to ensure all suggested movements are anatomically sound and safe.

**Generation Time**: <2 seconds for a complete validated routine

---

### 4. 🔄 "Desk-to-Gym" PWA Sync

**Multi-Surface Context Switching**: As a web app, Fittie monitors your "Sedentary State" via your laptop.

- **Sedentary Monitoring**: Detects 60+ minutes of inactivity and proactively suggests "Micro-Flows" (2-5 minute desk stretches)
- **Seamless Handoff**: Start on desktop, continue on mobile at the gym with full context preserved
- **Offline-First**: Works without internet using service workers and local caching

---

### 5. 🛡️ Real-Time Safety Validation

Every exercise is validated through a **triple-layer safety system**:

1. **Rule-Based Layer**: Fast contraindication checks (<10ms)
2. **RAG Knowledge Base**: Semantic search through biomechanical exercise database
3. **LLM Analysis**: Amazon Bedrock (Claude 3) contextually assesses safety

**Example**: User reports knee pain → System excludes jump squats, suggests wall sits instead

---

### 6. 🔁 Dynamic Mid-Workout Adaptation

**The Soma-Logic Framework**: Your biological state drives everything.

```
State Change → Agent Reasoning → App Transformation
```

**Real-World Flow**:
1. User says: *"My lower back hurts"*
2. Physical state updated in DynamoDB (< 200ms)
3. Agent detects constraint, triggers UI morph to Zen Mode
4. Routine regenerates excluding lower back stress
5. Voice coach: *"I've adjusted your routine to protect your back"*

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose |
|------------|---------|
| **Dreamflow / Flutter** | Visual builder for agentic UI and PWA deployment |
| **Service Workers** | Offline capability and asset caching |
| **PWA** | Installable web app (no app store friction) |

### Backend & Cloud (AWS)
| Service | Purpose |
|---------|---------|
| **AWS Amplify** | Authentication, user management |
| **AWS Lambda** | Serverless functions for state triggers |
| **Amazon DynamoDB** | NoSQL database for state logs and workout history |
| **Amazon Bedrock** | AI/LLM hosting for biomechanical knowledge base (Claude 3) |
| **Amazon S3** | Static assets (workout videos, animations) |
| **Amazon EventBridge** | Event-driven architecture for state changes |
| **AWS CloudFront** | CDN for PWA delivery |

### AI & Voice
| Technology | Purpose |
|------------|---------|
| **Dreamflow Orchestrator** | Manages reasoning loop and UI state changes |
| **ElevenLabs API** | High-fidelity voice synthesis for coaching |
| **Web Speech API** | Fallback speech recognition |

---

## 🧮 The "Soma-Logic" Framework

Fittie operates as a **Biological Operating System** that monitors and responds to your physical state:

```math
S_{user} = { Pain, Energy, Equipment }
```

```math
f_{Agent}(S_{user}) → { Routine_{new}, Theme_{new}, Voice_{profile} }
```

**When the User State ($S_{user}$) changes**—for instance, an increase in 'Pain'—**the Fittie Agent ($f_{Agent}$)** executes a real-time transformation of the app environment, ensuring your health 'flow' remains uninterrupted.

---

## 🚀 Key Performance Metrics

| Metric | Target | Status |
|--------|--------|--------|
| UI Transition Time | < 200ms | ⚡ Optimized |
| Voice Processing Latency | < 500ms | ⚡ Optimized |
| Routine Generation | < 2s | ⚡ Optimized |
| Safety Validation | < 3s | ⚡ Optimized |
| Offline Capability | 100% core features | ✅ Enabled |

---

## 🏆 The Winning Edge

### 1. **Zero-Friction Deployment**
By utilizing a mobile-first PWA, you bypass App Store hurdles—instant user onboarding via a **simple QR code**. Perfect for hackathon demos!

### 2. **Engineering Depth**
- State machine architecture
- Event-driven serverless design
- RAG-based AI validation
- Mathematical state transition model

### 3. **Dreamflow Innovation**
Showcases Dreamflow's agentic capabilities with real-world health impact—not just another CRUD app.

### 4. **AWS Cloud Club Alignment**
Demonstrates comprehensive AWS service integration (8+ services) while staying within free tier limits.

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│              User Layer (PWA + Voice)                   │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│         Presentation Layer (Dreamflow)                  │
│    UI Engine  │  Voice System  │  Workout Player        │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│         Orchestration (Dreamflow Agent)                 │
│              Reasoning & State Machine                  │
└────┬──────────────┬──────────────┬─────────────────────┘
     │              │              │
┌────▼────┐  ┌──────▼──────┐  ┌───▼──────────────────┐
│Physical │  │  Routine    │  │  Biomechanical       │
│State    │  │  Generator  │  │  Validator (RAG)     │
│Manager  │  │             │  │  (Amazon Bedrock)    │
└────┬────┘  └──────┬──────┘  └───┬──────────────────┘
     │              │              │
┌────▼──────────────▼──────────────▼────────────────────┐
│         Data Layer (AWS)                               │
│   DynamoDB  │  S3 Storage  │  Bedrock Knowledge Base │
└────────────────────────────────────────────────────────┘
```

---

## 🎬 Demo Scenarios

### Scenario 1: Pain-Triggered UI Morph
1. User starts high-intensity workout (Power Mode)
2. User says: *"My shoulder hurts"*
3. **Instant transition** to Zen Mode (<200ms)
4. Workout regenerates excluding overhead movements
5. Voice coach provides empathetic guidance

### Scenario 2: Desk-to-Gym Handoff
1. User works at desk for 90 minutes
2. Desktop notification: *"Time for a stretch!"*
3. User opens Fittie on phone at gym
4. **Context preserved**: App suggests mobility warm-up addressing desk stiffness
5. Full workout generated based on gym equipment

### Scenario 3: Real-Time Exercise Swap
1. Mid-workout: User attempts burpees
2. User says: *"This is too hard"*
3. Agent analyzes energy level and workout progress
4. Proposes regression: *"How about step-backs instead?"*
5. User confirms, workout continues seamlessly

---

## 📂 Project Structure

```
fittie/
├── README.md                    # This file
├── AGENTS.md                    # AI assistant instructions
├── .gitignore                   # Git ignore rules
└── openspec/                    # Planning & specifications
    ├── project.md               # Project context & conventions
    ├── AGENTS.md                # OpenSpec workflow guide
    └── changes/                 # Change proposals
        └── add-fittie-core-system/
            ├── proposal.md      # High-level overview
            ├── design.md        # Technical architecture
            ├── tasks.md         # Implementation checklist
            └── specs/           # Capability specifications
                ├── agentic-ui-engine/
                ├── voice-coaching-system/
                ├── physical-state-manager/
                ├── routine-generator/
                ├── biomechanical-validator/
                └── multi-surface-sync/
```

---

## 🔮 Future Enhancements

- **Wearable Integration**: Real-time heart rate and movement tracking
- **Social Features**: Workout sharing and challenges
- **Multi-Language Support**: Voice coaching in Spanish, French, Mandarin
- **Physical Therapy Network**: Connect with certified professionals
- **Advanced Form Analysis**: Computer vision for real-time correction

---

## 👨‍💻 Developer

Built with ❤️ by **Mikaela**  
AWS Cloud Club Captain | Computer Engineering Student

**For Dreamflow Buildathon 2026**

---

## 📄 License

This project is developed for the Dreamflow Buildathon.

---

## 🙏 Acknowledgments

- **Dreamflow** - For the agentic platform
- **AWS** - For comprehensive cloud infrastructure
- **ElevenLabs** - For natural voice synthesis
- **OpenSpec** - For spec-driven development framework

---

**⚡ Ready to transform fitness from advice to agency? Let's build Fittie! 🚀**
