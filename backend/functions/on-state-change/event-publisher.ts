/**
 * EventBridge publishing logic for state change events
 */

import { EventBridgeClient, PutEventsCommand, PutEventsRequestEntry } from '@aws-sdk/client-eventbridge';
import { PhysicalStateRecord, StateChangeEvent, ChangeType } from './types';

const eventBridge = new EventBridgeClient({ region: process.env.AWS_REGION });
const EVENT_BUS_NAME = process.env.EVENT_BUS_NAME || 'default';
const EVENT_SOURCE = 'fittie.physical-state';

/**
 * Detect the type of change between old and new state
 */
export function detectChangeType(
  oldState?: PhysicalStateRecord,
  newState?: PhysicalStateRecord
): ChangeType[] {
  const changes: ChangeType[] = [];

  if (!oldState || !newState) {
    return changes;
  }

  // Check pain changes
  const oldPain = oldState.painPoints || [];
  const newPain = newState.painPoints || [];
  if (newPain.length > oldPain.length) {
    changes.push('pain_increased');
  } else if (newPain.length < oldPain.length) {
    changes.push('pain_decreased');
  } else if (JSON.stringify(oldPain.sort()) !== JSON.stringify(newPain.sort())) {
    changes.push('pain_changed');
  }

  // Check energy changes
  if (oldState.energyLevel !== newState.energyLevel) {
    if ((newState.energyLevel || 0) > (oldState.energyLevel || 0)) {
      changes.push('energy_increased');
    } else {
      changes.push('energy_decreased');
    }
  }

  // Check location changes
  if (oldState.location !== newState.location) {
    changes.push('location_changed');
  }

  // Check equipment changes
  if (JSON.stringify(oldState.equipment?.sort()) !== JSON.stringify(newState.equipment?.sort())) {
    changes.push('equipment_changed');
  }

  // Check activity mode changes
  if (oldState.activityMode !== newState.activityMode) {
    changes.push('activity_mode_changed');
  }

  return changes.length > 0 ? changes : ['state_updated'];
}

/**
 * Build EventBridge event entry
 */
export function buildEventEntry(event: StateChangeEvent): PutEventsRequestEntry {
  return {
    EventBusName: EVENT_BUS_NAME,
    Source: EVENT_SOURCE,
    DetailType: event.detailType,
    Detail: JSON.stringify(event.detail),
    Time: new Date(event.detail.timestamp),
  };
}

/**
 * Publish state change event to EventBridge
 */
export async function publishStateChangeEvent(event: StateChangeEvent): Promise<void> {
  const entry = buildEventEntry(event);

  const response = await eventBridge.send(new PutEventsCommand({
    Entries: [entry],
  }));

  if (response.FailedEntryCount && response.FailedEntryCount > 0) {
    const failedEntry = response.Entries?.find(e => e.ErrorCode);
    throw new Error(`Failed to publish event: ${failedEntry?.ErrorCode} - ${failedEntry?.ErrorMessage}`);
  }
}

/**
 * Publish multiple events in batch
 */
export async function publishBatchEvents(events: StateChangeEvent[]): Promise<{ 
  successful: number; 
  failed: number;
}> {
  if (events.length === 0) {
    return { successful: 0, failed: 0 };
  }

  const entries = events.map(buildEventEntry);
  
  const response = await eventBridge.send(new PutEventsCommand({
    Entries: entries,
  }));

  return {
    successful: events.length - (response.FailedEntryCount || 0),
    failed: response.FailedEntryCount || 0,
  };
}
