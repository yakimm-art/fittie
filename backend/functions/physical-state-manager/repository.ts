import { DynamoDBClient, DynamoDBServiceException } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, QueryCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";
import { PhysicalStateRecord, StateHistoryQuery } from "./types";

const client = new DynamoDBClient({ region: process.env.AWS_REGION, ...(process.env.DYNAMODB_ENDPOINT && { endpoint: process.env.DYNAMODB_ENDPOINT }) });
const docClient = DynamoDBDocumentClient.from(client, { marshallOptions: { removeUndefinedValues: true } });
const TABLE_NAME = process.env.DYNAMODB_STATE_TABLE || "user-physical-state";
const MAX_RETRIES = 3;
const BASE_DELAY_MS = 100;

export class RepositoryError extends Error {
  public readonly operation: string;
  public readonly cause?: Error;
  constructor(message: string, operation: string, cause?: Error) {
    super(message);
    this.name = "RepositoryError";
    this.operation = operation;
    this.cause = cause;
  }
}

const logger = {
  info: (msg: string, data?: Record<string, unknown>) => console.log(JSON.stringify({ level: "INFO", msg, ...data })),
  error: (msg: string, err?: Error, data?: Record<string, unknown>) => console.error(JSON.stringify({ level: "ERROR", msg, error: err?.message, ...data })),
};

const sleep = (ms: number) => new Promise(r => setTimeout(r, ms));
const getBackoffDelay = (attempt: number) => BASE_DELAY_MS * Math.pow(2, attempt) + Math.random() * 100;

function isRetryableError(error: unknown): boolean {
  if (error instanceof DynamoDBServiceException) {
    return ["ProvisionedThroughputExceededException", "ThrottlingException", "ServiceUnavailable", "InternalServerError"].includes(error.name);
  }
  return false;
}

async function withRetry<T>(op: string, fn: () => Promise<T>): Promise<T> {
  let lastErr: Error | undefined;
  for (let i = 0; i < MAX_RETRIES; i++) {
    try { return await fn(); }
    catch (e) {
      lastErr = e as Error;
      if (!isRetryableError(e) || i === MAX_RETRIES - 1) { logger.error(op + " failed", lastErr); throw e; }
      await sleep(getBackoffDelay(i));
    }
  }
  throw lastErr;
}

export class PhysicalStateRepository {
  async saveState(state: PhysicalStateRecord): Promise<PhysicalStateRecord> {
    logger.info("saveState started", { userId: state.userId });
    try {
      await withRetry("saveState", () => docClient.send(new PutCommand({ TableName: TABLE_NAME, Item: state })));
      logger.info("saveState completed", { userId: state.userId });
      return state;
    } catch (e) {
      throw new RepositoryError("Failed to save state", "saveState", e as Error);
    }
  }

  async getLatestState(userId: string): Promise<PhysicalStateRecord | null> {
    logger.info("getLatestState started", { userId });
    try {
      const result = await withRetry("getLatestState", () => docClient.send(new QueryCommand({
        TableName: TABLE_NAME,
        KeyConditionExpression: "userId = :userId",
        ExpressionAttributeValues: { ":userId": userId },
        ScanIndexForward: false,
        Limit: 1,
      })));
      const state = result.Items?.[0] as PhysicalStateRecord | undefined;
      logger.info("getLatestState completed", { userId, found: !!state });
      return state || null;
    } catch (e) {
      throw new RepositoryError("Failed to get latest state", "getLatestState", e as Error);
    }
  }

  async getStateHistory(query: StateHistoryQuery): Promise<PhysicalStateRecord[]> {
    const { userId, fromTimestamp, toTimestamp, limit = 50 } = query;
    logger.info("getStateHistory started", { userId, limit });
    try {
      let kce = "userId = :userId";
      const eav: Record<string, unknown> = { ":userId": userId };
      if (fromTimestamp && toTimestamp) { kce += " AND #ts BETWEEN :from AND :to"; eav[":from"] = fromTimestamp; eav[":to"] = toTimestamp; }
      else if (fromTimestamp) { kce += " AND #ts >= :from"; eav[":from"] = fromTimestamp; }
      else if (toTimestamp) { kce += " AND #ts <= :to"; eav[":to"] = toTimestamp; }
      const result = await withRetry("getStateHistory", () => docClient.send(new QueryCommand({
        TableName: TABLE_NAME,
        KeyConditionExpression: kce,
        ExpressionAttributeNames: { "#ts": "timestamp" },
        ExpressionAttributeValues: eav,
        ScanIndexForward: false,
        Limit: limit,
      })));
      const records = (result.Items || []) as PhysicalStateRecord[];
      logger.info("getStateHistory completed", { userId, count: records.length });
      return records;
    } catch (e) {
      throw new RepositoryError("Failed to get state history", "getStateHistory", e as Error);
    }
  }

  async deleteState(userId: string, timestamp: number): Promise<void> {
    logger.info("deleteState started", { userId, timestamp });
    try {
      await withRetry("deleteState", () => docClient.send(new DeleteCommand({ TableName: TABLE_NAME, Key: { userId, timestamp } })));
      logger.info("deleteState completed", { userId, timestamp });
    } catch (e) {
      throw new RepositoryError("Failed to delete state", "deleteState", e as Error);
    }
  }
}
