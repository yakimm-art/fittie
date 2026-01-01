# Biomechanical Validator Specification

## ADDED Requirements

### Requirement: Exercise Safety Validation
The system SHALL validate all generated workout routines for biomechanical safety using RAG system and Amazon Bedrock (Claude 3) in < 3 seconds.

**Priority:** P0

#### Scenario: Knee Pain Contraindication Detection
**Given** user has reported knee pain  
**When** validator checks routine containing jump squats  
**Then** RAG retrieves biomechanics: "Jump squats involve high knee stress, eccentric landing forces"  
**And** LLM analyzes: "Jump squats contraindicated for knee pain"  
**And** validation result: {safe: false, reason: 'High impact on injured knee', riskLevel: 'high'}  
**And** alternative suggested: "Wall sits (isometric, low knee stress)"

---

### Requirement: Knowledge Base Retrieval
The system SHALL maintain and query 100+ exercises with detailed biomechanical data using semantic search via vector embeddings.

**Priority:** P0

#### Scenario: Semantic Exercise Similarity Search
**Given** validator needs alternatives for "barbell back squat"  
**When** knowledge base queried for similar exercises  
**Then** semantic search returns: goblet squat, leg press, split squat  
**And** results ranked by biomechanical similarity  
**And** retrieval completes in < 200ms

---

### Requirement: LLM-Powered Safety Analysis
The system SHALL use Amazon Bedrock (Claude 3) to perform contextual safety analysis with structured prompts.

**Priority:** P0

#### Scenario: LLM Contextual Safety Assessment
**Given** user has lower back pain and low energy (2/5)  
**When** validator analyzes "conventional deadlifts"  
**Then** Bedrock prompt: "User has lower back pain, energy 2/5. Is conventional deadlift safe?"  
**And** Claude responds: "Not safe. Deadlifts require perfect form and significant spinal loading..."  
**And** validator extracts: {safe: false, riskLevel: 'high', reasoning: 'Spinal loading risk', alternative: 'glute_bridges'}

---

### Requirement: Alternative Exercise Finder
The system SHALL suggest biomechanically similar but safer alternatives when exercises are deemed unsafe.

**Priority:** P0

#### Scenario: Finding Safe Alternative for Unsafe Exercise
**Given** "burpees" invalidated due to user knee pain  
**When** alternative finder searches replacements  
**Then** queries for: high-intensity, full-body, cardio excluding knee impact  
**And** returns: mountain climbers (modified), plank jacks, swimming motions  
**And** top result: "modified mountain climbers" with instructions

---

### Requirement: Rule-Based Contraindication Layer
The system SHALL implement explicit rule-based contraindication checks as fast first-pass filter before LLM analysis.

**Priority:** P1

#### Scenario: Rule-Based Fast Rejection
**Given** user reported shoulder pain  
**And** rule mapping: shoulder pain → avoid overhead pressing, pull-ups, dips  
**When** validator checks "overhead barbell press"  
**Then** rule-based layer immediately flags unsafe (< 10ms)  
**And** skips LLM analysis (cost saving)  
**And** returns: {safe: false, reason: 'Rule: overhead pressing contraindicated for shoulder pain'}
