# hadolint global ignore=DL3008,DL3013
ARG ARCH_PREFIX
ARG ROS_DISTRO=rolling
ARG BASE_IMAGE_NAME=polymathrobotics/ros:${ROS_DISTRO}-builder-ubuntu
FROM ${BASE_IMAGE_NAME} AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=$ROS_DISTRO
ENV ROS_PYTHON_VERSION=3

ENV COLCON_HOME=/etc/colcon
ENV COLCON_DEFAULTS_FILE=/ws/tools/defaults.yaml

ENV PIP_BREAK_SYSTEM_PACKAGES=1
# This is for colcon packages that explicitly unroll group-depends for buildfarm compatibility
ENV DISABLE_GROUPS_WORKAROUND=1

####################
# Rosdep Cache Layer
####################
FROM base AS depcache
ARG SKIP_KEYS
SHELL ["/bin/bash", "-c"]

# create file install_rosdeps.sh that won't change and bust cache if no dependencies change
RUN --mount=type=bind,source=src,target=/tmp/src \
    --mount=type=bind,source=tools/gather-rosdeps.sh,target=/tmp/gather-rosdeps.sh \
    rosdep update --rosdistro "$ROS_DISTRO" \
 && /tmp/gather-rosdeps.sh /tmp/install_rosdeps.sh /tmp/src

#################
# Workspace layer
#################
FROM base AS workspace

SHELL ["/bin/bash", "-c"]

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
    python3-colcon-mixin \
    python3-colcon-package-selection \
  && rm -rf /var/lib/apt/lists/*

# Install dependencies for workspace
COPY --from=depcache /tmp/install_rosdeps.sh /tmp/install_rosdeps.sh
RUN apt-get update \
  && cat /tmp/install_rosdeps.sh \
  && /tmp/install_rosdeps.sh \
  && rm -rf /var/lib/apt/lists/*

ARG OVERLAY_WS=/opt/ros/${ROS_DISTRO}
ENV OVERLAY_WS=${OVERLAY_WS}
COPY entry /opt/ros/ws-tools
ENTRYPOINT ["/opt/ros/ws-tools/entrypoint.sh"]
CMD ["/bin/bash"]
