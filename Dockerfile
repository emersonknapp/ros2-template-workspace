ARG UBUNTU_DISTRO=jammy
ARG ARCH_PREFIX
FROM rostooling/setup-ros-docker:${ARCH_PREFIX}ubuntu-${UBUNTU_DISTRO}-latest as base

ARG ROS_DISTRO=rolling
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=$ROS_DISTRO
ENV ROS_PYTHON_VERSION=3

ENV COLCON_HOME=/etc/colcon
ENV COLCON_DEFAULTS_FILE=/ws/tools/defaults.yaml

FROM base as depcache
ARG SKIP_KEYS
SHELL ["/bin/bash", "-c"]

# create file install_rosdeps.sh that won't change and bust cache if no dependencies change
RUN --mount=type=bind,source=src,target=/tmp/src \
    --mount=type=bind,source=tools/gather-rosdeps.sh,target=/tmp/gather-rosdeps.sh \
    rosdep update \
 && /tmp/gather-rosdeps.sh /tmp/install_rosdeps.sh /tmp/src

FROM base as workspace
WORKDIR /ws

# Uncomment following lines to use local apt cache - probably need to tweak IPs
# RUN echo 'Acquire::HTTP::Proxy "http://240.10.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
#  && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

# Install key development tools
RUN apt-get update && apt install -y \
#  clang \
#  libc++-dev \
#  libc++abi-dev \
  gdb \
  ccache

RUN python3 -m pip install setuptools==58.2.0

# Enable debug packages (optional but nice)
RUN apt-get update && apt-get install ubuntu-dbgsym-keyring && rm -rf /var/lib/apt/lists/*
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" > /etc/apt/sources.list.d/ddebs.list && \
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" > /etc/apt/sources.list.d/ddebs.list

# Install comfort tools (extra optional but nice)
RUN apt-get update && apt-get install -y zsh vim curl less htop tree

RUN python3 -m pip install -U colcon-mixin colcon-package-selection
RUN colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && colcon mixin update

# Install rosdeps for the workspace (not currently  allowing for ignoring packages)
COPY --from=depcache /tmp/install_rosdeps.sh /tmp/install_rosdeps.sh
RUN apt-get update && /tmp/install_rosdeps.sh
