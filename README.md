# ROS 2 Template Workspace

Want to start developing a new ROS 2 feature or application? Clone this and get going.

## Prerequisites

1. [Install Docker](https://docs.docker.com/engine/install/)
2. Install python workflow prerequisites

```shell
pip3 install vcstool rocker off-your-rocker
```

## Usage

* Edit `ws.repos` to contain repositories relevant to development.

* Build your dev environment and start it:

```shell
mkdir src
vcs import src < ws.repos
DEVIMG=my-img ./tools/build-ws --build-arg ROS_DISTRO=rolling --build-arg UBUNTU_DISTRO=noble
DEVIMG=my-img ./tools/start-ws
```

In the container (basic ROS dev workflow):

```shell
colcon build
```

To start a new shell in the running container,

```shell
DEVIMG=my-img ./tools/attach
```

Also, to avoid full reinstall of all dependencies, you can do an incremental rosdep installation of only new dependencies as a new layer on top of the prebuilt image:

```shell
DEVIMG=my-img ./tools/incremental-ws
```

### Repos Files

For convenience working on ROS 2 core on live distributions, various `.repos` files are provided here in [repos/](./repos/). They are not meant to be combined - each is a standalone copy from https://github.com/ros2/ros2 `ros2.repos` at the relevant branch. I wouldn't trust these too much to be all the way up to date - again, they are merely a convenience for core development.
