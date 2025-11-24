#!/usr/bin/env bash

# Script to configure kubectl using provided cluster information
# This script sets up local kubeconfig with the provided cluster details
# Usage: setup-kubectl.sh <cluster_id> <cluster_endpoint> <context_name> [copy_auth_from]
#
# Parameters:
#   cluster_id       - Unique identifier for the cluster
#   cluster_endpoint - The API server endpoint URL
#   context_name     - Name for the kubectl context
#   copy_auth_from   - (Optional) Existing context name to copy authentication from
#
# Authentication priority:
#   1. If copy_auth_from is provided, copy auth from existing context
#   2. Use KUBE_TOKEN environment variable
#   3. Use KUBE_CLIENT_CERT and KUBE_CLIENT_KEY environment variables

set -e

# Check required tools
if ! command -v kubectl >/dev/null 2>&1; then
    echo "❌ Error: kubectl is not installed or not in PATH"
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "❌ Error: jq is required for parsing kubeconfig but not found in PATH"
    echo "   Please install jq: https://stedolan.github.io/jq/download/"
    exit 1
fi

# Get arguments
CLUSTER_ID="$1"
CLUSTER_ENDPOINT="$2"
CONTEXT_NAME="$3"
COPY_AUTH_FROM="$4"

echo "🔧 Setting up kubectl with provided cluster information..."

# Validate arguments
if [[ -z "$CLUSTER_ID" || -z "$CLUSTER_ENDPOINT" || -z "$CONTEXT_NAME" ]]; then
    echo "❌ Error: Missing required arguments"
    echo "   Usage: $0 <cluster_id> <cluster_endpoint> <context_name> [copy_auth_from]"
    exit 1
fi

echo "📦 Cluster ID: $CLUSTER_ID"
echo "🌐 Endpoint: $CLUSTER_ENDPOINT"
echo "🏷️  Context Name: $CONTEXT_NAME"
if [[ -n "$COPY_AUTH_FROM" ]]; then
    echo "🔑 Copy Auth From: $COPY_AUTH_FROM"
fi



# Use environment variables from .envrc
LOCAL_KUBE_DIR="$(dirname "$KUBECONFIG")"

mkdir -p "$LOCAL_KUBE_DIR"

# Set up cluster configuration using kubectl
echo "⚙️  Adding cluster configuration..."
kubectl config set-cluster "$CLUSTER_ID" --server="$CLUSTER_ENDPOINT"

