# Quick Deployment Guide

## 🚀 One-Command Deployment

```bash
# Deploy the complete MLTP stack
helm install grafana-mltp ./grafana-mltp-stack --create-namespace --namespace grafana-mltp
```

## 📋 Pre-Deployment Checklist

- [ ] Kubernetes cluster running (v1.21+)
- [ ] Helm 3.8+ installed
- [ ] At least 4GB RAM available
- [ ] At least 2 CPU cores available
- [ ] Default storage class configured

## ⚡ Quick Access Commands

```bash
# Wait for all pods to be ready
kubectl wait --for=condition=ready pod --all -n grafana-mltp --timeout=300s

# Access Grafana (admin/admin)
kubectl port-forward -n grafana-mltp svc/grafana-mltp-grafana 3000:3000

# Access Mythical Beasts API
kubectl port-forward -n grafana-mltp svc/grafana-mltp-mythical-server 4000:4000

# Check deployment status
kubectl get pods -n grafana-mltp
```

## 🧪 Quick Test

```bash
# Test the API (after port-forwarding)
curl -X POST http://localhost:4000/unicorn \
  -H "Content-Type: application/json" \
  -d '{"name": "test-beast"}'

curl http://localhost:4000/unicorn
```

## 🔍 Verify Observability

1. **Open Grafana**: http://localhost:3000 (admin/admin)
2. **Check Datasources**: All 4 datasources should be green
3. **View Dashboards**: Pre-built MLTP dashboards available
4. **Monitor k6 Load Test**: Check running load test generating data

## 🔧 Customize Installation

```bash
# Install with custom values
helm install grafana-mltp ./grafana-mltp-stack \
  --set global.namespace=my-mltp \
  --set microservices.server.replicas=2 \
  --set k6.env.vus=10

# Install without load testing
helm install grafana-mltp ./grafana-mltp-stack \
  --set k6.enabled=false

# Install without auto-instrumentation
helm install grafana-mltp ./grafana-mltp-stack \
  --set beyla.enabled=false
```

## 🛠️ Troubleshooting

```bash
# Check pod status
kubectl get pods -n grafana-mltp

# View pod logs
kubectl logs -n grafana-mltp deployment/grafana-mltp-grafana

# Check resources
kubectl describe pod -n grafana-mltp -l app.kubernetes.io/component=grafana

# Force restart a deployment
kubectl rollout restart deployment/grafana-mltp-grafana -n grafana-mltp
```

## 🧹 Cleanup

```bash
# Uninstall everything
helm uninstall grafana-mltp -n grafana-mltp
kubectl delete namespace grafana-mltp
```

## 📊 Expected Resources

The deployment creates approximately **38 Kubernetes resources**:

- **1** Namespace
- **1** ServiceAccount  
- **13** Services (1 per component)
- **13** Deployments (microservices + observability stack)
- **1** Job (k6 load test)
- **3** PersistentVolumeClaims
- **6** ConfigMaps
- **1** Ingress (optional)

## 🎯 Success Indicators

✅ All pods in `Running` status  
✅ Grafana accessible on port 3000  
✅ All 4 datasources healthy in Grafana  
✅ k6 load test generating traffic  
✅ Metrics, logs, traces, and profiles flowing  
✅ API responding to test requests
