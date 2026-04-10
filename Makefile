STACK_PATH:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: install
install:
	@echo "Installing OpenCodeCo stack!"
	@sed 's#STACK_PATH=$$(pwd)#STACK_PATH=$(STACK_PATH)#g' ./stack > /tmp/stack
	@sudo mv /tmp/stack /usr/local/bin/stack
	@sudo chmod +x /usr/local/bin/stack
	@echo "Creating network..."
	@stack network
	@echo "🧱 Installed. Happy hacking!"

.PHONY: test
test:
	@bash $(STACK_PATH)/tests/run-all.sh
