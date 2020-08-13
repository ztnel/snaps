
SNAP=testapp
SNAP_ARCH=arm64

.PHONY: build
build:
	snapcraft --use-lxd --debug;

.PHONY: dist
dist:
	python3 -m pip install --upgrade pip;
	python3 -m pip install .;

.PHONY: shell
shell:
	lxc start snapcraft-$(SNAP)
	lxc exec snapcraft-$(SNAP) -- /bin/bash;

.PHONY: clean
clean:
	snapcraft clean --use-lxd;

.PHONY: install
install:
	sudo snap install $(SNAP)_0.1_$(SNAP_ARCH).snap --devmode
