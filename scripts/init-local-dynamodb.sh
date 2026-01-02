#!/bin/bash

# Initialize local DynamoDB tables
# Run this after starting docker-compose to create test tables

set -e

ENDPOINT="http://localhost:8000"
REGION="us-east-1"

echo "🚀 Initializing local DynamoDB tables..."
echo ""

# Wait for DynamoDB Local to be ready
echo "⏳ Waiting for DynamoDB Local to start..."
until curl -s "$ENDPOINT" > /dev/null 2>&1; do
  sleep 1
done
echo "✅ DynamoDB Local is ready"
echo ""

# Create user-physical-state table
echo "Creating user-physical-state table..."
aws dynamodb create-table \
  --table-name user-physical-state \
  --attribute-definitions \
    AttributeName=userId,AttributeType=S \
    AttributeName=timestamp,AttributeType=N \
  --key-schema \
    AttributeName=userId,KeyType=HASH \
    AttributeName=timestamp,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST \
  --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES \
  --endpoint-url "$ENDPOINT" \
  --region "$REGION" \
  > /dev/null

echo "✅ user-physical-state table created"

# Create workout-history table
echo "Creating workout-history table..."
aws dynamodb create-table \
  --table-name workout-history \
  --attribute-definitions \
    AttributeName=userId,AttributeType=S \
    AttributeName=workoutId,AttributeType=S \
    AttributeName=timestamp,AttributeType=N \
  --key-schema \
    AttributeName=userId,KeyType=HASH \
    AttributeName=workoutId,KeyType=RANGE \
  --global-secondary-indexes \
    "IndexName=timestamp-index,KeySchema=[{AttributeName=userId,KeyType=HASH},{AttributeName=timestamp,KeyType=RANGE}],Projection={ProjectionType=ALL}" \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url "$ENDPOINT" \
  --region "$REGION" \
  > /dev/null

echo "✅ workout-history table created"

# Create exercise-knowledge-base table
echo "Creating exercise-knowledge-base table..."
aws dynamodb create-table \
  --table-name exercise-knowledge-base \
  --attribute-definitions \
    AttributeName=exerciseId,AttributeType=S \
  --key-schema \
    AttributeName=exerciseId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url "$ENDPOINT" \
  --region "$REGION" \
  > /dev/null

echo "✅ exercise-knowledge-base table created"

echo ""
echo "🎉 All tables created successfully!"
echo ""
echo "📊 DynamoDB Admin UI: http://localhost:8001"
echo ""

# Insert sample data
echo "💾 Inserting sample data..."
echo ""

# Sample physical state
aws dynamodb put-item \
  --table-name user-physical-state \
  --item '{
    "userId": {"S": "test-user-123"},
    "timestamp": {"N": "1735822800"},
    "painPoints": {"L": [{"S": "lower_back"}]},
    "energyLevel": {"N": "3"},
    "equipment": {"L": [{"S": "dumbbells"}]},
    "location": {"S": "gym"},
    "activityMode": {"S": "active"},
    "sourceEvent": {"S": "manual"}
  }' \
  --endpoint-url "$ENDPOINT" \
  --region "$REGION" \
  > /dev/null

echo "✅ Sample physical state inserted"

# Sample exercise
aws dynamodb put-item \
  --table-name exercise-knowledge-base \
  --item '{
    "exerciseId": {"S": "ex-001"},
    "name": {"S": "Push-ups"},
    "description": {"S": "Classic bodyweight chest exercise"},
    "primaryMuscles": {"L": [{"S": "chest"}, {"S": "triceps"}]},
    "equipment": {"L": []},
    "difficulty": {"S": "beginner"},
    "contraindications": {"L": [{"S": "shoulder_pain"}, {"S": "wrist_pain"}]}
  }' \
  --endpoint-url "$ENDPOINT" \
  --region "$REGION" \
  > /dev/null

echo "✅ Sample exercise inserted"

echo ""
echo "✅ Sample data inserted successfully!"
echo ""
echo "🔗 Quick links:"
echo "   - Admin UI: http://localhost:8001"
echo "   - Endpoint: http://localhost:8000"
echo ""
echo "📝 Test query:"
echo "   aws dynamodb scan --table-name user-physical-state --endpoint-url http://localhost:8000"
