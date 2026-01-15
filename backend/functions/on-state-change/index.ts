/**
 * On-State-Change Lambda Handler
 * Processes DynamoDB Stream events and publishes to EventBridge
 */

import { DynamoDBStreamEvent, DynamoDBRecord } from 'aws-lambda';
import { EventBridgeClient, PutEventsCommand } from '@aws-sdk/client-eventbridge';
import { PhysicalStateRecord, StateChangeEvent } from './types';

const eventBridge = new EventBridgeClient({ region: process.env.AWS_REGION });
const EVENT_BUS_NAME = process.env.EVENT_BUS_NAME || 'default';
const EVENT_SOURCE = 'fittie.physical-state';

const logger = {
  info: (msg: string, data?: Record<string, unknown>) => 
    console.log(JSON.stringify({ level: 'INFO', msg, ...data })),
  error: (msg: string, err?: Error, data?: Record<string, unknown>) => 
    console.error(JSON.stringify({ level: 'ERROR', msg, error: err?.message, ...data })),
};

function unmarshallImage(image: Record<string, any> | undefined): PhysicalStateRecord | undefined {
  if (!image) return undefined;
  
  const result: Record<string, any> = {};
  for (const [key, value] of Object.entries(image)) {
    if (value.S) result[key] = value.S;
    else if (value.N) result[key] = Number(value.N);
    else if (value.L) result[key] = value.L.map((item: any) => item.S || item.N);
    else if (value.BOOL !== undefined) result[key] = value.BOOL;
    else if (value.NULL) result[key] = null;
  }
  return result as PhysicalStateRecord;
}

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

async function processRecord(record: DynamoDBRecord): Promise<void> {
  const eventName = record.eventName as 'INSERT' | 'MODIFY' | 'REMOVE';
  const newImage = unmarshallImage(record.dynamodb?.NewImage);
  const oldImage = unmarshallImage(record.dynamodb?.OldImage);
  
  const userId = newImage?.userId || oldImage?.userId;
  const timestamp = newImage?.timestamp || oldImage?.timestamp;
  
  if (!userId || !timestamp) {
    logger.error('Missing userId or timestamp in record', undefined, { record: JSON.stringify(record) });
    return;
  }

  const event: StateChangeEvent = {
    source: EVENT_SOURCE,
    detailType: `PhysicalState.${eventName}`,
    detail: {
      eventType: eventName,
      userId,
      timestamp,
      ...(newImage && { newState: newImage }),
      ...(oldImage && { oldState: oldImage }),
      ...(eventName === 'MODIFY' && { changedFields: getChangedFields(oldImage, newImage) }),
    },
  };

  logger.info('Publishing event to EventBridge', { 
    eventType: eventName, 
    userId, 
    detailType: event.detailType 
  });

  await eventBridge.send(new PutEventsCommand({
    Entries: [{
      EventBusName: EVENT_BUS_NAME,
      Source: event.source,
      DetailType: event.detailType,
      Detail: JSON.stringify(event.detail),
    }],
  }));
}

export async function handler(event: DynamoDBStreamEvent): Promise<void> {
  logger.info('Processing DynamoDB stream event', { recordCount: event.Records.length });

  const results = await Promise.allSettled(
    event.Records.map(record => processRecord(record))
  );

  const failures = results.filter(r => r.status === 'rejected');
  if (failures.length > 0) {
    logger.error('Some records failed to process', undefined, { 
      failureCount: failures.length,
      totalCount: event.Records.length 
    });
  }

  logger.info('Stream processing complete', { 
    processed: event.Records.length, 
    failures: failures.length 
  });
}
