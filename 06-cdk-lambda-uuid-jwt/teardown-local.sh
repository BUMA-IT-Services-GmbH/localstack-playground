#!/bin/bash

set -euo pipefail

export AWS_PAGER=""

COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[0;31m"
COLOR_RESET="\033[0m"

PROTECTED_STACKS=("CDKToolkit")

print_help() {
  echo -e "\n${COLOR_GREEN}🧹 Usage: ./teardown-local.sh [options]${COLOR_RESET}"
  echo ""
  echo "Options:"
  echo "  --all              Destroy all deployed stacks (except CDKToolkit)"
  echo "  --nonInteractive   Run without prompting (for CI/CD, requires --all)"
  echo "  --help             Show this help message"
  echo ""
}

# Parse args
ALL=false
NON_INTERACTIVE=false
for arg in "$@"; do
  case $arg in
    --all)
      ALL=true
      ;;
    --nonInteractive)
      NON_INTERACTIVE=true
      ;;
    --help)
      print_help
      exit 0
      ;;
    *)
      echo -e "${COLOR_RED}❌ Unknown option: $arg${COLOR_RESET}"
      print_help
      exit 1
      ;;
  esac
done

ALL_STACKS=$(aws --endpoint-url=http://localhost:4566 cloudformation list-stacks \
  --query "StackSummaries[?StackStatus!='DELETE_COMPLETE'].StackName" \
  --output text || true)

if [ -z "$ALL_STACKS" ]; then
  echo -e "${COLOR_YELLOW}ℹ️  No active stacks found in LocalStack.${COLOR_RESET}"
  exit 0
fi

# Filter out protected stacks
STACKS=$(echo "$ALL_STACKS" | tr '\t' '\n' | grep -v -x -e "${PROTECTED_STACKS[@]}")

echo -e "${COLOR_GREEN}📦 Found stacks (excluding protected ones):${COLOR_RESET}"
echo "$STACKS"

# Decide which stacks to delete
if [ "$ALL" = true ]; then
  SELECTED_STACKS=($STACKS)
elif [ "$NON_INTERACTIVE" = true ]; then
  echo -e "${COLOR_RED}❌ Cannot use --nonInteractive without --all (no user selection possible)${COLOR_RESET}"
  exit 1
else
  echo -e "${COLOR_GREEN}🔽 Select stacks to destroy (use tab to select, enter to confirm):${COLOR_RESET}"
  SELECTED_STACKS=($(echo "$STACKS" | fzf -m --prompt="Select stacks to destroy: "))
fi

if [ ${#SELECTED_STACKS[@]} -eq 0 ]; then
  echo -e "${COLOR_YELLOW}⚠️  No stacks selected. Aborting.${COLOR_RESET}"
  exit 0
fi

for stack in "${SELECTED_STACKS[@]}"; do
  if [[ " ${PROTECTED_STACKS[*]} " == *" $stack "* ]]; then
    echo -e "${COLOR_YELLOW}⚠️  Skipping protected stack: $stack${COLOR_RESET}"
    continue
  fi
  echo -e "${COLOR_RED}🧨 Destroying stack: $stack${COLOR_RESET}"
  npx cdklocal destroy "$stack" --force
done

# Detect and clean up default CDK asset bucket
ASSET_BUCKET=$(aws --endpoint-url=http://localhost:4566 s3api list-buckets --query "Buckets[?starts_with(Name, 'cdk-hnb659fds-assets-')].Name | [0]" --output text 2>/dev/null || true)

if [ -n "$ASSET_BUCKET" ] && aws --endpoint-url=http://localhost:4566 s3api head-bucket --bucket "$ASSET_BUCKET" 2>/dev/null; then
  echo -e "${COLOR_RED}🗑 Cleaning up assets in bucket: $ASSET_BUCKET${COLOR_RESET}"
  VERSIONS=$(aws --endpoint-url=http://localhost:4566 s3api list-object-versions --bucket "$ASSET_BUCKET" \
    --query "Versions[].{Key:Key,VersionId:VersionId}" --output json)

  for row in $(echo "$VERSIONS" | jq -c '.[]'); do
    KEY=$(echo "$row" | jq -r '.Key')
    VERSION_ID=$(echo "$row" | jq -r '.VersionId')
    echo -e "   - Deleting ${COLOR_YELLOW}$KEY${COLOR_RESET} (version: ${COLOR_YELLOW}$VERSION_ID${COLOR_RESET})"
    aws --endpoint-url=http://localhost:4566 s3api delete-object \
      --bucket "$ASSET_BUCKET" \
      --key "$KEY" \
      --version-id "$VERSION_ID" >/dev/null
  done

  echo -e "${COLOR_GREEN}🧽 Bucket content deleted. Retaining bootstrap bucket: $ASSET_BUCKET${COLOR_RESET}"
else
  echo -e "${COLOR_GREEN}✅ No bootstrap bucket found. Skipping asset cleanup.${COLOR_RESET}"
fi

# Optional: clean up cdk.out folder
if [ -d "cdk.out" ]; then
  echo -e "${COLOR_GREEN}🧹 Removing CDK output directory...${COLOR_RESET}"
  rm -rf cdk.out
fi

echo -e "${COLOR_GREEN}✅ Teardown complete.${COLOR_RESET}"