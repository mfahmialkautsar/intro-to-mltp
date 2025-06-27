#!/bin/bash

# Test script to verify Skaffold setup
echo "🧪 Testing Skaffold Development Setup"
echo "======================================"

# Test 1: Check if required tools are installed
echo ""
echo "📋 Checking prerequisites..."

if command -v skaffold &> /dev/null; then
    echo "✅ Skaffold is installed: $(skaffold version)"
else
    echo "❌ Skaffold is not installed"
    exit 1
fi

if command -v kubectl &> /dev/null; then
    echo "✅ kubectl is installed: $(kubectl version --client --short)"
else
    echo "❌ kubectl is not installed"
    exit 1
fi

if command -v helm &> /dev/null; then
    echo "✅ Helm is installed: $(helm version --short)"
else
    echo "❌ Helm is not installed"
    exit 1
fi

# Test 2: Check Kubernetes connectivity
echo ""
echo "🔌 Testing Kubernetes connectivity..."
if kubectl cluster-info &> /dev/null; then
    echo "✅ Connected to Kubernetes cluster: $(kubectl config current-context)"
else
    echo "❌ Not connected to Kubernetes cluster"
    exit 1
fi

# Test 3: Validate Skaffold configuration
echo ""
echo "📝 Validating Skaffold configuration..."
cd k8s-helm

if skaffold diagnose &> /dev/null; then
    echo "✅ Skaffold configuration is valid"
else
    echo "❌ Skaffold configuration has issues"
    skaffold diagnose
    exit 1
fi

# Test 4: Check source files
echo ""
echo "📁 Checking source files..."

required_files=(
    "../source/mythical-beasts-server/index.js"
    "../source/mythical-beasts-server/package.json"
    "../source/mythical-beasts-requester/index.js"
    "../source/mythical-beasts-requester/package.json"
    "../source/mythical-beasts-recorder/index.js"
    "../source/mythical-beasts-recorder/package.json"
    "../source/docker/Dockerfile"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ Found: $file"
    else
        echo "❌ Missing: $file"
        exit 1
    fi
done

# Test 5: Validate Helm templates
echo ""
echo "🎯 Validating Helm templates..."
if helm template grafana-mltp-stack grafana-mltp-stack -f dev-values-skaffold.yaml > /dev/null; then
    echo "✅ Helm templates are valid"
else
    echo "❌ Helm template validation failed"
    exit 1
fi

# Test 6: Check namespace (create if needed)
echo ""
echo "🏷️  Checking namespace..."
if kubectl get namespace mltp-dev &> /dev/null; then
    echo "✅ Namespace 'mltp-dev' exists"
else
    echo "📝 Creating namespace 'mltp-dev'..."
    kubectl create namespace mltp-dev
    echo "✅ Created namespace 'mltp-dev'"
fi

# All tests passed
echo ""
echo "🎉 All tests passed! Your development setup is ready."
echo ""
echo "Next steps:"
echo "  1. Run: ./dev-mode.sh"
echo "  2. Wait for deployment to complete"
echo "  3. Access Grafana at http://localhost:3000"
echo "  4. Make changes to source files and see them reload!"
echo ""
