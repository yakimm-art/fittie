/**
 * Input validation for Physical State Manager
 */

import {
  UpdateStateRequest,
  BodyPart,
  EnergyLevel,
  EquipmentType,
  Location,
  ActivityMode,
  SourceEvent,
} from './types';

export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

/**
 * Validate UpdateStateRequest
 */
export function validateUpdateStateRequest(data: any): UpdateStateRequest {
  if (!data || typeof data !== 'object') {
    throw new ValidationError('Request body must be an object');
  }

  // Validate painPoints
  if (!Array.isArray(data.painPoints)) {
    throw new ValidationError('painPoints must be an array');
  }
  
  const validBodyParts = Object.values(BodyPart);
  const painPoints = data.painPoints;
  
  for (const point of painPoints) {
    if (!validBodyParts.includes(point)) {
      throw new ValidationError(
        `Invalid body part: ${point}. Must be one of: ${validBodyParts.join(', ')}`
      );
    }
  }

  // Validate energyLevel
  const energyLevel = data.energyLevel;
  if (![1, 2, 3, 4, 5].includes(energyLevel)) {
    throw new ValidationError('energyLevel must be 1, 2, 3, 4, or 5');
  }

  // Validate equipment
  if (!Array.isArray(data.equipment)) {
    throw new ValidationError('equipment must be an array');
  }
  
  const validEquipment = Object.values(EquipmentType);
  const equipment = data.equipment;
  
  for (const item of equipment) {
    if (!validEquipment.includes(item)) {
      throw new ValidationError(
        `Invalid equipment: ${item}. Must be one of: ${validEquipment.join(', ')}`
      );
    }
  }

  // Validate location
  const validLocations: Location[] = ['home', 'gym', 'office', 'outdoor'];
  if (!validLocations.includes(data.location)) {
    throw new ValidationError(
      `Invalid location: ${data.location}. Must be one of: ${validLocations.join(', ')}`
    );
  }

  // Validate activityMode
  const validActivityModes: ActivityMode[] = ['sedentary', 'active'];
  if (!validActivityModes.includes(data.activityMode)) {
    throw new ValidationError(
      `Invalid activityMode: ${data.activityMode}. Must be 'sedentary' or 'active'`
    );
  }

  // Validate sourceEvent
  const validSourceEvents: SourceEvent[] = ['voice', 'manual', 'inferred'];
  if (!validSourceEvents.includes(data.sourceEvent)) {
    throw new ValidationError(
      `Invalid sourceEvent: ${data.sourceEvent}. Must be 'voice', 'manual', or 'inferred'`
    );
  }

  // Validate confidence (optional)
  if (data.confidence !== undefined) {
    const confidence = Number(data.confidence);
    if (isNaN(confidence) || confidence < 0 || confidence > 1) {
      throw new ValidationError('confidence must be a number between 0 and 1');
    }
  }

  return {
    painPoints: painPoints as BodyPart[],
    energyLevel: energyLevel as EnergyLevel,
    equipment: equipment as EquipmentType[],
    location: data.location as Location,
    activityMode: data.activityMode as ActivityMode,
    sourceEvent: data.sourceEvent as SourceEvent,
    confidence: data.confidence,
  };
}

/**
 * Validate query parameters for state history
 */
export function validateStateHistoryQuery(params: any): {
  fromTimestamp?: number;
  toTimestamp?: number;
  limit?: number;
} {
  const result: any = {};

  if (params.fromTimestamp) {
    const from = Number(params.fromTimestamp);
    if (isNaN(from) || from < 0) {
      throw new ValidationError('fromTimestamp must be a positive number');
    }
    result.fromTimestamp = from;
  }

  if (params.toTimestamp) {
    const to = Number(params.toTimestamp);
    if (isNaN(to) || to < 0) {
      throw new ValidationError('toTimestamp must be a positive number');
    }
    result.toTimestamp = to;
  }

  if (params.limit) {
    const limit = Number(params.limit);
    if (isNaN(limit) || limit < 1 || limit > 100) {
      throw new ValidationError('limit must be between 1 and 100');
    }
    result.limit = limit;
  }

  if (result.fromTimestamp && result.toTimestamp && result.fromTimestamp > result.toTimestamp) {
    throw new ValidationError('fromTimestamp must be less than toTimestamp');
  }

  return result;
}
