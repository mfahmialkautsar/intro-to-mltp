# Grafana MLTP Stack Helm Chart

This Helm chart deploys a complete **Grafana MLTP (Metrics, Logs, Traces, Profiles)** observability stack on Kubernetes, including sample microservices for demonstration purposes.

## Overview

The chart includes:

### 🏗️ **Sample Microservices**
- **Mythical Beasts Server** - REST API server (port 4000)
- **Mythical Beasts Requester** - Client application (port 4001) 
- **Mythical Beasts Recorder** - Database recorder service (port 4002)

### 🗄️ **Infrastructure Components**
- **PostgreSQL** - Database for persistent storage
- **RabbitMQ** - Message queue for inter-service communication

### 📊 **Observability Stack (MLTP)**
- **📈 Metrics**: Grafana Mimir - Long-term metrics storage
- **📝 Logs**: Grafana Loki - Log aggregation and querying
- **🔍 Traces**: Grafana Tempo - Distributed tracing
- **🔥 Profiles**: Grafana Pyroscope - Continuous profiling
- **📊 Dashboards**: Grafana - Unified observability platform
- **📡 Collection**: Grafana Alloy - Telemetry data collector

### 🔧 **Auto-Instrumentation & Testing**
- **Beyla** - eBPF auto-instrumentation for each microservice
- **k6** - Load testing with metrics export to Mimir

## Quick Start

### Prerequisites

- Kubernetes cluster (v1.21+)
- Helm 3.8+
- At least 4GB of available memory
- At least 2 CPU cores

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd intro-to-mltp/k8s-helm
   ```

2. **Install the chart:**
   ```bash
   helm install grafana-mltp grafana-mltp-stack/
   ```

3. **Wait for all pods to be ready:**
   ```bash
   kubectl get pods -n grafana-mltp -w
   ```

4. **Access Grafana:**
   ```bash
   kubectl port-forward -n grafana-mltp svc/grafana-mltp-grafana 3000:3000
   ```
   
   Open http://localhost:3000 (admin/admin)

## Configuration

### Global Settings

```yaml
global:
  namespace: grafana-mltp
  storageClass: ""  # Use default storage class
  nodeSelector: {}
  tolerations: []
  affinity: {}
```

### Microservices Configuration

```yaml
microservices:
  enabled: true
  
  server:
    enabled: true
    image:
      repository: grafana/intro-to-mltp
      tag: mythical-beasts-server-latest
    ports:
      http: 4000
      alt: 80
```

### Infrastructure Configuration

```yaml
infrastructure:
  postgresql:
    enabled: true
    persistence:
      size: 8Gi
    auth:
      postgresPassword: "mythical"
  
  rabbitmq:
    enabled: true
```

### Observability Stack Configuration

```yaml
observability:
  grafana:
    enabled: true
    persistence:
      size: 1Gi
  
  alloy:
    enabled: true
  
  tempo:
    enabled: true
  
  loki:
    enabled: true
  
  mimir:
    enabled: true
  
  pyroscope:
    enabled: true
```

### Auto-Instrumentation Configuration

```yaml
beyla:
  enabled: true
  services:
    server:
      enabled: true
      openPort: "4000"
    requester:
      enabled: true
      openPort: "4001"
    recorder:
      enabled: true
      openPort: "4002"
```

### Load Testing Configuration

```yaml
k6:
  enabled: true
  env:
    duration: "3600s"
    vus: "4"
```

### Service Exposure Configuration

```yaml
service:
  type: NodePort  # Use LoadBalancer for cloud environments
  autoExpose:
    enabled: true  # Enable automatic port exposure
    services:
      grafana:
        enabled: true
        nodePort: 30000  # External port for Grafana
      mythicalServer:
        enabled: true
        nodePort: 30001  # External port for Mythical Server
      # Configure individual services as needed
      postgresql:
        enabled: false  # Keep database internal for security
