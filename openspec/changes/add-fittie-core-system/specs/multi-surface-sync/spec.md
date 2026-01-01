# Multi-Surface Sync Specification

## ADDED Requirements

### Requirement: Cross-Device State Synchronization
The system SHALL synchronize user physical state, workout progress, and context across desktop and mobile devices in real-time using AWS Amplify DataStore.

**Priority:** P0

#### Scenario: State Sync from Desktop to Mobile
**Given** user updates physical state on desktop (adds equipment: dumbbells)  
**When** change is saved  
**Then** update pushed to AWS Amplify DataStore  
**And** user's mobile device receives update within 2 seconds  
**And** mobile app displays updated equipment list

---

### Requirement: Context Switching (Desk to Gym)
The system SHALL detect and adapt when users transition between sedentary (desk) and active (gym) contexts, morphing UI appropriately.

**Priority:** P0

#### Scenario: Desk to Gym Handoff
**Given** user has been at desk for 90 minutes on laptop (received stretch reminder)  
**When** user opens Fittie on phone at gym and sets location to "gym"  
**Then** system detects context change: desk → gym  
**And** UI morphs from Desk Mode to Gym Mode  
**And** voice coach says: "Ready for your workout? I see you've been at your desk for a while."  
**And** suggests mobility-focused warm-up

---

### Requirement: Sedentary State Monitoring
The system SHALL monitor sedentary periods on desktop and proactively suggest 2-5 minute movement breaks after 60 minutes of inactivity.

**Priority:** P1

#### Scenario: Desk Stretch Reminder
**Given** user working on laptop with no activity for 65 minutes  
**When** sedentary timer threshold reached  
**Then** Fittie displays notification: "Time for a quick stretch!"  
**And** suggests 3-minute routine: neck rolls, shoulder shrugs, wrist circles, standing stretch  
**And** user can snooze 15 minutes or start immediately

---

### Requirement: Offline Capability with Sync
The system SHALL function offline with local data persistence and sync queued changes when connectivity returns.

**Priority:** P0

#### Scenario: Offline Workout with Delayed Sync
**Given** user starts workout at gym  
**When** they lose internet connectivity mid-workout  
**Then** app continues functioning with cached data  
**And** displays "Offline" badge  
**And** workout progress recorded locally  
**When** connectivity restored  
**Then** all state changes synced to backend within 5 seconds

---

### Requirement: Conflict Resolution Strategy
The system SHALL resolve conflicts when same data is modified on multiple devices while offline using last-write-wins for state, merge for progress.

**Priority:** P1

#### Scenario: Concurrent State Updates on Two Devices
**Given** user modifies state on phone (adds pain: shoulder) while offline  
**And** simultaneously modifies on desktop (adds equipment: kettlebell) while offline  
**When** both devices regain connectivity  
**Then** system detects concurrent modifications  
**And** merges changes: final state has both shoulder pain AND kettlebell  
**And** conflict log records: "Merged offline updates from 2 devices"  
**And** user sees combined state on both devices
