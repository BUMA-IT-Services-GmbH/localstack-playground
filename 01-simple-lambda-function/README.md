# Welcome to 01-simple-lambda-function

This is a simple lambda function that returns a message and is deployed to localstack via CDKLOCAL.

# Prerequisites

## Prepare localstack
- export LOCALSTACK_AUTH_TOKEN
- set AWS credentials for localstack
    - run `aws configure` and set the following:
        - AWS Access Key ID: `test`
        - AWS Secret Access Key: `test`
        - AWS Default region name: `us-east-1`
    - run `export AWS_REGION="us-east-1"`
    - run `export AWS_PROFILE="localstack"`
## Start localstack
- run `docker-compose up` to start localstack
## Compile lambda function
- run `npm run build` to compile the lambda function

## Prepare CDKLOCAL
- run `cdklocal bootstrap aws://000000000000/us-east-1 --profile localstack` to bootstrap CDKLOCAL and point to localstack

# Deploy lambda function to localstack with CDKLOCAL
- run `cdklocal deploy --all --context "localstack.host=localhost" --context "localstack.port=4566" --profile localstack` to deploy the lambda function to localstack with CDKLOCAL

# Test lambda function when deployed to localstack

## Copy the name of the lambda function from the deploy command's output

## Invoke the lambda function
- run `aws lambda invoke --function-name <lambda-function-name> --payload '{}' --endpoint-url=http://localhost:4566 output.json --log-type None && cat output.json | jq -r '.body | fromjson'` to invoke the lambda function