# Set up user configuration (assuming token-based auth from environment)
echo "👤 Setting up user authentication..."
if [[ -n "$COPY_AUTH_FROM" ]]; then
    echo "🔑 Copying authentication from context '$COPY_AUTH_FROM'..."
    
    # Get the user from the source context
    SOURCE_USER=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$COPY_AUTH_FROM')].context.user}")
    if [[ -z "$SOURCE_USER" ]]; then
        echo "❌ Error: Source context '$COPY_AUTH_FROM' not found or has no user configured"
        exit 1
    fi
    
    # Check if the source user exists in the kubeconfig
    if ! kubectl config view -o jsonpath="{.users[?(@.name=='$SOURCE_USER')].name}" | grep -q "$SOURCE_USER"; then
        echo "❌ Error: User '$SOURCE_USER' from context '$COPY_AUTH_FROM' not found in kubeconfig"
        exit 1
    fi
    
    echo "📋 Found user '$SOURCE_USER' in source context"
    
    # Copy the user configuration to the new user name
    NEW_USER="$CLUSTER_ID-user"
    
    # Get the source user's auth configuration
    USER_CONFIG=$(kubectl config view --raw -o json | jq -r ".users[] | select(.name==\"$SOURCE_USER\")")
    if [[ "$USER_CONFIG" == "null" || -z "$USER_CONFIG" ]]; then
        echo "❌ Error: Could not retrieve user configuration for '$SOURCE_USER'"
        exit 1
    fi
    
    # Extract authentication details and apply them to the new user
    if echo "$USER_CONFIG" | jq -e '.user.token' >/dev/null 2>&1; then
        TOKEN=$(echo "$USER_CONFIG" | jq -r '.user.token')
        kubectl config set-credentials "$NEW_USER" --token="$TOKEN"
        echo "✅ Copied token authentication from '$SOURCE_USER'"
    elif echo "$USER_CONFIG" | jq -e '.user["client-certificate"]' >/dev/null 2>&1; then
        CLIENT_CERT=$(echo "$USER_CONFIG" | jq -r '.user["client-certificate"]')
        CLIENT_KEY=$(echo "$USER_CONFIG" | jq -r '.user["client-key"]')
        kubectl config set-credentials "$NEW_USER" --client-certificate="$CLIENT_CERT" --client-key="$CLIENT_KEY"
        echo "✅ Copied certificate authentication from '$SOURCE_USER'"
    elif echo "$USER_CONFIG" | jq -e '.user["client-certificate-data"]' >/dev/null 2>&1; then
        CLIENT_CERT_DATA=$(echo "$USER_CONFIG" | jq -r '.user["client-certificate-data"]')
        CLIENT_KEY_DATA=$(echo "$USER_CONFIG" | jq -r '.user["client-key-data"]')
        
        # Create a temporary config file with the user configuration including the certificate data
        TEMP_CONFIG=$(mktemp)
        cat > "$TEMP_CONFIG" << EOF
{
  "apiVersion": "v1",
  "kind": "Config",
  "users": [
    {
      "name": "$NEW_USER",
      "user": {
        "client-certificate-data": "$CLIENT_CERT_DATA",
        "client-key-data": "$CLIENT_KEY_DATA"
      }
    }
  ]
}
EOF
        
        # Merge the temporary config with the current config
        KUBECONFIG="$TEMP_CONFIG:$KUBECONFIG" kubectl config view --flatten > "${KUBECONFIG}.tmp"
        mv "${KUBECONFIG}.tmp" "$KUBECONFIG"
        rm "$TEMP_CONFIG"
        
        echo "✅ Copied certificate data authentication from '$SOURCE_USER'"
    elif echo "$USER_CONFIG" | jq -e '.user.exec' >/dev/null 2>&1; then
        # For exec-based auth, we need to copy the entire exec configuration
        EXEC_CONFIG=$(echo "$USER_CONFIG" | jq -r '.user.exec')
        
        # Create a temporary file with the user configuration
        TEMP_CONFIG=$(mktemp)
        echo "{\"users\": [{\"name\": \"$NEW_USER\", \"user\": {\"exec\": $EXEC_CONFIG}}]}" > "$TEMP_CONFIG"
        
        # Merge the configuration
        KUBECONFIG="$TEMP_CONFIG:$KUBECONFIG" kubectl config view --flatten > "${KUBECONFIG}.tmp"
        mv "${KUBECONFIG}.tmp" "$KUBECONFIG"
        rm "$TEMP_CONFIG"
        
        echo "✅ Copied exec authentication from '$SOURCE_USER'"
    else
        echo "❌ Error: Unsupported authentication method in source user '$SOURCE_USER'"
        echo "   Supported methods: token, client-certificate, client-certificate-data, exec"
        exit 1
    fi
    
elif [[ -n "$KUBE_TOKEN" ]]; then
    kubectl config set-credentials "$CLUSTER_ID-user" --token="$KUBE_TOKEN"
elif [[ -n "$KUBE_CLIENT_CERT" && -n "$KUBE_CLIENT_KEY" ]]; then
    kubectl config set-credentials "$CLUSTER_ID-user" --client-certificate="$KUBE_CLIENT_CERT" --client-key="$KUBE_CLIENT_KEY"
else
    echo "⚠️  Warning: No authentication credentials found in environment variables or copy_auth_from parameter"
    echo "   Expected: KUBE_TOKEN or (KUBE_CLIENT_CERT and KUBE_CLIENT_KEY) or copy_auth_from parameter"
fi

# Create or update the context
echo "� Creating context '$CONTEXT_NAME'..."
kubectl config set-context "$CONTEXT_NAME" --cluster="$CLUSTER_ID" --user="$CLUSTER_ID-user"

# Set appropriate permissions
chmod 600 "$KUBECONFIG"

# Switch to the new context
echo "🎯 Switching to context '$CONTEXT_NAME'..."
kubectl config use-context "$CONTEXT_NAME"

# Validate the connection
echo "🔍 Validating cluster connection..."
if kubectl cluster-info --request-timeout=10s >/dev/null 2>&1; then
    echo "✅ Successfully configured kubectl!"
    echo ""
    echo "📊 Cluster information:"
    kubectl cluster-info --request-timeout=10s
    echo ""
    echo "🏷️  Current context: $CONTEXT_NAME"
    echo ""
    echo "🔍 Available contexts:"
    kubectl config get-contexts
else
    echo "⚠️  Warning: Could not connect to cluster"
    echo "   Check your network connection and authentication credentials"
    echo ""
    echo "🔍 Available contexts:"
    kubectl config get-contexts
fi

echo ""
echo "🚀 kubectl is now configured for your cluster!"
echo ""
