#!/usr/bin/env bash

# Script to configure kubectl for local Kubernetes clusters
# This script detects and configures kubectl for Docker Desktop or minikube
# Usage: configure-kubectl-local.sh

set -e

# Detect if we're running in WSL2
IS_WSL2=$(grep -qi microsoft /proc/version 2>/dev/null && echo "true" || echo "false")

echo "🏠 Configuring kubectl for local Kubernetes cluster..."

# Function to setup Docker Desktop Kubernetes
setup_docker_desktop() {
    echo "🐳 Setting up Docker Desktop Kubernetes..."
    
    # Use environment variables from .envrc
    KUBECONFIG_DIR="$(dirname "$KUBECONFIG")"
    mkdir -p "$KUBECONFIG_DIR"
    
    # Check if we're running in WSL2
    if [[ "$IS_WSL2" == "true" ]]; then
        echo "🐧 Detected WSL2 environment"
        
        # Set up Windows kubeconfig path
        if ! command -v cmd.exe >/dev/null 2>&1; then
            echo "⚠️  cmd.exe not available - using default kubeconfig"
        else
            echo "🔧 Configuring Windows kubeconfig path..."
            WIN_HOME="$(wslpath "$(cmd.exe /C echo %USERPROFILE% | tr -d '\r')")"
            WIN_KUBECONFIG="$WIN_HOME/.kube/config"
            echo "📍 Found Windows kubeconfig: $WIN_KUBECONFIG"
            
            # Check if Windows kubeconfig exists
            if [[ ! -f "$WIN_KUBECONFIG" ]]; then
                echo "⚠️  Windows kubeconfig not found at: $WIN_KUBECONFIG"
                echo "   Make sure Docker Desktop is installed and Kubernetes is enabled"
                return 1
            fi
            
            # Merge Windows kubeconfig with local kubeconfig
            if [[ -f "$KUBECONFIG" ]] && [[ -s "$KUBECONFIG" ]]; then
                echo "🔗 Merging Windows kubeconfig with existing local kubeconfig..."
                KUBECONFIG="$KUBECONFIG:$WIN_KUBECONFIG" kubectl config view --flatten > "$KUBECONFIG.new"
                mv "$KUBECONFIG.new" "$KUBECONFIG"
            else
                echo "📝 Creating local kubeconfig from Windows kubeconfig..."
                cp "$WIN_KUBECONFIG" "$KUBECONFIG"
            fi
            
            # Set appropriate permissions
            chmod 600 "$KUBECONFIG"
        fi
    fi
    
    # Check if Docker Desktop context exists and is accessible
    if ! kubectl config get-contexts docker-desktop >/dev/null 2>&1; then
        echo "⚠️  Docker Desktop Kubernetes context not found"
        if [[ "$IS_WSL2" == "true" ]]; then
            echo "   In WSL2, make sure:"
            echo "   1. Docker Desktop is installed on Windows"
            echo "   2. WSL2 integration is enabled in Docker Desktop settings"
            echo "   3. Kubernetes is enabled in Docker Desktop settings"
        fi
        return 1
    fi
    
    kubectl config use-context docker-desktop
    
    # Verify the cluster is accessible
    if ! kubectl cluster-info --request-timeout=5s >/dev/null 2>&1; then
        echo "⚠️  Docker Desktop context exists but cluster is not accessible"
        echo "   Make sure Kubernetes is enabled in Docker Desktop settings"
        if [[ "$IS_WSL2" == "true" ]] && [[ -n "$WIN_KUBECONFIG" ]]; then
            echo "   Also verify that the Windows kubeconfig exists at: $WIN_KUBECONFIG"
        fi
        return 1
    fi
    
    echo "✅ Successfully configured kubectl for Docker Desktop!"
    
    # Use configure-kubectl.sh to rename context to 'local' with copied authentication
    echo "🏷️  Setting up 'local' context using configure-kubectl.sh..."
    DOCKER_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    ./scripts/configure-kubectl.sh "docker-desktop" "$DOCKER_ENDPOINT" "local" "docker-desktop"
    
    # Inform about the local kubeconfig setup
    echo "📍 Local kubeconfig location: $KUBECONFIG"
    
    return 0
}

# Function to setup minikube
setup_minikube() {
    echo "🔧 Setting up minikube..."
    
    # Check if minikube command exists
    if ! command -v minikube >/dev/null 2>&1; then
        echo "⚠️  minikube command not found"
        return 1
    fi
    
    # Check if minikube is running
    if ! minikube status >/dev/null 2>&1; then
        echo "⚠️  Minikube is not running"
        echo "   Start it with: minikube start"
        return 1
    fi
    
    echo "✅ Minikube is running"
    kubectl config use-context minikube
    
    # Verify the cluster is accessible
    if ! kubectl cluster-info --request-timeout=5s >/dev/null 2>&1; then
        echo "⚠️  Minikube context exists but cluster is not accessible"
        return 1
    fi
    
    echo "✅ Successfully configured kubectl for minikube!"
    
    # Use configure-kubectl.sh to rename context to 'local' with copied authentication
    echo "🏷️  Setting up 'local' context using configure-kubectl.sh..."
    MINIKUBE_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    ./scripts/configure-kubectl.sh "minikube" "$MINIKUBE_ENDPOINT" "local" "minikube"
    
    echo "📍 Local kubeconfig location: $KUBECONFIG"
    return 0
}

