# Skaffold Development Mode - Complete Guide

This guide shows you how to develop the Mythical Beasts microservices with **hot reloading** and **live updates** using Skaffold, just like `docker-compose watch`.

## 🚀 Quick Start

1. **Start Development Mode**:
   ```bash
   cd k8s-helm
   ./start-dev.sh
   ```

2. **Edit Source Code**: Make changes to files in `../source/` and watch them sync automatically!

3. **Access Services**:
   - **Grafana Dashboard**: http://localhost:3000
   - **Mythical Server API**: http://localhost:4000
   - **Mythical Requester**: http://localhost:4001/metrics
   - **Mythical Recorder**: http://localhost:4002/metrics

## 🔥 Hot Reload Features

### **Source Code Sync**
When you edit JavaScript files, Skaffold automatically syncs them to running containers:

```bash
# Edit any of these files for instant updates:
source/mythical-beasts-server/index.js
source/mythical-beasts-requester/index.js  
source/mythical-beasts-recorder/index.js
source/common/*.js
```

### **What Gets Synced**
- ✅ **JavaScript files** (`.js`) - Live sync, no restart
- ✅ **Common modules** - Shared across all services
- 🔄 **Package.json changes** - Triggers rebuild
- 🔄 **Dockerfile changes** - Triggers rebuild

### **No Restart Required**
Node.js applications automatically pick up changes to `.js` files without container restarts, making development super fast!

## 🏗️ Build Process

### **Local Image Building**
Skaffold builds images locally from source using the same Dockerfile as production:

```dockerfile
# Multi-stage build process
FROM node:23-alpine3.20 AS builder
ARG SERVICE  # mythical-beasts-server|requester|recorder

# Install dependencies
COPY ${SERVICE}/package.json /usr/src/app/
RUN npm install --production

# Runtime image
FROM node:23-alpine3.20
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY ${SERVICE}/*.js /usr/src/app/
COPY common/*.js /usr/src/app/
```

### **Build Performance**
- **Incremental builds** - Only changed layers rebuild
- **BuildKit support** - Faster, more efficient builds
- **Local caching** - Reuses layers between builds
- **Parallel builds** - All services build simultaneously

## 🎯 Development Workflow

### **1. Code-Save-See Cycle**
```bash
# 1. Edit source code
vim ../source/mythical-beasts-server/index.js

# 2. Save file (Ctrl+S)
# 3. See changes instantly in Kubernetes!
```

### **2. Debugging**
```bash
# View logs for a specific service
kubectl logs -f -n mltp-dev deployment/grafana-mltp-stack-mythical-server

# Get shell access to container
kubectl exec -it -n mltp-dev deployment/grafana-mltp-stack-mythical-server -- sh

# Check service status
kubectl get pods -n mltp-dev -w
```

### **3. Testing APIs**
```bash
# Test the server API
curl -X POST http://localhost:4000/unicorn \\
  -H "Content-Type: application/json" \\
  -d '{"name": "sparkles"}'

# Get all unicorns
curl http://localhost:4000/unicorn

# Check metrics
curl http://localhost:4001/metrics
curl http://localhost:4002/metrics
```

## 🛠️ Development Commands

### **Start Development**
```bash
./start-dev.sh start          # Start development mode
./start-dev.sh                # Same as start (default)
```

### **Check Status**
```bash
./start-dev.sh status         # Show what's running
./start-dev.sh check          # Validate prerequisites
```

### **Clean Up**
```bash
./start-dev.sh clean          # Clean up everything
```

### **Manual Skaffold Commands**
```bash
# Start development mode (manual)
skaffold dev --filename=skaffold.yaml

# Delete deployments
skaffold delete --filename=skaffold.yaml

# Build only (no deploy)
skaffold build --filename=skaffold.yaml
```

## 📦 What Gets Deployed

### **Microservices** (with local images)
- **mythical-beasts-server** - API server
- **mythical-beasts-requester** - Request generator  
- **mythical-beasts-recorder** - Queue consumer

### **Infrastructure**
- **PostgreSQL** - Database
- **RabbitMQ** - Message queue

### **Observability Stack**
- **Grafana** - Dashboards and visualization
- **Loki** - Log aggregation
- **Tempo** - Distributed tracing
- **Mimir** - Metrics storage
- **Pyroscope** - Continuous profiling
- **Alloy** - Telemetry collector

### **Auto-Instrumentation**
- **Beyla** - eBPF-based automatic instrumentation

## 🌐 Port Forwarding

Skaffold automatically forwards these ports:

