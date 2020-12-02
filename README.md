# Python Snaps for core20
Updated: 2020-12
![img](/docs/img/snapcraft-logo.jpg)

Build python snaps for core20 on UNIX compatible ARM64 or AMD/Intel architectures.

## Navigation
1. [Quickstart](#quickstart)
2. [Introduction to Snaps](docs/snap.md)
3. [Snapcraft](docs/snapcraft.md)
4. [Building on MacOS](/docs/README.md)
5. [License](/LICENSE)

## Quickstart
Ensure you have build-essentials for `make` using apt or other package manager:
```bash
sudo apt install build-essentials -y
```

### Pre-Build for RPi Ubuntu 20.04LTS (ARM64)
Set the `VENV` environment variable to `rpi` in the [.env](/.env) file.

Configure lxc environment
```bash
make setup
```

### Pre-Build for Other platform (multipass supported)
Set the `VENV` environment variable to `other` in the [.env](/.env) file.

Use your package manager to install multipass
```
brew install multipass
```

### Python Snap Build and Installation
Build and install snap
```bash
make all
```

### Debugging
Shell into container
```bash
make shell
```