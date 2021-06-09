FROM rostooling/setup-ros-docker:ubuntu-focal-latest

# RUN echo 'Acquire::HTTP::Proxy "http://240.10.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
#  && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
ENV COLCON_HOME=/etc/colcon
ENV ROS_DISTRO=foxy
ENV ROS_PYTHON_VERSION=3

# Enable debug packages
RUN apt-get update && apt-get install ubuntu-dbgsym-keyring && rm -rf /var/lib/apt/lists/*
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" > /etc/apt/sources.list.d/ddebs.list && \
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" > /etc/apt/sources.list.d/ddebs.list

# Install key development tools
RUN apt-get update && apt install -y \
  clang \
  libc++-dev \
  libc++abi-dev \
  gdb \
  ccache

# Install comfort tools
RUN apt-get update && apt-get install -y zsh vim curl less htop

# Install rosdeps for the workspace (not currently  allowing for ignoring packages)
WORKDIR /ws
COPY src/ src/
RUN apt-get update && rosdep update \
    && rosdep install --from-paths src/ --ignore-src --rosdistro $ROS_DISTRO -y --skip-keys "console_bridge fastcdr fastrtps libopensplice67 libopensplice69 rti-connext-dds-5.3.1 urdfdom_headers"

RUN python3 -m pip install -U colcon-mixin
RUN colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && colcon mixin update
