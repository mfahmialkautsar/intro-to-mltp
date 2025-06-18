#!/bin/bash

# Show Auto-Exposed Ports Configuration
# This script displays the port mappings that will be automatically exposed
# when deploying the Grafana MLTP stack with auto-expose enabled

echo "========================================="
echo "Grafana MLTP Stack - Auto-Exposed Ports"
echo "========================================="
echo ""
echo "The following services will be automatically exposed as NodePort services:"
echo ""

echo "🔍 OBSERVABILITY STACK:"
echo "  Grafana Dashboard:    http://localhost:30000  (Internal: 3000)"
echo "  Alloy Collector:      http://localhost:30345  (Internal: 12345)"
echo "  Loki Logs:           http://localhost:30100  (Internal: 3100)"
echo "  Mimir Metrics:       http://localhost:30200  (Internal: 9009)"
echo "  Tempo Traces:        http://localhost:30300  (Internal: 3200)"
echo "  Pyroscope Profiling: http://localhost:30400  (Internal: 4040)"
echo ""

echo "🏗️  MYTHICAL SERVICES:"
echo "  Mythical Server:     http://localhost:30001  (Internal: 4000)"
echo "  Mythical Requester:  http://localhost:30002  (Internal: 4001)"
echo "  Mythical Recorder:   http://localhost:30003  (Internal: 4002)"
echo ""

echo "🔧 INFRASTRUCTURE:"
echo "  RabbitMQ AMQP:       amqp://localhost:30501  (Internal: 5672)"
echo "  RabbitMQ Management: http://localhost:30500  (Internal: 15672)"
echo "  PostgreSQL:          DISABLED (Security - Internal only)"
echo ""

echo "📝 CONFIGURATION:"
echo "  Auto-expose is enabled in values.yaml"
echo "  Service type: NodePort"
echo "  PostgreSQL is intentionally not exposed for security"
echo ""

echo "🚀 USAGE:"
echo "  1. Deploy: helm install grafana-mltp-stack ./grafana-mltp-stack"
echo "  2. Wait for pods to be ready"
echo "  3. Access services using the URLs above"
echo "  4. Check actual status: ./show-exposed-ports.sh"
echo ""

echo "💡 To disable auto-expose:"
echo "  Set service.autoExpose.enabled: false in values.yaml"
echo ""
