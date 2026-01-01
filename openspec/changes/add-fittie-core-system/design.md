# Technical Design: Fittie Core System

**Change ID:** `add-fittie-core-system`  
**Last Updated:** 2026-01-01

## Architecture Overview

### System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         User Layer                          │
│  PWA Interface (Mobile/Desktop) + Voice Input (ElevenLabs) │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────────┐  ┌──────────────────────────────────┐ │
│  │ Agentic UI Engine│  │  Voice Coaching System           │ │
│  │ (Dreamflow)      │  │  (ElevenLabs Integration)        │ │
│  └──────────────────┘  └──────────────────────────────────┘ │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  Orchestration Layer                         │
│              Dreamflow Orchestrator                          │
│           (Agent Reasoning & State Machine)                  │
└────┬─────────────────┬─────────────────┬───────────────────┘
     │                 │                 │
┌────▼────┐    ┌───────▼──────┐    ┌────▼──────────────────┐
│Physical │    │   Routine    │    │  Biomechanical        │
│State    │    │  Generator   │    │  Validator (RAG)      │
│Manager  │    │              │    │  (Amazon Bedrock)     │
└────┬────┘    └───────┬──────┘    └────┬──────────────────┘
     │                 │                 │
┌────▼─────────────────▼─────────────────▼───────────────────┐
│                    Data Layer (AWS)                         │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │  DynamoDB    │  │  S3 Storage  │  │  Bedrock KB     │  │
│  │  (State Log) │  │  (Media)     │  │  (Exercises)    │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Component Design

### 1. Agentic UI Engine

**Technology:** Dreamflow + Flutter  
**Responsibility:** Dynamic interface morphing based on agent state decisions

#### State Modes

```typescript
enum UIMode {
  POWER = 'power',      // High-intensity: data-heavy, metrics-focused
  ZEN = 'zen',          // Recovery: minimal, calming, therapeutic
  DESK = 'desk',        // Sedentary: compact, non-intrusive reminders
  GYM = 'gym'           // Active: large touch targets, progress-focused
}

interface UIState {
  mode: UIMode;
  theme: ThemeConfig;
  layout: LayoutConfig;
  animations: AnimationConfig;
}
```

#### Transition Logic

```typescript
class AgenticUIEngine {
  async transitionTo(newMode: UIMode, transitionDuration = 200): Promise<void> {
    // 1. Pre-load new theme assets
    await this.preloadAssets(newMode);
    
    // 2. Trigger Dreamflow state update
    await this.dreamflow.setState({ uiMode: newMode });
    
    // 3. Animate transition (< 200ms requirement)
    await this.animateTransition(this.currentMode, newMode, transitionDuration);
    
    // 4. Update local state
    this.currentMode = newMode;
  }
}
```

#### Performance Requirements
- Transition latency: < 200ms
- Asset preloading: background prefetch on state hint
- Memory footprint: < 50MB per mode

---

### 2. Voice Coaching System

**Technology:** ElevenLabs API + Web Speech API (fallback)  
**Responsibility:** Real-time voice synthesis and active listening

#### Architecture

```typescript
interface VoiceCoach {
  // Output: Text-to-speech
  speak(message: string, emotion: EmotionProfile): Promise<void>;
  
  // Input: Speech-to-text + NLU
  listen(): AsyncIterator<VoiceCommand>;
  
  // Interruption handling
  interrupt(): void;
  resume(): void;
}

enum EmotionProfile {
  ENCOURAGING = 'encouraging',
  CALM = 'calm',
  URGENT = 'urgent',
  CELEBRATORY = 'celebratory'
}

interface VoiceCommand {
  transcript: string;
  intent: CommandIntent;
  entities: Record<string, any>;
  confidence: number;
}
```

#### Intent Classification

```typescript
enum CommandIntent {
  PAUSE_WORKOUT = 'pause_workout',
  SKIP_EXERCISE = 'skip_exercise',
  REPORT_PAIN = 'report_pain',
  REQUEST_MODIFICATION = 'request_modification',
  QUERY_STATUS = 'query_status'
}

// Example: "My knee is clicking" 
// → REPORT_PAIN { bodyPart: 'knee', symptom: 'clicking' }
```

#### Latency Optimization Strategy

