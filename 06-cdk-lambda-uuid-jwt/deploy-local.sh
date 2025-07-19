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
  echo "  --curl             Choose (yes/no) whether or not curl should be used to call the endpoint of the ApiGW - requires curl and jq to be installed"
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

# Collect and handle API Gateway endpoints
endpoints_keys=()
endpoints_values=()

for stack in "${SELECTED_STACKS[@]}"; do
  raw=$(aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
    --stack-name "$stack" \
    --query "Stacks[0].Outputs[?contains(OutputKey, 'ApiEndpoint') || contains(OutputKey, 'Endpoint') || contains(OutputKey, 'Url')].OutputValue" \
    --output text 2>/dev/null || true)
  if [[ -n "$raw" && "$raw" != "None" ]]; then
    endpoints_keys+=("$stack")
    endpoints_values+=("$raw")
  fi
done

if [[ ${#endpoints_keys[@]} -eq 0 ]]; then
  echo -e "${COLOR_YELLOW}⚠️  No API Gateway endpoints found.${COLOR_RESET}"
else
  echo -e "${COLOR_GREEN}🌐 Available API Endpoints:${COLOR_RESET}"
  i=1
  for ((j=0; j<${#endpoints_keys[@]}; j++)); do
    stack="${endpoints_keys[$j]}"
    endpoint="$(echo "${endpoints_values[$j]}" | head -n 1 | awk '{print $1}' | xargs)"
    echo -e "  [$i] ${COLOR_YELLOW}$stack${COLOR_RESET} → $endpoint"
    index_map[$i]=$j
    ((i++))
  done

  echo -e "  [$i] ${COLOR_YELLOW}All${COLOR_RESET} → All endpoints"
  all_option=$i

  echo -e "\n${COLOR_GREEN}🔢 Enter the number of the endpoint you want to open/curl (or press enter to skip):${COLOR_RESET}"
  read -r choice

  if [[ -n "$choice" && "$choice" =~ ^[0-9]+$ ]]; then
    if [[ "$choice" -eq "$all_option" ]]; then
      echo -e "${COLOR_GREEN}📦 Selected: All endpoints${COLOR_RESET}"
      for ((j=0; j<${#endpoints_keys[@]}; j++)); do
        endpoint="$(echo "${endpoints_values[$j]}" | head -n 1 | awk '{print $1}' | xargs)"
        echo -e "${COLOR_GREEN}🔗 Endpoint: ${COLOR_YELLOW}${endpoint}${COLOR_RESET}"
        if [[ "$use_curl" == "yes" ]]; then
          echo -e "${COLOR_GREEN}🔁 Testing via curl...${COLOR_RESET}"
          echo -e "${COLOR_GREEN}🔗 Fetching data from ${COLOR_YELLOW}${endpoint}${COLOR_YELLOW}${COLOR_RESET}..."
          sleep 1
          echo -e "${COLOR_GREEN}🔗 Response:${COLOR_RESET}"
          curl -sS "$endpoint" | jq . || echo -e "${COLOR_RED}❌ Failed to fetch: $endpoint${COLOR_RESET}"
        fi
        if [[ "$open_browser" == "yes" ]]; then
          echo -e "${COLOR_GREEN}🌐 Opening in browser...${COLOR_RESET}"
          open "$endpoint"
        fi
      done
    elif [[ -n "${index_map[$choice]}" ]]; then
      j="${index_map[$choice]}"
      stack="${endpoints_keys[$j]}"
      endpoint="$(echo "${endpoints_values[$j]}" | head -n 1 | awk '{print $1}' | xargs)"
      echo -e "${COLOR_GREEN}📦 Selected endpoint: ${COLOR_YELLOW}${endpoint}${COLOR_RESET}"

      if [[ "$use_curl" == "yes" ]]; then
        echo -e "${COLOR_GREEN}🔁 Testing via curl...${COLOR_RESET}"
        echo -e "${COLOR_GREEN}🔗 Fetching data from ${COLOR_YELLOW}${endpoint}${COLOR_RESET}..."
        sleep 1
        echo -e "${COLOR_GREEN}🔗 Response:${COLOR_RESET}"
        curl -sS "$endpoint" | jq . || echo -e "${COLOR_RED}❌ Failed to parse or fetch endpoint: $endpoint${COLOR_RESET}"
      fi

      if [[ "$open_browser" == "yes" ]]; then
        echo -e "${COLOR_GREEN}🌐 Opening in browser...${COLOR_RESET}"
        open "$endpoint"
      fi
    else
      echo -e "${COLOR_YELLOW}⚠️  Invalid selection. Skipping.${COLOR_RESET}"
    fi
  else
    echo -e "${COLOR_YELLOW}⚠️  No valid endpoint selected. Skipping.${COLOR_RESET}"
  fi
fi

echo -e "${COLOR_GREEN}✅ Deployment complete.${COLOR_RESET}"