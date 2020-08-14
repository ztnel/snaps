# Cumulative Guide to Ubuntu Snaps

This guide is for user reference or an introduction to setting up Snaps on Ubuntu core20 LTS.

## Introduction to Snaps

A snap is an immutable package for an application. Snaps work across a wide range of linux distributions. The Snap Store is the central hub for discovering and installing snaps.

### Versions and Revisions
Versions and revisions convey different details about one specific release of a snap:
> **Versions** are the release of the software being packages which is assigned by the developers. A version is a string assigned to a project by its developers according to their development practices which tells a user what content to expect from the snap.

> **Revisions** are the sequence number assigned by the store when the snap file was uploaded. A revision is an automated number assigned by the *Snap Store* giving each iteration of the snap a unique identifier in the channel.

Neither of these properties influence the order of release on the system. The local system will install the snap recommended by the publisher in the channel being tracked.


### Fundamental snap commands

> Note parameters encased in `[]` indicate mutable parameters to fit the readers purpose.

**`snap find [search_string]`** allows you to discover snaps from the Snap Store. A checkmark beside the developer indicates the snap publisher has been verified.
```console
$ snap find media
```

**`snap info [app_name]`** details specifics of a snap including the snap description, the publisher, the accompanying commands and the channel versions available for installation.
```console
$ snap info htop
```

**`snap install [app_name]`** installs a snap. Channels define which release of a snap is installed and tracked for updates. The *stable* channel is used by default but the channel can be defined manually using the `--channel` option. `sudo` ensures the command is being executed as the root user.
```console
$ sudo snap install htop
$ sudo snap install htop --channel=stable htop
```

**`snap switch --channel=[channel_name] [app_name]`** switches the active tracking channel for a particular application
```console
$ sudo snap switch --channel=stable htop
```

Applications installed through snap are found under `/snap/bin` and added to the `$PATH` variable automatically. Some snaps do not automatically add themselves so its convenient to add `/snap/bin` to the `$PATH` variable to run these apps.

**`snap list`** lists all snaps installed on the system
```console
$ snap list
```

**`snap refresh [app_name]`** manually updates a specified snap by checking for updates. Snaps are updated automatically via the tracked channel for a particular app. You can also change the tracked channel and refresh in the same command using the `--channel` option. Updates are automatically installed to all deployed systems within 6 hours of a revision being made to a tracked channel, keeping most systems up to date. The automatic update scheduling can be adjusted via config options.
```console
$ sudo snap refresh htop
$ sudo snap refresh --channel=beta htop
```

**`sudo snap revert [app_name]`** reverts a snap to a previously used revision. This will revert the snap revision and software data associated with that revision. 
```console
$ sudo snap refresh htop
$ sudo snap refresh --channel=beta htop
```
A snap will not automatically update to a version previously reverted from and running `snap refresh` will continue to assume the snap is running at the desired revision and will not perform a refresh. If the snap name is specified by `snap refresh` then the snap will be updated back to the most recent revision.

Ubuntu 18.04 LTS is a classic system maintains 2 revisions in cache using `snapd` by default:
1. most recently installed
2. previous install

However Ubuntu Core 18 allows for 3 revision cache so 2 `snap revert` commands can be executed consecutively. The retained revisions can be modified with the `refresh.retain` system option.

**`snap list --all [app_name]`** lists all revisions for any installed snap. `snapd` automatically removes old snap revisions once a refresh is applied.
```console
$ snap list --all htop
```

**`sudo snap enable [app_name]`** and **`sudo snap disable [app_name]`** enables and disables snaps if temporarily undesired which is a faster approach to uninstalling and reinstalling.
```console
$ sudo snap disable htop
$ sudo snap enable htop
```

**`sudo snap remove [app_name]`** uninstalls specified snap from the system. By default, all revisions are removed from the system. However to specify removal of certain revisions use the `--revision` argument.
```console
$ sudo snap remove htop
$ sudo snap remove --revision=1.1.2 htop
```

### Ubuntu Core and Snapcraft
Ubuntu core is a `strict` confinement OS. This means snaps installed on the system must be self-containing and cannot perform cross-system level activities. Therefor installing `classic` level confinement snaps is not possible. This restructs the installation of snapcraft and snap development. Look to a `classic` level OS confinement such as Ubuntu 18.04