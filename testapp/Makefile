
SNAP=testapp
SNAP_ARCH=arm64
REV=0.1

.PHONY: build
build: # Build snap in virtual environment
	if [[ "$(venv)" == lxd ]]; then snapcraft --use-lxd --debug; else snapcraft --debug; fi

.PHONY: dist
dist: ## Install python package using setup.py
	python3 -m pip install --upgrade pip;
	python3 -m pip install .;

.PHONY: shell
shell: ## Launch active snap build VM and drop into shell
	if [[ "$(venv)" == lxd ]]; then lxc start snapcraft-$(SNAP); lxc exec snapcraft-$(SNAP) -- /bin/bash; else multipass start snapcraft-$(SNAP); multipass exec snapcraft-$(SNAP) -- /bin/bash; fi

.PHONY: clean
clean: ## Clean snap build VM components
	if [[ "$(venv)" == lxd ]]; then snapcraft clean --use-lxd; else snapcraft clean; fi

.PHONY: install
install: ## Install snap using confined devmode (--dangerous implied with devmode)
	sudo snap install $(SNAP)_$(REV)_$(SNAP_ARCH).snap --devmode

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
