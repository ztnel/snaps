# Snapcraft Notes

General notes for snapcraft development on RPi 3B+ running Ubuntu 18.04 LTS. Following interactive tutorial found [here](https://discourse.ubuntu.com/t/create-your-first-snap/14006)

## Project Initialization

Create a general snaps directory for all snap dev projects [general] followed by a snap folder for this specific project.

```console
$ mkdir -p ~/[general]/[snap_name]
$ cd ~/[general]/[snap_name]
```

Initialize snapcraft environment. This geenrates a `snapcraft.yaml` file in which you declare how the snap is built and which properties it exposes to the user. 
```console
$ snapcraft init
```
`snapcraft.yaml` is stored inside a newly created directory `/snap` within the project folder `/hello`
```console
[general]/
└── [snap_name]
    └── snap
        └── snapcraft.yaml
```

`snapcraft.yaml` is initialized with some mutable properties for the snap:
```console
name: [snap_name]       # defines snap name for identifier on Snap Store
base: core18            # the base snap is the execution environment for this snap
version: '0.1'          # VERSION NOT REVISION! String just for devs to commmunicate release package
grade: devel            # must be 'stable' to release into candidate/stable channels
confinement: devmode    # use 'strict' for deployment
```
Some details for new concepts:
> **base**: A foundation snap that provides run-time environment with a minimal set of libraries common to most applications. `core18` corresponds to Ubuntu 18.04 LTS

> **version**: The version of the snap is useful for users to know that certain snap revision numbers are part of the same deployment package. Recall each time a snap is updated its version number increments automatically. So for a user it may not be clear if a new revision corresponds to a new package or a package update.

> **description**: Can span multiple lines if prefixed with `|`.

> **grade**: Used by publisher to indicate quality confidence metric in the build. The store will prevent publishing `devel` grade builds to the `stable` channel.

Update `snapcraft.yaml` init file with snap properties. `nano` is a GNU text editor that operates directly in the terminal. Make changes to the file and write using `^S` and `^X` when complete to close `nano`
```console
nano snapcraft.yaml
```
## Parts
`Parts` provide logical division within a snap and describe apppllication such as:
1. Component location
2. Build
3. Runtime requirements
4. Dependancies

Each `part` requires a `source` and `plugin` definition. The `source` defines what the part does by its src location (ie. `git`, local directory etc..). The `plugin` extends the possible project types (i. `autotools`, `cmake`, `python3` etc...)

Add a `parts` section to `snapcraft.yaml`:
```console
parts:
  [part_name]:
    source: [path_to_src]
    plugin: [plugin_name]
```

## Build snap
While navigated to `/[snap_name]` directory run:
```console
$ snapcraft
```

Snapcraft uses `multipass` to both simplify build process and confine the build environment within a virtual machine. If offers the objective best build experience. Install `multipass` on tracked channel. For my run `stable` had no revisions available.
```console
$ sudo snap install --channel=candidate --classic multipass
```
If runnning on a RPi, VM builds are not supported due to significant overhead see [here](https://snapcraft.io/docs/build-options) for supported build options for different linux distributions 

For Ubuntu 18.04 LTS (core18) we use the `--destructive-mode` argument for defining a temporary/short lived environments for Continuous Integration (CI) systems for rapid testing and development. The build has a chance of contaminating host build environment so it is less safe than an isolated VM solution.
```console
$ snapcraft --destructive-mode
```

Once the build is successful snapcraft will execute and print: `[snap_id].snap`. We can now install our snap with the `--devmode` argument.
```console
$ sudo snap install --devmode [snap_id].snap
```
Once installed we can list the snap details
```console
$ snap list [snap_name]
Name         Version  Rev  Tracking  Developer  Notes
[snap_name]  2.10     x1   -         -          devmode
```

## Defining command namespaces
We can't execute the snap using `[snap_name]` since we have not exposed our snap to the user by specifying the namespace. This will allow you to install snaps with the same name from different publishers and be able to run the snaps seperately.

To expose the `[snap_name]` command. Add the `apps` clause to `snapcraft.yaml`. This defines an `app` named `[snap_name]` which points to the executable defined in `bin/hello` as defined in the directory structure included with the snap (custom `/bin` namespace).
```console
apps:
  [snap_name]:
    command: bin/[snap_name]
```



