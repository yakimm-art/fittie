import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';

export class StorageStack extends cdk.Stack {
  public readonly pwaBucket: s3.Bucket;
  public readonly mediaBucket: s3.Bucket;

  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // 1. PWA Bucket (Website Hosting)
    this.pwaBucket = new s3.Bucket(this, 'FittiePWA', {
      bucketName: `fittie-pwa-${this.account}`,
      websiteIndexDocument: 'index.html',
      websiteErrorDocument: 'index.html', // For SPA routing
      publicReadAccess: true,
      blockPublicAccess: new s3.BlockPublicAccess({
        blockPublicAcls: false,
        blockPublicPolicy: false,
        ignorePublicAcls: false,
        restrictPublicBuckets: false,
      }),
      versioned: true,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
      autoDeleteObjects: false,
      cors: [
        {
          allowedMethods: [
            s3.HttpMethods.GET,
            s3.HttpMethods.HEAD,
          ],
          allowedOrigins: ['*'],
          allowedHeaders: ['*'],
          maxAge: 3600,
        },
      ],
    });

    // 2. Media Bucket (Assets)
    this.mediaBucket = new s3.Bucket(this, 'FittieMedia', {
      bucketName: `fittie-media-${this.account}`,
      publicReadAccess: true,
      blockPublicAccess: new s3.BlockPublicAccess({
        blockPublicAcls: false,
        blockPublicPolicy: false,
        ignorePublicAcls: false,
        restrictPublicBuckets: false,
      }),
      versioned: false,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
      autoDeleteObjects: false,
      cors: [
        {
          allowedMethods: [
            s3.HttpMethods.GET,
            s3.HttpMethods.HEAD,
          ],
          allowedOrigins: ['*'],
          allowedHeaders: ['*'],
          maxAge: 86400, // 24 hours
        },
      ],
      lifecycleRules: [
        {
          id: 'DeleteOldVersions',
          enabled: true,
          noncurrentVersionExpiration: cdk.Duration.days(90),
        },
      ],
    });

    // CloudFormation Outputs
    new cdk.CfnOutput(this, 'PWABucketName', {
      value: this.pwaBucket.bucketName,
      description: 'PWA Hosting Bucket Name',
      exportName: 'FittiePWABucketName',
    });

    new cdk.CfnOutput(this, 'PWABucketArn', {
      value: this.pwaBucket.bucketArn,
      description: 'PWA Hosting Bucket ARN',
      exportName: 'FittiePWABucketArn',
    });

    new cdk.CfnOutput(this, 'PWAWebsiteURL', {
      value: this.pwaBucket.bucketWebsiteUrl,
      description: 'PWA Website URL',
      exportName: 'FittiePWAWebsiteURL',
    });

    new cdk.CfnOutput(this, 'MediaBucketName', {
      value: this.mediaBucket.bucketName,
      description: 'Media Assets Bucket Name',
      exportName: 'FittieMediaBucketName',
    });

    new cdk.CfnOutput(this, 'MediaBucketArn', {
      value: this.mediaBucket.bucketArn,
      description: 'Media Assets Bucket ARN',
      exportName: 'FittieMediaBucketArn',
    });
  }
}
