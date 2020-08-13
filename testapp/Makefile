
.PHONY: build
build:
	snapcraft --use-lxd --debug;

.PHONY: dist
dist:
	python3 -m pip install --upgrade pip;
	python3 -m pip install .;

.PHONY: clean
clean:
	snapcraft clean --use-lxd;

.PHONY: install
install:
	sudo snap install testapp_0.1_arm64.snap --devmode
