set shell := ["bash", "-cu"]

default:
    cat entry/ros2_logo_ascii.txt
    echo "Hello, ROS 2 developer!"

### Meta-stuff

update-repos:
    ./tools/update-repos

### CLI ROS development workflow

# Gitignored file holding the selected workspace name and distro, written by `just name` / `just distro`
local_env_file := justfile_directory() / ".ws.env.local"

ros_distro := shell('[ -f "$1" ] && . "$1"; printf "%s" "${ROS_DISTRO:-rolling}"', local_env_file)
ws_name := shell('[ -f "$1" ] && . "$1"; printf "%s" "${WS_NAME:-$2}"', local_env_file, file_name(justfile_directory()))

ws_image := "ros_ws/" + ws_name + ":" + ros_distro
ws_container := ws_name + "-" + ros_distro

@_env_file:
    touch "{{local_env_file}}"

[no-exit-message]
@_error msg:
    printf "{{style("error")}}Error: {{msg}}{{NORMAL}}\n" >&2 && exit 1

# Set KEY=VALUE in the local env file, replacing any previous value
@_set_env key value: _env_file
    sed -i '/^{{key}}=/d' "{{local_env_file}}"
    printf '%s=%s\n' "{{key}}" "{{value}}" >> "{{local_env_file}}"

# Show the selected workspace name, distro, and resulting image/container names
@info:
    echo "name:      {{ws_name}}"
    echo "distro:    {{ros_distro}}"
    echo "image:     {{ws_image}}"
    echo "container: {{ws_container}}"

# List the available ROS 2 distros, derived from repos/<distro>.repos
@list-distros:
    basename -s .repos repos/*.repos

# Select the ROS 2 distro for the workspace
[no-exit-message]
distro distro:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! just list-distros | grep -qxF "{{distro}}"; then
        just _error "Unknown distro '{{distro}}'. Available: $(just list-distros | xargs)"
    fi
    just _set_env ROS_DISTRO "{{distro}}"
    just info

# Select the name of the workspace, used to tag the image and name the container
[no-exit-message]
name name:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! [[ "{{name}}" =~ ^[a-z0-9]+([._-][a-z0-9]+)*$ ]]; then
        just _error "Invalid name '{{name}}': use lowercase letters, digits, and single '.', '_' or '-' separators"
    fi
    just _set_env WS_NAME "{{name}}"
    just info

# Import sources
sync repos_file="ws.repos":
    mkdir -p src/
    uv run vcs import --recursive src/ < {{repos_file}}
    vcs pull src

# Create/update the workspace container image
create *args:
    DEVIMG={{ws_image}} ./tools/create-ws --build-arg ROS_DISTRO={{ros_distro}} {{replace_regex(args, '^--( |$)', '')}}

# Incremental update an existing ws with new dependencies, for faster iteration
create-inc *args:
    DEVIMG={{ws_image}} ./tools/incremental-ws --build-arg ROS_DISTRO={{ros_distro}} {{replace_regex(args, '^--( |$)', '')}}

# Start a workspace container
start:
    DEVIMG={{ws_image}} CONTAINER_NAME={{ws_container}} ./tools/start-ws

# Attach to a running workspace container
attach *args:
    CONTAINER_NAME={{ws_container}} ./tools/attach {{replace_regex(args, '^--( |$)', '')}}
