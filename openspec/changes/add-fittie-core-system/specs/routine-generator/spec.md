# Routine Generator Specification

## ADDED Requirements

### Requirement: Constraint-Aware Generation
The system SHALL generate personalized workout routines based on user physical state, equipment, time, and goals in < 2 seconds.

**Priority:** P0

#### Scenario: Lower Back Pain Avoidance
**Given** user has reported lower back pain  
**And** requests 30-minute workout with bodyweight equipment only  
**When** routine generator creates workout  
**Then** no exercises stress lower back (deadlifts, sit-ups excluded)  
**And** alternative core exercises included (planks, bird dogs)  
**And** routine is 28-32 minutes duration  
**And** generation completes within 2 seconds

---

### Requirement: Exercise Scoring Algorithm
The system SHALL score exercises based on alignment with constraints using weighted formula: goal (×10), energy (×8), equipment (×5), safety (critical).

**Priority:** P0

#### Scenario: High-Scoring Safe Exercise Selection
**Given** user wants strength training with energy level 4/5  
**And** has dumbbells available with no pain points  
**When** scoring algorithm evaluates "Dumbbell Goblet Squat"  
**Then** goal alignment score = +60 (strength)  
**And** energy match score = +32 (high energy exercise)  
**And** equipment score = +5 (dumbbells available)  
**And** safety score = +10 (no contraindications)  
**And** total score = 107 (high-ranking)

---

### Requirement: Routine Structure Builder
The system SHALL build structured workouts with proper phase distribution: warm-up (5-10%), main work (75-85%), cool-down (5-10%).

**Priority:** P0

#### Scenario: 30-Minute Balanced Workout
**Given** user requests 30-minute full-body workout  
**When** routine builder creates structure  
**Then** warm-up phase is 3 minutes (dynamic stretches)  
**And** main work is 24 minutes (6 exercises × 3 sets)  
**And** cool-down is 3 minutes (static stretches)  
**And** exercises target: legs (2), upper push (1), upper pull (1), core (2)

---

### Requirement: Dynamic Routine Regeneration
The system SHALL regenerate routines mid-workout when significant state changes occur, preserving workout context.

**Priority:** P0

#### Scenario: Mid-Workout Pain Triggers Regeneration
**Given** user is 15 minutes into 45-minute workout (completed 3 leg exercises)  
**When** user reports knee pain  
**Then** system evaluates remaining routine (3 leg exercises left)  
**And** regenerates last 30 minutes swapping knee-stressing for upper body work  
**And** voice coach announces: "I've adjusted your routine to protect your knee"
