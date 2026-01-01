# Project Context

## Purpose
Fittie is an agentic fitness companion PWA designed for the Dreamflow Buildathon. It treats the user's biological state as a real-time data input and autonomously reconfigures the application based on physical constraints (injury, fatigue, environment). Unlike traditional fitness apps with static routines, Fittie morphs the UI and re-engineers workout logic on the fly.

**Mission:** Transform from advice to agency - Fittie is a proactive partner that changes the app to adapt to you, not a reactive library of exercises.

## Tech Stack

### Frontend
- **Dreamflow / Flutter** - Visual builder for agentic UI and PWA deployment
- Mobile-first PWA architecture for zero-friction deployment

### Backend & Cloud (AWS)
- **AWS Amplify** - Authentication and user management
- **AWS Lambda** - Serverless functions for agent-triggered operations
- **Amazon DynamoDB** - NoSQL database for physical state logs and workout history
- **Amazon Bedrock** - AI/LLM hosting for biomechanical knowledge base (Claude 3/Titan)
- **Amazon S3** - Static asset storage for workout videos and animations

### AI & Voice
- **Dreamflow Orchestrator** - Manages reasoning loop and UI state changes
- **ElevenLabs API** - High-fidelity voice synthesis for real-time coaching

## Project Conventions

### Code Style
- TypeScript/JavaScript: Follow Airbnb style guide
- Flutter/Dart: Follow official Dart style guide
- Descriptive variable names that reflect biological/fitness domain
- Use camelCase for functions, PascalCase for components/classes

### Architecture Patterns
- **Agentic State Machine**: User state drives UI and logic transformations
- **Event-Driven**: Physical state changes trigger Lambda functions
- **RAG Pattern**: Retrieval-Augmented Generation for biomechanically sound suggestions
- **Serverless-First**: Minimize infrastructure management with Lambda + DynamoDB

### Testing Strategy
- Unit tests for state transition logic
- Integration tests for AWS service interactions
- E2E tests for critical user flows (voice input → workout adjustment)
- Accessibility testing for PWA compliance

### Git Workflow
- Main branch for production-ready code
- Feature branches: `feature/[capability-name]`
- Hotfix branches: `hotfix/[issue-description]`
- Commit messages: Follow Conventional Commits (feat:, fix:, docs:, etc.)

## Domain Context

### Biological Operating System (Soma-Logic Framework)
Fittie operates as a "Biological OS" that monitors and responds to:
- **Physical State** ($S_{user}$): Pain, Energy, Equipment availability
- **Agent Function** ($f_{Agent}$): Maps user state to UI/routine/voice transformations
- **Constraint-Aware Planning**: Generates routines based on available tools and limitations

### User States
- **Power Mode**: High-intensity workouts, data-heavy UI
- **Zen Mode**: Recovery-focused, simplified UI, therapeutic movements
- **Sedentary State**: Desk-based monitoring with proactive stretch suggestions
- **Gym Mode**: Active workout tracking with real-time adjustments

### Voice Interaction Model
- Active listening during workouts
- Context-aware responses ("This is too hard" → swap exercise)
- Empathetic coaching tone via ElevenLabs
- Hands-free operation for safety

## Important Constraints

### Technical
- PWA must work offline for gym environments with poor connectivity
- Voice processing latency < 500ms for real-time coaching
- UI state transitions must be smooth (< 200ms)
- All exercise suggestions must be biomechanically validated via RAG

### Business
- Target: Dreamflow Buildathon judges (engineering-heavy audience)
- Deployment: Instant via QR code (no app store delays)
- Demo must showcase UI morphing and voice interaction

### Health & Safety
- Never suggest exercises that could cause injury
- Always provide modifications for limitations
- Clear disclaimers about medical advice
- Privacy-first approach to health data

## External Dependencies

### Required Services
- **Dreamflow Platform**: Core orchestration and UI building
- **ElevenLabs API**: Voice synthesis (rate limits TBD)
- **AWS Services**: See tech stack above
- **Biomechanical Knowledge Base**: Exercise form database with safety constraints

### Optional Enhancements
- Wearable device integration (future)
- Social workout sharing (future)
- Physical therapy provider network (future)
