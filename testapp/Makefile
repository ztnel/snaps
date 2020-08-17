SHELL=/bin/bash
SNAP=testapp
SNAP_ARCH=arm64
REV=0.1

.PHONY: build
build: ## Build snap in virtual environment
	@if [[ "$(venv)" == lxd ]]; then \
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
	@if [[ "$(venv)" == lxd ]]; then \
		lxc start snapcraft-$(SNAP);\
	else \
		multipass start snapcraft-$(SNAP); fi

.PHONY: shell
shell: start ## Launch active snap build VM and drop into shell
	@if [[ "$(venv)" == lxd ]]; then \
		lxc exec snapcraft-$(SNAP) -- /bin/bash; \
	else \
		multipass exec snapcraft-$(SNAP) -- /bin/bash; fi

.PHONY: clean
clean: ## Clean snap build VM components
	@if [[ "$(venv)" == lxd ]]; then \
		snapcraft clean --use-lxd; \
	else \
		snapcraft clean; fi

.PHONY: install
install: ## Install snap using confined devmode (--dangerous implied with devmode)
	@if [[ "$(venv)" == lxd ]]; then \
		sudo snap install $(SNAP)_$(REV)_$(SNAP_ARCH).snap --devmode; \
	else \
		multipass launch -n snaps -v; \
		multipass mount $(PWD) snaps:/home/ubuntu/snaps -v; \
		multipass exec snaps -- sudo snap install --devmode /home/ubuntu/snaps/*.snap; fi

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
