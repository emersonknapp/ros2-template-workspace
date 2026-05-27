#!/usr/bin/bash
# SPDX-FileCopyrightText: 2026 Emerson Knapp
# SPDX-License-Identifier: Apache-2.0
set -e

cat /opt/ros/ws-tools/ros2_logo_ascii.txt
printf '\n\nHello, ROS developer!\n\n'
source "${OVERLAY_WS}"/setup.bash || echo "[WARN] Overlay workspace ${OVERLAY_WS} not found, not sourced"
source /opt/ros/ws-tools/colcon-aliases

exec "$@"
