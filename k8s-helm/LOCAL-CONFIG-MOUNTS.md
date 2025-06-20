# Local Config File Mounting for Development

This document describes how to mount local configuration files directly into Kubernetes pods for live development, similar to Docker Compose volume mounts.

## Overview

The Helm chart now supports two modes for configuration:

1. **ConfigMap Mode (Default)**: Config files are embedded in ConfigMaps and deployed as part of the chart
2. **Local Development Mode**: Config files are mounted directly from the host filesystem using hostPath volumes

## Local Development Mode

### Prerequisites

- Single-node Kubernetes cluster (minikube, kind, Docker Desktop, etc.)
- Config files must be accessible on the Kubernetes node
- Chart must be deployed with `development.localConfigs.enabled=true`

### How It Works

When `development.localConfigs.enabled=true`, the chart will:
- Use hostPath volumes instead of ConfigMaps for service configurations
- Mount local config files directly into containers
- Allow live editing of config files without redeploying

### Supported Services

The following services support local config mounting:

| Service | Config Files | Mount Path |
|---------|-------------|------------|
| Alloy | `config.alloy`, `endpoints.json` | `/etc/alloy/` |
| Tempo | `tempo.yaml` | `/etc/tempo.yaml` |
| Loki | `loki.yaml` | `/etc/loki/loki.yaml` |
| Mimir | `mimir.yaml` | `/etc/mimir.yaml` |
| Beyla | `config.yaml` | `/configs/config.yaml` |
| Grafana | `datasources.yaml`, dashboards | `/etc/grafana/provisioning/` |

### Configuration

Add this to your `values.yaml` or use `--set` flags:

```yaml
development:
  localConfigs:
    enabled: true
    basePath: "/path/to/intro-to-mltp"  # Absolute path to project root
    
    # Individual service config paths (relative to basePath)
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
```

### Example Usage

```bash
# Deploy with local config mounting
helm install grafana-mltp-stack ./grafana-mltp-stack \
  --set development.localConfigs.enabled=true \
  --set development.localConfigs.basePath="/Users/username/GoProjects/intro-to-mltp"

# Or use a custom values file
cat << EOF > dev-values.yaml
development:
  localConfigs:
    enabled: true
    basePath: "/Users/$(whoami)/GoProjects/intro-to-mltp"
EOF

helm install grafana-mltp-stack ./grafana-mltp-stack -f dev-values.yaml
```

### Live Config Editing

Once deployed with local config mounting:

1. Edit config files directly in your project directory:
   ```bash
   # Edit Alloy config
   vim alloy/config.alloy
   
   # Edit Tempo config
   vim tempo/tempo.yaml
   
   # Add new Grafana dashboard
   cp new-dashboard.json grafana/definitions/
   ```

2. Changes are immediately available to the containers (no restart required for most services)

3. Some services may require a restart to pick up config changes:
   ```bash
   kubectl rollout restart deployment/grafana-mltp-stack-alloy
   kubectl rollout restart deployment/grafana-mltp-stack-tempo
   ```

## Platform-Specific Setup

### Docker Desktop (macOS/Windows)

Docker Desktop automatically shares certain directories. Ensure your project is in a shared directory:

```bash
# Check Docker Desktop file sharing settings
# Default shared paths: /Users (macOS), C:\Users (Windows)
```

### Minikube

Mount the project directory into minikube:

```bash
# Start minikube with mount
minikube start
minikube mount /Users/username/GoProjects/intro-to-mltp:/host-project

# Or mount after starting
minikube mount /Users/username/GoProjects/intro-to-mltp:/host-project &
```

Use `/host-project` as the `basePath` in values:

```yaml
development:
  localConfigs:
    enabled: true
    basePath: "/host-project"
```

### kind (Kubernetes in Docker)

Create a kind cluster with extra mounts:

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
  - hostPath: /Users/username/GoProjects/intro-to-mltp
    containerPath: /host-project
```

```bash
kind create cluster --config kind-config.yaml
```

## Security Considerations

⚠️ **WARNING**: hostPath volumes have security implications:

- Pods can access the host filesystem
- Only use in development environments
- Never use in production or multi-tenant clusters
- Consider using `readOnly: true` where possible

## Troubleshooting

### Common Issues

1. **File not found errors**:
   - Verify the `basePath` is correct
   - Check file permissions
   - Ensure files exist on the Kubernetes node

2. **Permission denied**:
   - Check file/directory permissions
   - May need to adjust securityContext

3. **Changes not reflected**:
   - Some services cache configs - restart the pod
   - Check if the service supports config reloading

### Debug Commands

```bash
# Check if files are mounted correctly
kubectl exec -it deployment/grafana-mltp-stack-alloy -- ls -la /etc/alloy/

# View actual config content
kubectl exec -it deployment/grafana-mltp-stack-alloy -- cat /etc/alloy/config.alloy

# Check mount points
kubectl describe pod -l app.kubernetes.io/component=alloy
```

## Best Practices

1. **Use version control**: Keep config files in git for tracking changes
2. **Backup configs**: Before making changes, backup working configurations
3. **Gradual changes**: Test config changes on one service at a time
4. **Monitoring**: Watch logs when making config changes
5. **Documentation**: Document any custom configurations

## Production Deployment

For production deployments, always use ConfigMap mode:

```bash
helm install grafana-mltp-stack ./grafana-mltp-stack \
  --set development.localConfigs.enabled=false
```

This ensures configs are:
- Immutable and versioned with the chart
- Properly templated with Helm values
- Suitable for multi-node clusters
- More secure and portable
