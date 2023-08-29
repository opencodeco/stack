STACK_PATH:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: install
install:
	@echo "Installing OpenCodeCo stack!"
	@sed 's#STACK_PATH=$$(pwd)#STACK_PATH=$(STACK_PATH)#g' ./stack > /usr/local/bin/stack
	@chmod +x /usr/local/bin/stack
	@stack network
	@echo "🧱 Installed. Happy hacking!"
