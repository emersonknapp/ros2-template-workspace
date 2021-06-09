# ROS 2 Template Workspace

Want to start developing a new ROS 2 feature? Clone this and get going.

## Getting Started

* Edit `ws.repos` to contain repositories relevant to development.
* Touch up Dockerfile based on ROS distro, etc

```
mkdir src
vcs import src < ws.repos
docker build . -t ros2dev --pull
./tools/rebuild-img
./tools/startimg
```

To start a new shell in the running container,

```
./tools/attach
```