1. **Streaming Response**: Use ElevenLabs streaming API for faster TTFB
2. **Local Cache**: Pre-generate common phrases ("Good job!", "Take a break")
3. **Predictive Loading**: Anticipate next coaching phrases based on workout stage
4. **Fallback Chain**: ElevenLabs → Web Speech API → Text display

**Target:** < 500ms from command to audio playback

---

### 3. Routine Generator

**Technology:** Custom algorithm + Amazon Bedrock for validation  
**Responsibility:** Constraint-aware workout plan generation

#### Input Model

```typescript
interface WorkoutConstraints {
  // Physical limitations
  physicalState: {
    painPoints: BodyPart[];
    energyLevel: 1 | 2 | 3 | 4 | 5;
    recoveryNeeds: string[];
  };
  
  // Environmental constraints
  equipment: EquipmentType[];
  location: 'home' | 'gym' | 'outdoor' | 'office';
  timeAvailable: number; // minutes
  
  // User preferences
  goals: FitnessGoal[];
  experienceLevel: 'beginner' | 'intermediate' | 'advanced';
}

enum BodyPart {
  LOWER_BACK = 'lower_back',
  KNEES = 'knees',
  SHOULDERS = 'shoulders',
  // ... full anatomy map
}

enum EquipmentType {
  BODYWEIGHT = 'bodyweight',
  CHAIR = 'chair',
  RESISTANCE_BANDS = 'resistance_bands',
  DUMBBELLS = 'dumbbells',
  // ... full equipment catalog
}
```

#### Generation Algorithm

```typescript
class RoutineGenerator {
  async generate(constraints: WorkoutConstraints): Promise<Workout> {
    // Phase 1: Retrieve candidate exercises from knowledge base
    const candidates = await this.exerciseDB.query({
      equipment: constraints.equipment,
      excludedBodyParts: constraints.physicalState.painPoints
    });
    
    // Phase 2: Score exercises based on constraints
    const scored = candidates.map(ex => ({
      exercise: ex,
      score: this.scoreExercise(ex, constraints)
    }));
    
    // Phase 3: Build workout using constraint satisfaction
    const routine = this.buildRoutine(scored, constraints.timeAvailable);
    
    // Phase 4: Validate with biomechanical validator
    const validated = await this.validator.check(routine, constraints);
    
    return validated;
  }
  
  private scoreExercise(exercise: Exercise, constraints: WorkoutConstraints): number {
    let score = 0;
    
    // Alignment with goals
    score += this.goalAlignment(exercise, constraints.goals) * 10;
    
    // Energy level match
    score += this.energyMatch(exercise, constraints.physicalState.energyLevel) * 8;
    
    // Equipment availability
    score += exercise.equipment.every(eq => 
      constraints.equipment.includes(eq)) ? 5 : -100;
    
    // Safety for pain points (critical)
    score += exercise.stressedBodyParts.some(bp => 
      constraints.physicalState.painPoints.includes(bp)) ? -1000 : 10;
    
    return score;
  }
}
```

**Performance Target:** < 2s for complete routine generation

---

### 4. Physical State Manager

**Technology:** DynamoDB + AWS Lambda  
**Responsibility:** Persistent storage and event-driven state updates

#### Data Model

```typescript
// DynamoDB Table: user-physical-state
interface PhysicalStateRecord {
  userId: string;           // Partition key
  timestamp: number;        // Sort key
  
  // State snapshot
  painPoints: BodyPart[];
  energyLevel: number;
  equipment: EquipmentType[];
  location: string;
  
  // Context
  activityMode: 'sedentary' | 'active';
  lastWorkoutId?: string;
  
  // Metadata
  sourceEvent: 'voice' | 'manual' | 'inferred';
  confidence: number;
}

// DynamoDB Table: workout-history
interface WorkoutHistory {
  userId: string;           // Partition key
  workoutId: string;        // Sort key
  
  timestamp: number;
  routine: Workout;
  completedExercises: string[];
  performanceMetrics: {
    duration: number;
    caloriesBurned: number;
    difficultyRating: number;
  };
  
  stateChanges: PhysicalStateChange[];
}
```

#### Event-Driven Updates

