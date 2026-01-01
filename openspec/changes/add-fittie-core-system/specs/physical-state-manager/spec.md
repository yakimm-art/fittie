# Physical State Manager Specification

## ADDED Requirements

### Requirement: State Persistence
The system SHALL persistently store user physical state changes in DynamoDB with complete history for 90+ days.

**Priority:** P0

#### Scenario: Recording Pain Point
**Given** user reports lower back pain via voice command  
**When** state update API is called  
**Then** new record is written to DynamoDB  
**And** record contains: userId, timestamp, painPoints: ['lower_back'], energyLevel, equipment, sourceEvent: 'voice'  
**And** DynamoDB Stream triggers downstream Lambda functions

---

### Requirement: Real-Time State Updates
The system SHALL provide APIs for updating and retrieving user physical state with < 200ms response time.

**Priority:** P0

#### Scenario: Retrieving Latest State
**Given** user has recorded multiple state changes today  
**When** frontend calls GET /state/latest  
**Then** API returns most recent state record within 100ms  
**And** includes all fields: pain points, energy, equipment, location  
**And** response format is JSON

---

### Requirement: Event-Driven State Changes
The system SHALL emit events when physical state changes occur to trigger agent actions within 500ms.

**Priority:** P0

#### Scenario: Pain Point Detection Triggers Agent
**Given** DynamoDB Streams is monitoring the state table  
**When** new record inserted with painPoints: ['knee'] (previously no knee pain)  
**Then** Lambda function detects significant change  
**And** publishes event to EventBridge: {type: 'PAIN_REPORTED', bodyPart: 'knee', severity: 'new'}  
**And** Dreamflow Orchestrator receives event within 500ms

---

### Requirement: State Validation
The system SHALL validate all state updates for data integrity (energy 1-5, known body parts, approved equipment).

**Priority:** P1

#### Scenario: Invalid Energy Level Rejected
**Given** API receives state update request  
**When** energyLevel field is set to 7 (invalid, max is 5)  
**Then** request rejected with HTTP 400  
**And** error message: "energyLevel must be between 1 and 5"  
**And** no record written to DynamoDB
