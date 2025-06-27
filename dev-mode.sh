#!/bin/bash

# Skaffold Development Mode Script for Grafana MLTP Stack
# This script provides easy commands for development with hot reload

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if skaffold is installed
check_skaffold() {
    if ! command -v skaffold &> /dev/null; then
        print_error "Skaffold is not installed. Please install it first:"
        echo "  macOS: brew install skaffold"
        echo "  Linux: curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && sudo install skaffold /usr/local/bin/"
        exit 1
    fi
}

# Check if kubectl is installed and has context
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed."
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "kubectl is not connected to a Kubernetes cluster."
        print_warning "Make sure your Kubernetes cluster is running (Docker Desktop, minikube, etc.)"
        exit 1
    fi
}

# Show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Development commands for Grafana MLTP Stack:"
    echo ""
    echo "  dev           Start development mode with hot reload (default)"
    echo "  run           Run once without watching for changes"
    echo "  delete        Delete the development deployment"
    echo "  debug         Run with debug output"
    echo "  build         Build images only (no deployment)"
    echo "  deploy        Deploy only (using existing images)"
    echo "  ports         Show port forwarding info"
    echo "  logs          Show logs from all services"
    echo "  status        Show deployment status"
    echo "  help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                # Start development mode"
    echo "  $0 dev            # Start development mode"
    echo "  $0 debug          # Start with debug output"
    echo "  $0 delete         # Clean up development deployment"
    echo ""
}

# Start development mode with hot reload
start_dev() {
    print_status "Starting Skaffold development mode..."
    print_status "This will:"
    print_status "  - Build local images from source"
    print_status "  - Deploy to mltp-dev namespace"
    print_status "  - Watch for file changes and hot reload"
    print_status "  - Forward ports for easy access"
    echo ""
    
    cd k8s-helm
    skaffold dev --port-forward
}

# Run once without watching
run_once() {
    print_status "Running Skaffold once (no file watching)..."
    cd k8s-helm
    skaffold run
}

# Delete deployment
delete_deployment() {
    print_status "Deleting development deployment..."
    cd k8s-helm
    skaffold delete
    print_success "Development deployment deleted"
}

# Debug mode
debug_mode() {
    print_status "Starting Skaffold in debug mode..."
    cd k8s-helm
    skaffold dev --port-forward --verbosity=debug
}

# Build only
build_only() {
    print_status "Building images only..."
    cd k8s-helm
    skaffold build
}

# Deploy only
deploy_only() {
    print_status "Deploying only (using existing images)..."
    cd k8s-helm
    skaffold deploy
}

# Show port forwarding info
show_ports() {
    echo ""
    print_status "Port forwarding will be available on:"
    echo "  🌐 Grafana Dashboard:     http://localhost:3000"
    echo "  🚀 Mythical Server:       http://localhost:4000"
    echo "  📝 Mythical Requester:    http://localhost:4001" 
    echo "  📊 Mythical Recorder:     http://localhost:4002"
    echo ""
    print_status "Additional services via kubectl port-forward:"
    echo "  kubectl port-forward -n mltp-dev svc/grafana-mltp-stack-loki 3100:3100"
    echo "  kubectl port-forward -n mltp-dev svc/grafana-mltp-stack-mimir 9009:9009"
    echo "  kubectl port-forward -n mltp-dev svc/grafana-mltp-stack-tempo 3200:3200"
    echo ""
}

# Show logs
show_logs() {
    print_status "Showing logs from development deployment..."
    kubectl logs -n mltp-dev -l app.kubernetes.io/name=grafana-mltp-stack --tail=50 -f
}

# Show status
show_status() {
    print_status "Development deployment status:"
    echo ""
    kubectl get pods -n mltp-dev -l app.kubernetes.io/name=grafana-mltp-stack
    echo ""
    kubectl get services -n mltp-dev -l app.kubernetes.io/name=grafana-mltp-stack
}

# Main script logic
main() {
    # Check prerequisites
    check_skaffold
    check_kubectl
    
    # Handle commands
    case "${1:-dev}" in
        "dev"|"develop"|"development")
            start_dev
            ;;
        "run"|"once")
            run_once
            ;;
        "delete"|"clean"|"cleanup")
            delete_deployment
            ;;
        "debug")
            debug_mode
            ;;
        "build")
            build_only
            ;;
        "deploy")
            deploy_only
            ;;
        "ports"|"port-forward"|"forwarding")
            show_ports
            ;;
        "logs"|"log")
            show_logs
            ;;
        "status"|"ps")
            show_status
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
