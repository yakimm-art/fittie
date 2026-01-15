/**
 * Routine Generator Lambda Handler (Soma-Logic Engine)
 * 
 * Endpoint: POST /routine/generate
 */

import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, QueryCommand } from '@aws-sdk/lib-dynamodb';
import { 
  GenerateRoutineRequest, 
  PhysicalState, 
  ApiResponse,
  GeneratedRoutine 
} from './types';
import { buildConstraints } from './constraint-engine';
import { generateRoutine } from './generator';

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);
const STATE_TABLE = process.env.STATE_TABLE || 'user-physical-state';

const logger = {
  info: (msg: string, data?: Record<string, unknown>) => 
    console.log(JSON.stringify({ level: 'INFO', msg, ...data })),
  error: (msg: string, err?: Error, data?: Record<string, unknown>) => 
    console.error(JSON.stringify({ level: 'ERROR', msg, error: err?.message, stack: err?.stack, ...data })),
};

/**
 * Fetch user's latest physical state
 */
async function fetchLatestState(userId: string): Promise<PhysicalState | null> {
  const result = await docClient.send(new QueryCommand({
    TableName: STATE_TABLE,
    KeyConditionExpression: 'userId = :userId',
    ExpressionAttributeValues: { ':userId': userId },
    ScanIndexForward: false,
    Limit: 1,
  }));

  if (!result.Items || result.Items.length === 0) {
    return null;
  }

  return result.Items[0] as PhysicalState;
}

/**
 * Validate request body
 */
function validateRequest(body: unknown): GenerateRoutineRequest {
  const req = body as GenerateRoutineRequest;
  
  if (!req.userId || typeof req.userId !== 'string') {
    throw new ValidationError('userId is required');
  }
  
  if (!req.duration || typeof req.duration !== 'number' || req.duration < 5 || req.duration > 120) {
    throw new ValidationError('duration must be between 5 and 120 minutes');
  }
  
  if (!req.goals || !Array.isArray(req.goals) || req.goals.length === 0) {
    throw new ValidationError('goals must be a non-empty array');
  }
  
  const validGoals = ['strength', 'mobility', 'cardio', 'flexibility', 'balance', 'endurance'];
  for (const goal of req.goals) {
    if (!validGoals.includes(goal)) {
      throw new ValidationError(`Invalid goal: ${goal}`);
    }
  }
  
  return req;
}

class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

/**
 * Create API response
 */
function createResponse<T>(
  statusCode: number,
  body: ApiResponse<T>
): APIGatewayProxyResult {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Credentials': true,
    },
    body: JSON.stringify(body),
  };
}

/**
 * Handle POST /routine/generate
 */
async function handleGenerateRoutine(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  const startTime = Date.now();
  
  try {
    const body = JSON.parse(event.body || '{}');
    const request = validateRequest(body);
    
    logger.info('Generating routine', { 
      userId: request.userId, 
      duration: request.duration,
      goals: request.goals,
    });

    // Fetch physical state if requested
    let state: PhysicalState | null = null;
    if (request.useCurrentState) {
      state = await fetchLatestState(request.userId);
      logger.info('Fetched physical state', { 
        userId: request.userId, 
        hasState: !!state,
        painPoints: state?.painPoints,
      });
    }

    // Build constraints and generate routine
    const constraints = buildConstraints(state, request.duration, request.goals);
    const routine = await generateRoutine(state, constraints);

    const elapsed = Date.now() - startTime;
    logger.info('Routine generated', { 
      userId: request.userId,
      routineId: routine.routineId,
      exerciseCount: routine.exercises.length,
      estimatedDuration: routine.estimatedDuration,
      elapsedMs: elapsed,
    });

    return createResponse(200, {
      success: true,
      data: routine,
    });
  } catch (error) {
    logger.error('Failed to generate routine', error as Error);
    
    if (error instanceof ValidationError) {
      return createResponse(400, {
        success: false,
        error: {
          message: error.message,
          code: 'VALIDATION_ERROR',
        },
      });
    }
    
    if (error instanceof SyntaxError) {
      return createResponse(400, {
        success: false,
        error: {
          message: 'Invalid JSON in request body',
          code: 'INVALID_JSON',
        },
      });
    }
    
    return createResponse(500, {
      success: false,
      error: {
        message: 'Failed to generate routine',
        code: 'INTERNAL_ERROR',
      },
    });
  }
}

/**
 * Main Lambda handler
 */
export async function handler(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  logger.info('Request received', { 
    path: event.path, 
    method: event.httpMethod,
  });

  // Handle CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
      body: '',
    };
  }

  if (event.httpMethod === 'POST' && event.path === '/routine/generate') {
    return await handleGenerateRoutine(event);
  }

  return createResponse(404, {
    success: false,
    error: {
      message: 'Route not found',
      code: 'NOT_FOUND',
    },
  });
}
