# Grafana MLTP Stack Helm Chart

Production-ready Helm chart for the complete Grafana MLTP observability stack.

## Quick Deploy

```bash
helm install mltp ./grafana-mltp-stack --create-namespace --namespace mltp
```

## What's Included

**Sample Application:**
- Mythical Beasts Server, Requester, Recorder
- PostgreSQL database, RabbitMQ messaging

**Observability Stack (MLTP):**
- Grafana, Mimir, Loki, Tempo, Pyroscope
- Alloy (telemetry collection), Beyla (auto-instrumentation)
- k6 load testing, pre-built dashboards

## Configuration Examples

### Development Mode
```yaml
# values-dev.yaml
service:
  autoExpose:
    enabled: true
    
development:
  enabled: true
  
resources:
  requests:
    memory: 256Mi
    cpu: 250m
```

### Production Mode  
```yaml
# values-prod.yaml
ingress:
  enabled: true
  hosts:
    - host: grafana.company.com
      
persistence:
  enabled: true
  size: 50Gi
  
resources:
  requests:
    memory: 1Gi
    cpu: 500m
```

### Resource Optimization
```yaml
# Disable components for smaller deployments
k6:
  enabled: false
  
beyla:
  enabled: false
  
microservices:
  replicas: 1
```

## Validation

```bash
# Check deployment
kubectl get pods -n mltp

# Access Grafana  
kubectl port-forward svc/mltp-grafana 3000:3000

# Test API
kubectl port-forward svc/mltp-mythical-server 4000:4000
curl -X POST http://localhost:4000/unicorn -d '{"name":"test"}'
```

## Values Reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.autoExpose.enabled` | Auto-expose as NodePort | `true` |
| `microservices.enabled` | Deploy sample apps | `true` |
| `k6.enabled` | Enable load testing | `true` |
| `beyla.enabled` | Enable auto-instrumentation | `true` |
| `ingress.enabled` | Enable ingress | `false` |
| `persistence.enabled` | Enable persistent storage | `false` |

See `values.yaml` for complete configuration options.
