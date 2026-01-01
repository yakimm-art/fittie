# Implementation Tasks: Fittie Core System

**Change ID:** `add-fittie-core-system`  
**Status:** Not Started

## Pre-Implementation Setup

- [ ] **ENV-1**: Create AWS account and configure CLI credentials
- [ ] **ENV-2**: Enable required AWS services (Lambda, DynamoDB, Bedrock, S3, Amplify)
- [ ] **ENV-3**: Set up billing alarms ($50/month threshold)
- [ ] **ENV-4**: Create Dreamflow account and explore platform
- [ ] **ENV-5**: Obtain ElevenLabs API key and test rate limits
- [ ] **ENV-6**: Set up GitHub repository with CI/CD pipeline
- [ ] **ENV-7**: Initialize project structure (monorepo: `frontend/`, `backend/`, `infra/`)

## Phase 1: Infrastructure Foundation (Days 1-2)

### AWS Setup
- [ ] **INF-1**: Create AWS CDK project in `infra/` directory
- [ ] **INF-2**: Implement Cognito User Pool for authentication
- [ ] **INF-3**: Create DynamoDB tables:
  - [ ] `user-physical-state` (userId, timestamp)
  - [ ] `workout-history` (userId, workoutId)
  - [ ] `exercise-knowledge-base` (exerciseId)
- [ ] **INF-4**: Set up S3 buckets:
  - [ ] `fittie-pwa` (PWA hosting)
  - [ ] `fittie-media` (workout videos/animations)
- [ ] **INF-5**: Configure CloudFront distribution for PWA
- [ ] **INF-6**: Deploy infrastructure: `cdk deploy FittieStack`
- [ ] **INF-7**: Verify all resources in AWS Console

### Local Development Environment
- [ ] **DEV-1**: Set up Flutter/Dart development environment
- [ ] **DEV-2**: Install Node.js 18+ and npm dependencies
- [ ] **DEV-3**: Configure environment variables (`.env` template)
- [ ] **DEV-4**: Set up local DynamoDB emulator for offline development
- [ ] **DEV-5**: Create shared TypeScript types package (`@fittie/types`)

## Phase 2: Physical State Manager (Days 3-4)

### Backend: State Management System
- [ ] **PSM-1**: Create Lambda function: `physical-state-manager`
  - [ ] POST `/state` - Update user physical state
  - [ ] GET `/state/latest` - Retrieve current state
  - [ ] GET `/state/history` - Retrieve state timeline
- [ ] **PSM-2**: Implement DynamoDB service layer:
  - [ ] `createStateRecord(userId, state)`
  - [ ] `getLatestState(userId)`
  - [ ] `queryStateHistory(userId, fromTimestamp, toTimestamp)`
- [ ] **PSM-3**: Add DynamoDB Streams trigger for state changes
- [ ] **PSM-4**: Implement Lambda: `on-state-change-handler`
  - [ ] Detect significant state changes (pain, energy drop)
  - [ ] Publish events to EventBridge
- [ ] **PSM-5**: Write unit tests for state transitions
- [ ] **PSM-6**: Deploy and test with Postman/curl

### Frontend: State Integration
- [ ] **PSM-7**: Create `PhysicalStateService` class in frontend
- [ ] **PSM-8**: Implement state update UI components:
  - [ ] Pain point selector (body diagram)
  - [ ] Energy level slider (1-5)
  - [ ] Equipment availability checklist
- [ ] **PSM-9**: Connect UI to backend API via Amplify
- [ ] **PSM-10**: Test real-time state updates

## Phase 3: Basic UI Shell (Days 4-5)

### Dreamflow/Flutter Setup
- [ ] **UI-1**: Create Flutter PWA project
- [ ] **UI-2**: Configure PWA manifest (`manifest.json`):
  - [ ] App name: "Fittie"
  - [ ] Icons (192x192, 512x512)
  - [ ] Theme colors
  - [ ] Offline capability flag
- [ ] **UI-3**: Implement service worker (`sw.js`):
  - [ ] Cache static assets
  - [ ] Cache API responses (stale-while-revalidate)
  - [ ] Offline fallback page
- [ ] **UI-4**: Create base theme system:
  - [ ] Power Mode theme (dark, high-contrast)
  - [ ] Zen Mode theme (light, calming pastels)
  - [ ] Desk Mode theme (compact, minimal)
  - [ ] Gym Mode theme (large fonts, high-vis)
