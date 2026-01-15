/**
 * Seed script for exercise-knowledge-base DynamoDB table
 * Run with: npx ts-node scripts/seed-exercises.ts
 */

import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });
const docClient = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.EXERCISE_TABLE || 'exercise-knowledge-base';

interface Exercise {
  exerciseId: string;
  name: string;
  category: string;
  targetMuscles: string[];
  movementPatterns: string[];
  difficulty: string;
  equipmentRequired: string[];
  contraindicatedBodyParts: string[];
  baseReps: number;
  baseSets: number;
  restSeconds: number;
  safetyNotes: string[];
  modifications: { condition: string; modification: string }[];
}

const exercises: Exercise[] = [
  // Strength exercises
  {
    exerciseId: 'ex-001',
    name: 'Goblet Squat',
    category: 'strength',
    targetMuscles: ['quadriceps', 'glutes', 'core'],
    movementPatterns: ['squat'],
    difficulty: 'beginner',
    equipmentRequired: ['dumbbells'],
    contraindicatedBodyParts: ['knees', 'hips'],
    baseReps: 12,
    baseSets: 3,
    restSeconds: 60,
    safetyNotes: ['Keep core engaged', 'Knees track over toes'],
    modifications: [
      { condition: 'low_energy', modification: 'Use lighter weight or bodyweight only' },
      { condition: 'knees', modification: 'Reduce depth of squat' },
    ],
  },
  {
    exerciseId: 'ex-002',
    name: 'Push-up',
    category: 'strength',
    targetMuscles: ['chest', 'triceps', 'shoulders', 'core'],
    movementPatterns: ['push'],
    difficulty: 'beginner',
    equipmentRequired: [],
    contraindicatedBodyParts: ['wrists', 'shoulders'],
    baseReps: 10,
    baseSets: 3,
    restSeconds: 45,
    safetyNotes: ['Maintain straight body line', 'Elbows at 45 degrees'],
    modifications: [
      { condition: 'low_energy', modification: 'Perform on knees' },
      { condition: 'wrists', modification: 'Use push-up handles or fists' },
    ],
  },
  {
    exerciseId: 'ex-003',
    name: 'Dumbbell Row',
    category: 'strength',
    targetMuscles: ['lats', 'rhomboids', 'biceps'],
    movementPatterns: ['pull'],
    difficulty: 'beginner',
    equipmentRequired: ['dumbbells'],
    contraindicatedBodyParts: ['lower_back', 'shoulders'],
    baseReps: 10,
    baseSets: 3,
    restSeconds: 60,
    safetyNotes: ['Keep back flat', 'Pull elbow to hip'],
    modifications: [
      { condition: 'lower_back', modification: 'Support chest on incline bench' },
    ],
  },
  {
    exerciseId: 'ex-004',
    name: 'Dumbbell Shoulder Press',
    category: 'strength',
    targetMuscles: ['shoulders', 'triceps'],
    movementPatterns: ['push'],
    difficulty: 'intermediate',
    equipmentRequired: ['dumbbells'],
    contraindicatedBodyParts: ['shoulders', 'neck'],
    baseReps: 10,
    baseSets: 3,
    restSeconds: 60,
    safetyNotes: ['Keep core tight', 'Dont arch back'],
    modifications: [
      { condition: 'shoulders', modification: 'Use lighter weight with neutral grip' },
    ],
  },
  {
    exerciseId: 'ex-005',
    name: 'Romanian Deadlift',
    category: 'strength',
    targetMuscles: ['hamstrings', 'glutes', 'lower_back'],
    movementPatterns: ['hinge'],
    difficulty: 'intermediate',
    equipmentRequired: ['dumbbells'],
    contraindicatedBodyParts: ['lower_back', 'hamstrings'],
    baseReps: 10,
    baseSets: 3,
    restSeconds: 90,
    safetyNotes: ['Keep back neutral', 'Slight knee bend'],
    modifications: [
      { condition: 'lower_back', modification: 'Reduce range of motion' },
    ],
  },
  {
    exerciseId: 'ex-006',
    name: 'Plank',
    category: 'strength',
    targetMuscles: ['core', 'shoulders'],
    movementPatterns: ['plank'],
    difficulty: 'beginner',
    equipmentRequired: [],
    contraindicatedBodyParts: ['wrists', 'shoulders', 'lower_back'],
    baseReps: 30, // seconds
    baseSets: 3,
    restSeconds: 30,
    safetyNotes: ['Keep body in straight line', 'Dont let hips sag'],
    modifications: [
      { condition: 'wrists', modification: 'Perform on forearms' },
      { condition: 'lower_back', modification: 'Elevate hands on bench' },
    ],
  },
  // Mobility exercises
  {
    exerciseId: 'ex-007',
    name: 'Cat-Cow Stretch',
    category: 'mobility',
    targetMuscles: ['spine', 'core'],
    movementPatterns: ['stretch'],
    difficulty: 'beginner',
    equipmentRequired: ['yoga_mat'],
    contraindicatedBodyParts: [],
    baseReps: 10,
    baseSets: 2,
    restSeconds: 30,
    safetyNotes: ['Move slowly and controlled', 'Breathe with movement'],
    modifications: [],
  },
  {
    exerciseId: 'ex-008',
    name: 'Hip Flexor Stretch',
    category: 'mobility',
    targetMuscles: ['hip_flexors', 'quadriceps'],
    movementPatterns: ['stretch'],
    difficulty: 'beginner',
    equipmentRequired: ['yoga_mat'],
    contraindicatedBodyParts: ['knees'],
    baseReps: 30, // seconds per side
    baseSets: 2,
    restSeconds: 15,
    safetyNotes: ['Keep torso upright', 'Squeeze glute of back leg'],
    modifications: [
      { condition: 'knees', modification: 'Place cushion under knee' },
    ],
  },
  {
    exerciseId: 'ex-009',
    name: 'Thoracic Rotation',
    category: 'mobility',
    targetMuscles: ['thoracic_spine', 'obliques'],
    movementPatterns: ['rotation'],
    difficulty: 'beginner',
    equipmentRequired: ['yoga_mat'],
    contraindicatedBodyParts: ['lower_back'],
    baseReps: 10,
    baseSets: 2,
    restSeconds: 30,
    safetyNotes: ['Keep hips stable', 'Rotate from mid-back'],
    modifications: [],
  },
  {
    exerciseId: 'ex-010',
    name: 'World\'s Greatest Stretch',
    category: 'mobility',
    targetMuscles: ['hip_flexors', 'hamstrings', 'thoracic_spine'],
    movementPatterns: ['stretch', 'rotation'],
    difficulty: 'intermediate',
    equipmentRequired: [],
    contraindicatedBodyParts: ['knees', 'hips'],
    baseReps: 5,
    baseSets: 2,
    restSeconds: 30,
    safetyNotes: ['Move through each position slowly'],
    modifications: [
      { condition: 'knees', modification: 'Reduce lunge depth' },
    ],
  },
  // Balance exercises
  {
    exerciseId: 'ex-011',
    name: 'Single Leg Balance',
    category: 'balance',
    targetMuscles: ['ankles', 'core', 'glutes'],
    movementPatterns: ['balance'],
    difficulty: 'beginner',
    equipmentRequired: [],
    contraindicatedBodyParts: ['ankles'],
    baseReps: 30, // seconds per side
    baseSets: 2,
    restSeconds: 15,
    safetyNotes: ['Stand near wall for support if needed'],
    modifications: [
      { condition: 'ankles', modification: 'Hold onto wall or chair' },
    ],
  },
  {
    exerciseId: 'ex-012',
    name: 'Bird Dog',
    category: 'balance',
    targetMuscles: ['core', 'glutes', 'shoulders'],
    movementPatterns: ['balance', 'plank'],
    difficulty: 'beginner',
    equipmentRequired: ['yoga_mat'],
    contraindicatedBodyParts: ['wrists', 'lower_back'],
    baseReps: 10,
    baseSets: 2,
    restSeconds: 30,
    safetyNotes: ['Keep back flat', 'Move slowly'],
    modifications: [
      { condition: 'wrists', modification: 'Perform on fists or use yoga blocks' },
    ],
  },
  // Cardio exercises
  {
    exerciseId: 'ex-013',
    name: 'Jumping Jacks',
    category: 'cardio',
    targetMuscles: ['full_body'],
    movementPatterns: ['jump'],
    difficulty: 'beginner',
    equipmentRequired: [],
    contraindicatedBodyParts: ['knees', 'ankles', 'shoulders'],
    baseReps: 30,
    baseSets: 3,
    restSeconds: 30,
    safetyNotes: ['Land softly', 'Keep core engaged'],
    modifications: [
      { condition: 'knees', modification: 'Step out instead of jumping' },
    ],
  },
  {
    exerciseId: 'ex-014',
    name: 'Mountain Climbers',
    category: 'cardio',
    targetMuscles: ['core', 'shoulders', 'hip_flexors'],
    movementPatterns: ['plank', 'cardio'],
    difficulty: 'intermediate',
    equipmentRequired: [],
    contraindicatedBodyParts: ['wrists', 'shoulders', 'hips'],
    baseReps: 20,
    baseSets: 3,
    restSeconds: 30,
    safetyNotes: ['Keep hips level', 'Maintain plank position'],
    modifications: [
      { condition: 'wrists', modification: 'Perform on elevated surface' },
    ],
  },
  {
    exerciseId: 'ex-015',
    name: 'High Knees',
    category: 'cardio',
    targetMuscles: ['hip_flexors', 'core', 'calves'],
    movementPatterns: ['cardio'],
    difficulty: 'beginner',
    equipmentRequired: [],
    contraindicatedBodyParts: ['knees', 'hips'],
    baseReps: 30,
    baseSets: 3,
    restSeconds: 30,
    safetyNotes: ['Land on balls of feet', 'Keep core tight'],
    modifications: [
      { condition: 'knees', modification: 'March in place instead' },
    ],
  },
];

async function seedExercises() {
  console.log(`Seeding ${exercises.length} exercises to ${TABLE_NAME}...`);
  
  for (const exercise of exercises) {
    try {
      await docClient.send(new PutCommand({
        TableName: TABLE_NAME,
        Item: exercise,
      }));
      console.log(`✓ Seeded: ${exercise.name}`);
    } catch (error) {
      console.error(`✗ Failed to seed ${exercise.name}:`, error);
    }
  }
  
  console.log('Done!');
}

seedExercises().catch(console.error);