# Function to setup kind
setup_kind() {
    echo "🔗 Setting up kind..."
    
    # Check if kind command exists
    if ! command -v kind >/dev/null 2>&1; then
        echo "⚠️  kind command not found"
        return 1
    fi
    
    # Check if there are any kind clusters
    if ! kind get clusters >/dev/null 2>&1; then
        echo "⚠️  No kind clusters found"
        echo "   Create one with: kind create cluster"
        return 1
    fi
    
    CLUSTERS=$(kind get clusters)
    if [[ -z "$CLUSTERS" ]]; then
        echo "⚠️  No kind clusters found"
        echo "   Create one with: kind create cluster"
        return 1
    fi
    
    # Use the first available cluster
    CLUSTER_NAME=$(echo "$CLUSTERS" | head -n1)
    CONTEXT_NAME="kind-$CLUSTER_NAME"
    
    if ! kubectl config get-contexts "$CONTEXT_NAME" >/dev/null 2>&1; then
        echo "⚠️  Kind cluster found but kubectl context is missing"
        return 1
    fi
    
    kubectl config use-context "$CONTEXT_NAME"
    
    # Verify the cluster is accessible
    if ! kubectl cluster-info --request-timeout=5s >/dev/null 2>&1; then
        echo "⚠️  Kind context exists but cluster is not accessible"
        return 1
    fi
    
    echo "✅ Successfully configured kubectl for kind cluster: $CLUSTER_NAME!"
    
    # Use configure-kubectl.sh to rename context to 'local' with copied authentication
    echo "🏷️  Setting up 'local' context using configure-kubectl.sh..."
    KIND_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    ./scripts/configure-kubectl.sh "kind-$CLUSTER_NAME" "$KIND_ENDPOINT" "local" "kind-$CLUSTER_NAME"
    
    echo "📍 Local kubeconfig location: $KUBECONFIG"
    return 0
}

# Function to check if 'local' context already exists and is working
check_existing_local() {
    echo "🏠 Checking for existing 'local' context..."
    
    # Check if 'local' context exists
    if ! kubectl config get-contexts local >/dev/null 2>&1; then
        return 1
    fi
    
    echo "🔍 Found existing 'local' context, testing connection..."
    kubectl config use-context local
    
    # Test if the cluster is accessible
    if ! kubectl cluster-info --request-timeout=5s >/dev/null 2>&1; then
        echo "⚠️  Existing 'local' context is not accessible, trying to reconfigure..."
        return 1
    fi
    
    echo "✅ Existing 'local' context is working!"
    return 0
}

# Try different local cluster options in order of preference
echo "🔍 Detecting local Kubernetes clusters..."

# Try existing local context first
if check_existing_local; then
    CLUSTER_TYPE="existing local"
# Try Docker Desktop second
elif setup_docker_desktop; then
    CLUSTER_TYPE="Docker Desktop"
# Try minikube third
elif setup_minikube; then
    CLUSTER_TYPE="minikube"
# Try kind fourth
elif setup_kind; then
    CLUSTER_TYPE="kind"
else
    echo ""
    echo "❌ No accessible local Kubernetes cluster found!"
    echo ""
    echo "📋 Available options to set up local Kubernetes:"
    echo ""
    echo "🐳 Docker Desktop:"
    echo "   1. Install Docker Desktop"
    echo "   2. Go to Settings → Kubernetes → Enable Kubernetes"
    echo "   3. Apply & Restart"
    echo ""
    echo "🔧 Minikube:"
    echo "   1. Install minikube: https://minikube.sigs.k8s.io/docs/start/"
    echo "   2. Start cluster: minikube start"
    echo ""
    echo "🔗 Kind:"
    echo "   1. Install kind: https://kind.sigs.k8s.io/docs/user/quick-start/"
    echo "   2. Create cluster: kind create cluster"
    echo ""
    exit 1
fi

echo ""
echo "🚀 kubectl is now configured for your local $CLUSTER_TYPE cluster!"
echo ""
echo "📊 Cluster information:"
kubectl cluster-info --request-timeout=10s
echo ""
echo "🏷️  Current context: $(kubectl config current-context)"
echo ""
echo "📋 Next steps:"
echo "   • List nodes: task infrastructure:k8s:get-nodes"
echo "   • Show cluster info: task infrastructure:k8s:info"
echo "   • List all available k8s tasks: task --list-all | grep k8s"
