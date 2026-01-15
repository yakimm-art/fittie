/**
 * Unit tests for Routine Generator (Soma-Logic Engine)
 */

import { buildConstraints, adjustForEnergy, getExcludedMovements, getAvoidedReason } from '../constraint-engine';
import { filterExercises, selectBalancedExercises } from '../exercise-selector';
import { Exercise, PhysicalState, RoutineConstraints, WorkoutGoal } from '../types';

describe('Constraint Engine', () => {
  describe('buildConstraints', () => {
    const baseState: PhysicalState = {
      userId: 'user-123',
      timestamp: Date.now(),
      painPoints: ['knees', 'lower_back'],
      energyLevel: 3,
      equipment: ['dumbbells', 'yoga_mat'],
      location: 'home',
      activityMode: 'active',
    };

    it('should build constraints from physical state', () => {
      const constraints = buildConstraints(baseState, 30, ['strength']);
      
      expect(constraints.maxDuration).toBe(30);
      expect(constraints.energyLevel).toBe(3);
      expect(constraints.goals).toEqual(['strength']);
      expect(constraints.availableEquipment).toEqual(['dumbbells', 'yoga_mat']);
      expect(constraints.excludedBodyParts).toContain('knees');
      expect(constraints.excludedBodyParts).toContain('lower_back');
    });

    it('should handle null state with defaults', () => {
      const constraints = buildConstraints(null, 20, ['mobility']);
      
      expect(constraints.maxDuration).toBe(20);
      expect(constraints.energyLevel).toBe(3);
      expect(constraints.availableEquipment).toEqual(['none']);
      expect(constraints.excludedBodyParts).toEqual([]);
    });

    it('should deduplicate excluded body parts', () => {
      const stateWithDuplicates: PhysicalState = {
        ...baseState,
        painPoints: ['knees', 'knees'],
      };
      const constraints = buildConstraints(stateWithDuplicates, 30, ['strength']);
      
      const kneeCount = constraints.excludedBodyParts.filter(p => p === 'knees').length;
      expect(kneeCount).toBe(1);
    });
  });

  describe('adjustForEnergy', () => {
    it('should reduce sets/reps for low energy', () => {
      const result = adjustForEnergy(3, 12, 1);
      
      expect(result.sets).toBeLessThan(3);
      expect(result.reps).toBeLessThan(12);
    });

    it('should increase sets/reps for high energy', () => {
      const result = adjustForEnergy(3, 12, 5);
      
      expect(result.sets).toBeGreaterThanOrEqual(3);
      expect(result.reps).toBeGreaterThanOrEqual(12);
    });

    it('should maintain baseline for medium energy', () => {
      const result = adjustForEnergy(3, 12, 3);
      
      expect(result.sets).toBeGreaterThanOrEqual(2);
      expect(result.sets).toBeLessThanOrEqual(4);
      expect(result.reps).toBeGreaterThanOrEqual(10);
      expect(result.reps).toBeLessThanOrEqual(14);
    });

    it('should never return less than 1 set or 4 reps', () => {
      const result = adjustForEnergy(1, 4, 1);
      
      expect(result.sets).toBeGreaterThanOrEqual(1);
      expect(result.reps).toBeGreaterThanOrEqual(4);
    });
  });

  describe('getExcludedMovements', () => {
    it('should return movements to avoid for knee pain', () => {
      const excluded = getExcludedMovements(['knees']);
      
      expect(excluded).toContain('deep_squat');
      expect(excluded).toContain('lunge');
      expect(excluded).toContain('jump');
    });

    it('should return movements to avoid for lower back pain', () => {
      const excluded = getExcludedMovements(['lower_back']);
      
      expect(excluded).toContain('deadlift');
      expect(excluded).toContain('bent_over_row');
    });

    it('should combine movements for multiple pain points', () => {
      const excluded = getExcludedMovements(['knees', 'shoulders']);
      
      expect(excluded).toContain('lunge');
      expect(excluded).toContain('overhead_press');
    });

    it('should return empty array for no pain points', () => {
      const excluded = getExcludedMovements([]);
      expect(excluded).toEqual([]);
    });

    it('should deduplicate movements', () => {
      const excluded = getExcludedMovements(['knees', 'knees']);
      const uniqueCount = new Set(excluded).size;
      expect(excluded.length).toBe(uniqueCount);
    });
  });

  describe('getAvoidedReason', () => {
    it('should format single pain point', () => {
      const reason = getAvoidedReason(['lower_back']);
      expect(reason).toBe('User reported pain in: lower back');
    });

    it('should format multiple pain points', () => {
      const reason = getAvoidedReason(['knees', 'shoulders']);
      expect(reason).toBe('User reported pain in: knees, shoulders');
    });

    it('should return undefined for no pain points', () => {
      const reason = getAvoidedReason([]);
      expect(reason).toBeUndefined();
    });
  });
});