```typescript
// Lambda trigger on state change
export async function onPhysicalStateChange(
  event: DynamoDBStreamEvent
): Promise<void> {
  for (const record of event.Records) {
    if (record.eventName !== 'INSERT' && record.eventName !== 'MODIFY') {
      continue;
    }
    
    const newState = unmarshall(record.dynamodb.NewImage);
    
    // Check if state change requires UI morphing
    if (await shouldTriggerUIMorph(newState)) {
      await triggerUITransition(newState.userId, newState);
    }
    
    // Check if routine needs regeneration
    if (await shouldRegenerateRoutine(newState)) {
      await queueRoutineRegeneration(newState.userId, newState);
    }
  }
}
```

---

### 5. Biomechanical Validator (RAG System)

**Technology:** Amazon Bedrock (Claude 3 / Titan) + Vector DB  
**Responsibility:** Ensure exercise safety through knowledge retrieval

#### Knowledge Base Structure

```typescript
interface ExerciseKnowledge {
  exerciseId: string;
  name: string;
  
  // Biomechanics
  primaryMuscles: MuscleGroup[];
  secondaryMuscles: MuscleGroup[];
  jointInvolvement: Joint[];
  
  // Safety constraints
  contraindications: Condition[];
  commonMistakes: string[];
  injuryRisks: InjuryRisk[];
  
  // Modifications
  modifications: ExerciseVariation[];
  progressions: ExerciseVariation[];
  regressions: ExerciseVariation[];
  
  // Embeddings for semantic search
  embedding: number[]; // 1536-dim vector
}

interface InjuryRisk {
  bodyPart: BodyPart;
  riskLevel: 'low' | 'medium' | 'high';
  conditions: string[];
  preventionCues: string[];
}
```

#### Validation Flow

```typescript
class BiomechanicalValidator {
  async validateRoutine(
    routine: Workout,
    userConstraints: WorkoutConstraints
  ): Promise<ValidationResult> {
    const results: ExerciseValidation[] = [];
    
    for (const exercise of routine.exercises) {
      // 1. Retrieve exercise knowledge
      const knowledge = await this.knowledgeBase.retrieve(exercise.id);
      
      // 2. Check contraindications
      const contraCheck = this.checkContraindications(
        knowledge,
        userConstraints.physicalState.painPoints
      );
      
      // 3. LLM-based safety analysis
      const llmAnalysis = await this.bedrock.analyze({
        exercise: knowledge,
        userState: userConstraints.physicalState,
        prompt: `Analyze if this exercise is safe given user constraints.
                 Consider: pain points, energy level, form requirements.`
      });
      
      // 4. Suggest modifications if needed
      let finalExercise = exercise;
      if (!contraCheck.safe || !llmAnalysis.safe) {
        finalExercise = await this.findSafeAlternative(exercise, userConstraints);
      }
      
      results.push({
        original: exercise,
        validated: finalExercise,
        safe: contraCheck.safe && llmAnalysis.safe,
        reasoning: llmAnalysis.reasoning
      });
    }
    
    return { exercises: results, overallSafe: results.every(r => r.safe) };
  }
}
```

---

### 6. Multi-Surface Sync

**Technology:** AWS Amplify DataStore + Service Worker  
**Responsibility:** Seamless context switching between devices/modes

#### Sync Architecture

```typescript
interface SyncState {
  userId: string;
  deviceId: string;
  
  // Current context
  surface: 'desktop' | 'mobile';
  activityMode: 'sedentary' | 'active';
  
  // Continuity data
  currentWorkout?: Workout;
  workoutProgress?: WorkoutProgress;
  physicalState: PhysicalStateRecord;
  
  // Sync metadata
  lastSyncTimestamp: number;
  pendingUpdates: SyncUpdate[];
}

// Amplify DataStore model
@model
class WorkoutSession {
  @key(fields: ['userId', 'sessionId'])
  userId: string;
  sessionId: string;
  
  startTime: number;
  surface: string;
  
  // Real-time sync
  @hasMany
  stateUpdates: PhysicalStateRecord[];
  
  // Conflict resolution
  version: number;
  lastModifiedBy: string;
}
```

#### Sync Flow Example: Desk → Gym

```typescript
// 1. User at desk (laptop), receives stretch reminder
// Desktop PWA detects sedentary state
await physicalStateManager.update({
  activityMode: 'sedentary',
  location: 'office',
  energyLevel: 3
});

// 2. User switches to phone, opens PWA at gym
// Mobile PWA syncs latest state via Amplify DataStore
const latestState = await amplify.sync();

// 3. Agent detects context change (office → gym)
if (latestState.location === 'office' && currentLocation === 'gym') {
  // Morph UI from DESK mode to GYM mode
  await uiEngine.transitionTo(UIMode.GYM);
  
  // Generate new routine for gym equipment
  const gymRoutine = await routineGenerator.generate({
    ...latestState,
    equipment: ['dumbbells', 'barbell', 'bench'],
    timeAvailable: 45
  });
}
```

