#!/bin/bash

set -euo pipefail

COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[0;31m"
COLOR_RESET="\033[0m"

print_help() {
  echo -e "\n${COLOR_GREEN}🧹 Usage: ./deploy-local.sh [options]${COLOR_RESET}"
  echo ""
  echo "Options:"
  echo "  --openBrowser      Choose (yes/no) whether or not your default browser shall be opened and the endpoint of the ApiGW shall be called"
  echo "  --curl             Choose (yes/no) whether or not curl should be used to call the endpoint of the ApiGW - rquires curl and jq to be installed"
  echo "  --help             Show this help message"
  echo ""
}

# Default options
open_browser="yes"
use_curl="yes"

# Parse arguments
for arg in "$@"; do
  case $arg in
    --openBrowser=*)
      open_browser="${arg#*=}"
      ;;
    --curl=*)
      use_curl="${arg#*=}"
      ;;
    --help)
      print_help
      exit 0
      ;;
    *)
      echo -e "${COLOR_RED}❌ Unknown option: $arg${COLOR_RESET}"
      exit 1
      ;;
  esac
done

# Optional: load environment variables
if [ -f ".env.localstack" ]; then
  echo -e "${COLOR_GREEN}📄 Loading environment from .env.localstack...${COLOR_RESET}"
  source .env.localstack
fi

# Bootstrap environment
echo -e "${COLOR_GREEN}🔧 Bootstrapping LocalStack environment...${COLOR_RESET}"
npx cdklocal bootstrap --require-approval never

# List available stacks from CDK app
echo -e "${COLOR_GREEN}📋 Listing available stacks in the CDK app...${COLOR_RESET}"
STACKS_RAW=$(npx cdklocal list)
STACKS=($(echo "$STACKS_RAW"))

if [[ ${#STACKS[@]} -eq 0 ]]; then
  echo -e "${COLOR_YELLOW}⚠️  No stacks defined in your CDK app.${COLOR_RESET}"
  exit 1
fi

# Stack selection
if command -v fzf &> /dev/null; then
  echo -e "${COLOR_GREEN}🔽 Select stacks to deploy (use tab to select, enter to confirm):${COLOR_RESET}"
  SELECTED_STACKS=($(echo "${STACKS[@]}" | tr ' ' '\n' | fzf -m --prompt="Select stacks to deploy: "))
else
  echo -e "${COLOR_YELLOW}⚠️  fzf not found. Deploying all stacks.${COLOR_RESET}"
  SELECTED_STACKS=("${STACKS[@]}")
fi

if [[ ${#SELECTED_STACKS[@]} -eq 0 ]]; then
  echo -e "${COLOR_YELLOW}⚠️  No stacks selected. Aborting.${COLOR_RESET}"
  exit 0
fi

# Deploy selected stacks
for stack in "${SELECTED_STACKS[@]}"; do
  echo -e "${COLOR_GREEN}🚀 Deploying stack: $stack${COLOR_RESET}"
  npx cdklocal deploy "$stack" --require-approval never
done

# Try to detect API Gateway endpoint from outputs
for stack in "${SELECTED_STACKS[@]}"; do
  endpoint=$(aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
    --stack-name "$stack" \
    --query "Stacks[0].Outputs[?OutputKey=='ApiEndpoint'].OutputValue" \
    --output text 2>/dev/null || true)

  if [[ -n "$endpoint" && "$endpoint" != "None" ]]; then
    echo -e "${COLOR_GREEN}📦 API Endpoint for $stack: $endpoint${COLOR_RESET}"

    if [[ "$open_browser" == "yes" ]]; then
      echo -e "${COLOR_GREEN}🌐 Opening in browser...${COLOR_RESET}"
      open "$endpoint"  # macOS only
    fi

    if [[ "$use_curl" == "yes" ]]; then
      echo -e "${COLOR_GREEN}🔁 Testing via curl...${COLOR_RESET}"
      curl -s "$endpoint" | jq
    fi
  fi
done

echo -e "${COLOR_GREEN}✅ Deployment complete.${COLOR_RESET}"