/**
 * Local types for Physical State Manager Lambda
 */

export interface PhysicalStateRecord {
  userId: string;
  timestamp: number;
  painPoints: BodyPart[];
  energyLevel: EnergyLevel;
  equipment: EquipmentType[];
  location: Location;
  activityMode: ActivityMode;
  sourceEvent: SourceEvent;
  confidence?: number;
  ttl?: number;
}

export enum BodyPart {
  LOWER_BACK = 'lower_back',
  UPPER_BACK = 'upper_back',
  KNEES = 'knees',
  SHOULDERS = 'shoulders',
  NECK = 'neck',
  HIPS = 'hips',
  ANKLES = 'ankles',
  WRISTS = 'wrists',
  ELBOWS = 'elbows',
}

export type EnergyLevel = 1 | 2 | 3 | 4 | 5;

export enum EquipmentType {
  NONE = 'none',
  DUMBBELLS = 'dumbbells',
  RESISTANCE_BANDS = 'resistance_bands',
  YOGA_MAT = 'yoga_mat',
  PULL_UP_BAR = 'pull_up_bar',
  KETTLEBELL = 'kettlebell',
  BARBELL = 'barbell',
  BENCH = 'bench',
  FOAM_ROLLER = 'foam_roller',
}

export type Location = 'home' | 'gym' | 'office' | 'outdoor';
export type ActivityMode = 'sedentary' | 'active';
export type SourceEvent = 'voice' | 'manual' | 'inferred';

export interface UpdateStateRequest {
  painPoints: BodyPart[];
  energyLevel: EnergyLevel;
  equipment: EquipmentType[];
  location: Location;
  activityMode: ActivityMode;
  sourceEvent: SourceEvent;
  confidence?: number;
}

export interface StateHistoryQuery {
  userId: string;
  fromTimestamp?: number;
  toTimestamp?: number;
  limit?: number;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: {
    message: string;
    code: string;
  };
}
