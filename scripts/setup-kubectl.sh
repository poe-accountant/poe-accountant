#!/bin/bash

# Script to configure kubectl using provided cluster information
# This script echo ""
echo "🚀 kubectl is now configured for your Terraform-managed cluster!"
echo ""
echo "📁 Local kubeconfig location: $KUBECONFIG"
echo "🔧 To use kubectl with this cluster in other terminals:"
echo "   export KUBECONFIG=\"$KUBECONFIG\""p local kubeconfig with the provided cluster details
# Usage: setup-kubectl.sh <cluster_id> <cluster_endpoint> <kubeconfig_content>

set -e

# Get arguments
CLUSTER_ID="$1"
CLUSTER_ENDPOINT="$2"
KUBECONFIG_CONTENT="$3"

echo "🔧 Setting up kubectl with provided cluster information..."

# Validate arguments
if [[ -z "$CLUSTER_ID" || -z "$CLUSTER_ENDPOINT" || -z "$KUBECONFIG_CONTENT" ]]; then
    echo "❌ Error: Missing required arguments"
    echo "   Usage: $0 <cluster_id> <cluster_endpoint> <kubeconfig_content>"
    exit 1
fi

echo "📦 Cluster ID: $CLUSTER_ID"
echo "🌐 Endpoint: $CLUSTER_ENDPOINT"

# Use environment variables from .envrc
LOCAL_KUBE_DIR="$(dirname "$KUBECONFIG")"
LOCAL_KUBECONFIG="$KUBECONFIG"

mkdir -p "$LOCAL_KUBE_DIR"

# Backup existing local kubeconfig if it exists
if [[ -f "$LOCAL_KUBECONFIG" ]]; then
    echo "💾 Backing up existing local kubeconfig to $LOCAL_KUBE_DIR/config.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$LOCAL_KUBECONFIG" "$LOCAL_KUBE_DIR/config.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Create temporary kubeconfig from provided content
echo "⬇️  Setting up kubeconfig from provided content..."
TEMP_KUBECONFIG=$(mktemp)
echo "$KUBECONFIG_CONTENT" > "$TEMP_KUBECONFIG"

# Validate the kubeconfig
if ! kubectl --kubeconfig="$TEMP_KUBECONFIG" cluster-info --request-timeout=10s >/dev/null 2>&1; then
    echo "❌ Error: Retrieved kubeconfig is not valid or cluster is not accessible"
    rm -f "$TEMP_KUBECONFIG"
    exit 1
fi

# Merge or replace local kubeconfig
if [[ -f "$LOCAL_KUBECONFIG" ]] && [[ -s "$LOCAL_KUBECONFIG" ]]; then
    echo "🔗 Merging with existing local kubeconfig..."
    # Use kubectl to merge configs properly
    KUBECONFIG="$LOCAL_KUBECONFIG:$TEMP_KUBECONFIG" kubectl config view --flatten > "$LOCAL_KUBECONFIG.new"
    mv "$LOCAL_KUBECONFIG.new" "$LOCAL_KUBECONFIG"
else
    echo "📝 Creating new local kubeconfig..."
    cp "$TEMP_KUBECONFIG" "$LOCAL_KUBECONFIG"
fi

# Clean up temporary file
rm -f "$TEMP_KUBECONFIG"

# Set appropriate permissions
chmod 600 "$LOCAL_KUBECONFIG"

# Export KUBECONFIG for this session and inform user
export KUBECONFIG="$LOCAL_KUBECONFIG"

# Find and set the DigitalOcean context
echo "🎯 Setting kubectl context..."
CONTEXT_NAME=$(kubectl config get-contexts -o name | grep -E "(do-|digitalocean)" | head -1)

if [[ -n "$CONTEXT_NAME" ]]; then
    kubectl config use-context "$CONTEXT_NAME"
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
    echo "⚠️  Warning: Could not automatically set DigitalOcean context"
    echo "   Available contexts:"
    kubectl config get-contexts
    echo ""
    echo "   Manually switch context with: task infrastructure:k8s:switch-context -- <context-name>"
fi

echo ""
echo "🚀 kubectl is now configured for your Terraform-managed cluster!"
echo ""
echo "� Local kubeconfig location: $LOCAL_KUBECONFIG"
echo "🔧 To use kubectl with this cluster in other terminals:"
echo "   export KUBECONFIG=\"$LOCAL_KUBECONFIG\""
echo ""
echo "�📋 Next steps:"
echo "   • List nodes: task infrastructure:k8s:get-nodes"
echo "   • Show cluster info: task infrastructure:k8s:info"
echo "   • List all available k8s tasks: task --list-all | grep k8s"
