# 🏋️ Fittie

**The Agentic Fitness Companion that Flows with You**

> Fitness should be frictionless. Scan. Train. Done.

[![PWA](https://img.shields.io/badge/PWA-Zero--Install-blue)](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)
[![AWS](https://img.shields.io/badge/AWS-Powered-orange)](https://aws.amazon.com/)
[![Dreamflow](https://img.shields.io/badge/Dreamflow-Agentic-purple)](https://dreamflow.ai/)

---

## 🔥 The "Fittie Anywhere" Philosophy

> "Fittie lives at a URL. Scan a QR code at the gym and start your session instantly. We removed every barrier between intention and action."

**Fittie isn't just an app—it's a presence.** It's the pinned tab reminding you to stretch after 90 minutes of coding. It's the same session continuing on your phone as you walk to the gym. It's voice coaching you through your last rep when your hands are on the barbell, not your screen.

### Instant Access, Any Device

As a PWA, Fittie works seamlessly across your laptop, phone, and tablet. No downloads required—just open and go. Add it to your home screen for a native app experience, or keep it in a browser tab. Your choice, your flow.

---

## 📁 Project Structure

```
fittie/
├── frontend/          # Dreamflow PWA - "Instant Access Layer"
├── backend/           # AWS Lambda functions
│   ├── src/          # TypeScript Lambda handlers
│   └── package.json  # Backend dependencies
├── infra/            # AWS CDK infrastructure code
│   ├── lib/          # CDK stack definitions
│   └── package.json  # Infrastructure dependencies
├── shared/           # Shared TypeScript types
│   ├── types/        # Common type definitions
│   └── package.json  # Shared package
├── docs/             # Documentation
│   └── elevenlabs-integration.md
├── scripts/          # Utility scripts
├── .github/
│   └── workflows/    # CI/CD pipelines
├── package.json      # Monorepo root configuration
└── openspec/         # Spec-driven development
```

This is a **monorepo** using npm workspaces for managing multiple packages.

---

## 💡 The Idea

**Fittie** is an autonomous, mobile-first Progressive Web App (PWA) that manages your physical health as a **dynamic system**. Unlike traditional fitness apps that offer static, one-size-fits-all routines, Fittie treats your biological state as real-time data input.

Through an **agentic feedback loop**, Fittie observes human physical constraints—such as injury, fatigue, or environment—and autonomously reconfigures the application. When you report a physical "bottleneck" (e.g., *"My lower back is tight from coding"*), Fittie doesn't just suggest a fix; it **morphs the UI** and **re-engineers the workout logic** on the fly.

### From Advice to Agency

Most fitness apps tell you what to do (**Advice**). Fittie changes the app to adapt to you (**Agency**). It's a proactive partner, not a reactive library.

---

## 🎯 Core Features & Functionalities

### 1. 🎨 Morphic UI — The Agentic Showstopper

**The interface literally reshapes itself based on your physical and mental state.** Tell it you're exhausted, and the aggressive HIIT dashboard melts into a gentle recovery flow. The AI doesn't just respond—it *transforms*.

| Mode | Trigger | Visual Character |
|------|---------|------------------|
| **Power Mode** | High energy, intense workout | High-contrast, data-heavy, aggressive reds/oranges |
| **Zen Mode** | Fatigue, pain, stress detected | Calming pastels, simplified interface, blues/greens |
| **Desk Mode** | Sedentary detection | Compact, non-intrusive, minimal |
| **Gym Mode** | Active session | Large touch targets, progress-focused |

**Visual Demo Idea**: Split-screen showing user saying "I'm tired" → UI animating from high-energy red/orange to calm blue/green with completely different workout suggestions. That's a "wow" moment.

---

### 2. 🎙️ Voice Coach — Hands-Free Coaching

**ElevenLabs Integration**: High-fidelity, empathetic voice synthesis for real-time coaching.

- **Active Listening**: Talk to Fittie mid-workout. Say *"This is too hard"* or *"My knee is clicking"* and the agent pauses, analyzes, and swaps exercises.
- **Contextual Tone**: Encouraging in Power Mode, calming in Zen Mode
- **Sub-500ms Latency**: Fast enough to feel like a real conversation

---

### 3. 🧠 Soma-Logic Engine — On-Demand Routine Generation

**Constraint-Aware Planning** builds custom routines based on:
- Available equipment (e.g., "chair only", "dumbbells + resistance bands")
- Current physical state (e.g., "lower back pain", "energy level 2/5")
- Time available (15-60 minutes)
- Fitness goals (strength, cardio, mobility, recovery)

**Biomechanical Validation**: RAG system powered by **Amazon Bedrock** ensures all movements are anatomically sound.

**Generation Time**: <2 seconds for a complete validated routine

---

### 4. 🔄 Seamless Sync — "Desk-to-Gym" Flow

**Multi-Surface Context Switching**: This is where the web-first approach shines.

**The Workflow**:
1. User has Fittie open in a pinned tab on their laptop ("Desk Mode")
2. Detects 60+ minutes of inactivity → suggests "Micro-Flows" (2-5 minute desk stretches)
3. User heads to the gym, opens the same URL on their phone
4. **Context preserved**: Full workout generated based on gym equipment, addressing desk stiffness

> "We chose a PWA because fitness should be frictionless. Users can scan a QR code at the gym and start their session instantly."

---

### 5. 🛡️ Real-Time Safety Validation

Every exercise is validated through a **triple-layer safety system**:

1. **Rule-Based Layer**: Fast contraindication checks (<10ms)
2. **RAG Knowledge Base**: Semantic search through biomechanical exercise database
3. **LLM Analysis**: Amazon Bedrock (Claude 3) contextually assesses safety

**Example**: User reports knee pain → System excludes jump squats, suggests wall sits instead

---

### 6. 🔁 Morphic State — Dynamic Mid-Workout Adaptation

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

## 🛠️ Tech Stack — With Marketing Names

| Component | Implementation | Marketing Name |
|-----------|----------------|----------------|
| **Frontend** | Dreamflow (PWA) | **Instant Access Layer** |
| **Identity** | AWS Amplify Auth | **Seamless Sync** |
| **Logic** | .NET Web API / Lambda on AWS | **Soma-Logic Engine** |
| **Voice** | ElevenLabs Web SDK | **Voice Coach** |
| **State** | Lambda + DynamoDB | **Morphic State** |
| **AI/RAG** | Amazon Bedrock (Claude 3) | **Biomechanical Validator** |
| **CDN** | CloudFront | **Global Edge Delivery** |

### Full AWS Integration (8+ Services)

| Service | Purpose |
|---------|---------|
| **AWS Amplify** | Authentication, user management |
| **AWS Lambda** | Serverless functions for state triggers |
| **Amazon DynamoDB** | NoSQL database for state logs and workout history |
| **Amazon Bedrock** | AI/LLM hosting for biomechanical knowledge base |
| **Amazon S3** | Static assets (workout videos, animations) |
| **Amazon EventBridge** | Event-driven architecture for state changes |
| **AWS CloudFront** | CDN for PWA delivery |

---

## 🧮 The "Soma-Logic" Framework

Fittie operates as a **Biological Operating System** that monitors and responds to your physical state:

```math
S_{user} = { Pain, Energy, Equipment }
```

```math
f_{Agent}(S_{user}) → { Routine_{new}, Theme_{new}, Voice_{profile} }
```

**When the User State ($S_{user}$) changes**—for instance, an increase in 'Pain'—**the Fittie Agent ($f_{Agent}$)** executes a real-time transformation of the app environment.

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

### 1. **Zero-Friction Deployment** (The Killer Demo)
Record your 60-second video showing someone scanning a QR code at a gym entrance, and within 3 seconds they're getting voice-coached through their first set. Instant access, instant value.

### 2. **The "Ambient Fitness Companion" Angle**
> "Fittie isn't just an app—it's a presence."

The .NET/Lambda backend maintains session state via AWS, so the transition from laptop → phone is seamless. The user never "logs in again"—they just... continue.

### 3. **Morphic UI as the Star**
The hackathon specifically rewards Dreamflow's agentic builder. The focus is on how intelligent the interface is—the UI that transforms based on your state.

### 4. **Engineering Depth**
- State machine architecture
- Event-driven serverless design
- RAG-based AI validation
- Mathematical state transition model

### 5. **AWS Cloud Club Alignment**
Demonstrates comprehensive AWS service integration (8+ services) while staying within free tier limits.

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│         User Layer (PWA + Voice) - "Instant Access"     │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│      Presentation Layer - "Morphic UI" (Dreamflow)      │
│    UI Engine  │  Voice Coach  │  Workout Player         │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│      Orchestration - "Soma-Logic Engine" (Agent)        │
│              Reasoning & State Machine                  │
└────┬──────────────┬──────────────┬─────────────────────┘
     │              │              │
┌────▼────┐  ┌──────▼──────┐  ┌───▼──────────────────┐
│Morphic  │  │  Routine    │  │  Biomechanical       │
│State    │  │  Generator  │  │  Validator (RAG)     │
│Manager  │  │             │  │  (Amazon Bedrock)    │
└────┬────┘  └──────┬──────┘  └───┬──────────────────┘
     │              │              │
┌────▼──────────────▼──────────────▼────────────────────┐
│      Data Layer - "Seamless Sync" (AWS)                │
│   DynamoDB  │  S3 Storage  │  Bedrock Knowledge Base  │
└────────────────────────────────────────────────────────┘
```

---

## 🎬 Demo Scenarios

### Scenario 1: Instant Access
1. User scans QR code at gym entrance
2. Fittie loads instantly (PWA cached)
3. Voice coach: *"Welcome back! Ready for leg day?"*
4. **Instant access, instant value**

### Scenario 2: Morphic UI in Action
1. User starts high-intensity workout (Power Mode - red/orange UI)
2. User says: *"I'm exhausted"*
3. **Instant visual transformation** to Zen Mode (<200ms)
4. UI melts from aggressive to calming blues/greens
5. Workout regenerates with recovery focus

### Scenario 3: Desk-to-Gym Handoff
1. User works at desk for 90 minutes (pinned tab)
2. Desktop notification: *"Time for a stretch!"*
3. User opens Fittie on phone at gym
4. **Context preserved**: App suggests mobility warm-up addressing desk stiffness
5. Full workout generated based on gym equipment

### Scenario 4: Real-Time Safety Swap
1. Mid-workout: User attempts burpees
2. User says: *"My knee is clicking"*
3. Agent analyzes, excludes high-impact movements
4. Voice coach: *"Let's protect that knee. How about step-backs instead?"*
5. Workout continues seamlessly

---

## 🚀 Getting Started

### Prerequisites

- Node.js 18+
- npm 9+
- AWS CLI configured
- GitHub CLI (for secrets management)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/fittie.git
cd fittie
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your actual values
```

#### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_REGION` | AWS region for resources | `us-east-1` |
| `COGNITO_USER_POOL_ID` | Cognito User Pool ID | `us-east-1_xxxxxxxxx` |
| `COGNITO_CLIENT_ID` | Cognito User Pool Client ID | `xxxxxxxxxxxxxxxxxxxx` |
| `DYNAMODB_STATE_TABLE` | Physical state table name | `user-physical-state` |
| `DYNAMODB_HISTORY_TABLE` | Workout history table name | `workout-history` |
| `DYNAMODB_EXERCISE_TABLE` | Exercise knowledge base table | `exercise-knowledge-base` |
| `S3_PWA_BUCKET` | S3 bucket for PWA hosting | `fittie-pwa-xxxxxxxxxxxx` |
| `S3_MEDIA_BUCKET` | S3 bucket for media assets | `fittie-media-xxxxxxxxxxxx` |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront distribution ID | `XXXXXXXXXXXXXX` |
| `CLOUDFRONT_URL` | CloudFront distribution URL | `https://xxxx.cloudfront.net` |

#### Optional Environment Variables

| Variable | Description | Purpose |
|----------|-------------|---------|
| `ELEVENLABS_API_KEY` | ElevenLabs API key | Voice Coach synthesis |
| `DREAMFLOW_API_KEY` | Dreamflow API key | Morphic UI orchestration |

Validate your environment configuration:
```bash
./scripts/check-env.sh
```

4. Run tests:
```bash
npm test
```

### Development

#### Local DynamoDB Setup (Optional)

For offline development and testing:

```bash
# Start local DynamoDB + Admin UI
./scripts/local-dev.sh start

# Use local environment
export $(cat .env.local | xargs)
npm run dev:backend

# Stop local services
./scripts/local-dev.sh stop
```

#### Development Commands

```bash
npm run dev:backend    # Run backend in watch mode
npm run dev:frontend   # Run frontend (Dreamflow)
npm run lint:fix       # Lint and fix code
npm run format         # Format code
```

### Deployment

```bash
npm run deploy:infra   # Deploy infrastructure with CDK
```

---

## 📚 Documentation

- [ElevenLabs Integration Guide](docs/elevenlabs-integration.md)
- [Scripts README](scripts/README.md)
- [OpenSpec Planning](openspec/)

---

## 🔮 Future Enhancements

- **Wearable Integration**: Real-time heart rate and movement tracking
- **Social Features**: Workout sharing and challenges
- **Multi-Language Voice Coach**: Spanish, French, Mandarin support
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

**⚡ Scan. Train. Done. Welcome to Fittie. 🚀**
