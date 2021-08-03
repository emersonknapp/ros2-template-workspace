from rosdev

copy src/ src/
run apt-get update && rosdep update && \
    rosdep install --from-paths src/ --ignore-src -y --rosdistro rolling --skip-keys "console_bridge fastcdr fastrtps rti-connext-dds-5.3.1 urdfdom_headers"