---

## Data Flow: Complete User Journey

### Scenario: User Reports Pain During Workout

```
1. User (voice): "My lower back hurts"
   ↓
2. Voice System:
   - Transcribes via ElevenLabs
   - Classifies intent: REPORT_PAIN { bodyPart: 'lower_back' }
   ↓
3. Physical State Manager:
   - Updates DynamoDB: painPoints.push('lower_back')
   - Triggers Lambda: onPhysicalStateChange
   ↓
4. Dreamflow Orchestrator:
   - Receives state change event
   - Reasons: "User in pain → switch to recovery mode"
   - Emits actions: [MORPH_UI(ZEN), REGENERATE_ROUTINE(recovery)]
   ↓
5a. Agentic UI Engine:
   - Transitions UI to ZEN mode (< 200ms)
   - Displays calming colors, therapeutic animations
   ↓
5b. Routine Generator:
   - Generates new routine:
     * Excludes lower back stress
     * Focuses on gentle mobility
     * Includes stretching exercises
   ↓
6. Biomechanical Validator:
   - Validates each exercise against lower_back pain
   - Suggests modifications: "Replace deadlifts with glute bridges"
   ↓
7. Voice System:
   - Speaks (calming tone): "I've noticed your lower back pain.
     Let's switch to a recovery routine focused on gentle mobility."
   ↓
8. User continues with adapted workout
```

---

## Security & Privacy

### Data Protection

```typescript
// DynamoDB encryption at rest (AWS managed keys)
const stateTable = new Table(this, 'PhysicalState', {
  encryption: TableEncryption.AWS_MANAGED,
  pointInTimeRecovery: true
});

// Cognito for authentication
const userPool = new UserPool(this, 'FittieUsers', {
  passwordPolicy: {
    minLength: 8,
    requireUppercase: true,
    requireDigits: true
  },
  mfa: Mfa.OPTIONAL,
  accountRecovery: AccountRecovery.EMAIL_ONLY
});

// HIPAA considerations (future)
// - Sign BAA with AWS
// - Enable CloudTrail logging
// - Implement audit logs for all health data access
```

### API Security

```typescript
// Lambda authorizer for API Gateway
export async function authorizeRequest(
  event: APIGatewayTokenAuthorizerEvent
): Promise<AuthorizerResponse> {
  const token = event.authorizationToken;
  
  try {
    const claims = await verifyJWT(token);
    return {
      principalId: claims.sub,
      policyDocument: {
        Statement: [{
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: event.methodArn
        }]
      },
      context: {
        userId: claims.sub,
        email: claims.email
      }
    };
  } catch (error) {
    throw new Error('Unauthorized');
  }
}
```

---

## Performance Optimization

### Caching Strategy

```typescript
// Service Worker caching for PWA
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) {
        // Cache hit: return immediately
        return cachedResponse;
      }
      
      return fetch(event.request).then((response) => {
        // Cache workout videos and UI assets
        if (event.request.url.includes('/media/') || 
            event.request.url.includes('/assets/')) {
          const cache = await caches.open('fittie-v1');
          cache.put(event.request, response.clone());
        }
        
        return response;
      });
    })
  );
});
```

### Lambda Cold Start Mitigation

```typescript
// Provisioned concurrency for critical functions
const routineGeneratorFn = new Function(this, 'RoutineGenerator', {
  runtime: Runtime.NODEJS_18_X,
  handler: 'index.handler',
  reservedConcurrentExecutions: 5,
  
  // Keep 2 instances warm
  currentVersionOptions: {
    provisionedConcurrentExecutions: 2
  }
});
```

---

## Testing Strategy

### Unit Tests
- State transition logic (all possible state combinations)
- Exercise scoring algorithm
- Voice command classification

### Integration Tests
- DynamoDB streams → Lambda triggers
- Bedrock RAG retrieval accuracy
- ElevenLabs API response times

### E2E Tests (Critical Paths)
1. Voice pain report → UI morph → routine swap
2. Desk reminder → gym handoff → workout start
3. Equipment change → routine regeneration
4. Offline mode → sync on reconnect

