#!/bin/bash

set -euo pipefail
export AWS_PAGER=""

# Colors
COLOR_GREEN=$'\033[0;32m'
COLOR_YELLOW=$'\033[1;33m'
COLOR_RED=$'\033[0;31m'
COLOR_BLUE=$'\033[1;34m'
COLOR_RESET=$'\033[0m'

echo -e "${COLOR_GREEN}📡 Fetching Lambda functions from LocalStack...${COLOR_RESET}"
functions=$(awslocal lambda list-functions --query "Functions[].FunctionName" --output text)

if [ -z "$functions" ]; then
  echo -e "${COLOR_YELLOW}⚠️  No Lambda functions found.${COLOR_RESET}"
  exit 0
fi

IFS=$'\t' read -r -a function_names <<< "$functions"

if command -v fzf &> /dev/null; then
  echo -e "${COLOR_GREEN}🔍 Select a Lambda function:${COLOR_RESET}"
  selected_function=$(printf "%s\n" "${function_names[@]}" | fzf --prompt="Select Lambda: ")
else
  selected_function="${function_names[0]}"
  echo -e "${COLOR_YELLOW}⚠️  fzf not found, defaulting to first function: $selected_function${COLOR_RESET}"
fi

log_group="/aws/lambda/$selected_function"

log_stream=$(awslocal logs describe-log-streams \
  --log-group-name "$log_group" \
  --order-by "LastEventTime" \
  --descending \
  --limit 1 \
  --query "logStreams[0].logStreamName" \
  --output text)

if [ "$log_stream" == "None" ]; then
  echo -e "${COLOR_YELLOW}⚠️  No logs found for function: $selected_function${COLOR_RESET}"
  exit 0
fi

echo -e "${COLOR_GREEN}📄 Fetching logs from:${COLOR_RESET}"
echo -e "   Log Group: ${COLOR_YELLOW}$log_group${COLOR_RESET}"
echo -e "   Stream:    ${COLOR_YELLOW}$log_stream${COLOR_RESET}"
echo
echo -e "${COLOR_GREEN}🧾 Log Output:${COLOR_RESET}"

messages=$(awslocal logs get-log-events \
  --log-group-name "$log_group" \
  --log-stream-name "$log_stream" \
  --query "events[].message" \
  --output json)

if command -v jq &> /dev/null; then
  jq -r '.[]' <<< "$messages" | while IFS= read -r line; do
    # Highlight UUIDs
    line=$(echo "$line" | sed -E "s/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/${COLOR_YELLOW}\1${COLOR_RESET}/g")

    # Color-code log levels with emoji + label
    line=$(echo "$line" | sed -E \
      -e "s/INFO/${COLOR_BLUE}📘 INFO:${COLOR_RESET}/g" \
      -e "s/WARN/${COLOR_YELLOW}⚠️ WARN:${COLOR_RESET}/g" \
      -e "s/ERROR/${COLOR_RED}❗ ERROR:${COLOR_RESET}/g")

    printf "%b\n" "$line"
  done
else
  echo "$messages" | sed 's/^"//;s/"$//;s/","/\n/g'
fi