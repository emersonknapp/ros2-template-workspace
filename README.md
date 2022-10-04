# ROS 2 Template Workspace

Want to start developing a new ROS 2 feature? Clone this and get going.

## Getting Started

* Prerequisites

```
# install docker
pip3 install vcstool rocker off-your-rocker
```

* Edit `ws.repos` to contain repositories relevant to development.

* Build your dev environment and start it

```
mkdir src
vcs import src < ws.repos
DEVIMG=my-img ./tools/rebuild-img --build-arg ROS_DISTRO=rolling --build-arg UBUNTU_DISTRO=jammy
DEVIMG=my-img ./tools/startimg
```

In the container (basic ROS dev workflow):

```
source /opt/ros/$ROS_DISTRO/setup.bash
colcon build
```

To start a new shell in the running container,

```
DEVIMG=my-img ./tools/attach
```
