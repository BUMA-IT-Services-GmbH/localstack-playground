#!/usr/bin/env node
import { App } from "aws-cdk-lib";
import { CdkLambdaUuidDemoStack } from "../lib/cdk-lambda-uuid-demo-stack";
import { HelloWorldStack } from "../lib/hello-world-stack";

const app = new App();
new CdkLambdaUuidDemoStack(app, "CdkLambdaUuidDemoStack");
new HelloWorldStack(app, "HelloWorldStack");