- [ ] **UI-5**: Build responsive layout shell:
  - [ ] Top navigation bar
  - [ ] Main content area
  - [ ] Bottom action buttons
- [ ] **UI-6**: Implement theme switching logic
- [ ] **UI-7**: Test UI on mobile (Chrome DevTools, real device)

### UI State Transitions
- [ ] **UI-8**: Create `AgenticUIEngine` class
- [ ] **UI-9**: Implement `transitionTo(mode)` with animations
- [ ] **UI-10**: Measure and optimize transition latency (< 200ms)
- [ ] **UI-11**: Add visual transition effects (fade, slide)

## Phase 4: Voice Coaching System (Days 6-7)

### ElevenLabs Integration
- [ ] **VOICE-1**: Create `VoiceCoachService` class
- [ ] **VOICE-2**: Implement text-to-speech:
  - [ ] Connect to ElevenLabs API
  - [ ] Handle streaming responses
  - [ ] Cache common phrases locally
- [ ] **VOICE-3**: Test voice synthesis with different emotion profiles
- [ ] **VOICE-4**: Implement fallback to Web Speech API
- [ ] **VOICE-5**: Measure and optimize latency (< 500ms)

### Speech Recognition
- [ ] **VOICE-6**: Implement speech-to-text using Web Speech API
- [ ] **VOICE-7**: Create intent classification system:
  - [ ] Define command patterns (regex + keywords)
  - [ ] Map intents: PAUSE, SKIP, REPORT_PAIN, MODIFY
  - [ ] Extract entities (body parts, symptoms)
- [ ] **VOICE-8**: Build voice command UI:
  - [ ] Microphone button
  - [ ] Live transcription display
  - [ ] Visual feedback (listening indicator)
- [ ] **VOICE-9**: Implement interruption handling (pause/resume)
- [ ] **VOICE-10**: Test hands-free voice interaction flow

### Voice Command Processing
- [ ] **VOICE-11**: Create Lambda: `process-voice-command`
- [ ] **VOICE-12**: Connect voice intents to state updates
- [ ] **VOICE-13**: Generate contextual responses based on state
- [ ] **VOICE-14**: Test end-to-end: voice → state → response

## Phase 5: Routine Generator (Days 7-9)

### Exercise Knowledge Base
- [ ] **ROUTINE-1**: Design exercise data schema:
  - [ ] Exercise ID, name, description
  - [ ] Primary/secondary muscles
  - [ ] Equipment required
  - [ ] Difficulty level
  - [ ] Form instructions
  - [ ] Video URL (S3)
- [ ] **ROUTINE-2**: Seed exercise database:
  - [ ] 50+ bodyweight exercises
  - [ ] 30+ equipment-based exercises
  - [ ] 20+ mobility/stretching exercises
  - [ ] 10+ desk-friendly micro-exercises
- [ ] **ROUTINE-3**: Upload exercise videos to S3
- [ ] **ROUTINE-4**: Generate embeddings for semantic search (optional)

### Generation Logic
- [ ] **ROUTINE-5**: Create `RoutineGenerator` class
- [ ] **ROUTINE-6**: Implement exercise scoring algorithm:
  - [ ] Goal alignment scoring
  - [ ] Energy level matching
  - [ ] Equipment requirement checking
  - [ ] Safety scoring (pain point avoidance)
- [ ] **ROUTINE-7**: Implement constraint satisfaction solver:
  - [ ] Time-based workout building
  - [ ] Muscle group balancing
  - [ ] Progressive overload logic
- [ ] **ROUTINE-8**: Create Lambda: `generate-routine`
- [ ] **ROUTINE-9**: Test routine generation with various constraints
- [ ] **ROUTINE-10**: Optimize generation speed (< 2s)

### Frontend: Routine Display
- [ ] **ROUTINE-11**: Build workout display UI:
  - [ ] Exercise cards (name, video thumbnail, reps/sets)
  - [ ] Rest timer
  - [ ] Progress indicator
- [ ] **ROUTINE-12**: Implement workout player:
  - [ ] Play/pause controls
  - [ ] Next/previous exercise
  - [ ] Real-time voice coaching
- [ ] **ROUTINE-13**: Add manual exercise swap feature

## Phase 6: Biomechanical Validator (Days 9-10)

### Amazon Bedrock Setup
- [ ] **VAL-1**: Enable Amazon Bedrock in AWS account
- [ ] **VAL-2**: Request access to Claude 3 model
- [ ] **VAL-3**: Create knowledge base in Bedrock:
  - [ ] Upload exercise biomechanics documents
  - [ ] Configure vector embeddings
  - [ ] Set up retrieval parameters
