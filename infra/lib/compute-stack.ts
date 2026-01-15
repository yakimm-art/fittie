import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as events from 'aws-cdk-lib/aws-events';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as eventsources from 'aws-cdk-lib/aws-lambda-event-sources';
import * as path from 'path';

interface ComputeStackProps extends cdk.StackProps {
  stateTableName: string;
  stateTableArn: string;
  stateTableStreamArn: string;
  historyTableName: string;
  exerciseTableName: string;
  userPoolId: string;
  userPoolClientId: string;
}

export class ComputeStack extends cdk.Stack {
  public readonly api: apigateway.RestApi;

  constructor(scope: Construct, id: string, props: ComputeStackProps) {
    super(scope, id, props);

    // Physical State Manager Lambda Function
    const physicalStateFunction = new lambda.Function(this, 'PhysicalStateFunction', {
      functionName: 'fittie-physical-state-manager',
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset(path.join(__dirname, '../../backend/functions/physical-state-manager'), {
        bundling: {
          local: {
            tryBundle(outputDir: string) {
              const execSync = require('child_process').execSync;
              const funcDir = path.join(__dirname, '../../backend/functions/physical-state-manager');
              execSync(`cp -r ${funcDir}/dist/* ${outputDir}/`);
              execSync(`cp -r ${funcDir}/node_modules ${outputDir}/`);
              return true;
            },
          },
          image: lambda.Runtime.NODEJS_20_X.bundlingImage,
          command: [
            'bash', '-c',
            'npm install && npm run build && cp -r dist/* /asset-output/ && cp -r node_modules /asset-output/'
          ],
        },
      }),
      environment: {
        DYNAMODB_STATE_TABLE: props.stateTableName,
      },
      timeout: cdk.Duration.seconds(30),
      memorySize: 512,
    });

    // Grant DynamoDB permissions
    physicalStateFunction.addToRolePolicy(new iam.PolicyStatement({
      actions: [
        'dynamodb:PutItem',
        'dynamodb:GetItem',
        'dynamodb:Query',
        'dynamodb:Scan',
      ],
      resources: [
        `arn:aws:dynamodb:${this.region}:${this.account}:table/${props.stateTableName}`,
      ],
    }));

    // Create API Gateway
    this.api = new apigateway.RestApi(this, 'FittieApi', {
      restApiName: 'Fittie API',
      description: 'API for Fittie fitness coaching application',
      defaultCorsPreflightOptions: {
        allowOrigins: apigateway.Cors.ALL_ORIGINS,
        allowMethods: apigateway.Cors.ALL_METHODS,
        allowHeaders: ['Content-Type', 'Authorization', 'x-user-id'],
      },
      deployOptions: {
        stageName: 'prod',
        loggingLevel: apigateway.MethodLoggingLevel.INFO,
        dataTraceEnabled: true,
      },
    });

    // Create /state resource
    const stateResource = this.api.root.addResource('state');

    // POST /state - Update physical state
    stateResource.addMethod('POST', new apigateway.LambdaIntegration(physicalStateFunction));

    // GET /state/latest - Get latest state
    const latestResource = stateResource.addResource('latest');
    latestResource.addMethod('GET', new apigateway.LambdaIntegration(physicalStateFunction));

    // GET /state/history - Get state history
    const historyResource = stateResource.addResource('history');
    historyResource.addMethod('GET', new apigateway.LambdaIntegration(physicalStateFunction));

    // Output API URL
    new cdk.CfnOutput(this, 'ApiUrl', {
      value: this.api.url,
      description: 'API Gateway endpoint URL',
      exportName: 'FittieApiUrl',
    });

    new cdk.CfnOutput(this, 'PhysicalStateFunctionArn', {
      value: physicalStateFunction.functionArn,
      description: 'Physical State Manager Lambda ARN',
    });

    // EventBridge Event Bus for Fittie events
    const eventBus = new events.EventBus(this, 'FittieEventBus', {
      eventBusName: 'fittie-events',
    });

    // On-State-Change Lambda - processes DynamoDB stream events
    const onStateChangeFunction = new lambda.Function(this, 'OnStateChangeFunction', {
      functionName: 'fittie-on-state-change',
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset(path.join(__dirname, '../../backend/functions/on-state-change'), {
        bundling: {
          local: {
            tryBundle(outputDir: string) {
              const execSync = require('child_process').execSync;
              const funcDir = path.join(__dirname, '../../backend/functions/on-state-change');
              execSync(`cp -r ${funcDir}/dist/* ${outputDir}/`);
              execSync(`cp -r ${funcDir}/node_modules ${outputDir}/`);
              return true;
            },
          },
          image: lambda.Runtime.NODEJS_20_X.bundlingImage,
          command: [
            'bash', '-c',
            'npm install && npm run build && cp -r dist/* /asset-output/ && cp -r node_modules /asset-output/'
          ],
        },
      }),
      environment: {
        EVENT_BUS_NAME: eventBus.eventBusName,
      },
      timeout: cdk.Duration.seconds(30),
      memorySize: 256,
    });

    // Grant EventBridge permissions
    eventBus.grantPutEventsTo(onStateChangeFunction);

    // Import the DynamoDB table to add stream trigger
    const stateTable = dynamodb.Table.fromTableAttributes(this, 'ImportedStateTable', {
      tableArn: props.stateTableArn,
      tableStreamArn: props.stateTableStreamArn,
    });

    // Grant stream read permissions
    stateTable.grantStreamRead(onStateChangeFunction);

    // Add DynamoDB Stream as event source
    onStateChangeFunction.addEventSource(
      new eventsources.DynamoEventSource(stateTable, {
        startingPosition: lambda.StartingPosition.LATEST,
        batchSize: 10,
        retryAttempts: 3,
      })
    );

    new cdk.CfnOutput(this, 'OnStateChangeFunctionArn', {
      value: onStateChangeFunction.functionArn,
      description: 'On-State-Change Lambda ARN',
    });

    new cdk.CfnOutput(this, 'EventBusArn', {
      value: eventBus.eventBusArn,
      description: 'Fittie EventBridge Bus ARN',
      exportName: 'FittieEventBusArn',
    });
  }
}
