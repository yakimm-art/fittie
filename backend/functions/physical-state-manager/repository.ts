/**
 * DynamoDB repository for Physical State operations
 */

import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import {
  DynamoDBDocumentClient,
  PutCommand,
  QueryCommand,
  GetCommand,
} from '@aws-sdk/lib-dynamodb';
import { PhysicalStateRecord, StateHistoryQuery } from './types';

const client = new DynamoDBClient({
  region: process.env.AWS_REGION,
  ...(process.env.DYNAMODB_ENDPOINT && {
    endpoint: process.env.DYNAMODB_ENDPOINT,
  }),
});

const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_STATE_TABLE || 'user-physical-state';

export class PhysicalStateRepository {
  /**
   * Save a new physical state record
   */
  async saveState(state: PhysicalStateRecord): Promise<PhysicalStateRecord> {
    const command = new PutCommand({
      TableName: TABLE_NAME,
      Item: state,
    });

    await docClient.send(command);
    return state;
  }

  /**
   * Get the latest physical state for a user
   */
  async getLatestState(userId: string): Promise<PhysicalStateRecord | null> {
    const command = new QueryCommand({
      TableName: TABLE_NAME,
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: {
        ':userId': userId,
      },
      ScanIndexForward: false, // Descending order
      Limit: 1,
    });

    const result = await docClient.send(command);
    
    if (!result.Items || result.Items.length === 0) {
      return null;
    }

    return result.Items[0] as PhysicalStateRecord;
  }

  /**
   * Query physical state history for a user
   */
  async getStateHistory(query: StateHistoryQuery): Promise<PhysicalStateRecord[]> {
    const { userId, fromTimestamp, toTimestamp, limit = 50 } = query;

    let keyConditionExpression = 'userId = :userId';
    const expressionAttributeValues: Record<string, any> = {
      ':userId': userId,
    };

    if (fromTimestamp && toTimestamp) {
      keyConditionExpression += ' AND #ts BETWEEN :from AND :to';
      expressionAttributeValues[':from'] = fromTimestamp;
      expressionAttributeValues[':to'] = toTimestamp;
    } else if (fromTimestamp) {
      keyConditionExpression += ' AND #ts >= :from';
      expressionAttributeValues[':from'] = fromTimestamp;
    } else if (toTimestamp) {
      keyConditionExpression += ' AND #ts <= :to';
      expressionAttributeValues[':to'] = toTimestamp;
    }

    const command = new QueryCommand({
      TableName: TABLE_NAME,
      KeyConditionExpression: keyConditionExpression,
      ExpressionAttributeNames: {
        '#ts': 'timestamp',
      },
      ExpressionAttributeValues: expressionAttributeValues,
      ScanIndexForward: false, // Descending order (newest first)
      Limit: limit,
    });

    const result = await docClient.send(command);
    return (result.Items || []) as PhysicalStateRecord[];
  }
}
