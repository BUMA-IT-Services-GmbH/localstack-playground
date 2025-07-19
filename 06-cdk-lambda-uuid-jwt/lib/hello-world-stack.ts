import { CfnOutput, Stack, StackProps } from "aws-cdk-lib";
import { Construct } from "constructs";
import * as path from "path";
import { NodejsFunction } from "aws-cdk-lib/aws-lambda-nodejs";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as apigateway from "aws-cdk-lib/aws-apigateway";

export class HelloWorldStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    const lambdaFn = new NodejsFunction(this, "HelloWorldLambda", {
      runtime: lambda.Runtime.NODEJS_20_X,
      entry: path.join(__dirname, "../lambda/src/hello.ts"),
      handler: "handler",
      bundling: {
        forceDockerBundling: true,
      },
    });

    const apigw = new apigateway.LambdaRestApi(this, "HelloWorldApi", {
      handler: lambdaFn,
      proxy: true,
    });

    new CfnOutput(this, "HelloWorldApiEndpoint", {
      value: apigw.url,
    });
  }
}
