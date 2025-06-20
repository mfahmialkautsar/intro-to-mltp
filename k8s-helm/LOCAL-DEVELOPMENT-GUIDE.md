# Local Development with Volume Binding

This guide shows how to use the Helm chart's local file mounting feature, which works similarly to Docker Compose volume binding. This allows you to edit config files locally and have changes reflected immediately in running pods.

## 🐳 Docker Compose vs Kubernetes Volume Binding

### Docker Compose Style
```yaml
volumes:
  - "./loki/loki.yaml:/etc/loki/loki.yaml"
  - "./tempo/tempo.yaml:/etc/tempo.yaml"
  - "./alloy/config.alloy:/etc/alloy/config.alloy"
```

### Kubernetes Helm Chart Equivalent
```yaml
development:
  localConfigs:
    enabled: true
    basePath: "/Users/username/GoProjects/intro-to-mltp"
    loki:
      configPath: "loki/loki.yaml"
    tempo:
      configPath: "tempo/tempo.yaml"
    alloy:
      configPath: "alloy/config.alloy"
```

## ⚡ Quick Setup

### 1. Enable Local Config Mounting

Create a development values file:

```bash
# Create development-specific values
cat > dev-values.yaml << EOF
development:
  localConfigs:
    enabled: true
    basePath: "$(pwd)"
    
    alloy:
      configPath: "alloy/config.alloy"
      endpointsPath: "alloy/endpoints.json"
    tempo:
      configPath: "tempo/tempo.yaml"
    loki:
      configPath: "loki/loki.yaml"
    mimir:
      configPath: "mimir/mimir.yaml"
    beyla:
      configPath: "beyla/config.yaml"
    grafana:
      provisioningPath: "grafana/provisioning"
      dashboardsPath: "grafana/definitions"
EOF
```

### 2. Deploy with Local Files

```bash
# Deploy with local config file mounting
helm upgrade --install grafana-mltp-stack ./grafana-mltp-stack \
  --namespace grafana-mltp \
  --create-namespace \
  -f dev-values.yaml
```

### 3. Verify Volume Mounts

```bash
# Check that pods are using hostPath volumes
kubectl get pods -n grafana-mltp -o yaml | grep -A5 -B5 hostPath
```

## 🔧 How It Works

### Volume Mount Logic

The deployment templates conditionally use either:

1. **Development Mode** (`localConfigs.enabled: true`):
   - Uses `hostPath` volumes to mount local files directly
   - Changes to local files are reflected immediately in pods
   - Similar to Docker Compose volume binding

2. **Production Mode** (`localConfigs.enabled: false`):
   - Uses ConfigMaps to store configuration
   - Changes require ConfigMap updates and pod restarts

### Example: Loki Deployment Template

```yaml
# Template logic in loki-deployment.yaml
volumeMounts:
  {{- if .Values.development.localConfigs.enabled }}
  - name: config-volume
    mountPath: /etc/loki/loki.yaml
    subPath: {{ base .Values.development.localConfigs.loki.configPath }}
    readOnly: true
  {{- else }}
  - name: config
    mountPath: /etc/loki/loki.yaml
    subPath: loki.yaml
  {{- end }}

volumes:
  {{- if .Values.development.localConfigs.enabled }}
  - name: config-volume
    hostPath:
      path: {{ .Values.development.localConfigs.basePath }}/{{ .Values.development.localConfigs.loki.configPath }}
      type: File
  {{- else }}
  - name: config
    configMap:
      name: {{ include "grafana-mltp-stack.fullname" . }}-loki-config
  {{- end }}
```

## 📁 Supported Services

The following services support local file mounting:

| Service | Config File | Description |
|---------|-------------|-------------|
| **Alloy** | `alloy/config.alloy` | Telemetry collection pipeline |
| **Alloy** | `alloy/endpoints.json` | Service endpoint definitions |
| **Loki** | `loki/loki.yaml` | Log aggregation configuration |
| **Tempo** | `tempo/tempo.yaml` | Distributed tracing backend |
| **Mimir** | `mimir/mimir.yaml` | Metrics storage configuration |
| **Beyla** | `beyla/config.yaml` | Auto-instrumentation settings |
| **Grafana** | `grafana/provisioning/` | Data sources and dashboards |

## 🛠️ Development Workflow

### 1. Edit Local Config Files

```bash
# Edit any config file directly
vim loki/loki.yaml
vim alloy/config.alloy
vim tempo/tempo.yaml
```

### 2. Changes Apply Automatically

Since files are mounted directly via `hostPath`, changes are reflected immediately in the running pods (no restart required for most services).

### 3. Validate Changes

```bash
# Check if services picked up changes
kubectl logs -n grafana-mltp deployment/grafana-mltp-stack-loki -f
kubectl logs -n grafana-mltp deployment/grafana-mltp-stack-alloy -f
```

## ⚠️ Important Considerations

### 1. **Local Cluster Only**
- `hostPath` volumes only work on local clusters (minikube, kind, Docker Desktop)
- **DO NOT** use this in cloud clusters (EKS, GKE, AKS) - the files won't exist on cluster nodes

### 2. **File Permissions**
- Ensure files are readable by the pod user (usually root or service-specific user)
- Use `chmod 644` on config files if needed

### 3. **Path Validation**
- All paths in `basePath` and individual `configPath` values must exist
- The chart will fail to deploy if files are missing

### 4. **Service Restart Requirements**
Some services may require restart to pick up config changes:

```bash
# Restart specific services if needed
kubectl rollout restart deployment/grafana-mltp-stack-loki -n grafana-mltp
kubectl rollout restart deployment/grafana-mltp-stack-tempo -n grafana-mltp
kubectl rollout restart deployment/grafana-mltp-stack-mimir -n grafana-mltp
```

## 🚀 Quick Start Commands

### Enable Local Development Mode

```bash
# Navigate to project root
cd /Users/mfahmialkautsar/GoProjects/intro-to-mltp

# Create development values
cat > k8s-helm/dev-values.yaml << EOF
development:
  localConfigs:
    enabled: true
    basePath: "$(pwd)"
EOF

# Deploy with local file mounting
cd k8s-helm
helm upgrade --install grafana-mltp-stack ./grafana-mltp-stack \
  --namespace grafana-mltp \
  --create-namespace \
  -f dev-values.yaml

# Verify volumes are mounted
kubectl describe pod -l app.kubernetes.io/component=loki -n grafana-mltp | grep -A10 "Volumes:"
```

### Switch Back to Production Mode

```bash
# Deploy without local file mounting (uses ConfigMaps)
helm upgrade --install grafana-mltp-stack ./grafana-mltp-stack \
  --namespace grafana-mltp
```

## 🔍 Troubleshooting

### Check Mount Status
```bash
# Verify hostPath volumes are created
kubectl get pods -n grafana-mltp -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{range .spec.volumes[*]}{.name}: {.hostPath.path}{"\n"}{end}{"\n"}{end}'
```

### Validate File Access
```bash
# Check if files are accessible from within pods
kubectl exec -n grafana-mltp deployment/grafana-mltp-stack-loki -- ls -la /etc/loki/
kubectl exec -n grafana-mltp deployment/grafana-mltp-stack-alloy -- ls -la /etc/alloy/
```

### Debug Path Issues
```bash
# Check if files exist on the host
ls -la /Users/mfahmialkautsar/GoProjects/intro-to-mltp/loki/loki.yaml
ls -la /Users/mfahmialkautsar/GoProjects/intro-to-mltp/alloy/config.alloy
```

This system provides the same flexibility as Docker Compose volumes while maintaining the power and scalability of Kubernetes deployments.