### Performance Tests
- UI transition latency (target: < 200ms)
- Voice processing latency (target: < 500ms)
- Routine generation under load
- DynamoDB query performance

---

## Deployment Architecture

### Infrastructure as Code (AWS CDK)

```typescript
export class FittieStack extends Stack {
  constructor(scope: Construct, id: string) {
    super(scope, id);
    
    // Authentication
    const userPool = new UserPool(this, 'Users');
    
    // Database
    const stateTable = new Table(this, 'PhysicalState', {
      partitionKey: { name: 'userId', type: AttributeType.STRING },
      sortKey: { name: 'timestamp', type: AttributeType.NUMBER },
      stream: StreamViewType.NEW_AND_OLD_IMAGES
    });
    
    // Functions
    const stateManager = new Function(this, 'StateManager', {
      runtime: Runtime.NODEJS_18_X,
      handler: 'state-manager.handler',
      environment: {
        STATE_TABLE: stateTable.tableName
      }
    });
    
    stateTable.grantReadWriteData(stateManager);
    
    // API Gateway
    const api = new RestApi(this, 'FittieAPI', {
      defaultCorsPreflightOptions: {
        allowOrigins: Cors.ALL_ORIGINS,
        allowMethods: Cors.ALL_METHODS
      }
    });
    
    const workouts = api.root.addResource('workouts');
    workouts.addMethod('POST', new LambdaIntegration(stateManager));
  }
}
```

### PWA Deployment
- Host on S3 + CloudFront
- Automatic HTTPS via ACM
- CI/CD via GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy Fittie PWA
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build PWA
        run: npm run build
      - name: Deploy to S3
        run: aws s3 sync ./dist s3://fittie-pwa
      - name: Invalidate CloudFront
        run: aws cloudfront create-invalidation --distribution-id ${{ secrets.CLOUDFRONT_ID }} --paths "/*"
```

---

## Monitoring & Observability

### CloudWatch Dashboards

```typescript
const dashboard = new Dashboard(this, 'FittieDashboard');

// Key metrics
dashboard.addWidgets(
  new GraphWidget({
    title: 'Voice Processing Latency',
    left: [voiceCoachFn.metricDuration()]
  }),
  new GraphWidget({
    title: 'UI Transition Times',
    left: [uiEngineMetric]
  }),
  new SingleValueWidget({
    title: 'Active Users',
    metrics: [new Metric({
      namespace: 'Fittie',
      metricName: 'ActiveSessions'
    })]
  })
);
```

### Alarms

```typescript
// Alert on high latency
voiceCoachFn.metricDuration().createAlarm(this, 'VoiceLatencyAlarm', {
  threshold: 500,
  evaluationPeriods: 2,
  alarmDescription: 'Voice processing exceeds 500ms'
});

// Alert on validator failures
new Alarm(this, 'SafetyFailures', {
  metric: new Metric({
    namespace: 'Fittie',
    metricName: 'BiomechanicalValidationFailures'
  }),
  threshold: 10,
  evaluationPeriods: 1,
  alarmDescription: 'Too many exercise validation failures'
});
```

---

## Cost Estimation (Monthly, Assuming Demo Usage)

| Service | Usage | Cost |
|---------|-------|------|
| AWS Lambda | 100K invocations/month | $0.20 |
| DynamoDB | 10GB storage, 100K reads/writes | $2.50 |
| Amazon Bedrock | 10K tokens/day (Claude 3) | $30.00 |
| S3 + CloudFront | 10GB storage, 100GB transfer | $5.00 |
| ElevenLabs | 10K characters/day (voice) | $22.00 |
| **Total** | | **~$60/month** |

*Note: Free tier covers most AWS costs during initial development*

---

## Open Technical Questions

1. **Dreamflow Capabilities**: Need to validate UI morphing performance in Dreamflow platform
2. **Exercise Database**: Source for biomechanical knowledge base (OpenFitness API? Custom curation?)
3. **Voice Privacy**: Should voice data be stored? Transcripts only? Neither?
4. **Offline Sync Conflicts**: Resolution strategy when user modifies workout on multiple devices offline
5. **Wearable Integration**: Future scope - how to integrate heart rate, movement tracking?

---

**Design Status:** Draft - Ready for Review  
**Next Step:** Prototype voice + UI integration to validate latency requirements
