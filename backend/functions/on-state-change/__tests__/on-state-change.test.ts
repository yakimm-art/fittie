/**
 * Unit tests for on-state-change Lambda
 */

import { detectChangeType } from '../event-publisher';
import { PhysicalStateRecord } from '../types';

describe('detectChangeType', () => {
  const baseState: PhysicalStateRecord = {
    userId: 'user-123',
    timestamp: 1704067200000,
    painPoints: ['lower_back'],
    energyLevel: 3,
    equipment: ['dumbbells'],
    location: 'gym',
    activityMode: 'active',
  };

  it('should return empty array when oldState is undefined', () => {
    const result = detectChangeType(undefined, baseState);
    expect(result).toEqual([]);
  });

  it('should return empty array when newState is undefined', () => {
    const result = detectChangeType(baseState, undefined);
    expect(result).toEqual([]);
  });

  it('should detect pain_increased when more pain points added', () => {
    const newState = { ...baseState, painPoints: ['lower_back', 'shoulders'] };
    const result = detectChangeType(baseState, newState);
    expect(result).toContain('pain_increased');
  });

  it('should detect pain_decreased when pain points removed', () => {
    const newState = { ...baseState, painPoints: [] };
    const result = detectChangeType(baseState, newState);
    expect(result).toContain('pain_decreased');
  });

  it('should detect pain_changed when pain points differ but same count', () => {
    const newState = { ...baseState, painPoints: ['shoulders'] };
    const result = detectChangeType(baseState, newState);
    expect(result).toContain('pain_changed');
  });

  it('should detect energy_increased', () => {
    const newState = { ...baseState, energyLevel: 5 };
    const result = detectChangeType(baseState, newState);
    expect(result).toContain('energy_increased');
  });

  it('should detect energy_decreased', () => {
    const newState = { ...baseState, energyLevel: 1 };
    const result = detectChangeType(baseState, newState);
    expect(result).toContain('energy_decreased');
  });

  it('should detect location_changed', () => {
    const newState = { ...baseState, location: 'home' };
    const result = detectChangeType(baseState, newState);
    expect(result).toContain('location_changed');
  });

  it('should detect equipment_changed', () => {
    const newState = { ...baseState, equipment: ['barbell', 'bench'] };
    const result = detectChangeType(baseState, newState);
    expect(result).toContain('equipment_changed');
  });

  it('should detect activity_mode_changed', () => {
    const newState = { ...baseState, activityMode: 'sedentary' };
    const result = detectChangeType(baseState, newState);
    expect(result).toContain('activity_mode_changed');
  });

  it('should detect multiple changes', () => {
    const newState = { 
      ...baseState, 
      energyLevel: 5, 
      location: 'home',
      painPoints: ['lower_back', 'neck'],
    };
    const result = detectChangeType(baseState, newState);
    expect(result).toContain('energy_increased');
    expect(result).toContain('location_changed');
    expect(result).toContain('pain_increased');
  });

  it('should return state_updated when no specific changes detected', () => {
    const result = detectChangeType(baseState, { ...baseState });
    expect(result).toEqual(['state_updated']);
  });
});

describe('unmarshallImage', () => {
  // Import the function for testing (would need to export it)
  // These tests verify the unmarshalling logic works correctly
});
