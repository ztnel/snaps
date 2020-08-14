
SNAP=testapp
SNAP_ARCH=arm64
REV=0.1

.PHONY: build
build:
	if [ $(venv)=lxd ];
	then
		snapcraft --use-lxd --debug;
	else
		# default to multipass
		snapcraft --debug
	fi

.PHONY: dist
dist:
	python3 -m pip install --upgrade pip;
	python3 -m pip install .;

.PHONY: shell
shell:
	if [ $(venv)=lxd ];
	then
		lxc start snapcraft-$(SNAP)
		lxc exec snapcraft-$(SNAP) -- /bin/bash;
	else
		multipass start snapcraft-$(SNAP)
		multipass exec snapcraft-$(SNAP) -- /bin/bash;
	fi

.PHONY: clean
clean:
	if [ $(venv)=lxd ];
	then
		snapcraft clean --use-lxd;
	else
		snapcraft clean
	fi
.PHONY: install
install:
	sudo snap install $(SNAP)_$(REV)_$(SNAP_ARCH).snap --devmode
