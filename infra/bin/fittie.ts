#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { FittieStack } from '../lib/fittie-stack';

const app = new cdk.App();

new FittieStack(app, 'FittieStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION || 'us-east-1',
  },
  description: 'Fittie - AI-powered fitness coaching system',
});

app.synth();
