SHELL := /bin/bash

# Project configuration
PROJECT_NAME := intro-to-mltp
DEV_NAMESPACE := mltp-dev
PROD_NAMESPACE := mltp
CHART_PATH := ./grafana-mltp-stack
REGISTRY_NAME ?= grafana/intro-to-mltp
VERSION ?= latest
SOURCE_PATH := ../source

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
NC := \033[0m

# Helper functions
define log_info
	echo -e "$(BLUE)ℹ️  $(1)$(NC)"
endef

define log_success
	echo -e "$(GREEN)✅ $(1)$(NC)"
endef

define log_warning
	echo -e "$(YELLOW)⚠️  $(1)$(NC)"
endef

define log_error
	echo -e "$(RED)❌ $(1)$(NC)"
endef

define log_step
	echo -e "$(CYAN)🔧 $(1)$(NC)"
endef

.PHONY: help setup

# Default target
help: ## Show all available commands
	@echo "🎭 Mythical Beasts MLTP Stack"
	@echo "=========================================="
	@echo
	@echo "$(CYAN)📋 Available Commands:$(NC)"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  $(CYAN)%-18s$(NC) %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sort
	@echo
	@echo "$(YELLOW)🚀 Quick Start:$(NC)"
	@echo "  $(CYAN)make setup$(NC)       # Install prerequisites"
	@echo "  $(CYAN)make dev$(NC)         # Start development"
	@echo "  $(CYAN)make deploy$(NC)      # Deploy to production"
	@echo

# =============================================================================
# SETUP & PREREQUISITES
# =============================================================================

setup: ## Install all prerequisites (macOS)
	@$(call log_step,"Installing prerequisites...")
	@if command -v brew >/dev/null 2>&1; then \
		brew install kubectl helm skaffold; \
	else \
		$(call log_error,"Homebrew not found. Please install manually:"); \
		echo "  kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl/"; \
		echo "  helm: https://helm.sh/docs/intro/install/"; \
		echo "  skaffold: https://skaffold.dev/docs/install/"; \
		exit 1; \
	fi
	@$(call log_success,"Prerequisites installed!")

check: ## Check if all required tools are available
	@$(call log_step,"Checking prerequisites...")
	@MISSING=""; \
	for cmd in kubectl helm skaffold docker; do \
		if ! command -v $$cmd >/dev/null 2>&1; then \
			MISSING="$$MISSING $$cmd"; \
		fi; \
	done; \
	if [ -n "$$MISSING" ]; then \
		$(call log_error,"Missing tools:$$MISSING"); \
		echo "Run: make setup"; \
		exit 1; \
	fi
	@if ! kubectl cluster-info >/dev/null 2>&1; then \
		$(call log_error,"Kubernetes cluster not accessible"); \
		echo "Start Docker Desktop or your local cluster"; \
		exit 1; \
	fi
	@$(call log_success,"All prerequisites available")

# =============================================================================
# DEVELOPMENT COMMANDS
# =============================================================================

dev: check ## Start development with hot reload (Skaffold)
	@$(call log_step,"Starting development environment...")
	@$(call log_info,"Building from source with hot reload")
	@$(call log_info,"Namespace: $(DEV_NAMESPACE)")
	@skaffold dev --port-forward --namespace $(DEV_NAMESPACE)

dev-build: check ## Build development images only
	@$(call log_step,"Building development images...")
	@skaffold build

dev-run: check ## Deploy once without file watching
	@$(call log_step,"Deploying development environment...")
	@skaffold run --namespace $(DEV_NAMESPACE)

dev-debug: check ## Start development with verbose logging
	@$(call log_step,"Starting development with debug output...")
	@skaffold dev --port-forward --verbosity=debug --namespace $(DEV_NAMESPACE)

# =============================================================================
# DEPLOYMENT COMMANDS  
# =============================================================================

deploy: check ## Deploy to production
	@$(call log_step,"Deploying to production...")
	@helm upgrade --install $(PROJECT_NAME) $(CHART_PATH) \
		--create-namespace --namespace $(PROD_NAMESPACE) \
		--wait --timeout=15m
	@$(call log_success,"Production deployment complete!")
	@$(call log_info,"Access Grafana: kubectl port-forward -n $(PROD_NAMESPACE) svc/$(PROJECT_NAME)-grafana 3000:3000")

deploy-dev: check ## Deploy development using registry images
	@$(call log_step,"Deploying development with registry images...")
	@helm upgrade --install $(PROJECT_NAME)-dev $(CHART_PATH) \
		--create-namespace --namespace $(DEV_NAMESPACE) \
		--set development.enabled=true \
		--wait --timeout=10m
	@$(call log_success,"Development deployment complete!")

# =============================================================================
# SOURCE & IMAGE MANAGEMENT
# =============================================================================

images: ## Build and push source images
	@$(call log_step,"Building source images...")
	@if [ -z "$(REGISTRY_NAME)" ]; then \
		$(call log_error,"REGISTRY_NAME not set"); \
		exit 1; \
	fi
	@$(SOURCE_PATH)/build-source.sh $(REGISTRY_NAME) $(VERSION)
	@$(call log_success,"Images built and pushed!")

# =============================================================================
# TESTING & VALIDATION
# =============================================================================

test: check ## Run comprehensive test suite
	@$(call log_step,"Running test suite...")
	@$(call log_info,"Validating Helm templates...")
	@helm template test-release $(CHART_PATH) >/dev/null
	@$(call log_info,"Linting Helm chart...")
	@helm lint $(CHART_PATH)
	@$(call log_info,"Testing image builds...")
	@skaffold build --dry-run
	@$(call log_success,"All tests passed!")

validate: ## Validate configurations only
	@$(call log_step,"Validating configurations...")
	@helm template validate $(CHART_PATH) --values $(CHART_PATH)/values.yaml >/dev/null
	@$(call log_success,"Validation successful!")

lint: ## Lint Helm chart and configurations
	@$(call log_step,"Linting Helm chart...")
	@helm lint $(CHART_PATH)
	@$(call log_success,"Linting complete!")

# =============================================================================
# MONITORING & STATUS
# =============================================================================

status: ## Show deployment status
	@$(call log_step,"Checking deployment status...")
	@echo "$(CYAN)Development ($(DEV_NAMESPACE)):$(NC)"
	@kubectl get pods -n $(DEV_NAMESPACE) 2>/dev/null | grep -v "No resources" || echo "  No development deployment"
	@echo
	@echo "$(CYAN)Production ($(PROD_NAMESPACE)):$(NC)"
	@kubectl get pods -n $(PROD_NAMESPACE) 2>/dev/null | grep -v "No resources" || echo "  No production deployment"

logs: ## Follow logs from all services
	@$(call log_info,"Following logs from $(DEV_NAMESPACE) namespace...")
	@kubectl logs -n $(DEV_NAMESPACE) -l app.kubernetes.io/name=$(PROJECT_NAME) --tail=50 -f 2>/dev/null || \
		echo "No logs available. Try: make dev"

logs-prod: ## Follow production logs
	@$(call log_info,"Following logs from $(PROD_NAMESPACE) namespace...")
	@kubectl logs -n $(PROD_NAMESPACE) -l app.kubernetes.io/name=$(PROJECT_NAME) --tail=50 -f

ports: ## Show exposed service ports
	@$(call log_step,"Exposed services:")
	@echo
	@NODE_IP=$$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || echo "localhost"); \
	for ns in $(DEV_NAMESPACE) $(PROD_NAMESPACE); do \
		if kubectl get namespace $$ns >/dev/null 2>&1; then \
			echo "$(CYAN)Namespace: $$ns$(NC)"; \
			kubectl get svc -n $$ns --no-headers 2>/dev/null | while read name type cluster_ip external_ip port_spec age; do \
				if [ "$$type" = "NodePort" ]; then \
					PORT=$$(echo $$port_spec | cut -d: -f2 | cut -d/ -f1); \
					echo "  ✅ $$name → http://$$NODE_IP:$$PORT"; \
				fi; \
			done 2>/dev/null || echo "  No exposed services"; \
			echo; \
		fi; \
	done

