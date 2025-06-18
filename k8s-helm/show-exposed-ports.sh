#!/bin/bash

# Show Exposed Ports Script
# This script displays all the exposed NodePort services like Docker Compose

echo "🚀 Grafana MLTP Stack - Exposed Services"
echo "========================================"
echo

# Get node IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
if [ -z "$NODE_IP" ]; then
    NODE_IP="localhost"
fi

# Function to check if a service is exposed
check_service() {
    local service_name=$1
    local description=$2
    local path=$3
    
    SERVICE=$(kubectl get svc -n grafana-mltp "$service_name" -o jsonpath='{.spec.type}' 2>/dev/null)
    if [ "$SERVICE" = "NodePort" ]; then
        PORT=$(kubectl get svc -n grafana-mltp "$service_name" -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
        if [ ! -z "$PORT" ]; then
            echo "✅ $description"
            echo "   🌐 http://$NODE_IP:$PORT$path"
            echo
        fi
    fi
}

# Check all services
check_service "grafana-mltp-stack-grafana" "Grafana Dashboard" ""
check_service "grafana-mltp-stack-mythical-server" "Mythical Server API" ""
check_service "grafana-mltp-stack-mythical-requester" "Mythical Requester Metrics" "/metrics"
check_service "grafana-mltp-stack-mythical-recorder" "Mythical Recorder Metrics" "/metrics"
check_service "grafana-mltp-stack-loki" "Loki (Logs)" ""
check_service "grafana-mltp-stack-mimir" "Mimir (Metrics)" ""
check_service "grafana-mltp-stack-tempo" "Tempo (Traces)" ""
check_service "grafana-mltp-stack-pyroscope" "Pyroscope (Profiling)" ""
check_service "mythical-queue" "RabbitMQ Management" ""

echo "📝 Usage Examples:"
echo "=================="
echo
echo "# Test Mythical Beasts API:"
echo "curl -X POST http://$NODE_IP:30001/unicorn -H \"Content-Type: application/json\" -d '{\"name\": \"sparkles\"}'"
echo "curl http://$NODE_IP:30001/unicorn"
echo
echo "# View metrics:"
echo "curl http://$NODE_IP:30002/metrics  # Requester metrics"
echo "curl http://$NODE_IP:30003/metrics  # Recorder metrics"
echo
echo "# Access observability tools:"
echo "# - Grafana: http://$NODE_IP:30000 (admin/admin)"
echo "# - Loki: http://$NODE_IP:30100"
echo "# - Mimir: http://$NODE_IP:30200" 
echo "# - Tempo: http://$NODE_IP:30300"
echo "# - Pyroscope: http://$NODE_IP:30400"
echo "# - RabbitMQ: http://$NODE_IP:30500"
echo
echo "💡 To disable auto-exposure, set service.autoExpose.enabled=false in values.yaml"
