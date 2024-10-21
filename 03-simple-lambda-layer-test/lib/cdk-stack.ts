import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import { NodejsFunction } from 'aws-cdk-lib/aws-lambda-nodejs';
import * as path from 'path';

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Lambda Layer
    const tokenValidationLayer = new lambda.LayerVersion(this, 'TokenValidationLayer', {
      code: lambda.Code.fromAsset("./lambda/layers/auth"),
      compatibleRuntimes: [lambda.Runtime.NODEJS_20_X],
      description: 'A layer for token validation',
      layerVersionName: 'TokenValidationLayer',
    });

    // Create Employee Lambda
    const userLoginFunction = new NodejsFunction(this, 'UserLoginFunction', {
      entry: "lambda/functions/user-login.ts",
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: "handler",
      layers: [tokenValidationLayer],
    });

    // output the Lambda function names
    new cdk.CfnOutput(this, 'UserLoginFunctionNameOutput', {
      value: userLoginFunction.functionName,
      description: 'The name of the User Login Lambda function',
    });
  }
}
