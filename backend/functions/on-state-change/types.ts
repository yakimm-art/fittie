/**
 * Types for on-state-change Lambda function
 */

export interface PhysicalStateRecord {
  userId: string;
  timestamp: number;
  painPoints?: string[];
  energyLevel?: number;
  equipment?: string[];
  location?: string;
  activityMode?: string;
  sourceEvent?: string;
  ttl?: number;
}

export interface StateChangeEvent {
  source: string;
  detailType: string;
  detail: {
    eventType: 'INSERT' | 'MODIFY' | 'REMOVE';
    userId: string;
    timestamp: number;
    newState?: PhysicalStateRecord;
    oldState?: PhysicalStateRecord;
    changedFields?: string[];
  };
}