```

**Auto-Expose Options:**
- `enabled: true` - Automatically expose services as NodePort
- `enabled: false` - Use ClusterIP only (manual port-forwarding required)
- Individual service control via `services.<serviceName>.enabled`

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Requester     │───▶│     Server      │───▶│    Recorder     │
│   (Port 4001)   │    │   (Port 4000)   │    │   (Port 4002)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Beyla (eBPF)   │    │  Beyla (eBPF)   │    │  Beyla (eBPF)   │
│ Auto-Instrument │    │ Auto-Instrument │    │ Auto-Instrument │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                    ┌─────────────────┐
                    │  Grafana Alloy  │
                    │   (Collector)   │
                    └─────────────────┘
                                 │
                ┌────────────────┼────────────────┐
                ▼                ▼                ▼
    ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
    │      Tempo      │ │      Loki       │ │     Mimir       │
    │    (Traces)     │ │     (Logs)      │ │   (Metrics)     │
    └─────────────────┘ └─────────────────┘ └─────────────────┘
                                 │
                                 ▼
                    ┌─────────────────┐
                    │   Pyroscope     │
                    │   (Profiles)    │
                    └─────────────────┘
                                 │
                                 ▼
                    ┌─────────────────┐
                    │    Grafana      │
                    │  (Dashboard)    │
                    └─────────────────┘
```

## Features

### 🔧 **Complete MLTP Stack**
- **Metrics**: Prometheus-compatible metrics with Mimir
- **Logs**: Structured logging with Loki
- **Traces**: Distributed tracing with Tempo
- **Profiles**: Continuous profiling with Pyroscope

### 🤖 **Auto-Instrumentation**
- **eBPF-based**: No code changes required
- **Language Agnostic**: Works with any application
- **Zero Overhead**: Minimal performance impact

### 📊 **Pre-configured Dashboards**
- Service topology and health
- Request rates and latencies
- Error rates and patterns
- Resource utilization

### 🔗 **Integrated Experience**
- **Traces to Logs**: Navigate from traces to related logs
- **Traces to Metrics**: Jump from traces to metrics
- **Metrics to Traces**: Drill down from metrics to traces
- **Profiles Integration**: Profile data linked to traces

## Service Exposure & Access

### 🚀 **Auto-Expose Feature**

This chart includes an **auto-expose** feature that automatically exposes services as NodePort services, similar to how Docker Compose exposes ports. This eliminates the need for manual port-forwarding.

#### **Configuration**

Auto-expose is **enabled by default** and can be configured in `values.yaml`:

```yaml
service:
  type: NodePort  # Change to LoadBalancer for cloud environments
  autoExpose:
    enabled: true  # Set to false to disable auto port exposure
    services:
      grafana:
        enabled: true
        nodePort: 30000
      mythicalServer:
        enabled: true  
        nodePort: 30001
      # ... other services
```

#### **Auto-Exposed Ports**

When auto-expose is enabled, these services are automatically accessible:

| Service | External Port | Internal Port | URL |
|---------|---------------|---------------|-----|
| **Grafana Dashboard** | 30000 | 3000 | http://localhost:30000 |
| **Alloy Collector** | 30345 | 12345 | http://localhost:30345 |
| **Mythical Server** | 30001 | 4000 | http://localhost:30001 |
| **Mythical Requester** | 30002 | 4001 | http://localhost:30002 |
| **Mythical Recorder** | 30003 | 4002 | http://localhost:30003 |
| **Loki Logs** | 30100 | 3100 | http://localhost:30100 |
| **Mimir Metrics** | 30200 | 9009 | http://localhost:30200 |
| **Tempo Traces** | 30300 | 3200 | http://localhost:30300 |
| **Pyroscope Profiling** | 30400 | 4040 | http://localhost:30400 |
| **RabbitMQ Management** | 30500 | 15672 | http://localhost:30500 |
| **RabbitMQ AMQP** | 30501 | 5672 | amqp://localhost:30501 |

> **Note**: PostgreSQL is intentionally **not exposed** externally for security reasons.

#### **Quick Access Script**

Use the included script to see current port mappings:

```bash
# Show configured auto-exposed ports
./show-auto-exposed-ports.sh

# Show currently exposed ports (after deployment)
./show-exposed-ports.sh
```

### Manual Port Forward Commands (Alternative)

