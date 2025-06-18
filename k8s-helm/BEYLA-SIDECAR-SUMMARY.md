# Beyla Sidecar Configuration Summary

## ✅ COMPLETED CHANGES

### 1. **Converted from Standalone to Sidecar Pattern**

#### **Before**: Standalone Beyla Deployments
- Separate deployment for each service (beyla-server, beyla-requester, beyla-recorder)
- Used `hostPID: true` to access host processes
- Required complex process discovery across container boundaries

#### **After**: Sidecar Pattern with Process Namespace Sharing
- Beyla deployed as sidecar containers within target service pods
- Enabled `shareProcessNamespace: true` for Docker Compose-like container sharing
- Direct process access within the same pod (similar to `pid: "container:target"`)

### 2. **Updated Mythical Service Deployments**

#### **mythical-server-deployment.yaml**
```yaml
spec:
  template:
    spec:
      shareProcessNamespace: true  # Enable process sharing
      containers:
        - name: mythical-server
          # ...existing configuration...
        - name: beyla                # Beyla sidecar
          image: "grafana/beyla:2.1.0"
          securityContext:
            privileged: true
            readOnlyRootFilesystem: true
          env:
            - name: BEYLA_OPEN_PORT
              value: "4000"
            # ...other environment variables...
```

#### **mythical-requester-deployment.yaml**
- ✅ Added `shareProcessNamespace: true`
- ✅ Added Beyla sidecar container with port 4001

#### **mythical-recorder-deployment.yaml**
- ✅ Added `shareProcessNamespace: true`
- ✅ Added Beyla sidecar container with port 4002

### 3. **Disabled Standalone Beyla Deployments**

All standalone Beyla deployment files are now disabled:
- `beyla-server-deployment.yaml` - Disabled with `{{- if false }}`
- `beyla-requester-deployment.yaml` - Disabled with `{{- if false }}`
- `beyla-recorder-deployment.yaml` - Disabled with `{{- if false }}`

### 4. **Docker Compose-like Container Sharing**

#### **Docker Compose Pattern**:
```yaml
services:
  beyla:
    pid: "container:clean-microservices-playground-ecommerce-service-1"
```

#### **Kubernetes Equivalent**:
```yaml
spec:
  template:
    spec:
      shareProcessNamespace: true
      containers:
        - name: target-service
        - name: beyla  # Can access target-service processes
```

## 🔧 TECHNICAL DETAILS

### **Process Namespace Sharing Benefits**
1. **Direct Process Access**: Beyla can instrument processes in the same pod without host-level access
2. **Container-like Behavior**: Similar to Docker Compose `pid: "container:..."` pattern
3. **Improved Security**: No need for `hostPID: true` across the entire cluster
4. **Better Isolation**: Each service has its own instrumentation instance

### **Sidecar Container Configuration**
```yaml
- name: beyla
  image: "grafana/beyla:2.1.0"
  securityContext:
    privileged: true
    readOnlyRootFilesystem: true
  env:
    - name: BEYLA_OPEN_PORT
      value: "4000"  # Target service port
    - name: BEYLA_SERVICE_NAMESPACE
      value: "mythical"
    - name: OTEL_SERVICE_NAME
      value: "beyla-mythical-server"
    - name: OTEL_EXPORTER_OTLP_ENDPOINT
      value: "http://grafana-mltp-stack-alloy:4317"
  volumeMounts:
    - name: var-run-beyla
      mountPath: /var/run/beyla
```

## 🚀 DEPLOYMENT VERIFICATION

### **Test Template Generation**
```bash
cd k8s-helm
helm template grafana-mltp-stack ./grafana-mltp-stack --values ./grafana-mltp-stack/values.yaml | grep -A 10 "shareProcessNamespace"
```

### **Lint Check**
```bash
helm lint ./grafana-mltp-stack
# Result: 1 chart(s) linted, 0 chart(s) failed
```

## 📋 BENEFITS OF THE NEW CONFIGURATION

1. **✅ Docker Compose Compatibility**: Replicates the `pid: "container:..."` pattern
2. **✅ Improved Security**: No host-level PID access required
3. **✅ Better Resource Management**: Beyla lifecycle tied to target service
4. **✅ Simplified Deployment**: Single pod per service with integrated instrumentation
5. **✅ Reduced Complexity**: No separate service discovery needed

## 🎯 NEXT STEPS

The Beyla configuration now matches the Docker Compose pattern where Beyla can access the target container's processes directly through process namespace sharing. This provides the same instrumentation capabilities while maintaining Kubernetes best practices for security and resource management.

Deploy with:
```bash
helm install grafana-mltp-stack ./grafana-mltp-stack
```

The Beyla sidecars will automatically instrument the mythical services with the same process access as the Docker Compose `pid: "container:..."` configuration.
