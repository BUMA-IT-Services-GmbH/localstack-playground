#!/usr/bin/env node
import { App } from "aws-cdk-lib";
import { CdkLambdaUuidDemoStack } from "../lib/cdk-lambda-uuid-demo-stack";

const app = new App();
new CdkLambdaUuidDemoStack(app, "CdkLambdaUuidDemoStack");