- [ ] **VAL-4**: Test RAG retrieval with sample queries

### Validation Logic
- [ ] **VAL-5**: Create `BiomechanicalValidator` class
- [ ] **VAL-6**: Implement contraindication checking:
  - [ ] Map pain points to unsafe exercises
  - [ ] Rule-based safety filters
- [ ] **VAL-7**: Implement LLM-based validation:
  - [ ] Prompt engineering for safety analysis
  - [ ] Parse LLM responses for risk assessment
- [ ] **VAL-8**: Create Lambda: `validate-routine`
- [ ] **VAL-9**: Implement alternative exercise finder:
  - [ ] Semantic similarity search
  - [ ] Difficulty-adjusted swaps
- [ ] **VAL-10**: Test validation accuracy (manual review of 100 cases)
- [ ] **VAL-11**: Add validation results to UI (safety badges)

## Phase 7: Agentic Orchestration (Days 10-11)

### Dreamflow Integration
- [ ] **AGENT-1**: Set up Dreamflow Orchestrator project
- [ ] **AGENT-2**: Define agent state machine:
  - [ ] States: Idle, Listening, Generating, Coaching, Recovering
  - [ ] Transitions: Pain detected → Recovering
  - [ ] Actions: Morph UI, regenerate routine, adjust voice
- [ ] **AGENT-3**: Implement reasoning loop:
  - [ ] Read physical state from DynamoDB
  - [ ] Evaluate state changes
  - [ ] Emit UI/routine/voice actions
- [ ] **AGENT-4**: Connect Dreamflow to AWS services:
  - [ ] EventBridge for state change events
  - [ ] Lambda invocations for routine generation
  - [ ] DynamoDB queries for history
- [ ] **AGENT-5**: Test agent decision-making with mock scenarios

### Integration Testing
- [ ] **AGENT-6**: End-to-end test: Pain report flow
  - [ ] User says "My knee hurts"
  - [ ] State updated in DynamoDB
  - [ ] Agent triggers UI morph to Zen Mode
  - [ ] Routine regenerated without knee stress
  - [ ] Voice coach responds empathetically
- [ ] **AGENT-7**: End-to-end test: Energy drop flow
- [ ] **AGENT-8**: End-to-end test: Equipment change flow

## Phase 8: Multi-Surface Sync (Days 11-12)

### Amplify DataStore
- [ ] **SYNC-1**: Configure Amplify DataStore in frontend
- [ ] **SYNC-2**: Define sync models:
  - [ ] `WorkoutSession` (real-time updates)
  - [ ] `PhysicalState` (cross-device sync)
- [ ] **SYNC-3**: Implement conflict resolution strategy:
  - [ ] Last-write-wins for state updates
  - [ ] Merge for workout progress
- [ ] **SYNC-4**: Add offline persistence with IndexedDB
- [ ] **SYNC-5**: Test sync across devices:
  - [ ] Desktop browser → Mobile browser
  - [ ] Offline changes → Online sync

### Context Switching Logic
- [ ] **SYNC-6**: Implement location detection:
  - [ ] Manual selection (Desk, Gym, Home)
  - [ ] Automatic hints (screen size, time of day)
- [ ] **SYNC-7**: Create desk monitoring feature:
  - [ ] Idle timer (alert after 60 min sedentary)
  - [ ] Micro-flow suggestions (2-min stretches)
- [ ] **SYNC-8**: Implement gym handoff:
  - [ ] Transfer context from desk to gym mode
  - [ ] Preserve state + suggest full workout
- [ ] **SYNC-9**: Test complete journey: Desk reminder → Gym workout

## Phase 9: Polish & Demo Prep (Days 13-14)

### UI/UX Refinement
- [ ] **POLISH-1**: Design and implement app logo
- [ ] **POLISH-2**: Create onboarding flow:
  - [ ] Welcome screen
  - [ ] Quick tutorial (voice commands, state updates)
  - [ ] Initial state setup (goals, equipment)
- [ ] **POLISH-3**: Add loading states and skeletons
- [ ] **POLISH-4**: Implement error handling UI:
  - [ ] Network errors
  - [ ] Voice recognition failures
  - [ ] Validation failures
- [ ] **POLISH-5**: Accessibility audit:
  - [ ] Screen reader support
  - [ ] Keyboard navigation
  - [ ] WCAG AA compliance
