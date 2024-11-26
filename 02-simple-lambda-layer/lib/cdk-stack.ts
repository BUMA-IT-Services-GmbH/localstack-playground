import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as path from 'path';

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    // Lambda Layer
    const tokenValidationLayer = new lambda.LayerVersion(this, 'TokenValidationLayer', {
      code: lambda.Code.fromAsset(path.join(__dirname, '../lambda/layers/auth')),
      compatibleRuntimes: [lambda.Runtime.NODEJS_20_X],
      description: 'A layer for token validation',
    });

    // User Register Lambda
    const userRegisterFunction = new lambda.Function(this, 'UserRegisterFunction', {
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset(path.join(__dirname, '../lambda/functions/user-register')),
    });

    // User Login Lambda
    const userLoginFunction = new lambda.Function(this, 'UserLoginFunction', {
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset(path.join(__dirname, '../lambda/functions/user-login')),
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
