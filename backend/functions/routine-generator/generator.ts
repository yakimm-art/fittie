/**
 * Routine Generator - Assembles complete workout routines
 */

import { v4 as uuidv4 } from 'uuid';
import { 
  Exercise, 
  GeneratedRoutine, 
  RoutineExercise, 
  RoutineConstraints,
  PhysicalState 
} from './types';
import { adjustForEnergy, getExcludedMovements, getAvoidedReason } from './constraint-engine';
import { fetchExercises, filterExercises, selectBalancedExercises } from './exercise-selector';

/**
 * Generate a personalized workout routine
 */
export async function generateRoutine(
  state: PhysicalState | null,
  constraints: RoutineConstraints
): Promise<GeneratedRoutine> {
  // Fetch and filter exercises
  const allExercises = await fetchExercises();
  const filteredExercises = filterExercises(allExercises, constraints);
  const selectedExercises = selectBalancedExercises(filteredExercises, constraints);

  // Build routine exercises with adjustments
  const routineExercises = selectedExercises.map(exercise => 
    buildRoutineExercise(exercise, constraints, state)
  );

  // Calculate totals
  const estimatedDuration = calculateDuration(routineExercises);
  const targetMuscles = getTargetMuscles(selectedExercises);
  const avoidedMovements = state?.painPoints 
    ? getExcludedMovements(state.painPoints) 
    : [];

  return {
    routineId: `routine-${uuidv4().slice(0, 8)}`,
    exercises: routineExercises,
    estimatedDuration,
    targetMuscles,
    avoidedMovements,
    avoidedReason: state?.painPoints ? getAvoidedReason(state.painPoints) : undefined,
    generatedAt: Date.now(),
  };
}

/**
 * Build a routine exercise from base exercise
 */
function buildRoutineExercise(
  exercise: Exercise,
  constraints: RoutineConstraints,
  state: PhysicalState | null
): RoutineExercise {
  const { sets, reps } = adjustForEnergy(
    exercise.baseSets,
    exercise.baseReps,
    constraints.energyLevel
  );

  // Get applicable modifications
  const modifications = getApplicableModifications(exercise, state);

  return {
    exerciseId: exercise.exerciseId,
    name: exercise.name,
    sets,
    reps,
    restSeconds: exercise.restSeconds,
    modifications,
    safetyNotes: exercise.safetyNotes || [],
  };
}

/**
 * Get modifications applicable to current state
 */
function getApplicableModifications(
  exercise: Exercise,
  state: PhysicalState | null
): string[] {
  const modifications: string[] = [];

  if (!exercise.modifications) return modifications;

  for (const mod of exercise.modifications) {
    // Check energy-based modifications
    if (mod.condition === 'low_energy' && state && state.energyLevel <= 2) {
      modifications.push(mod.modification);
    }
    
    // Check pain-based modifications
    if (state?.painPoints?.some(p => mod.condition.includes(p))) {
      modifications.push(mod.modification);
    }
  }

  return modifications;
}

/**
 * Calculate total routine duration
 */
function calculateDuration(exercises: RoutineExercise[]): number {
  let totalSeconds = 0;

  for (const exercise of exercises) {
    // Estimate 3 seconds per rep
    const exerciseTime = exercise.sets * (exercise.reps * 3 + exercise.restSeconds);
    totalSeconds += exerciseTime;
  }

  // Add 2 minutes for warmup/cooldown
  return Math.round(totalSeconds / 60) + 2;
}

/**
 * Get unique target muscles from exercises
 */
function getTargetMuscles(exercises: Exercise[]): string[] {
  const muscles = new Set<string>();
  
  for (const exercise of exercises) {
    exercise.targetMuscles?.forEach(m => muscles.add(m));
  }
  
  return [...muscles];
}
