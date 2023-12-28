STACK_PATH:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: install
install:
	@echo "Installing OpenCodeCo stack!"
	@sudo sed 's#STACK_PATH=$$(pwd)#STACK_PATH=$(STACK_PATH)#g' ./stack > /usr/local/bin/stack
	@sudo chmod +x /usr/local/bin/stack
	@echo "Creating network..."
	@stack network
	@echo "🧱 Installed. Happy hacking!"
