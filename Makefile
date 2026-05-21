.PHONY: help up halt status ssh-gateway ssh-inventory ssh-billing clean install test

help:
	@echo "CRUD Master — available targets:"
	@echo "  make up          - Start all VMs (vagrant up)"
	@echo "  make halt        - Stop all VMs (vagrant halt)"
	@echo "  make status      - Show VM status (vagrant status)"
	@echo "  make ssh-gateway - SSH into gateway-vm"
	@echo "  make ssh-inventory - SSH into inventory-vm"
	@echo "  make ssh-billing - SSH into billing-vm"
	@echo "  make destroy     - Destroy all VMs (vagrant destroy -f)"
	@echo "  make clean       - Remove venv, __pycache__, .pyc files"
	@echo "  make install     - Install Vagrant + VirtualBox (Ubuntu/Debian)"
	@echo "  make test        - Run local smoke tests (requires running services)"

up:
	vagrant up

halt:
	vagrant halt

status:
	vagrant status

ssh-gateway:
	vagrant ssh gateway-vm

ssh-inventory:
	vagrant ssh inventory-vm

ssh-billing:
	vagrant ssh billing-vm

destroy:
	vagrant destroy -f

clean:
	find . -type d -name venv -prune -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	find . -name "*.pyo" -delete 2>/dev/null || true
	find . -name ".pytest_cache" -prune -exec rm -rf {} + 2>/dev/null || true

install:
	bash scripts/install_vagrant.sh

test:
	@echo "=== Inventory API ==="
	@curl -s -o /dev/null -w "GET /api/movies -> %{http_code}\n" http://localhost:8080/api/movies || true
	@echo ""
	@echo "=== Gateway ==="
	@curl -s -o /dev/null -w "GET /api/movies -> %{http_code}\n" http://localhost:8000/api/movies || true
	@echo ""
	@echo "=== Billing (POST) ==="
	@curl -s -o /dev/null -w "POST /api/billing -> %{http_code}\n" -X POST http://localhost:8000/api/billing -H "Content-Type: application/json" -d '{"user_id":"1","number_of_items":1,"total_amount":10.0}' || true
