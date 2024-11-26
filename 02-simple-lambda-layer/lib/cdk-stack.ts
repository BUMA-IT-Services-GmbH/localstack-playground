import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import { NodejsFunction } from 'aws-cdk-lib/aws-lambda-nodejs';

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    // Lambda Layer
    const tokenValidationLayer = new lambda.LayerVersion(this, 'TokenValidationLayer', {
      code: lambda.Code.fromAsset('./lambda/layers/auth/nodejs'),
      compatibleRuntimes: [lambda.Runtime.NODEJS_20_X],
      description: 'A layer for token validation',
      layerVersionName: 'TokenValidationLayer',
    });

    // User Register Lambda
    const userRegisterFunction = new NodejsFunction(this, 'UserRegisterFunction', {
      entry: 'lambda/functions/user-register/index.ts',
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
    });

    // User Login Lambda
    const userLoginFunction = new NodejsFunction(this, 'UserLoginFunction', {
      entry: 'lambda/functions/user-login/index.ts',
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      layers: [tokenValidationLayer],
    });

    // output the Lambda function names
    new cdk.CfnOutput(this, 'UserRegisterFunctionNameOutput', {
      value: userRegisterFunction.functionName,
      description: 'The name of the User Register Lambda function',
    });
    new cdk.CfnOutput(this, 'UserLoginFunctionNameOutput', {
      value: userLoginFunction.functionName,
      description: 'The name of the User Register Lambda function',
    });    
  }
}