describe('Exercise Selector', () => {
  const mockExercises: Exercise[] = [
    {
      exerciseId: 'ex-001',
      name: 'Goblet Squat',
      category: 'strength',
      targetMuscles: ['quadriceps', 'glutes'],
      movementPatterns: ['squat'],
      difficulty: 'beginner',
      equipmentRequired: ['dumbbells'],
      contraindicatedBodyParts: ['knees'],
      baseReps: 12,
      baseSets: 3,
      restSeconds: 60,
      safetyNotes: ['Keep core engaged'],
      modifications: [],
    },
    {
      exerciseId: 'ex-002',
      name: 'Push-up',
      category: 'strength',
      targetMuscles: ['chest', 'triceps'],
      movementPatterns: ['push'],
      difficulty: 'beginner',
      equipmentRequired: [],
      contraindicatedBodyParts: ['wrists', 'shoulders'],
      baseReps: 10,
      baseSets: 3,
      restSeconds: 45,
      safetyNotes: ['Maintain straight body line'],
      modifications: [],
    },
    {
      exerciseId: 'ex-003',
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
      safetyNotes: ['Move slowly'],
      modifications: [],
    },
    {
      exerciseId: 'ex-004',
      name: 'Barbell Deadlift',
      category: 'strength',
      targetMuscles: ['hamstrings', 'glutes', 'lower_back'],
      movementPatterns: ['hinge'],
      difficulty: 'advanced',
      equipmentRequired: ['barbell'],
      contraindicatedBodyParts: ['lower_back'],
      baseReps: 5,
      baseSets: 5,
      restSeconds: 120,
      safetyNotes: ['Keep back neutral'],
      modifications: [],
    },
  ];

  describe('filterExercises', () => {
    it('should exclude exercises with contraindicated body parts', () => {
      const constraints: RoutineConstraints = {
        excludedBodyParts: ['knees'],
        availableEquipment: ['dumbbells'],
        maxDuration: 30,
        energyLevel: 3,
        goals: ['strength'],
      };

      const filtered = filterExercises(mockExercises, constraints);
      
      expect(filtered.find(e => e.exerciseId === 'ex-001')).toBeUndefined();
      expect(filtered.find(e => e.exerciseId === 'ex-002')).toBeDefined();
    });

    it('should exclude exercises requiring unavailable equipment', () => {
      const constraints: RoutineConstraints = {
        excludedBodyParts: [],
        availableEquipment: ['yoga_mat'],
        maxDuration: 30,
        energyLevel: 3,
        goals: ['strength', 'mobility'],
      };

      const filtered = filterExercises(mockExercises, constraints);
      
      expect(filtered.find(e => e.exerciseId === 'ex-001')).toBeUndefined(); // needs dumbbells
      expect(filtered.find(e => e.exerciseId === 'ex-003')).toBeDefined(); // needs yoga_mat
    });

    it('should filter by goals', () => {
      const constraints: RoutineConstraints = {
        excludedBodyParts: [],
        availableEquipment: ['dumbbells', 'yoga_mat'],
        maxDuration: 30,
        energyLevel: 3,
        goals: ['mobility'],
      };

      const filtered = filterExercises(mockExercises, constraints);
      
      expect(filtered.every(e => e.category === 'mobility' || e.category === 'flexibility')).toBe(true);
    });

    it('should exclude advanced exercises for low energy', () => {
      const constraints: RoutineConstraints = {
        excludedBodyParts: [],
        availableEquipment: ['barbell'],
        maxDuration: 30,
        energyLevel: 2,
        goals: ['strength'],
      };

      const filtered = filterExercises(mockExercises, constraints);
      
      expect(filtered.find(e => e.exerciseId === 'ex-004')).toBeUndefined();
    });
  });

  describe('selectBalancedExercises', () => {
    it('should select exercises up to target count', () => {
      const constraints: RoutineConstraints = {
        excludedBodyParts: [],
        availableEquipment: ['dumbbells', 'yoga_mat'],
        maxDuration: 15, // ~3 exercises
        energyLevel: 3,
        goals: ['strength', 'mobility'],
      };

      const selected = selectBalancedExercises(mockExercises, constraints);
      
      expect(selected.length).toBeLessThanOrEqual(3);
    });

    it('should prefer variety in movement patterns', () => {
      const constraints: RoutineConstraints = {
        excludedBodyParts: [],
        availableEquipment: ['dumbbells', 'yoga_mat'],
        maxDuration: 30,
        energyLevel: 3,
        goals: ['strength', 'mobility'],
      };

      const selected = selectBalancedExercises(mockExercises, constraints);
      const patterns = selected.flatMap(e => e.movementPatterns);
      const uniquePatterns = new Set(patterns);
      
      // Should have variety
      expect(uniquePatterns.size).toBeGreaterThan(1);
    });
  });
});
