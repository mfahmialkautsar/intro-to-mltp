# 📦 Development Environment Setup

## Install Required Tools

### 1. Install Skaffold

**macOS (Homebrew)**:
```bash
brew install skaffold
```

**macOS (Direct Download)**:
```bash
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-darwin-amd64
sudo install skaffold /usr/local/bin/
```

**Linux**:
```bash
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
sudo install skaffold /usr/local/bin/
```

**Windows**:
```powershell
choco install -y skaffold
```

### 2. Verify Installation
```bash
skaffold version
kubectl version --client
helm version
```

### 3. Setup Kubernetes Cluster

**Docker Desktop**:
1. Enable Kubernetes in Docker Desktop settings
2. Wait for it to start
3. Verify: `kubectl cluster-info`

**Minikube**:
```bash
minikube start
kubectl config use-context minikube
```

**Kind**:
```bash
kind create cluster --name mltp-dev
kubectl config use-context kind-mltp-dev
```

### 4. Test Setup
```bash
./test-dev-setup.sh
```

### 5. Start Development
```bash
./dev-mode.sh
```

## 🎯 What You Get

✅ **Hot Reload**: File changes sync instantly  
✅ **Local Builds**: Images built from your source code  
✅ **Port Forwarding**: Easy access to all services  
✅ **Real-time Logs**: See what's happening  
✅ **Fast Iterations**: No manual docker builds  

Ready to code! 🚀
