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
	@printf "${OKB}Setting up build environment on ${OKG}${VENV} ${NC}\n";
	@if [[ "$(VENV)" == rpi ]]; then\
		./scripts/lxd-setup.sh; fi;
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: lint
lint: ## Lint .yaml, .py and .sh files using yamllint, flake8 and shellcheck tools
	@printf "${OKB} Linting ${OKG}.yaml ${OKB}filesystems ...${NC}\n";
	@(yamllint . && printf "${OKG} ✓ ${NC} Pass\n"|| printf "${FAIL} ✗ ${NC} Fail\n")
	@printf "${OKB} Linting ${OKG}.sh ${OKB}filesystems ...${NC}\n";
	@(shellcheck bin/* scripts/*.sh && printf "${OKG} ✓ ${NC} Pass\n"|| printf "${FAIL} ✗ ${NC} Fail\n")
	@printf "${OKB} Linting ${OKG}.py ${OKB}filesystems ...${NC}\n";
	@(flake8 hello && printf "${OKG} ✓ ${NC} Pass\n"|| printf "${FAIL} ✗ ${NC} Fail\n")

.PHONY: build
build: lint ## Build snap in virtual environment
	@printf "${OKB}Parsing snapcraft buildspec injecting ${OKG}${SNAP_NAME} ${ARCH}${NC}\n";
	@python3 scripts/yaml_parser.py "./snap/snapcraft.yaml"
	@printf "${OKB}Building snap ${OKG}${SNAP_NAME}${OKB} on ${OKG}${VENV}${NC}\n";
	@if [[ "${VENV}" == rpi ]]; then \
		snapcraft --use-lxd --debug;\
	else \
		snapcraft --debug; fi
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: dist
dist: ## Install python package using setup.py
	@printf "${OKB}Building python package ... ${NC}\n";
	@python3 -m pip install --upgrade pip;
	@python3 -m pip install .;
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: start
start: ## Restarts an inactive instance
	@if [[ "$(VENV)" == rpi ]]; then \
		lxc start ${BUILD_VM};\
	else \
		multipass start ${BUILD_VM}; fi
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: shell
shell: start ## Launch active snap build VM and drop into shell
	@if [[ "$(VENV)" == rpi ]]; then \
		lxc exec ${BUILD_VM} -- /bin/bash; \
	else \
		multipass exec ${BUILD_VM} -- /bin/bash; fi
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: clean
clean: ## Clean snap build artefacts and teardown VM components
	@printf "${OKB}Cleaning build artefacts ... ${NC}\n";
	@if [[ "$(VENV)" == rpi ]]; then \
		snapcraft clean --use-lxd; \
		lxc stop ${BUILD_VM}; \
		lxc unmount ${BUILD_VM};\
		lxc delete ${BUILD_VM};\
	else \
		multipass stop ${BUILD_VM} ${RUN_VM}; \
		multipass unmount ${BUILD_VM} ${RUN_VM}; \
		multipass delete ${BUILD_VM} ${RUN_VM}; \
		multipass purge; fi;
	@if [ -f *.snap ]; then \
		rm -v *.snap; \
	fi;
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: install
install: ## Install snap using confined devmode (--dangerous implied with devmode)
	@printf "${OKB}Installing snap ${OKG}${SNAP_NAME}${OKB} in devmode${NC}\n";
	@if [[ "$(VENV)" == rpi ]]; then \
		sudo snap install *.snap --devmode; \
	else \
		multipass launch -n ${RUN_VM} -v; \
		multipass start ${RUN_VM} -v; \
		multipass mount $(PWD) ${RUN_VM}:/home/ubuntu/snaps -v; \
		multipass exec ${RUN_VM} -- cd snaps && sudo snap install --devmode *.snap; fi
	@printf "${OKG} ✓ ${NC} Complete\n";

.PHONY: review
review: ## lint using canonical approved review-tools lib
	@printf "${OKB}Reviewing snap ${OKG}${SNAP_NAME}${NC}\n";
	@if [[ "$(VENV)" == rpi ]]; then \
		sudo snap install review-tools;\
		(review-tools.snap-review *.snap -v && printf "${OKG} ✓ ${NC} Pass\n") || \
			printf "${FAIL} ✗ ${NC} Fail\n"; \
	else \
		multipass exec ${RUN_VM} -- sudo snap install review-tools; \
		(multipass exec ${RUN_VM} -- cd snaps && review-tools.snap-review *.snap -v && \
			printf "${OKG} ✓ ${NC} Pass\n") || printf "${FAIL} ✗ ${NC} Fail\n"; fi;

.PHONY: publish
publish: review ## publish the snap to the snapstore
	@printf "${OKB}Registering snap ${OKG}${SNAP_NAME}${NC} with snapstore\n";
	@snapcraft login
	@snapcraft register ${SNAP_NAME}
	@printf "${OKB}Publishing snap ${OKG}${SNAP_NAME}${NC} to snapstore\n";
	@snapcraft upload *.snap --release=${CHANNEL}
	@printf "${OKG} ✓ ${NC} Complete\n";
