.PHONY: help build start stop restart logs logs-follow status shell clean clean-all ps health

# Default target
.DEFAULT_GOAL := help

# Colors for terminal output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)ComfyUI Docker - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "  1. Copy .env.example to .env and configure USER_ID/GROUP_ID"
	@echo "  2. Run 'make build' to build the Docker image"
	@echo "  3. Run 'make start' to start ComfyUI"
	@echo "  4. Open http://localhost:8188 in your browser"
	@echo ""

build: ## Build the Docker image
	@echo "$(BLUE)Building ComfyUI Docker image...$(NC)"
	docker-compose build --progress=plain

build-no-cache: ## Build the Docker image without cache
	@echo "$(BLUE)Building ComfyUI Docker image (no cache)...$(NC)"
	docker-compose build --no-cache --progress=plain

start: ## Start ComfyUI container
	@echo "$(GREEN)Starting ComfyUI...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)ComfyUI started! Access at http://localhost:8188$(NC)"

stop: ## Stop ComfyUI container
	@echo "$(YELLOW)Stopping ComfyUI...$(NC)"
	docker-compose down

restart: ## Restart ComfyUI container
	@echo "$(YELLOW)Restarting ComfyUI...$(NC)"
	docker-compose restart

logs: ## Show last 100 lines of logs
	docker-compose logs --tail=100

logs-follow: ## Follow logs in real-time
	docker-compose logs -f

status: ## Show container status
	@echo "$(BLUE)Container Status:$(NC)"
	@docker-compose ps

ps: status ## Alias for status

shell: ## Open a shell inside the running container
	@echo "$(BLUE)Opening shell in ComfyUI container...$(NC)"
	docker-compose exec comfyui /bin/bash

shell-root: ## Open a root shell inside the running container
	@echo "$(RED)Opening ROOT shell in ComfyUI container...$(NC)"
	docker-compose exec -u root comfyui /bin/bash

health: ## Check health status of the container
	@echo "$(BLUE)Checking ComfyUI health...$(NC)"
	@docker-compose ps | grep comfyui
	@echo ""
	@echo "$(BLUE)Testing HTTP endpoint...$(NC)"
	@curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8188 || echo "$(RED)Cannot connect to ComfyUI$(NC)"

clean: ## Stop and remove containers (keeps volumes)
	@echo "$(YELLOW)Removing containers (keeping data volumes)...$(NC)"
	docker-compose down

clean-all: ## Stop and remove containers and volumes (DESTRUCTIVE!)
	@echo "$(RED)WARNING: This will delete all ComfyUI data, models, and outputs!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(RED)Removing containers and volumes...$(NC)"; \
		docker-compose down -v; \
	else \
		echo "$(GREEN)Cancelled.$(NC)"; \
	fi

prune: ## Remove unused Docker resources (images, containers, networks)
	@echo "$(YELLOW)Pruning Docker system...$(NC)"
	docker system prune -f

update: ## Pull latest changes and rebuild
	@echo "$(BLUE)Updating ComfyUI setup...$(NC)"
	git pull
	@echo "$(BLUE)Rebuilding image...$(NC)"
	docker-compose build --pull
	@echo "$(GREEN)Update complete! Run 'make restart' to apply changes.$(NC)"

backup: ## Create a backup of ComfyUI data
	@echo "$(BLUE)Creating backup of ComfyUI data...$(NC)"
	@mkdir -p backups
	@BACKUP_FILE=backups/comfy-backup-$$(date +%Y%m%d-%H%M%S).tar.gz; \
	tar -czf $$BACKUP_FILE -C $(HOME) comfy/ && \
	echo "$(GREEN)Backup created: $$BACKUP_FILE$(NC)" || \
	echo "$(RED)Backup failed!$(NC)"

env-setup: ## Create .env file from .env.example
	@if [ -f .env ]; then \
		echo "$(YELLOW).env file already exists. Skipping.$(NC)"; \
	else \
		echo "$(BLUE)Creating .env file...$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN).env file created! Please edit it to match your system.$(NC)"; \
		echo "$(YELLOW)Run 'id -u' and 'id -g' to get your USER_ID and GROUP_ID$(NC)"; \
	fi

check-prereqs: ## Check if prerequisites are installed
	@echo "$(BLUE)Checking prerequisites...$(NC)"
	@command -v docker >/dev/null 2>&1 && echo "$(GREEN)✓ Docker installed$(NC)" || echo "$(RED)✗ Docker not found$(NC)"
	@command -v docker-compose >/dev/null 2>&1 && echo "$(GREEN)✓ Docker Compose installed$(NC)" || echo "$(RED)✗ Docker Compose not found$(NC)"
	@nvidia-smi >/dev/null 2>&1 && echo "$(GREEN)✓ NVIDIA driver installed$(NC)" || echo "$(RED)✗ NVIDIA driver not found$(NC)"
	@docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi >/dev/null 2>&1 && echo "$(GREEN)✓ NVIDIA Container Toolkit working$(NC)" || echo "$(RED)✗ NVIDIA Container Toolkit not working$(NC)"

info: ## Show system and GPU information
	@echo "$(BLUE)System Information:$(NC)"
	@echo "Hostname: $$(hostname)"
	@echo "Kernel: $$(uname -r)"
	@echo "User: $$(whoami) (UID: $$(id -u), GID: $$(id -g))"
	@echo ""
	@echo "$(BLUE)GPU Information:$(NC)"
	@nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null || echo "$(RED)nvidia-smi not available$(NC)"
	@echo ""
	@echo "$(BLUE)Docker Information:$(NC)"
	@docker --version
	@docker-compose --version

install-hooks: ## Install git pre-commit hooks (future)
	@echo "$(YELLOW)Git hooks not yet implemented$(NC)"

test: ## Run basic tests
	@echo "$(BLUE)Running basic tests...$(NC)"
	@echo "$(BLUE)1. Checking if container is running...$(NC)"
	@docker-compose ps | grep -q "Up" && echo "$(GREEN)✓ Container is running$(NC)" || echo "$(RED)✗ Container not running$(NC)"
	@echo "$(BLUE)2. Testing HTTP endpoint...$(NC)"
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:8188 | grep -q "200\|404" && echo "$(GREEN)✓ HTTP endpoint responding$(NC)" || echo "$(RED)✗ HTTP endpoint not responding$(NC)"
	@echo "$(BLUE)3. Checking PyTorch and CUDA...$(NC)"
	@docker-compose exec comfyui python -c "import torch; print('PyTorch:', torch.__version__); print('CUDA:', torch.version.cuda); print('cuDNN:', torch.backends.cudnn.version()); assert torch.cuda.is_available(), 'CUDA not available'" && echo "$(GREEN)✓ PyTorch and CUDA working$(NC)" || echo "$(RED)✗ PyTorch/CUDA check failed$(NC)"
