/**
 * Exercise Selector - Queries exercise knowledge base and filters by constraints
 */

import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, ScanCommand } from '@aws-sdk/lib-dynamodb';
import { Exercise, RoutineConstraints, WorkoutGoal } from './types';

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);
const EXERCISE_TABLE = process.env.EXERCISE_TABLE || 'exercise-knowledge-base';

// Map goals to exercise categories
const GOAL_TO_CATEGORY: Record<WorkoutGoal, string[]> = {
  strength: ['strength'],
  mobility: ['mobility', 'flexibility'],
  cardio: ['cardio'],
  flexibility: ['flexibility', 'mobility'],
  balance: ['balance', 'mobility'],
  endurance: ['cardio', 'strength'],
};

/**
 * Fetch all exercises from knowledge base
 */
export async function fetchExercises(): Promise<Exercise[]> {
  const result = await docClient.send(new ScanCommand({
    TableName: EXERCISE_TABLE,
  }));
  
  return (result.Items || []) as Exercise[];
}

/**
 * Filter exercises based on constraints
 */
export function filterExercises(
  exercises: Exercise[],
  constraints: RoutineConstraints
): Exercise[] {
  return exercises.filter(exercise => {
    // Check if exercise targets contraindicated body parts
    const hasContraindication = exercise.contraindicatedBodyParts?.some(
      part => constraints.excludedBodyParts.includes(part)
    );
    if (hasContraindication) return false;

    // Check equipment availability
    const needsEquipment = exercise.equipmentRequired?.length > 0;
    if (needsEquipment) {
      const hasRequiredEquipment = exercise.equipmentRequired.every(
        eq => constraints.availableEquipment.includes(eq) || eq === 'none'
      );
      if (!hasRequiredEquipment) return false;
    }

    // Check if exercise matches goals
    const matchingCategories = constraints.goals.flatMap(g => GOAL_TO_CATEGORY[g]);
    const matchesGoal = matchingCategories.includes(exercise.category);
    if (!matchesGoal) return false;

    // Adjust difficulty based on energy level
    if (constraints.energyLevel <= 2 && exercise.difficulty === 'advanced') {
      return false;
    }

    return true;
  });
}

/**
 * Select exercises for a balanced routine
 */
export function selectBalancedExercises(
  exercises: Exercise[],
  constraints: RoutineConstraints
): Exercise[] {
  const selected: Exercise[] = [];
  const usedPatterns = new Set<string>();
  const usedMuscles = new Set<string>();
  
  // Target exercise count based on duration (roughly 5 min per exercise)
  const targetCount = Math.min(Math.floor(constraints.maxDuration / 5), 8);
  
  // Sort by relevance to goals
  const sorted = [...exercises].sort((a, b) => {
    const aScore = getGoalScore(a, constraints.goals);
    const bScore = getGoalScore(b, constraints.goals);
    return bScore - aScore;
  });

  for (const exercise of sorted) {
    if (selected.length >= targetCount) break;

    // Prefer variety in movement patterns
    const hasNewPattern = exercise.movementPatterns?.some(p => !usedPatterns.has(p));
    const hasNewMuscle = exercise.targetMuscles?.some(m => !usedMuscles.has(m));
    
    // Prioritize exercises that add variety
    if (selected.length < 3 || hasNewPattern || hasNewMuscle) {
      selected.push(exercise);
      exercise.movementPatterns?.forEach(p => usedPatterns.add(p));
      exercise.targetMuscles?.forEach(m => usedMuscles.add(m));
    }
  }

  return selected;
}

/**
 * Calculate goal relevance score for an exercise
 */
function getGoalScore(exercise: Exercise, goals: WorkoutGoal[]): number {
  let score = 0;
  
  for (const goal of goals) {
    const categories = GOAL_TO_CATEGORY[goal];
    if (categories.includes(exercise.category)) {
      score += 2;
    }
  }
  
  return score;
}
