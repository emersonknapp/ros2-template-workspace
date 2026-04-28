default:
    cat entry/ros2_logo_ascii.txt
    echo "Hello, ROS 2 developer!"

### CLI ROS development workflow

default_ws := "ros_ws"
default_ros_distro := "rolling"

# Import sources
sync repos_file:
    mkdir -p src/
    uv run vcs import --recursive src/ < {{repos_file}}
    vcs pull src

# Create/update the workspace container image
create ws_name=default_ws *args:
    DEVIMG={{ws_name}} ./tools/create-ws {{args}}

# Incremental update an existing ws with new dependencies, for faster iteration
create-inc ws_name=default_ws *args:
    DEVIMG={{ws_name}} ./tools/incremental-ws {{args}}

# Start a workspace container
start ws_name=default_ws:
    DEVIMG={{ws_name}} ./tools/start-ws

# Attach to a running workspace container
attach ws_name=default_ws:
    DEVIMG={{ws_name}} ./build-tools/attach
