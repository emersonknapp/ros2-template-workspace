# hadolint global ignore=DL3008,DL3013
ARG UBUNTU_DISTRO=jammy
ARG ARCH_PREFIX
FROM rostooling/setup-ros-docker:${ARCH_PREFIX}ubuntu-${UBUNTU_DISTRO}-latest AS base

ARG ROS_DISTRO=rolling
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=$ROS_DISTRO
ENV ROS_PYTHON_VERSION=3

ENV COLCON_HOME=/etc/colcon
ENV COLCON_DEFAULTS_FILE=/ws/tools/defaults.yaml

####################
# Rosdep Cache Layer
####################
FROM base AS depcache
ARG SKIP_KEYS
SHELL ["/bin/bash", "-c"]

# create file install_rosdeps.sh that won't change and bust cache if no dependencies change
RUN --mount=type=bind,source=src,target=/tmp/src \
    --mount=type=bind,source=tools/gather-rosdeps.sh,target=/tmp/gather-rosdeps.sh \
    rosdep update \
 && /tmp/gather-rosdeps.sh /tmp/install_rosdeps.sh /tmp/src

#################
# Workspace layer
#################
FROM base AS workspace
WORKDIR /ws

# Install key development tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends -q \
    #  clang \
    #  libc++-dev \
    #  libc++abi-dev \
    gdb \
    ccache \
  && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir setuptools==58.2.0

# Enable debug packages (optional but nice)
RUN apt-get update \
  && apt-get install -y --no-install-recommends -q \
    ubuntu-dbgsym-keyring \
  && rm -rf /var/lib/apt/lists/*
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" > /etc/apt/sources.list.d/ddebs.list && \
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" > /etc/apt/sources.list.d/ddebs.list

# Install comfort tools (extra optional but nice)
RUN apt-get update \
  && apt-get install -y --no-install-recommends -q \
    zsh \
    vim \
    curl \
    less \
    htop \
    tree \
  && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir -U colcon-mixin colcon-package-selection
RUN colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && colcon mixin update

# Install rosdeps for the workspace (not currently allowing for ignoring packages)
COPY --from=depcache /tmp/install_rosdeps.sh /tmp/install_rosdeps.sh
RUN apt-get update \
  && /tmp/install_rosdeps.sh \
  && rm -rf /var/lib/apt/lists/*