watch: ## Watch pod status in real-time
	@$(call log_info,"Watching pods in $(DEV_NAMESPACE)...")
	@kubectl get pods -n $(DEV_NAMESPACE) -w

# =============================================================================
# QUICK ACCESS & UTILITIES
# =============================================================================

dashboard: ## Open Grafana dashboard
	@$(call log_info,"Opening Grafana dashboard...")
	@kubectl port-forward -n $(DEV_NAMESPACE) svc/$(PROJECT_NAME)-grafana 3000:3000 >/dev/null 2>&1 &
	@sleep 2
	@open http://localhost:3000 2>/dev/null || echo "Visit: http://localhost:3000 (admin/admin)"

api: ## Test the Mythical Beasts API
	@$(call log_step,"Testing Mythical Beasts API...")
	@kubectl port-forward -n $(DEV_NAMESPACE) svc/$(PROJECT_NAME)-mythical-server 4000:4000 >/dev/null 2>&1 &
	@sleep 2
	@echo "Testing POST /unicorn..."
	@curl -X POST http://localhost:4000/unicorn \
		-H "Content-Type: application/json" \
		-d '{"name": "sparkles"}' -w "\nStatus: %{http_code}\n" || echo "API not available"
	@echo
	@echo "Testing GET /unicorn..."
	@curl http://localhost:4000/unicorn -w "\nStatus: %{http_code}\n" || echo "API not available"

