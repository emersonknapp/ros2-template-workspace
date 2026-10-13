# ROS 2 Template Workspace

Want to start developing a new ROS 2 feature or application? Clone this and get going.

## Prerequisites

1. [Docker](https://docs.docker.com/engine/install/)
1. Python workflow prerequisites (install with `pip` or `uv`, etc):
   - `vcs2l`
   - `rocker`
   - `off-your-rocker`
1. Recommended: [just](https://just.systems/man/en/installation.html)

## Usage

All workflows are available as `just` recipes, which wrap the scripts in `tools/`.
See `just -l` for a list with comments on the commands.

### Select a workspace

Choose a ROS distro and a name for the workspace.
The selection is stored in the gitignored `.ws.env.local` and used by all following commands, so you only need to do this once (or when switching).

```shell
just distro lyrical   # one of `just list-distros`, defaults to rolling
just name rosgraph    # defaults to the name of this directory
just info          # show the current selection
```

This produces the image `ros_ws/<name>:<distro>` (e.g. `ros_ws/rosgraph:lyrical`) and the container `<name>-<distro>` (e.g. `rosgraph-lyrical`).

### Build and run

- Edit `ws.repos` to contain repositories relevant to development, then import them into `src/`:

```shell
just sync                         # imports ws.repos
just sync repos/lyrical.repos     # or any other .repos file
```

- Build your dev environment image and start it:

```shell
just create
just start
```

Extra arguments to `docker build` can be passed after `--`, e.g. `just create -- --no-cache`.

In the container (basic ROS dev workflow):

```shell
colcon build
```

To start a new shell in the running container:

```shell
just attach
```

To avoid a full reinstall of all dependencies, you can do an incremental rosdep installation of only new dependencies as a new layer on top of the previously built image:

```shell
just create-inc
```

Run a full `just create` occasionally, since each incremental build stacks more layers on the image.

### Without just

The scripts in `tools/` take the image name from `DEVIMG` and the container name from `CONTAINER_NAME` (defaulting to `DEVIMG`):

```shell
DEVIMG=ros_ws/rosgraph:lyrical ./tools/create-ws --build-arg ROS_DISTRO=lyrical
DEVIMG=ros_ws/rosgraph:lyrical CONTAINER_NAME=rosgraph-lyrical ./tools/start-ws
CONTAINER_NAME=rosgraph-lyrical ./tools/attach
```

### Repos Files

For convenience working on ROS 2 core on live distributions, various `.repos` files are provided here in [repos/](./repos/). They are not meant to be combined - each is a standalone copy from https://github.com/ros2/ros2 `ros2.repos` at the relevant branch. I wouldn't trust these too much to be all the way up to date - again, they are merely a convenience for core development.
