#!/bin/bash
set -eu

source "${OVERLAY_WS}"/setup.bash
source tools/aliases

exec "$@"
