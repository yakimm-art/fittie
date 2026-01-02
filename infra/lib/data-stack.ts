import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';

export class DataStack extends cdk.Stack {
  public readonly physicalStateTable: dynamodb.Table;
  public readonly workoutHistoryTable: dynamodb.Table;
  public readonly exerciseKnowledgeBaseTable: dynamodb.Table;

  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // 1. User Physical State Table
    this.physicalStateTable = new dynamodb.Table(this, 'PhysicalStateTable', {
      tableName: 'user-physical-state',
      partitionKey: { name: 'userId', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'timestamp', type: dynamodb.AttributeType.NUMBER },
      stream: dynamodb.StreamViewType.NEW_AND_OLD_IMAGES,
      timeToLiveAttribute: 'ttl',
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
      pointInTimeRecovery: true,
    });

    // 2. Workout History Table
    this.workoutHistoryTable = new dynamodb.Table(this, 'WorkoutHistoryTable', {
      tableName: 'workout-history',
      partitionKey: { name: 'userId', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'workoutId', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
      pointInTimeRecovery: true,
    });

    // Add GSI for chronological queries
    this.workoutHistoryTable.addGlobalSecondaryIndex({
      indexName: 'timestamp-index',
      partitionKey: { name: 'userId', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'timestamp', type: dynamodb.AttributeType.NUMBER },
      projectionType: dynamodb.ProjectionType.ALL,
    });

    // 3. Exercise Knowledge Base Table
    this.exerciseKnowledgeBaseTable = new dynamodb.Table(this, 'ExerciseKnowledgeBaseTable', {
      tableName: 'exercise-knowledge-base',
      partitionKey: { name: 'exerciseId', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
      pointInTimeRecovery: true,
    });

    // CloudFormation Outputs
    new cdk.CfnOutput(this, 'PhysicalStateTableName', {
      value: this.physicalStateTable.tableName,
      description: 'User Physical State Table Name',
      exportName: 'FittiePhysicalStateTableName',
    });

    new cdk.CfnOutput(this, 'PhysicalStateTableArn', {
      value: this.physicalStateTable.tableArn,
      description: 'User Physical State Table ARN',
      exportName: 'FittiePhysicalStateTableArn',
    });

    new cdk.CfnOutput(this, 'PhysicalStateTableStreamArn', {
      value: this.physicalStateTable.tableStreamArn || 'N/A',
      description: 'User Physical State Table Stream ARN',
      exportName: 'FittiePhysicalStateTableStreamArn',
    });

    new cdk.CfnOutput(this, 'WorkoutHistoryTableName', {
      value: this.workoutHistoryTable.tableName,
      description: 'Workout History Table Name',
      exportName: 'FittieWorkoutHistoryTableName',
    });

    new cdk.CfnOutput(this, 'WorkoutHistoryTableArn', {
      value: this.workoutHistoryTable.tableArn,
      description: 'Workout History Table ARN',
      exportName: 'FittieWorkoutHistoryTableArn',
    });

    new cdk.CfnOutput(this, 'ExerciseKnowledgeBaseTableName', {
      value: this.exerciseKnowledgeBaseTable.tableName,
      description: 'Exercise Knowledge Base Table Name',
      exportName: 'FittieExerciseKnowledgeBaseTableName',
    });

    new cdk.CfnOutput(this, 'ExerciseKnowledgeBaseTableArn', {
      value: this.exerciseKnowledgeBaseTable.tableArn,
      description: 'Exercise Knowledge Base Table ARN',
      exportName: 'FittieExerciseKnowledgeBaseTableArn',
    });
  }
}
