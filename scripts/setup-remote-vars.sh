#!/bin/bash

# Script to extract all Terraform/OpenTofu outputs and set them as environment variables
# with TFoutputs_ prefix. This script should be sourced, not executed.
#
# Usage: source scripts/setup-remote-vars.sh

set -euo pipefail

# Check if we're in the right directory (should have infrastructure/terraform)
if [[ ! -d "infrastructure/terraform" ]]; then
    echo "Error: infrastructure/terraform directory not found. Please run from project root." >&2
    return 1
fi

# Check if required tools are available
if ! command -v tofu &> /dev/null; then
    echo "Error: tofu command not found. Please install OpenTofu." >&2
    return 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq command not found. Please install jq." >&2
    return 1
fi

# Store current directory to return to later
original_dir=$(pwd)
cd infrastructure/terraform

# Get outputs in JSON format with better error handling
echo "Extracting Terraform outputs..."
if ! outputs_json=$(tofu output -json 2>/dev/null); then
    echo "Error: Failed to get tofu outputs. Make sure you're in a valid terraform workspace." >&2
    cd "$original_dir"
    return 1
fi

# Check if outputs exist and are valid JSON
if ! echo "$outputs_json" | jq empty 2>/dev/null; then
    echo "Error: Invalid JSON returned from tofu output." >&2
    cd "$original_dir"
    return 1
fi

# Check if we have any outputs
output_count=$(echo "$outputs_json" | jq 'length')
if [[ "$output_count" -eq 0 ]]; then
    echo "Warning: No terraform outputs found."
    cd "$original_dir"
    return 0
fi

echo "Found $output_count terraform output(s). Setting environment variables with TFoutputs_ prefix..."

# Parse JSON and set environment variables using jq's power
# Handle different value types (string, number, boolean, array, object)
while IFS=$'\t' read -r key value_type raw_value; do
    if [[ -n "$key" ]]; then
        # Convert key to uppercase and replace invalid characters for env var names
        clean_key=$(echo "$key" | tr '[:lower:]' '[:upper:]' | tr '-.' '_')
        
        # Handle different value types appropriately
        case "$value_type" in
            "string"|"number"|"boolean")
                # Simple values - use as-is
                clean_value="$raw_value"
                ;;
            "array"|"object")
                # Complex values - convert back to JSON string
                clean_value="$raw_value"
                ;;
            *)
                # Fallback - treat as string
                clean_value="$raw_value"
                ;;
        esac
        
        # Set the environment variable
        export TFoutputs_${clean_key}="$clean_value"
        
        # Show what we set (truncate very long values for readability)
        if [[ ${#clean_value} -gt 100 ]]; then
            echo "  TFoutputs_${clean_key}=${clean_value:0:97}..."
        else
            echo "  TFoutputs_${clean_key}=${clean_value}"
        fi
    fi
done < <(echo "$outputs_json" | jq -r 'to_entries[] | [.key, (.value.value | type), (.value.value | if type == "object" or type == "array" then tostring else . end)] | @tsv')

# Return to original directory
cd "$original_dir"

echo "Done! Environment variables have been set."
echo "To verify, you can run: env | grep '^TFoutputs_' | sort"
