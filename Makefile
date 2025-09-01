.PHONY: help up down restart logs clean status health mongo-shell minio-console

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Default target
help:
	@echo "$(GREEN)MongoDB Ops Manager Infrastructure Commands:$(NC)"
	@echo ""
	@echo "  $(YELLOW)make up$(NC)           - Start all services"
	@echo "  $(YELLOW)make down$(NC)         - Stop all services"
	@echo "  $(YELLOW)make restart$(NC)      - Restart all services"
	@echo "  $(YELLOW)make logs$(NC)         - Show logs from all services"
	@echo "  $(YELLOW)make logs-follow$(NC)  - Follow logs in real-time"
	@echo "  $(YELLOW)make clean$(NC)        - Remove all volumes and containers"
	@echo "  $(YELLOW)make status$(NC)       - Show status of all services"
	@echo "  $(YELLOW)make health$(NC)       - Check health of all services"
	@echo ""
	@echo "$(GREEN)Utility Commands:$(NC)"
	@echo "  $(YELLOW)make mongo-shell$(NC)  - Connect to MongoDB shell"
	@echo "  $(YELLOW)make minio-console$(NC) - Open MinIO console URL"
	@echo "  $(YELLOW)make ops-manager$(NC)  - Open Ops Manager URL"
	@echo ""

# Start all services
up:
	@echo "$(GREEN)Starting MongoDB Ops Manager infrastructure...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Services starting up. Use 'make logs-follow' to monitor progress.$(NC)"
	@echo ""
	@echo "$(YELLOW)Access URLs:$(NC)"
	@echo "  Ops Manager:   http://localhost:8080"
	@echo "  MinIO Console: http://localhost:9001 (minioadmin/minioadmin123)"
	@echo "  MongoDB:       mongodb://admin:admin123@localhost:27017"

# Stop all services
down:
	@echo "$(YELLOW)Stopping all services...$(NC)"
	docker-compose down

# Restart all services
restart:
	@echo "$(YELLOW)Restarting all services...$(NC)"
	docker-compose restart

# Show logs (last 100 lines)
logs:
	docker-compose logs --tail=100

# Follow logs in real-time
logs-follow:
	docker-compose logs -f

# Clean everything (WARNING: This will delete all data!)
clean:
	@echo "$(RED)WARNING: This will delete all data and volumes!$(NC)"
	@echo -n "Are you sure? (y/N): " && read answer && [ $${answer:-N} = y ]
	@echo "$(RED)Cleaning up...$(NC)"
	docker-compose down -v
	docker system prune -f
	@echo "$(GREEN)Cleanup completed.$(NC)"

# Show service status
status:
	@echo "$(GREEN)Service Status:$(NC)"
	@docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Check health of services
health:
	@echo "$(GREEN)Checking service health...$(NC)"
	@echo ""
	@echo "$(YELLOW)MongoDB Health:$(NC)"
	@docker exec mongodb mongosh --quiet --eval "try { db.adminCommand('ping'); print('✅ MongoDB is healthy'); } catch(e) { print('❌ MongoDB is unhealthy: ' + e); }" 2>/dev/null || echo "❌ MongoDB container not running"
	@echo ""
	@echo "$(YELLOW)MinIO Health:$(NC)"
	@curl -sf http://localhost:9000/minio/health/live >/dev/null && echo "✅ MinIO is healthy" || echo "❌ MinIO is unhealthy"
	@echo ""
	@echo "$(YELLOW)Ops Manager Health:$(NC)"
	@curl -sf http://localhost:8080/account/login >/dev/null && echo "✅ Ops Manager is healthy" || echo "❌ Ops Manager is unhealthy or still starting"

# Connect to MongoDB shell
mongo-shell:
	@echo "$(GREEN)Connecting to MongoDB shell...$(NC)"
	@echo "Use: db.adminCommand('listCollections') to list collections"
	docker exec -it mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# Open MinIO console
minio-console:
	@echo "$(GREEN)MinIO Console: http://localhost:9001$(NC)"
	@echo "Username: minioadmin"
	@echo "Password: minioadmin123"
	@command -v open >/dev/null && open http://localhost:9001 || echo "Open http://localhost:9001 in your browser"

# Open Ops Manager
ops-manager:
	@echo "$(GREEN)Ops Manager: http://localhost:8080$(NC)"
	@command -v open >/dev/null && open http://localhost:8080 || echo "Open http://localhost:8080 in your browser"

# Quick setup verification
verify:
	@echo "$(GREEN)Verifying setup...$(NC)"
	@echo ""
	@make health
	@echo ""
	@echo "$(YELLOW)Container Status:$(NC)"
	@make status

# Test MongoDB connection
test-mongodb:
	@echo "$(GREEN)Testing MongoDB connection...$(NC)"
	@docker exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin --quiet --eval "print('✅ MongoDB connection successful'); db.getSiblingDB('opsmanager').getCollectionNames()"

# Test Ops Manager APIs
test-ops-manager:
	@echo "$(GREEN)Testing Ops Manager APIs...$(NC)"
	@echo "Version API:"
	@curl -s http://localhost:8080/api/public/v1.0/unauth/version | jq . 2>/dev/null || curl -s http://localhost:8080/api/public/v1.0/unauth/version
	@echo ""
	@echo "Web Interface:"
	@curl -s -I http://localhost:8080/ | head -1

# Full system test
test-all: test-mongodb test-ops-manager
	@echo ""
	@echo "$(GREEN)🎉 All tests completed!$(NC)"
	@echo ""
	@echo "$(YELLOW)Access URLs:$(NC)"
	@echo "  Ops Manager:   http://localhost:8080"
	@echo "  MinIO Console: http://localhost:9001"
	@echo "  MongoDB:       mongodb://admin:admin123@localhost:27017"

# Show connection details
info:
	@echo "$(GREEN)MongoDB Ops Manager Development Environment$(NC)"
	@echo ""
	@echo "$(YELLOW)🔗 Connection Details:$(NC)"
	@echo "  Ops Manager:   http://localhost:8080"
	@echo "  MinIO Console: http://localhost:9001 (minioadmin/minioadmin123)"
	@echo "  MongoDB:       mongodb://admin:admin123@localhost:27017"
	@echo ""
	@echo "$(YELLOW)📊 Service Status:$(NC)"
	@make health
	@echo ""
	@echo "$(YELLOW)💡 Useful Commands:$(NC)"
	@echo "  make test-all      - Run all tests"
	@echo "  make mongo-shell   - Connect to MongoDB"
	@echo "  make logs-follow   - Follow logs"

