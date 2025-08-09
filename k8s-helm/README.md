# Mythical Beasts MLTP - Kubernetes Development

Modern development environment for the Grafana MLTP (Metrics, Logs, Traces, Profiles) stack using Kubernetes and hot reload capabilities.

## 🚀 Quick Start

```bash
# Install prerequisites (macOS)
make setup

# Start development with hot reload
make dev

# Access Grafana dashboard
make dashboard  # Opens http://localhost:3000 (admin/admin)
```

## 📋 Available Commands

```bash
make help         # Show all available commands
make check        # Verify prerequisites  
make dev          # Start development with hot reload
make deploy       # Deploy to production
make status       # Show deployment status
make logs         # Follow service logs
make ports        # Show exposed services
make clean        # Clean up environment
```

## Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl, helm, skaffold
- macOS: Run `make setup` to install automatically

**All commands must be run from this `k8s-helm` directory.**

## 🎭 What You're Building

**The Mythical Beasts Application:**
- 🦄 **Server** - REST API for managing mythical creatures
- 🔄 **Requester** - Client that makes API requests
- 📝 **Recorder** - Records data to PostgreSQL via RabbitMQ

**Complete Observability Stack:**
- 📊 **Grafana** - Unified dashboards
- 📈 **Mimir** - Long-term metrics storage
- 📝 **Loki** - Log aggregation  
- 🔍 **Tempo** - Distributed tracing
- 🔥 **Pyroscope** - Continuous profiling
- 📡 **Alloy** - Telemetry collection
- 🎯 **Beyla** - Auto-instrumentation (eBPF)
- ⚡ **k6** - Load testing

## 🔥 Development Features

### Hot Reload
Edit source code and see changes instantly:
```bash
# Edit any file in source/
source/mythical-beasts-server/index.js
source/mythical-beasts-requester/index.js
source/mythical-beasts-recorder/index.js
source/common/

# Changes sync automatically, no restart needed!
```

### Local Image Building
- Images built from your local source code
- Multi-stage Docker builds with caching
- Parallel builds for all services
- BuildKit support for fast iterations

### Auto-Instrumentation
- Zero-code observability with Beyla
- Automatic metrics, logs, and traces
- eBPF-based instrumentation
- No application changes required

## 🛠 Available Commands

### Development
```bash
make dev          # Start with hot reload
make dev-debug    # Start with verbose logging  
make dev-build    # Build images only
make dev-run      # Deploy once (no watching)
```

### Deployment
```bash
make deploy       # Deploy to production
make deploy-dev   # Deploy dev with registry images
make upgrade      # Upgrade existing deployment
```

### Monitoring
```bash
make status       # Show pod status
make logs         # Follow all logs
make ports        # Show exposed services
make watch        # Watch pods in real-time
```

### Testing & Validation
```bash
make test         # Run full test suite
make validate     # Validate configurations
make lint         # Lint Helm charts
```

### Quick Access
```bash
make dashboard    # Open Grafana
make api          # Test API endpoints
make shell        # Get container shell
```

### Cleanup
```bash
make clean        # Clean development
make clean-prod   # Clean production  
make reset        # Clean and restart
```

## 🏗 Architecture

```
┌─────────────┐    HTTP    ┌─────────────┐    AMQP    ┌─────────────┐
│  Requester  │ ────────▶  │   Server    │ ────────▶  │  Recorder   │
│             │            │             │            │             │
│ Port: 4001  │            │ Port: 4000  │            │ Port: 4002  │
└─────────────┘            └─────────────┘            └─────────────┘
                                   │                          │
                                   ▼                          ▼
                           ┌─────────────┐            ┌─────────────┐
                           │  RabbitMQ   │            │ PostgreSQL  │
                           │             │            │             │
                           │ Management  │            │ Database    │
                           └─────────────┘            └─────────────┘
```

**Observability Layer:**
- Every service automatically instrumented with Beyla
- Metrics, logs, traces collected by Alloy
- Data stored in Mimir, Loki, Tempo
- Visualized in Grafana dashboards

## 🎯 Development Workflow

### 1. Code → Save → See
```bash
# 1. Start development
make dev

# 2. Edit source code
vim source/mythical-beasts-server/index.js

# 3. Save file (Ctrl+S)
# 4. Changes appear instantly in Kubernetes!
```

### 2. Debug & Monitor
```bash
# View logs
make logs

# Check service status  
make status

# Access Grafana dashboards
make dashboard

# Test the API
make api
```

### 3. Validate & Test
```bash
# Run tests before committing
make test

# Validate configurations
make validate

# Check exposed ports
make ports
```

## 🔧 Configuration

### Resource Allocation
Services run with reduced resources in development:
- **CPU**: 0.1-0.5 cores per service
- **Memory**: 128-512Mi per service  
- **Storage**: Minimal persistent volumes

### Port Forwarding
Development automatically forwards these ports:
- **3000** - Grafana dashboard
- **4000** - Mythical Server API
- **4001** - Requester metrics
- **4002** - Recorder metrics

### Environment Variables
Key environment settings:
```bash
# Namespace configuration
DEV_NAMESPACE=mltp-dev      # Development namespace
PROD_NAMESPACE=mltp         # Production namespace

# Image configuration  
REGISTRY_NAME=grafana/intro-to-mltp
VERSION=latest
```

## 🧪 Testing the Stack

### API Testing
```bash
# Test unicorn creation
curl -X POST http://localhost:4000/unicorn \
  -H "Content-Type: application/json" \
  -d '{"name": "sparkles", "color": "rainbow"}'

# List all unicorns
curl http://localhost:4000/unicorn

# Check metrics
curl http://localhost:4001/metrics
```

### Load Testing
The k6 service automatically generates realistic load:
- Creates and queries mythical creatures
- Generates metrics, logs, and traces
- Exports data to the observability stack

### Observability Validation
1. **Grafana**: Check all 4 datasources are healthy
2. **Dashboards**: View pre-built MLTP dashboards
3. **Explore**: Query logs, traces, metrics directly
4. **Alerts**: Monitor service health and performance

## 🚨 Troubleshooting

### Common Issues

**Pods stuck in Pending:**
```bash
make status         # Check pod status
kubectl describe pod -n mltp-dev <pod-name>
```

**Port conflicts:**
```bash
make ports          # Check what's exposed
lsof -i :3000      # Check port usage
```

**Image build failures:**
```bash
make dev-debug     # Start with verbose logging
docker system prune -f  # Clean Docker cache
```

**Skaffold sync issues:**
```bash
make reset         # Clean restart
```

### Getting Help
```bash
make help          # Show all commands
make status        # Check current state
make logs          # View service logs
```

### Reset Everything
```bash
make clean         # Clean development
make setup         # Reinstall prerequisites  
make dev           # Start fresh
```

## 🎓 Next Steps

1. **Explore Dashboards** - Visit Grafana and explore the pre-built dashboards
2. **Modify Code** - Edit the source files and see hot reload in action
3. **Add Features** - Extend the mythical beasts API
4. **Create Dashboards** - Build custom observability dashboards
5. **Deploy Production** - Use `make deploy` for production deployment

The development environment gives you a complete, modern observability stack to learn from and experiment with!