| Service | Local Port | Description |
|---------|------------|-------------|
| Grafana | 3000 | Dashboard UI |
| Mythical Server | 4000 | API endpoints |
| Mythical Requester | 4001 | Metrics endpoint |
| Mythical Recorder | 4002 | Metrics endpoint |
| Loki | 3100 | Log queries |
| Mimir | 9009 | Metrics queries |
| Tempo | 3200 | Trace queries |

## 🔧 Configuration

### **Development Values**
The `dev-values-skaffold.yaml` file configures development mode:

```yaml
development:
  mode: true                    # Enable development mode
  
microservices:
  server:
    image:
      repository: mythical-beasts-server  # Local image name
      tag: latest
      pullPolicy: Never                   # Don't pull from registry
      
service:
  autoExpose:
    enabled: true              # Auto-expose services
```

### **Skaffold Configuration**
The `skaffold.yaml` defines the development workflow:

```yaml
build:
  artifacts:
    - image: mythical-beasts-server
      context: ../source
      docker:
        dockerfile: docker/Dockerfile
        buildArgs:
          SERVICE: mythical-beasts-server
      sync:                    # Hot reload configuration
        manual:
          - src: "mythical-beasts-server/**/*.js"
            dest: /usr/src/app/
```

## 🚨 Troubleshooting

### **Common Issues**

#### **"Image pull backoff" Error**
```bash
# Make sure images are being built locally
skaffold build --filename=skaffold.yaml

# Check image pull policy is set to Never
kubectl get pod -n mltp-dev -o yaml | grep imagePullPolicy
```

#### **File Sync Not Working**
```bash
# Check if files are being watched
skaffold dev --verbosity=debug

# Verify file paths in skaffold.yaml match your changes
ls -la ../source/mythical-beasts-server/
```

#### **Port Forward Conflicts**
```bash
# Check what's using the port
lsof -i :3000

# Kill conflicting processes
pkill -f "port-forward"
```

#### **Slow Builds**
```bash
# Enable Docker BuildKit for faster builds
export DOCKER_BUILDKIT=1

# Clean up old images
docker system prune
```

### **Debugging Steps**

1. **Check Prerequisites**:
   ```bash
   ./start-dev.sh check
   ```

2. **Verify Kubernetes Connection**:
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

3. **Check Pod Status**:
   ```bash
   kubectl get pods -n mltp-dev
   kubectl describe pod -n mltp-dev <pod-name>
   ```

4. **View Logs**:
   ```bash
   kubectl logs -f -n mltp-dev deployment/grafana-mltp-stack-mythical-server
   ```

## 🆚 Docker Compose vs Skaffold

### **Docker Compose Watch** (Previous)
```yaml
# docker-compose.yml
services:
  mythical-server:
    build:
      context: ./source
      dockerfile: docker/Dockerfile
    develop:
      watch:
        - action: sync
          path: ./source/mythical-beasts-server
          target: /usr/src/app
```

### **Skaffold** (Current)
```yaml
# skaffold.yaml
build:
  artifacts:
    - image: mythical-beasts-server
      sync:
        manual:
          - src: "mythical-beasts-server/**/*.js"
            dest: /usr/src/app/
```

### **Benefits of Skaffold**
- ✅ **Kubernetes Native** - Deploy to real Kubernetes
- ✅ **Production Parity** - Same YAML as production
- ✅ **Advanced Debugging** - kubectl, logs, exec
- ✅ **Observability** - Full metrics, logs, traces
- ✅ **Scalability** - Can scale to multiple nodes
- ✅ **Cloud Ready** - Works with any Kubernetes cluster

## 🎓 Learning More

### **Skaffold Documentation**
- [Skaffold.dev](https://skaffold.dev/)
- [File Sync](https://skaffold.dev/docs/pipeline-stages/filesync/)
- [Debugging](https://skaffold.dev/docs/workflows/debug/)

### **Kubernetes Development**
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Development Best Practices](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)

### **Observability**
- [Grafana Documentation](https://grafana.com/docs/)
- [OpenTelemetry](https://opentelemetry.io/)
- [eBPF and Beyla](https://grafana.com/oss/beyla/)

## 🎉 Happy Developing!

You now have a powerful development environment that combines:
- **🔥 Hot reloading** like Docker Compose
- **🏗️ Production parity** with Kubernetes  
- **📊 Full observability** with Grafana stack
- **🚀 Fast builds** with Skaffold optimization

Make some changes to your code and watch them appear instantly in your Kubernetes cluster!
