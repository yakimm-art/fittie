/**
 * Unit tests for Physical State Manager
 */

import { validateUpdateStateRequest, validateStateHistoryQuery, ValidationError } from '../validators';
import { BodyPart, EquipmentType } from '../types';

describe('Physical State Manager - Validators', () => {
  describe('validateUpdateStateRequest', () => {
    it('should validate a valid request', () => {
      const validRequest = {
        painPoints: ['lower_back', 'knees'],
        energyLevel: 3,
        equipment: ['dumbbells'],
        location: 'gym',
        activityMode: 'active',
        sourceEvent: 'voice',
      };

      const result = validateUpdateStateRequest(validRequest);
      expect(result.painPoints).toEqual([BodyPart.LOWER_BACK, BodyPart.KNEES]);
      expect(result.energyLevel).toBe(3);
      expect(result.equipment).toEqual([EquipmentType.DUMBBELLS]);
    });

    it('should throw ValidationError for invalid painPoints', () => {
      const invalidRequest = {
        painPoints: ['invalid_body_part'],
        energyLevel: 3,
        equipment: ['dumbbells'],
        location: 'gym',
        activityMode: 'active',
        sourceEvent: 'voice',
      };

      expect(() => validateUpdateStateRequest(invalidRequest)).toThrow(ValidationError);
    });

    it('should throw ValidationError for invalid energyLevel', () => {
      const invalidRequest = {
        painPoints: ['lower_back'],
        energyLevel: 6,
        equipment: ['dumbbells'],
        location: 'gym',
        activityMode: 'active',
        sourceEvent: 'voice',
      };

      expect(() => validateUpdateStateRequest(invalidRequest)).toThrow(ValidationError);
    });

    it('should throw ValidationError for invalid location', () => {
      const invalidRequest = {
        painPoints: ['lower_back'],
        energyLevel: 3,
        equipment: ['dumbbells'],
        location: 'invalid_location',
        activityMode: 'active',
        sourceEvent: 'voice',
      };

      expect(() => validateUpdateStateRequest(invalidRequest)).toThrow(ValidationError);
    });
  });

  describe('validateStateHistoryQuery', () => {
    it('should validate valid query parameters', () => {
      const validParams = {
        fromTimestamp: '1609459200000',
        toTimestamp: '1640995200000',
        limit: '50',
      };

      const result = validateStateHistoryQuery(validParams);
      expect(result.fromTimestamp).toBe(1609459200000);
      expect(result.toTimestamp).toBe(1640995200000);
      expect(result.limit).toBe(50);
    });

    it('should throw ValidationError when fromTimestamp > toTimestamp', () => {
      const invalidParams = {
        fromTimestamp: '1640995200000',
        toTimestamp: '1609459200000',
      };

      expect(() => validateStateHistoryQuery(invalidParams)).toThrow(ValidationError);
    });

    it('should throw ValidationError for invalid limit', () => {
      const invalidParams = {
        limit: '200',
      };

      expect(() => validateStateHistoryQuery(invalidParams)).toThrow(ValidationError);
    });
  });
});

// Note: Run tests with Jest after installing dependencies
// npm install --save-dev jest @types/jest ts-jest
// npx jest
