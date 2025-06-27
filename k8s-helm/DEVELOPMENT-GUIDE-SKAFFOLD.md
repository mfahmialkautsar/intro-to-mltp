# Development Mode with Skaffold

This document explains how to use Skaffold for local development with hot reload capabilities, similar to Docker Compose watch.

## 🚀 Quick Start

### Prerequisites

1. **Install Skaffold**:
   ```bash
   # macOS
   brew install skaffold
   
   # Linux
   curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
   sudo install skaffold /usr/local/bin/
   ```

2. **Kubernetes Cluster**: Ensure you have a local Kubernetes cluster running:
   - Docker Desktop with Kubernetes enabled
   - minikube
   - kind
   - k3s

3. **Verify Setup**:
   ```bash
   kubectl cluster-info
   skaffold version
   ```

### Start Development Mode

```bash
# Easy way - use the dev script
./dev-mode.sh

# Or directly with skaffold
cd k8s-helm
skaffold dev --port-forward
```

## 🔥 Features

### Hot Reload
- **Source Code Changes**: JavaScript files in `source/` are automatically synced to running containers
- **Fast Rebuild**: Only changed files are synced, no full image rebuild needed
- **Live Updates**: Changes are reflected immediately without pod restarts

### Local Image Building
- **From Source**: Images are built locally from `source/docker/Dockerfile`
- **Multiple Services**: Builds `mythical-beasts-server`, `mythical-beasts-requester`, and `mythical-beasts-recorder`
- **Build Args**: Uses proper SERVICE build arguments for each service

### Port Forwarding
Automatic port forwarding for easy access:
- **Grafana**: http://localhost:3000
- **Mythical Server**: http://localhost:4000
- **Mythical Requester**: http://localhost:4001
- **Mythical Recorder**: http://localhost:4002

## 📝 Development Workflow

### 1. Start Development
```bash
./dev-mode.sh dev
```

This will:
- Build images from local source
- Deploy to `mltp-dev` namespace
- Start watching for file changes
- Forward ports for easy access
- Show logs in real-time

### 2. Make Code Changes
Edit any JavaScript file in:
- `source/mythical-beasts-server/`
- `source/mythical-beasts-requester/`
- `source/mythical-beasts-recorder/`
- `source/common/`

Changes are automatically synced to the running containers!

### 3. Access Services
- **Grafana Dashboard**: http://localhost:3000 (admin/admin)
- **API Endpoints**: http://localhost:4000, 4001, 4002
- **Metrics**: Each service exposes `/metrics` endpoint

### 4. View Logs
```bash
./dev-mode.sh logs
```

### 5. Check Status
```bash
./dev-mode.sh status
```

### 6. Clean Up
```bash
./dev-mode.sh delete
```

## 🛠 Available Commands

| Command | Description |
|---------|-------------|
| `./dev-mode.sh` | Start development mode (default) |
| `./dev-mode.sh dev` | Start development mode with hot reload |
| `./dev-mode.sh run` | Run once without file watching |
| `./dev-mode.sh delete` | Delete development deployment |
| `./dev-mode.sh debug` | Start with debug output |
| `./dev-mode.sh build` | Build images only |
| `./dev-mode.sh deploy` | Deploy only (using existing images) |
| `./dev-mode.sh ports` | Show port forwarding info |
| `./dev-mode.sh logs` | Show logs from all services |
| `./dev-mode.sh status` | Show deployment status |

## ⚙️ Configuration Files

### Skaffold Configuration
- **`skaffold.yaml`**: Main configuration with dev and prod profiles
- **`k8s-helm/skaffold.yaml`**: Helm-specific development configuration

### Helm Values
- **`k8s-helm/dev-values-skaffold.yaml`**: Development overrides
  - Local image repositories
  - Reduced resource requirements
  - Faster health checks
  - Auto-exposure enabled

### Image Building
- **Context**: `source/` directory
- **Dockerfile**: `source/docker/Dockerfile`
- **Build Args**: SERVICE={server,requester,recorder}

## 🔄 File Sync Configuration

```yaml
sync:
  manual:
    - src: "mythical-beasts-server/**/*.js"
      dest: /usr/src/app/
      strip: "mythical-beasts-server/"
    - src: "common/**/*.js"
      dest: /usr/src/app/
      strip: "common/"
```

## 🐳 Comparison with Docker Compose

| Feature | Docker Compose | Skaffold |
|---------|---------------|----------|
| **Hot Reload** | `watch` + `sync` | File sync |
| **Multi-service** | ✅ | ✅ |
| **Port Forwarding** | `ports` mapping | `portForward` |
| **Build from Source** | `build` context | `artifacts` |
| **Environment** | Docker | Kubernetes |
| **Service Discovery** | Docker networks | Kubernetes services |
| **Persistence** | Docker volumes | Kubernetes PVCs |

## 🔧 Advanced Usage

### Custom Profiles
```bash
# Development mode
skaffold dev -p dev

# Production deployment
skaffold run -p prod
```

### Manual Commands
```bash
# Build specific image
skaffold build -a mythical-beasts-server

# Deploy with custom values
skaffold deploy --helm-values dev-custom.yaml
```

### Debugging
```bash
# Verbose output
skaffold dev --verbosity=debug

# Skip tests
skaffold dev --skip-tests
```

## 🚨 Troubleshooting

### Common Issues

1. **Images not updating**:
   ```bash
   # Force rebuild
   skaffold dev --no-prune=false --cache-artifacts=false
   ```

2. **Port conflicts**:
   ```bash
   # Check what's using the port
   lsof -i :3000
   ```

3. **Kubernetes context**:
   ```bash
   # Check current context
   kubectl config current-context
   ```

4. **Sync not working**:
   - Ensure file paths match the sync configuration
   - Check container file permissions

### Reset Everything
```bash
./dev-mode.sh delete
docker system prune -f
skaffold dev
```

## 📚 Resources

- [Skaffold Documentation](https://skaffold.dev/)
- [Skaffold File Sync](https://skaffold.dev/docs/workflows/file-sync/)
- [Helm with Skaffold](https://skaffold.dev/docs/deployers/helm/)

---

Happy developing! 🎉