```bash
# Grafana Dashboard
kubectl port-forward -n grafana-mltp svc/grafana-mltp-grafana 3000:3000

# Mythical Beasts Server API
kubectl port-forward -n grafana-mltp svc/grafana-mltp-mythical-server 4000:4000

# RabbitMQ Management UI
kubectl port-forward -n grafana-mltp svc/grafana-mltp-rabbitmq 15672:15672

# Direct access to observability components
kubectl port-forward -n grafana-mltp svc/grafana-mltp-tempo 3200:3200      # Tempo
kubectl port-forward -n grafana-mltp svc/grafana-mltp-loki 3100:3100       # Loki
kubectl port-forward -n grafana-mltp svc/grafana-mltp-mimir 9009:9009      # Mimir
kubectl port-forward -n grafana-mltp svc/grafana-mltp-pyroscope 4040:4040  # Pyroscope
```

### API Testing

```bash
# Test the Mythical Beasts API
curl -X POST http://localhost:4000/unicorn \
  -H "Content-Type: application/json" \
  -d '{"name": "sparkles"}'

curl http://localhost:4000/unicorn

curl -X DELETE http://localhost:4000/unicorn \
  -H "Content-Type: application/json" \
  -d '{"name": "sparkles"}'
```

## Monitoring & Observability

### Pre-configured Datasources in Grafana

1. **Mimir** (Metrics) - `http://grafana-mltp-mimir:9009/prometheus`
2. **Loki** (Logs) - `http://grafana-mltp-loki:3100`
3. **Tempo** (Traces) - `http://grafana-mltp-tempo:3200`
4. **Pyroscope** (Profiles) - `http://grafana-mltp-pyroscope:4040`

### Key Metrics to Monitor

- **Request Rate**: Requests per second across services
- **Response Time**: P50, P95, P99 latencies
- **Error Rate**: 4xx/5xx error percentages
- **Resource Usage**: CPU, Memory, Disk usage
- **Queue Depth**: RabbitMQ message backlogs

## Troubleshooting

### Common Issues

1. **Pods not starting**: Check resource limits and node capacity
   ```bash
   kubectl describe pods -n grafana-mltp
   kubectl top nodes
   ```

2. **PVC binding issues**: Verify storage class availability
   ```bash
   kubectl get pv,pvc -n grafana-mltp
   kubectl get storageclass
   ```

3. **Service connectivity**: Check service discovery
   ```bash
   kubectl get svc -n grafana-mltp
   kubectl get endpoints -n grafana-mltp
   ```

### Debug Commands

```bash
# Check all resources
kubectl get all -n grafana-mltp

# View logs for specific components
kubectl logs -n grafana-mltp -l app.kubernetes.io/component=alloy
kubectl logs -n grafana-mltp -l app.kubernetes.io/component=grafana
kubectl logs -n grafana-mltp -l app.kubernetes.io/component=mythical-server

# Check k6 load test results
kubectl logs -n grafana-mltp -l app.kubernetes.io/component=k6-loadtest
```

## Customization

### Adding Custom Dashboards

Place JSON dashboard files in the Grafana dashboards ConfigMap or mount them as volumes.

### Custom Alloy Configuration

Override the Alloy configuration in `values.yaml`:

```yaml
configOverrides:
  alloy: |
    // Your custom Alloy configuration
    otelcol.receiver.otlp "default" {
      grpc {
        endpoint = "0.0.0.0:4317"
      }
      http {
        endpoint = "0.0.0.0:4318"
      }
      output {
        traces  = [otelcol.exporter.otlp.tempo.input]
        metrics = [otelcol.exporter.prometheus.mimir.input]
        logs    = [otelcol.exporter.loki.loki.input]
      }
    }
```

## Production Considerations

### Security
- Change default passwords
- Enable RBAC and network policies
- Use proper storage classes with encryption
- Configure TLS for external access

### Scalability
- Adjust resource limits based on load
- Consider horizontal scaling for stateless components
- Use dedicated storage for high-throughput scenarios

### High Availability
- Deploy across multiple availability zones
- Configure proper backup strategies
- Implement monitoring and alerting

## Uninstallation

```bash
helm uninstall grafana-mltp -n grafana-mltp
kubectl delete namespace grafana-mltp
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm lint` and `helm template`
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Support

For issues and questions:
- GitHub Issues: [Create an issue](https://github.com/grafana/intro-to-mltp/issues)
- Documentation: [Grafana Documentation](https://grafana.com/docs/)
- Community: [Grafana Community](https://community.grafana.com/)
