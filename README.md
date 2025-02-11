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
DEVIMG=my-img ./tools/rebuild-img --build-arg ROS_DISTRO=rolling --build-arg UBUNTU_DISTRO=jammy
DEVIMG=my-img ./tools/startimg
```

In the container (basic ROS dev workflow):

```shell
source /opt/ros/$ROS_DISTRO/setup.bash
colcon build
```

To start a new shell in the running container,

```shell
DEVIMG=my-img ./tools/attach
```
