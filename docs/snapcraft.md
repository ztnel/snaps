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

Each `part` requires a `source` and `plugin` definition. The `source` defines what the part does by its src location (ie. `git`, local directory etc..). The `plugin` builds the source (i. `autotools`, `cmake`, `python3` etc...)

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

## Snap Iterations
Snaps are build are performed in 4 stages:
1. **pull**: downloads components needed to built part (`source`: header)
2. **build**: constructs part from previously pulled components
3. copy built component to staging area
4. copy staging components to priming area then to final locations for resulting snap.

Once a snap has underwent an initial build a new build using `snapcraft` will only build new or changes will be merged into a new snap. A more useful command for iterative build testing is `prime` which allows us to observe the snap before its created. `prime` tells snapcraft to build up until the prime stage of the buiild process and open a shell within the snap environment so we can observe the snap.
```console
$ snapcraft prime --shell --destructive-mode
```
Furthermore snapcraft provides a convienient `--debug` argument for opening a shell in the environment when an error occurs allowing for dynamic investigation of the error before resuming the build.
```console
$ snapcraft --debug --destructive-mode
```

Within the shell environment during a the `prime` stage you can navigate to `stage/bin` and verify the snap build is there but the `prime/bin` directory has yet to be created.

In order to build a specific stage use the `prime`, `stage`, `build` or `pull` commands
```console
$ snapcraft prime
```

After a rebuild the snap must be reinstalled before the changes can be observed on the system.

## Snap Parts
Adding a gnu-bash terminal to our app allows us to simply extend the app to include bash.
```console
apps:
  [...]
  gnu-bash:
    bash:
      command: bash

parts:
  [...]  
  gnu-bash:
    source: http://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz
    plugin: autotools
```

By default all commands within a snap are exposed to the user as `[snap_name].[cmd_name]`. The `[snap_name]` prefix provides a namespace for the snap command that is seperate from that of other snaps. For example `[snap_name].bash` will map `[snap_name]`'s implementation of bash and not be overwritten by system binaries `/bin/bash` commmand which will always take prescedence over commands imported through snaps. Notably the namespace of `[snap_name]` is also `[snap_name]` so the full command would be `[snap_name].[snap_name]` but for simplification simply `[snap_name]` is accepted practice.

This iteration of `[snap_name]` has two binaries being shipped: `hello` and `bash` commands. `snapcraft` creates a wrapper around the executables which set environment variables. `$SNAP/bin` will be prepended to your `$PATH`

Rebuilding and running `[snap_name].bash` should yield a bash terminal. You can see the lit of environment variables for this scaled doen version of bash.

## Snap Daemons and Shell Entry

Snap daemons are executed as `root`. If your python app is packaged into a module and exeucted by a shell script (such as below) you need to ensure your `$PYTHONPATH` is updated to point to the snap's `site-packages`.
```bash
#!/bin/bash
export HELLO="whateveryouwant"

python3 -m hello
```
This is because upon executing the shell script the interpreter will not have access to the user level `$PYTHONPATH` which includes the snap's `site-packages`. To resolve this, ensure the daemon app appends the snap's `site-packages` to the `$PYTHONPATH`:
```yaml
apps:
  testapp:
    command: bin/hello
    daemon: simple
    plugs: 
      - home
      - network-bind
    environment:
      # daemons execute as root so the python paths must be updated
      PYTHONPATH: $SNAP/lib/python3.8/site-packages:$PYTHONPATH
```
Otherwise the daemon will fail to find the module.

## Removing devmode and Publishing
Any user using `devmode` snaps will need to specify the `--devmode` argument as an explicit acknowledgment to trust you and your snap. Removing `devmode` also allows publishing to `stable` or `candidate` channels and users will be able to search for it using `snap find`. `beta` and `edge` channels are for less trusted snap iterations.

To begin the publishing stage we need to remove `devmode` status. We do this by editing the confinement field to `strict`.
```console
$ nano snapcraft.yaml
[...]
confinement: strict
[...]
```
Note that during `devmode` we ran a snap that wasn't signed by the Snap Store. The `--devmode` argument essentially tells the compiler that it was OK to install an unsigned snap in addition to it having unrestricted confinement. Since the `devmode` confinement parameter no longer exists we use the `--dangerous` argumnent to notify the compiler that its OK to install an unsigned snap without the `devmode` confinement.
```console
$ sudo snap install[snap_id].snap --dangerous
```

Notably while the snap's confined level is `strict` performing an operation that attempts to interact outside of the `\snap` folder is denied by the system. such as running
```console
$ hello.bash
bash-4.3$ ls
ls: cannot open directory '.': Permission denied
```

## Snap Store

With a Ubuntu SSO account we can login and logout of our account using `snapcraft`
```console
$ snapcraft login
Email: [ubuntu_sso_email]
Password: [ubuntu_sso_pass]
$ snapcraft logout
```

To register a snap name for a particular project we use the terminal
```console
$ snapcraft register [snap_name]
```
Verify that `snapcraft.yaml` `name:` field matches the snap name you registered with the Snap Store. When ready to push change the `grade:` field to `stable`. Finally rebuild. Also dont forget to remove older builds of your `devmode` projects from your system.

## Pushing and Releasing
Registering our snap with Snap Store involves a push command that allows anyone to install the snap.
```console
$ snapcraft push [snap_id].snap --release=[channel]
```

Finally we can release the snap to a `stable` channel allowing it to be immediately visible in the store. By default we start at revision `1` and release to `stable` channel.

```console
$ snapcraft release [snap_name] [revision] [channel]
````
