#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { FittieStack } from '../lib/fittie-stack';
import { AuthStack } from '../lib/auth-stack';
import { DataStack } from '../lib/data-stack';
import { StorageStack } from '../lib/storage-stack';
import { ComputeStack } from '../lib/compute-stack';
import { FrontendStack } from '../lib/frontend-stack';

const app = new cdk.App();

const env = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: process.env.CDK_DEFAULT_REGION || 'us-east-1',
};

// Authentication Stack
const authStack = new AuthStack(app, 'FittieAuthStack', {
  env,
  description: 'Fittie Authentication - Cognito User Pool',
});

// Data Stack
const dataStack = new DataStack(app, 'FittieDataStack', {
  env,
  description: 'Fittie Data Layer - DynamoDB Tables',
});

// Storage Stack
const storageStack = new StorageStack(app, 'FittieStorageStack', {
  env,
  description: 'Fittie Storage - S3 Buckets',
});

// Compute Stack
const computeStack = new ComputeStack(app, 'FittieComputeStack', {
  env,
  description: 'Fittie Compute - Lambda Functions',
  stateTableName: dataStack.physicalStateTable.tableName,
  historyTableName: dataStack.workoutHistoryTable.tableName,
  exerciseTableName: dataStack.exerciseKnowledgeBaseTable.tableName,
  userPoolId: authStack.userPool.userPoolId,
  userPoolClientId: authStack.userPoolClient.userPoolClientId,
});

// Add dependencies
computeStack.addDependency(dataStack);
computeStack.addDependency(authStack);

// Frontend Stack
const frontendStack = new FrontendStack(app, 'FittieFrontendStack', {
  env,
  description: 'Fittie Frontend - CloudFront Distribution',
});

// Main Stack (legacy, can be removed later)
new FittieStack(app, 'FittieStack', {
  env,
  description: 'Fittie - AI-powered fitness coaching system',
});

app.synth();
