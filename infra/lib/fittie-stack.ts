import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

export class FittieStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Stack will be populated with resources in subsequent tasks
    new cdk.CfnOutput(this, 'StackName', {
      value: this.stackName,
      description: 'Fittie Stack Name',
    });
  }
}
