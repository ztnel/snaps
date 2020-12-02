# Source user env flags
include .env
export $(shell sed 's/=.*//' .env)

.PHONY: build
build: ## Build snap in virtual environment
	@if [[ "$(VENV)" == lxd ]]; then \
		snapcraft --use-lxd --debug;\
	else \
		snapcraft --debug; fi

.PHONY: all
all : build install

.PHONY: dist
dist: ## Install python package using setup.py
	python3 -m pip install --upgrade pip;
	python3 -m pip install .;

.PHONY: start
start: ## Restarts an inactive instance
	@if [[ "$(VENV)" == lxd ]]; then \
		lxc start snapcraft-$(SNAP);\
	else \
		multipass start snapcraft-$(SNAP); fi

.PHONY: shell
shell: start ## Launch active snap build VM and drop into shell
	@if [[ "$(VENV)" == lxd ]]; then \
		lxc exec snapcraft-$(SNAP) -- /bin/bash; \
	else \
		multipass exec snapcraft-$(SNAP) -- /bin/bash; fi

.PHONY: clean
clean: ## Clean snap build VM components
	@if [[ "$(VENV)" == lxd ]]; then \
		snapcraft clean --use-lxd; \
	fi;
	@if [ -f *.snap ]; then \
		rm -v *.snap; \
	fi;
	@multipass exec snaps -- sudo snap remove testapp; 
	

.PHONY: install
install: ## Install snap using confined devmode (--dangerous implied with devmode)
	@if [[ "$(VENV)" == lxd ]]; then \
		sudo snap install *.snap --devmode; \
	else \
		multipass launch -n snaps -v; \
		multipass start snaps -v; \
		multipass mount $(PWD) snaps:/home/ubuntu/snaps -v; \
		multipass exec snaps -- sudo snap install --devmode /home/ubuntu/snaps/testapp_0.1_amd64.snap; fi

.PHONY: help	
help:
	@echo Usage:
	@echo "  make [target]"
	@echo
	@echo Targets:
	@awk -F ':|##' \
		'/^[^\t].+?:.*?##/ {\
			printf "  %-30s %s\n", $$1, $$NF \
		 }' $(MAKEFILE_LIST)
