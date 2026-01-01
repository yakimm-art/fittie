# Voice Coaching System Specification

## ADDED Requirements

### Requirement: Real-Time Voice Synthesis
The system SHALL convert text to natural-sounding speech with emotional context for real-time workout coaching using ElevenLabs API with< 500ms latency.

**Priority:** P0

#### Scenario: Encouraging Mid-Workout Coaching
**Given** the user is 30 seconds into a plank exercise  
**When** the voice coach generates encouragement: "You're doing great! 20 seconds left!"  
**Then** text is sent to ElevenLabs with "encouraging" emotion profile  
**And** audio playback begins within 500ms  
**And** voice tone is energetic and motivating

---

### Requirement: Active Voice Listening
The system SHALL continuously listen for and process voice commands during workouts with hands-free operation.

**Priority:** P0

#### Scenario: Mid-Workout Pain Report
**Given** user is performing squats with microphone enabled  
**When** user says "My knee is clicking"  
**Then** system transcribes speech in real-time  
**And** classifies intent as REPORT_PAIN with entity {bodyPart: 'knee', symptom: 'clicking'}  
**And** triggers state update within 200ms

---

### Requirement: Intent Classification
The system SHALL accurately classify user voice commands into actionable intents (PAUSE, SKIP, REPORT_PAIN, MODIFY, QUERY) with 85%+ accuracy.

**Priority:** P0

#### Scenario: Pause Command During High-Intensity Interval
**Given** user is in middle of burpee set  
**When** user says "Stop" or "Pause" or "Wait"  
**Then** system classifies intent as PAUSE_WORKOUT with confidence > 0.9  
**And** workout timer pauses immediately  
**And** voice coach responds: "Paused. Take your time."

---

### Requirement: Contextual Coaching Responses
The system SHALL generate coaching messages contextually appropriate based on workout state, user energy, and progress.

**Priority:** P1

#### Scenario: Contextual Form Cue During Planks
**Given** user is 45 seconds into 60-second plank with energy level 3/5  
**When** voice coach determines it's a critical moment  
**Then** it generates: "Keep your hips level and core engaged. You've got this!"  
**And** uses encouraging emotion profile  
**And** references specific exercise and time remaining

---

### Requirement: Voice Command Phrase Library
The system SHALL pre-cache 100+ common coaching phrases for instant playback with 60%+ cache hit rate.

**Priority:** P1

#### Scenario: Instant Encouragement from Cache
**Given** voice coach phrase library is loaded  
**When** coach needs to say "Good job!"  
**Then** system retrieves pre-cached audio file  
**And** playback starts within 50ms without API call  
**And** logs cache hit to metrics
