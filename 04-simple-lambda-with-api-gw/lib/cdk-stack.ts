import * as cdk from 'aws-cdk-lib';
import { NodejsFunction } from 'aws-cdk-lib/aws-lambda-nodejs';
import { Construct } from 'constructs';

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create User Management Lambda Function
    const userLoginFunction = new NodejsFunction(this, 'UserManagementFunction', {
      entry: 'lambda/functions/user-management.ts',
      runtime: cdk.aws_lambda.Runtime.NODEJS_20_X,
      handler: 'handler',
    });

    // Output the Lambda function name
    new cdk.CfnOutput(this, 'UserManagementFunctionNameOutput', {
      value: userLoginFunction.functionName,
      description: 'The name of the User Management Lambda function',
    });

    // Create API Gateway
    const api = new cdk.aws_apigateway.RestApi(this, 'UserManagementAPI', {
      restApiName: 'User Management API',
    });

    // Create API Gateway resource
    const userManagementResource = api.root.addResource('user-management');

    // Create API Gateway method
    userManagementResource.addMethod('POST', new cdk.aws_apigateway.LambdaIntegration(userLoginFunction));

  }
}
