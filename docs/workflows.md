# ROS 2 Dev Workflows

Just a collection of tips and tricks.

## Python debugging

Matcher pattern is going to match the test file first, not the name of the test

```shell
ctvp ros2service --pytest-args -s -k "test_cli"
```

You can just toss python under a `gdb` to test bound libraries like `rcl`

```shell
gdb python3
```

## GDB

`.gdbinit` files good for repeated runs

Example:

```gdb
set pagination off
set breakpoint pending on
break _rclpy_logging.cpp:213
run -u -m pytest /ws/src/ros2/rclpy/rclpy/test/test_destruction.py
```

Some other reminders

```gdb
thread apply all bt

info breakpoints (info b)
del 1
b function_name
b line_in_current_file
b file:line
b file:function
b line if condition

# TODO breakpoint commands, like print on hit
```
