/**
 * Constraint Engine - Maps pain points to movement exclusions
 */

import { PhysicalState, RoutineConstraints, WorkoutGoal } from './types';

// Map body parts to movements that should be avoided
const PAIN_TO_MOVEMENT_MAP: Record<string, string[]> = {
  lower_back: ['deadlift', 'good_morning', 'bent_over_row', 'heavy_squat'],
  upper_back: ['pull_up', 'lat_pulldown', 'rowing'],
  knees: ['deep_squat', 'lunge', 'jump', 'running', 'box_jump'],
  shoulders: ['overhead_press', 'lateral_raise', 'push_up', 'bench_press'],
  neck: ['shoulder_shrug', 'neck_extension', 'overhead_press'],
  hips: ['squat', 'lunge', 'hip_hinge', 'deadlift'],
  ankles: ['calf_raise', 'jump', 'running', 'squat'],
  wrists: ['push_up', 'plank', 'front_squat', 'clean'],
  elbows: ['tricep_extension', 'bicep_curl', 'push_up', 'pull_up'],
};

// Map body parts to contraindicated body parts for exercise selection
const PAIN_TO_CONTRAINDICATED: Record<string, string[]> = {
  lower_back: ['lower_back', 'spine', 'lumbar'],
  upper_back: ['upper_back', 'thoracic', 'lats'],
  knees: ['knees', 'quadriceps', 'patella'],
  shoulders: ['shoulders', 'deltoids', 'rotator_cuff'],
  neck: ['neck', 'cervical', 'trapezius'],
  hips: ['hips', 'hip_flexors', 'glutes'],
  ankles: ['ankles', 'calves', 'achilles'],
  wrists: ['wrists', 'forearms'],
  elbows: ['elbows', 'biceps', 'triceps'],
};

/**
 * Build constraints from physical state
 */
export function buildConstraints(
  state: PhysicalState | null,
  duration: number,
  goals: WorkoutGoal[]
): RoutineConstraints {
  const excludedBodyParts: string[] = [];
  
  if (state?.painPoints) {
    for (const painPoint of state.painPoints) {
      const contraindicated = PAIN_TO_CONTRAINDICATED[painPoint] || [];
      excludedBodyParts.push(...contraindicated);
    }
  }

  return {
    excludedBodyParts: [...new Set(excludedBodyParts)],
    availableEquipment: state?.equipment || ['none'],
    maxDuration: duration,
    energyLevel: state?.energyLevel || 3,
    goals,
  };
}

/**
 * Get movements to avoid based on pain points
 */
export function getExcludedMovements(painPoints: string[]): string[] {
  const excluded: string[] = [];
  
  for (const painPoint of painPoints) {
    const movements = PAIN_TO_MOVEMENT_MAP[painPoint] || [];
    excluded.push(...movements);
  }
  
  return [...new Set(excluded)];
}

/**
 * Get reason for avoided movements
 */
export function getAvoidedReason(painPoints: string[]): string | undefined {
  if (painPoints.length === 0) return undefined;
  
  const formatted = painPoints.map(p => p.replace(/_/g, ' ')).join(', ');
  return `User reported pain in: ${formatted}`;
}

/**
 * Adjust sets/reps based on energy level
 */
export function adjustForEnergy(
  baseSets: number,
  baseReps: number,
  energyLevel: number
): { sets: number; reps: number } {
  // Energy level 1-5, where 3 is baseline
  const multiplier = 0.6 + (energyLevel * 0.13); // 0.73 to 1.25
  
  return {
    sets: Math.max(1, Math.round(baseSets * multiplier)),
    reps: Math.max(4, Math.round(baseReps * multiplier)),
  };
}