- [ ] **POLISH-6**: Performance optimization:
  - [ ] Lazy load exercise videos
  - [ ] Compress images
  - [ ] Minimize bundle size

### Demo Preparation
- [ ] **DEMO-1**: Create QR code for PWA installation
- [ ] **DEMO-2**: Prepare demo script:
  - [ ] Scenario 1: Voice pain report → UI morph
  - [ ] Scenario 2: Desk to gym handoff
  - [ ] Scenario 3: Equipment change → routine swap
- [ ] **DEMO-3**: Record demo video (backup for live demo)
- [ ] **DEMO-4**: Test on multiple devices (iOS, Android, desktop)
- [ ] **DEMO-5**: Prepare pitch deck:
  - [ ] Problem statement
  - [ ] Soma-Logic framework explanation
  - [ ] Live demo
  - [ ] Technical architecture
  - [ ] Buildathon alignment (agency vs advice)

### Documentation
- [ ] **DOC-1**: Write README.md:
  - [ ] Project description
  - [ ] Installation instructions
  - [ ] Architecture overview
  - [ ] Demo links
- [ ] **DOC-2**: Create API documentation (OpenAPI spec)
- [ ] **DOC-3**: Document deployment process
- [ ] **DOC-4**: Add troubleshooting guide

## Phase 10: Testing & Validation (Ongoing)

### Automated Testing
- [ ] **TEST-1**: Set up Jest for unit tests
- [ ] **TEST-2**: Write tests for state manager (80% coverage)
- [ ] **TEST-3**: Write tests for routine generator (90% coverage)
- [ ] **TEST-4**: Write tests for voice intent classification (85% coverage)
- [ ] **TEST-5**: Set up Cypress for E2E tests
- [ ] **TEST-6**: Create E2E test suite (critical paths)
- [ ] **TEST-7**: Set up CI pipeline to run tests on PR

### Performance Testing
- [ ] **PERF-1**: Measure UI transition times (target: < 200ms)
- [ ] **PERF-2**: Measure voice processing latency (target: < 500ms)
- [ ] **PERF-3**: Load test routine generation (100 concurrent users)
- [ ] **PERF-4**: Measure PWA load time (target: < 3s on 3G)
- [ ] **PERF-5**: Optimize bottlenecks

### Security Testing
- [ ] **SEC-1**: Run dependency vulnerability scan (`npm audit`)
- [ ] **SEC-2**: Test authentication flows (XSS, CSRF protection)
- [ ] **SEC-3**: Verify HTTPS enforcement
- [ ] **SEC-4**: Test rate limiting on APIs
- [ ] **SEC-5**: Review IAM policies (least privilege)

## Pre-Launch Checklist

- [ ] **LAUNCH-1**: All critical tests passing
- [ ] **LAUNCH-2**: Performance metrics meet targets
- [ ] **LAUNCH-3**: Security scan clean
- [ ] **LAUNCH-4**: Demo rehearsed (3+ practice runs)
- [ ] **LAUNCH-5**: Backup demo video prepared
- [ ] **LAUNCH-6**: QR code tested on multiple devices
- [ ] **LAUNCH-7**: Monitoring dashboards configured
- [ ] **LAUNCH-8**: Error alerting set up
- [ ] **LAUNCH-9**: Pitch deck finalized
- [ ] **LAUNCH-10**: Team ready for Q&A

## Post-Buildathon (Optional Enhancements)

- [ ] **FUTURE-1**: Add workout analytics dashboard
- [ ] **FUTURE-2**: Integrate wearable devices (Fitbit, Apple Watch)
- [ ] **FUTURE-3**: Social features (share workouts, challenges)
- [ ] **FUTURE-4**: Physical therapy provider network
- [ ] **FUTURE-5**: Nutrition tracking and meal suggestions
- [ ] **FUTURE-6**: Multi-language support
- [ ] **FUTURE-7**: Advanced AI coach (personalized form correction)

---

## Task Status Legend

- `[ ]` Not Started
- `[~]` In Progress
- `[x]` Completed
- `[!]` Blocked (add blocker note)

## Notes

- Tasks are ordered roughly by dependency
- Some tasks can be parallelized (e.g., UI work + backend work)
- Adjust timeline based on actual progress
- Re-prioritize if buildathon deadline shifts

---

**Total Estimated Tasks:** 180+  
**Estimated Timeline:** 14 days (aggressive, hackathon pace)  
**Critical Path:** ENV → INF → PSM → VOICE → ROUTINE → AGENT → DEMO
