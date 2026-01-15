/**
 * AWS Lambda handler for Physical State Manager
 * 
 * Endpoints:
 * - POST /state - Update physical state
 * - GET /state/latest - Get latest state
 * - GET /state/history - Get state history
 */

import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { PhysicalStateRepository, RepositoryError } from './repository';
import { PhysicalStateService } from './service';
import { validateUpdateStateRequest, validateStateHistoryQuery, ValidationError } from './validators';
import { ApiResponse } from './types';

const repository = new PhysicalStateRepository();
const service = new PhysicalStateService(repository);

/**
 * Extract userId from API Gateway authorizer context
 */
function getUserId(event: APIGatewayProxyEvent): string {
  // In production, this comes from Cognito authorizer
  // For now, get from query parameter or header for testing
  const userId = 
    event.requestContext?.authorizer?.claims?.sub ||
    event.queryStringParameters?.userId ||
    event.headers['x-user-id'];

  if (!userId) {
    throw new Error('User ID not found in request');
  }

  return userId;
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
 * Handle POST /state - Update physical state
 */
async function handleUpdateState(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  try {
    const userId = getUserId(event);
    const body = JSON.parse(event.body || '{}');
    
    // Validate request
    const validatedRequest = validateUpdateStateRequest(body);
    
    // Update state
    const stateRecord = await service.updateState(userId, validatedRequest);
    
    return createResponse(200, {
      success: true,
      data: stateRecord,
    });
  } catch (error) {
    console.error('Error updating state:', error);
    
    if (error instanceof ValidationError) {
      return createResponse(400, {
        success: false,
        error: {
          message: error.message,
          code: 'VALIDATION_ERROR',
        },
      });
    }

    if (error instanceof RepositoryError) {
      return createResponse(503, {
        success: false,
        error: {
          message: 'Database operation failed',
          code: 'DATABASE_ERROR',
        },
      });
    }
    
    return createResponse(500, {
      success: false,
      error: {
        message: 'Internal server error',
        code: 'INTERNAL_ERROR',
      },
    });
  }
}

/**
 * Handle GET /state/latest - Get latest state
 */
async function handleGetLatestState(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  try {
    const userId = getUserId(event);
    
    const latestState = await service.getLatestState(userId);
    
    if (!latestState) {
      return createResponse(404, {
        success: false,
        error: {
          message: 'No state found for user',
          code: 'NOT_FOUND',
        },
      });
    }
    
    return createResponse(200, {
      success: true,
      data: latestState,
    });
  } catch (error) {
    console.error('Error getting latest state:', error);

    if (error instanceof RepositoryError) {
      return createResponse(503, {
        success: false,
        error: {
          message: 'Database operation failed',
          code: 'DATABASE_ERROR',
        },
      });
    }
    
    return createResponse(500, {
      success: false,
      error: {
        message: 'Internal server error',
        code: 'INTERNAL_ERROR',
      },
    });
  }
}

/**
 * Handle GET /state/history - Get state history
 */
async function handleGetStateHistory(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  try {
    const userId = getUserId(event);
    const queryParams = event.queryStringParameters || {};
    
    // Validate query parameters
    const validatedParams = validateStateHistoryQuery(queryParams);
    
    const history = await service.getStateHistory(userId, validatedParams);
    
    return createResponse(200, {
      success: true,
      data: history,
    });
  } catch (error) {
    console.error('Error getting state history:', error);
    
    if (error instanceof ValidationError) {
      return createResponse(400, {
        success: false,
        error: {
          message: error.message,
          code: 'VALIDATION_ERROR',
        },
      });
    }

    if (error instanceof RepositoryError) {
      return createResponse(503, {
        success: false,
        error: {
          message: 'Database operation failed',
          code: 'DATABASE_ERROR',
        },
      });
    }
    
    return createResponse(500, {
      success: false,
      error: {
        message: 'Internal server error',
        code: 'INTERNAL_ERROR',
      },
    });
  }
}

/**
 * Main Lambda handler
 */
export async function handler(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  const httpMethod = event.httpMethod;
  const path = event.path;

  // Handle CORS preflight
  if (httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, x-user-id',
      },
      body: '',
    };
  }

  try {
    // Route to appropriate handler
    if (httpMethod === 'POST' && path === '/state') {
      return await handleUpdateState(event);
    } else if (httpMethod === 'GET' && path === '/state/latest') {
      return await handleGetLatestState(event);
    } else if (httpMethod === 'GET' && path === '/state/history') {
      return await handleGetStateHistory(event);
    }

    // Unknown route
    return createResponse(404, {
      success: false,
      error: {
        message: 'Route not found',
        code: 'NOT_FOUND',
      },
    });
  } catch (error) {
    console.error('Unhandled error:', error);
    
    return createResponse(500, {
      success: false,
      error: {
        message: 'Internal server error',
        code: 'INTERNAL_ERROR',
      },
    });
  }
}
