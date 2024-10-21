import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';

export class LambdaStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Define the Lambda function
    const lambdaFunction = new lambda.Function(this, 'MyFirstLambdaFunction', {
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset('lambda'),
    });

    // Output the Lambda function name
    new cdk.CfnOutput(this, 'LambdaFunctionNameOutput', {
      value: lambdaFunction.functionName,
      description: 'The name of the Lambda function',
    });

    // Output the Lambda function ARN
    new cdk.CfnOutput(this, 'LambdaFunctionArnOutput', {
      value: lambdaFunction.functionArn,
      description: 'The ARN of the Lambda function',
    });
  }
}
