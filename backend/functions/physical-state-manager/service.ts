/**
 * Business logic service for Physical State Manager
 */

import { PhysicalStateRepository } from './repository';
import {
  PhysicalStateRecord,
  UpdateStateRequest,
  StateHistoryQuery,
} from './types';

export class PhysicalStateService {
  constructor(private repository: PhysicalStateRepository) {}

  /**
   * Update user's physical state
   */
  async updateState(
    userId: string,
    request: UpdateStateRequest
  ): Promise<PhysicalStateRecord> {
    const timestamp = Date.now();
    
    // Calculate TTL: 90 days from now (in seconds)
    const ttl = Math.floor(timestamp / 1000) + (90 * 24 * 60 * 60);

    const stateRecord: PhysicalStateRecord = {
      userId,
      timestamp,
      painPoints: request.painPoints,
      energyLevel: request.energyLevel,
      equipment: request.equipment,
      location: request.location,
      activityMode: request.activityMode,
      sourceEvent: request.sourceEvent,
      confidence: request.confidence,
      ttl,
    };

    return await this.repository.saveState(stateRecord);
  }

  /**
   * Get the latest physical state for a user
   */
  async getLatestState(userId: string): Promise<PhysicalStateRecord | null> {
    return await this.repository.getLatestState(userId);
  }

  /**
   * Get physical state history for a user
   */
  async getStateHistory(
    userId: string,
    queryParams: { fromTimestamp?: number; toTimestamp?: number; limit?: number }
  ): Promise<PhysicalStateRecord[]> {
    const query: StateHistoryQuery = {
      userId,
      ...queryParams,
    };

    return await this.repository.getStateHistory(query);
  }
}
