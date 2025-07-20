#!/bin/bash
HOST=$1
PORT=$2
# Send a request to fetch the available models and save the response to a file
result_model=$(curl -s http://"$1":"$2"/v1/models | tee test-two-pods-minimal-example.json)

# Check if the response is empty
if [[ -z "$result_model" ]]; then
    echo "Error: Failed to retrieve model list. Response is empty." >> $GITHUB_STEP_SUMMARY
    echo "Output: $result_model" >> $GITHUB_STEP_SUMMARY
    exit 1
fi

# Send a request to generate a text completion and save the response to a file
result_query=$(curl -s -X POST http://"$1":"$2"/v1/completions \
    -H "Content-Type: application/json" \
    -d '{"model": "facebook/opt-125m", "prompt": "Once upon a time,", "max_tokens": 10}' \
    | tee test-two-pods-minimal-example.json)

# Check if the response is empty
if [[ -z "$result_query" ]]; then
    echo "Error: Failed to retrieve query response. Response is empty." >> $GITHUB_STEP_SUMMARY
    echo "Output: $result_query" >> $GITHUB_STEP_SUMMARY
    exit 1
fi

echo "Success: Two Pods Minimal Example Requests were successful." >> $GITHUB_STEP_SUMMARY
echo "Output: $result_model" >> $GITHUB_STEP_SUMMARY
echo "Output: $result_query" >> $GITHUB_STEP_SUMMARY    