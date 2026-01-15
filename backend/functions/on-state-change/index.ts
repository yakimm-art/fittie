/**
 * On-State-Change Lambda Handler
 * Processes DynamoDB Stream events and publishes to EventBridge
 */

import { DynamoDBStreamEvent, DynamoDBRecord } from 'aws-lambda';
import { PhysicalStateRecord, StateChangeEvent } from './types';
import { publishStateChangeEvent, detectChangeType } from './event-publisher';

const EVENT_SOURCE = 'fittie.physical-state';

const logger = {
  info: (msg: string, data?: Record<string, unknown>) => 
    console.log(JSON.stringify({ level: 'INFO', msg, ...data })),
  error: (msg: string, err?: Error, data?: Record<string, unknown>) => 
    console.error(JSON.stringify({ level: 'ERROR', msg, error: err?.message, stack: err?.stack, ...data })),
  warn: (msg: string, data?: Record<string, unknown>) =>
    console.warn(JSON.stringify({ level: 'WARN', msg, ...data })),
};

/**
 * Unmarshall DynamoDB image to plain object
 */
function unmarshallImage(image: Record<string, any> | undefined): PhysicalStateRecord | undefined {
  if (!image) return undefined;
  
  const result: Record<string, any> = {};
  for (const [key, value] of Object.entries(image)) {
    if (value.S !== undefined) result[key] = value.S;
    else if (value.N !== undefined) result[key] = Number(value.N);
    else if (value.L !== undefined) result[key] = value.L.map((item: any) => item.S ?? item.N);
    else if (value.BOOL !== undefined) result[key] = value.BOOL;
    else if (value.NULL !== undefined) result[key] = null;
    else if (value.SS !== undefined) result[key] = value.SS;
    else if (value.NS !== undefined) result[key] = value.NS.map(Number);
  }
  return result as PhysicalStateRecord;
}

/**
 * Get list of changed fields between old and new state
 */
function getChangedFields(oldState?: PhysicalStateRecord, newState?: PhysicalStateRecord): string[] {
  if (!oldState || !newState) return [];
  
  const changed: string[] = [];
  const allKeys = new Set([...Object.keys(oldState), ...Object.keys(newState)]);
  
  for (const key of allKeys) {
    const oldVal = JSON.stringify((oldState as any)[key]);
    const newVal = JSON.stringify((newState as any)[key]);
    if (oldVal !== newVal) changed.push(key);
  }
  return changed;
}

/**
 * Process a single DynamoDB stream record
 */
async function processRecord(record: DynamoDBRecord): Promise<void> {
  const eventName = record.eventName as 'INSERT' | 'MODIFY' | 'REMOVE';
  const newImage = unmarshallImage(record.dynamodb?.NewImage);
  const oldImage = unmarshallImage(record.dynamodb?.OldImage);
  
  const userId = newImage?.userId || oldImage?.userId;
  const timestamp = newImage?.timestamp || oldImage?.timestamp || Date.now();
  
  if (!userId) {
    logger.warn('Missing userId in record, skipping', { 
      eventID: record.eventID,
      eventName 
    });
    return;
  }

  const changedFields = eventName === 'MODIFY' ? getChangedFields(oldImage, newImage) : [];
  const changeTypes = eventName === 'MODIFY' ? detectChangeType(oldImage, newImage) : [];

  const event: StateChangeEvent = {
    source: EVENT_SOURCE,
    detailType: `PhysicalState.${eventName}`,
    detail: {
      eventType: eventName,
      userId,
      timestamp,
      ...(newImage && { newState: newImage }),
      ...(oldImage && { oldState: oldImage }),
      ...(changedFields.length > 0 && { changedFields }),
      ...(changeTypes.length > 0 && { changeTypes }),
    },
  };

  logger.info('Publishing event to EventBridge', { 
    eventType: eventName, 
    userId, 
    detailType: event.detailType,
    changeTypes,
  });

  await publishStateChangeEvent(event);
}

/**
 * Lambda handler for DynamoDB Stream events
 */
export async function handler(event: DynamoDBStreamEvent): Promise<void> {
  logger.info('Processing DynamoDB stream event', { 
    recordCount: event.Records.length 
  });

  const results = await Promise.allSettled(
    event.Records.map(record => processRecord(record))
  );

  const failures = results.filter(r => r.status === 'rejected');
  
  if (failures.length > 0) {
    failures.forEach((failure, index) => {
      if (failure.status === 'rejected') {
        logger.error('Record processing failed', failure.reason as Error, {
          recordIndex: index,
        });
      }
    });
  }

  logger.info('Stream processing complete', { 
    processed: event.Records.length, 
    successful: event.Records.length - failures.length,
    failures: failures.length,
  });

  // If all records failed, throw to trigger DLQ
  if (failures.length === event.Records.length && event.Records.length > 0) {
    throw new Error(`All ${failures.length} records failed to process`);
  }
}
