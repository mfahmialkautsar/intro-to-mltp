#!/bin/bash

# Helm Template Validation Script
# This script validates all Helm templates and ensures external config files are correctly loaded

set -e

CHART_DIR="/Users/mfahmialkautsar/GoProjects/intro-to-mltp/k8s-helm/grafana-mltp-stack"
RELEASE_NAME="validation-test"

echo "🔍 Validating Helm Chart: grafana-mltp-stack"
echo "=================================================="

cd "$CHART_DIR"

echo ""
echo "📋 Checking config files exist..."
CONFIG_FILES=(
    "configs/alloy-config.alloy"
    "configs/alloy-endpoints.json"
    "configs/beyla-config.yml"
    "configs/grafana-datasources.yaml"
    "configs/k6-loadtest.js"
    "configs/loki-config.yaml"
    "configs/mimir-config.yaml"
    "configs/tempo-config.yaml"
)

for config in "${CONFIG_FILES[@]}"; do
    if [[ -f "$config" ]]; then
        echo "✅ $config exists"
    else
        echo "❌ $config missing"
        exit 1
    fi
done

echo ""
echo "🔧 Running Helm template validation..."

# Test basic template rendering
echo "Testing basic template rendering..."
helm template "$RELEASE_NAME" . --values values.yaml > /dev/null
echo "✅ Basic template rendering successful"

# Test specific ConfigMaps with external files
echo ""
echo "Testing ConfigMaps with external config files..."

# Test Alloy ConfigMap
echo "- Testing Alloy ConfigMap..."
helm template "$RELEASE_NAME" . --values values.yaml --show-only templates/alloy-configmap.yaml > /tmp/alloy-test.yaml
if grep -q "validation-test-grafana-mltp-stack-mimir:9009" /tmp/alloy-test.yaml; then
    echo "  ✅ Alloy config placeholders replaced correctly"
else
    echo "  ❌ Alloy config placeholders not replaced"
    echo "  Debug: Checking actual content..."
    grep -n "mimir:9009" /tmp/alloy-test.yaml | head -2
    exit 1
fi

# Test Beyla ConfigMap
echo "- Testing Beyla ConfigMap..."
helm template "$RELEASE_NAME" . --values values.yaml --show-only templates/beyla-configmap.yaml > /tmp/beyla-test.yaml
if grep -q "validation-test-grafana-mltp-stack-alloy" /tmp/beyla-test.yaml; then
    echo "  ✅ Beyla config placeholders replaced correctly"
else
    echo "  ❌ Beyla config placeholders not replaced"
    exit 1
fi

# Test Loki ConfigMap
echo "- Testing Loki ConfigMap..."
helm template "$RELEASE_NAME" . --values values.yaml --show-only templates/loki-configmap.yaml > /tmp/loki-test.yaml
if grep -q "ruler:" /tmp/loki-test.yaml; then
    echo "  ✅ Loki config loaded correctly"
else
    echo "  ❌ Loki config not loaded"
    exit 1
fi

# Test Tempo ConfigMap
echo "- Testing Tempo ConfigMap..."
helm template "$RELEASE_NAME" . --values values.yaml --show-only templates/tempo-configmap.yaml > /tmp/tempo-test.yaml
if grep -q "validation-test-grafana-mltp-stack-mimir:9009" /tmp/tempo-test.yaml; then
    echo "  ✅ Tempo config placeholders replaced correctly"
else
    echo "  ❌ Tempo config placeholders not replaced"
    exit 1
fi

# Test Mimir ConfigMap
echo "- Testing Mimir ConfigMap..."
helm template "$RELEASE_NAME" . --values values.yaml --show-only templates/mimir-configmap.yaml > /tmp/mimir-test.yaml
if grep -q "multitenancy_enabled: false" /tmp/mimir-test.yaml; then
    echo "  ✅ Mimir config loaded correctly"
else
    echo "  ❌ Mimir config not loaded"
    exit 1
fi

# Test Grafana Datasources ConfigMap
echo "- Testing Grafana Datasources ConfigMap..."
helm template "$RELEASE_NAME" . --values values.yaml --show-only templates/grafana-datasources-configmap.yaml > /tmp/grafana-ds-test.yaml
if grep -q "validation-test-grafana-mltp-stack-mimir:9009" /tmp/grafana-ds-test.yaml; then
    echo "  ✅ Grafana datasources config placeholders replaced correctly"
else
    echo "  ❌ Grafana datasources config placeholders not replaced"
    exit 1
fi

# Test K6 ConfigMap (if enabled)
echo "- Testing K6 ConfigMap..."
helm template "$RELEASE_NAME" . --values values.yaml --set k6.enabled=true --show-only templates/k6-configmap.yaml > /tmp/k6-test.yaml
if grep -q "mythical-server.grafana-mltp.svc.cluster.local" /tmp/k6-test.yaml; then
    echo "  ✅ K6 config placeholders replaced correctly"
else
    echo "  ❌ K6 config placeholders not replaced"
    exit 1
fi

echo ""
echo "🧪 Testing Helm template dry-run..."
helm template "$RELEASE_NAME" . --values values.yaml --dry-run > /dev/null
echo "✅ Dry-run successful"

echo ""
echo "🔍 Checking for common issues..."

# Check for missing template functions
if helm template "$RELEASE_NAME" . --values values.yaml 2>&1 | grep -q "function.*not defined"; then
    echo "❌ Template function errors found"
    exit 1
else
    echo "✅ No template function errors"
fi

# Clean up temporary files
rm -f /tmp/*-test.yaml

echo ""
echo "🎉 All validations passed!"
echo "✨ Helm chart is ready for deployment with externalized configurations."
