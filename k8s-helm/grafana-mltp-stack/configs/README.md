# Configuration Files Directory

This directory contains externalized configuration files for all major services in the Grafana MLTP Stack.

## Files Overview

### Core Observability Services
- **`loki-config.yaml`** - Log aggregation service configuration
- **`tempo-config.yaml`** - Distributed tracing backend configuration  
- **`mimir-config.yaml`** - Metrics storage and querying configuration

### Telemetry Collection
- **`alloy-config.alloy`** - Main telemetry collection pipeline configuration
- **`alloy-endpoints.json`** - Service endpoint definitions for monitoring

### Auto-Instrumentation
- **`beyla-config.yml`** - Automatic instrumentation for Node.js microservices

### Visualization & Testing
- **`grafana-datasources.yaml`** - Grafana data source connection definitions
- **`k6-loadtest.js`** - Load testing script for performance validation

## Placeholder System

Configuration files use placeholders that are dynamically replaced during Helm template rendering:

### Service Endpoints
- `__ALLOY_ENDPOINT__` - Alloy service endpoint
- `__MIMIR_ENDPOINT__` - Mimir service endpoint  
- `__LOKI_ENDPOINT__` - Loki service endpoint
- `__TEMPO_ENDPOINT__` - Tempo service endpoint
- `__PYROSCOPE_ENDPOINT__` - Pyroscope service endpoint
- `__GRAFANA_METRICS_ENDPOINT__` - Grafana metrics endpoint

### Application Endpoints
- `__MYTHICAL_SERVER_URL__` - Full URL for mythical server (used in K6)
- `__MYTHICAL_*_ENDPOINT__` - Individual microservice endpoints

### Environment Variables
- `__CLUSTER_NAME__` - Kubernetes cluster name

## Editing Guidelines

1. **Direct Editing**: Modify configuration files directly for changes
2. **Placeholder Usage**: Use placeholders for dynamic values that change per deployment
3. **Validation**: Run `../validate-templates.sh` after making changes
4. **Syntax**: Maintain proper YAML/JSON/JavaScript syntax as appropriate

## Configuration Overrides

Individual configurations can be overridden via `values.yaml`:

```yaml
configOverrides:
  loki: |
    # Custom Loki configuration
    server:
      http_listen_port: 3100
  
  alloy: |
    # Custom Alloy configuration
    otelcol.receiver.otlp "custom" {
      // Custom configuration
    }
```

This allows for deployment-specific customizations while maintaining the base configuration structure.
