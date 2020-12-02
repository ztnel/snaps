# Source user env flags
include .env
export $(shell sed 's/=.*//' .env)

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

.PHONY: all
all : build install

.PHONY: setup
setup: ## setup snap build environment
	@printf "${OKB} Setting up build environment on ${OKG} ${VENV} ${NC}\n";
	@if [[ "$(VENV)" == rpi ]]; then\
		./scripts/lxd-setup.sh; fi;
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: build
build: ## Build snap in virtual environment
	@printf "${OKB} Building snap on ${OKG} ${VENV} ${NC}\n";
	@if [[ "${VENV}" == rpi ]]; then \
		snapcraft --use-lxd --debug;\
	else \
		snapcraft --debug; fi
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: dist
dist: ## Install python package using setup.py
	@printf "${OKB} Building python package ... ${NC}\n";
	@python3 -m pip install --upgrade pip;
	@python3 -m pip install .;
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: start
start: ## Restarts an inactive instance
	@if [[ "$(VENV)" == rpi ]]; then \
		lxc start snapcraft-$(SNAP);\
	else \
		multipass start snapcraft-$(SNAP); fi
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: shell
shell: start ## Launch active snap build VM and drop into shell
	@if [[ "$(VENV)" == rpi ]]; then \
		lxc exec snapcraft-$(SNAP) -- /bin/bash; \
	else \
		multipass exec snapcraft-$(SNAP) -- /bin/bash; fi
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: clean
clean: ## Clean snap build VM components
	@printf "${OKB} Cleaning build artefacts ... ${NC}\n";
	@if [[ "$(VENV)" == rpi ]]; then \
		snapcraft clean --use-lxd; \
	fi;
	@if [ -f *.snap ]; then \
		rm -v *.snap; \
	fi;
	@multipass exec snaps -- sudo snap remove testapp;
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: install
install: ## Install snap using confined devmode (--dangerous implied with devmode)
	@if [[ "$(VENV)" == rpi ]]; then \
		sudo snap install *.snap --devmode; \
	else \
		multipass launch -n snaps -v; \
		multipass start snaps -v; \
		multipass mount $(PWD) snaps:/home/ubuntu/snaps -v; \
		multipass exec snaps -- sudo snap install --devmode /home/ubuntu/snaps/testapp_0.1_amd64.snap; fi
	@printf "${OKG} ✓ ${NC} Complete\n";

