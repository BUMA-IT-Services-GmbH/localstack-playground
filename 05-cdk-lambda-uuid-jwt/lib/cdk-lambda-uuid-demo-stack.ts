import { CfnOutput, Stack, StackProps } from "aws-cdk-lib";
import { Construct } from "constructs";
import * as path from "path";
import { NodejsFunction } from "aws-cdk-lib/aws-lambda-nodejs";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as apigateway from "aws-cdk-lib/aws-apigateway";

export class CdkLambdaUuidDemoStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    const lambdaFn = new NodejsFunction(this, "UuidJwtLambda", {
      runtime: lambda.Runtime.NODEJS_20_X,
      entry: path.join(__dirname, "../lambda/handler.ts"),
      handler: "handler",
      bundling: {
        externalModules: [], // bundle all node_modules including uuid/jsonwebtoken
        nodeModules: ["uuid", "jsonwebtoken"],
        forceDockerBundling: true, // Required for LocalStack + Mac (ARM) compatibility
      },
    });

    const apigw = new apigateway.LambdaRestApi(this, "UuidJwtApi", {
      handler: lambdaFn,
      proxy: true,
    });

    new CfnOutput(this, "ApiEndpoint", {
      value: apigw.url,
    });
  }
}
