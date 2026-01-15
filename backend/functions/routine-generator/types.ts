/**
 * Types for Routine Generator Lambda (Soma-Logic Engine)
 */

export interface GenerateRoutineRequest {
  userId: string;
  duration: number; // minutes
  goals: WorkoutGoal[];
  useCurrentState: boolean;
}

export type WorkoutGoal = 'strength' | 'mobility' | 'cardio' | 'flexibility' | 'balance' | 'endurance';

export interface GeneratedRoutine {
  routineId: string;
  exercises: RoutineExercise[];
  estimatedDuration: number;
  targetMuscles: string[];
  avoidedMovements: string[];
  avoidedReason?: string;
  generatedAt: number;
}

export interface RoutineExercise {
  exerciseId: string;
  name: string;
  sets: number;
  reps: number;
  restSeconds: number;
  modifications: string[];
  safetyNotes: string[];
  duration?: number; // for timed exercises
}

export interface Exercise {
  exerciseId: string;
  name: string;
  category: ExerciseCategory;
  targetMuscles: string[];
  movementPatterns: MovementPattern[];
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  equipmentRequired: string[];
  contraindicatedBodyParts: string[]; // body parts that should avoid this exercise
  baseReps: number;
  baseSets: number;
  restSeconds: number;
  safetyNotes: string[];
  modifications: ExerciseModification[];
}

export type ExerciseCategory = 'strength' | 'mobility' | 'cardio' | 'flexibility' | 'balance';

export type MovementPattern = 
  | 'push' | 'pull' | 'squat' | 'hinge' | 'lunge' 
  | 'rotation' | 'carry' | 'plank' | 'stretch';

export interface ExerciseModification {
  condition: string; // e.g., "low_energy", "knee_pain"
  modification: string;
}

export interface PhysicalState {
  userId: string;
  timestamp: number;
  painPoints: string[];
  energyLevel: number;
  equipment: string[];
  location: string;
  activityMode: string;
}

export interface RoutineConstraints {
  excludedBodyParts: string[];
  availableEquipment: string[];
  maxDuration: number;
  energyLevel: number;
  goals: WorkoutGoal[];
}

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: {
    message: string;
    code: string;
  };
}
