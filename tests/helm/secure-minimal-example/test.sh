#!/bin/bash

# Retrieve host and port from script arguments
HOST=$1
PORT=$2
VLLM_API_KEY=abc123XYZ987  # API key for authentication

# Directory to store output
OUTPUT_DIR="test-secure-minimal-example"
[ ! -d "$OUTPUT_DIR" ] && mkdir "$OUTPUT_DIR"  # Create directory if it doesn't exist
chmod -R 777 "$OUTPUT_DIR"  # Ensure full read/write permissions

# Fetch the model list with authentication and save the response to a file
curl -s -H "Authorization: Bearer $VLLM_API_KEY" \
     "http://$HOST:$PORT/v1/models" | tee "$OUTPUT_DIR/models-secure-minimal-example.json"

# Run the text completion query with authentication and save the response to a file
curl -s -X POST -H "Authorization: Bearer $VLLM_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "facebook/opt-125m", "prompt": "Once upon a time,", "max_tokens": 10}' \
     "http://$HOST:$PORT/v1/completions" | tee "$OUTPUT_DIR/query-secure-minimal-example.json"

# Validate model response
if [[ ! -s "$OUTPUT_DIR/models-secure-minimal-example.json" ]]; then
    echo "Error: Model list request failed or returned an empty response." >> $GITHUB_STEP_SUMMARY
    echo "Output: $result_model" >> $GITHUB_STEP_SUMMARY
    exit 1
fi

# Validate query response
if [[ ! -s "$OUTPUT_DIR/query-secure-minimal-example.json" ]]; then
    echo "Error: Completion request failed or returned an empty response." >> $GITHUB_STEP_SUMMARY
    echo "Output: $result_query" >> $GITHUB_STEP_SUMMARY
    exit 1
fi

echo "Success: llvm secure minimal example requests completed successfully." >> $GITHUB_STEP_SUMMARY
echo "Output: $result_model" >> $GITHUB_STEP_SUMMARY
