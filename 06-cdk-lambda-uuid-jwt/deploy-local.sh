# #!/bin/bash

# set -e

# # Optional: load environment variables
# if [ -f ".env.localstack" ]; then
#   source .env.localstack
# fi

# # Run CDK bootstrap
# echo "🔧 Bootstrapping LocalStack environment..."
# npx cdklocal bootstrap --require-approval never

# # Run deploy using cdklocal
# echo "🛠 Deploying to LocalStack..."
# npx cdklocal deploy --require-approval never

# # Get API endpoint from stack output
# endpoint=$(aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
#   --stack-name CdkLambdaUuidDemoStack \
#   --query "Stacks[0].Outputs[?OutputKey=='ApiEndpoint'].OutputValue" \
#   --output text)

# # Check if endpoint is not empty
# if [[ -n "$endpoint" ]]; then
#   # Open the API Gateway endpoint in the browser
#   echo "🌐 Opening deployed API Gateway endpoint: $endpoint"
#   open "$endpoint"  # macOS only; use xdg-open on Linux
#   # Test the Lambda function via curl
#   echo "🔁 Testing Lambda via curl..."
#   curl -s "$endpoint" | jqelse
#   echo "❌ Could not find API endpoint in stack outputs."
# fi


#!/bin/bash

set -e

# Default options
open_browser="yes"
use_curl="yes"

# Parse arguments
for arg in "$@"; do
  case $arg in
    --openBrowser=*)
      open_browser="${arg#*=}"
      shift
      ;;
    --curl=*)
      use_curl="${arg#*=}"
      shift
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

# Optional: load environment variables
if [ -f ".env.localstack" ]; then
  source .env.localstack
fi

# Run CDK bootstrap
echo "🔧 Bootstrapping LocalStack environment..."
npx cdklocal bootstrap --require-approval never

# Run deploy using cdklocal
echo "🛠 Deploying to LocalStack..."
npx cdklocal deploy --require-approval never

# Get API endpoint from stack output
endpoint=$(aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
  --stack-name CdkLambdaUuidDemoStack \
  --query "Stacks[0].Outputs[?OutputKey=='ApiEndpoint'].OutputValue" \
  --output text)

# Check if endpoint is not empty
if [[ -n "$endpoint" ]]; then
  echo "📦 API Endpoint: $endpoint"

  if [[ "$open_browser" == "yes" ]]; then
    echo "🌐 Opening in browser..."
    open "$endpoint"  # macOS only; use xdg-open on Linux
  fi

  if [[ "$use_curl" == "yes" ]]; then
    echo "🔁 Testing via curl..."
    curl -s "$endpoint" | jq
  fi
else
  echo "❌ Could not find API endpoint in stack outputs."
fi