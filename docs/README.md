# Setup for Snap Development

## MacOSX
Homebrew has a package for snapcraft development:
```bash
brew install snapcraft
```

In order to build, install and test the snap a ubuntu container will be required. The default container for snapcraft development is `multipass`. Multipass is a tool to launch and manage VMs on Windows, Mac and Linux that simulates a cloud environment with support for cloud-init.
```bash
brew cask install multipass
```

### Troubleshooting
If a mount error occurs like the one below:
![img](./img/err.png)

You need to give `multipassd` explicit access to your disk in order for the mount to be successful. Visit the *System & Privacy* tab in *System Preferences* then check the boxes for `multipassd`. Once applied you should see the access permissions displayed:

![img](./img/privacy.png)

## Ubuntu Server 20.04 (RPi)