shell: ## Get shell access to main server container
	@POD=$$(kubectl get pods -n $(DEV_NAMESPACE) -l app.kubernetes.io/name=$(PROJECT_NAME),app.kubernetes.io/component=mythical-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null); \
	if [ -n "$$POD" ]; then \
		$(call log_info,"Connecting to $$POD..."); \
		kubectl exec -it -n $(DEV_NAMESPACE) $$POD -- sh; \
	else \
		$(call log_error,"No server pod found. Is the development environment running?"); \
	fi

# =============================================================================
# CLEANUP COMMANDS
# =============================================================================

clean: ## Clean up development environment
	@$(call log_warning,"Cleaning up development environment...")
	@skaffold delete --namespace $(DEV_NAMESPACE) 2>/dev/null || true
	@kubectl delete namespace $(DEV_NAMESPACE) --ignore-not-found=true
	@$(call log_success,"Development environment cleaned!")

clean-prod: ## Clean up production deployment
	@$(call log_warning,"⚠️  This will destroy the production deployment!")
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@helm uninstall $(PROJECT_NAME) -n $(PROD_NAMESPACE) 2>/dev/null || true
	@kubectl delete namespace $(PROD_NAMESPACE) --ignore-not-found=true
	@$(call log_success,"Production deployment removed!")

clean-all: clean clean-prod ## Clean up everything
	@$(call log_warning,"Cleaning Docker system...")
	@docker system prune -f >/dev/null 2>&1 || true
	@$(call log_success,"Complete cleanup finished!")

reset: clean ## Reset development environment
	@$(call log_step,"Resetting development environment...")
	@sleep 2
	@$(MAKE) dev

# =============================================================================
# ADVANCED OPERATIONS
# =============================================================================

upgrade: ## Upgrade Helm chart in-place
	@$(call log_step,"Upgrading Helm chart...")
	@helm upgrade $(PROJECT_NAME) $(CHART_PATH) -n $(PROD_NAMESPACE)
	@$(call log_success,"Upgrade complete!")

rollback: ## Rollback to previous Helm release
	@$(call log_warning,"Rolling back to previous release...")
	@helm rollback $(PROJECT_NAME) -n $(PROD_NAMESPACE)
	@$(call log_success,"Rollback complete!")

backup: ## Export current configuration
	@$(call log_step,"Backing up configurations...")
	@mkdir -p backup/$(shell date +%Y%m%d-%H%M%S)
	@helm get values $(PROJECT_NAME) -n $(PROD_NAMESPACE) > backup/$(shell date +%Y%m%d-%H%M%S)/values.yaml 2>/dev/null || true
	@kubectl get all -n $(PROD_NAMESPACE) -o yaml > backup/$(shell date +%Y%m%d-%H%M%S)/resources.yaml 2>/dev/null || true
	@$(call log_success,"Backup created in backup/ directory")

.DEFAULT_GOAL := help
