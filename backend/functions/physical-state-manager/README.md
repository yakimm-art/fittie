# Physical State Manager Lambda Function

AWS Lambda function for managing user physical state in the Fittie fitness coaching application.

## API Endpoints

### POST /state
Update user's current physical state.

**Request Body:**
```json
{
  "painPoints": ["lower_back", "knees"],
  "energyLevel": 3,
  "equipment": ["dumbbells"],
  "location": "gym",
  "activityMode": "active",
  "sourceEvent": "voice",
  "confidence": 0.85
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": "user-123",
    "timestamp": 1704225600000,
    "painPoints": ["lower_back", "knees"],
    "energyLevel": 3,
    "equipment": ["dumbbells"],
    "location": "gym",
    "activityMode": "active",
    "sourceEvent": "voice",
    "confidence": 0.85,
    "ttl": 1711968000
  }
}
```

### GET /state/latest
Get the most recent physical state for the authenticated user.

**Query Parameters:**
- `userId` (string) - User ID (for testing; in production comes from Cognito authorizer)

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": "user-123",
    "timestamp": 1704225600000,
    "painPoints": ["lower_back"],
    "energyLevel": 4,
    "equipment": ["dumbbells"],
    "location": "home",
    "activityMode": "active",
    "sourceEvent": "manual",
    "ttl": 1711968000
  }
}
```

### GET /state/history
Query physical state history for the authenticated user.

**Query Parameters:**
- `userId` (string) - User ID (for testing)
- `fromTimestamp` (number, optional) - Start timestamp in milliseconds
- `toTimestamp` (number, optional) - End timestamp in milliseconds
- `limit` (number, optional) - Maximum number of records (1-100, default: 50)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "userId": "user-123",
      "timestamp": 1704225600000,
      "painPoints": ["lower_back"],
      "energyLevel": 4,
      "equipment": ["dumbbells"],
      "location": "home",
      "activityMode": "active",
      "sourceEvent": "manual",
      "ttl": 1711968000
    }
  ]
}
```

## Local Development

### Install Dependencies
```bash
npm install
```

### Build
```bash
npm run build
```

### Test Locally
Set up local DynamoDB first:
```bash
cd ../../..
./scripts/local-dev.sh start
```

Then you can test the function using AWS SAM or by invoking it directly with test events.

### Run Tests
```bash
npm test
```

## Deployment

The function is deployed via AWS CDK:
```bash
cd ../../../infra
cdk deploy FittieComputeStack
```

## Environment Variables

- `AWS_REGION` - AWS region (default: us-east-1)
- `DYNAMODB_STATE_TABLE` - Physical state table name
- `DYNAMODB_ENDPOINT` - DynamoDB endpoint (for local development)

## Architecture

```
index.ts           # Lambda handler and routing
├── service.ts     # Business logic
├── repository.ts  # DynamoDB operations
├── validators.ts  # Input validation
└── types.ts       # TypeScript type definitions
```

## Error Handling

The function returns appropriate HTTP status codes:

- **200** - Success
- **400** - Bad Request (validation error)
- **404** - Not Found (no state exists)
- **500** - Internal Server Error

All errors include a structured error response:
```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE"
  }
}
```

## Data Retention

Physical state records are automatically deleted after 90 days using DynamoDB TTL.
