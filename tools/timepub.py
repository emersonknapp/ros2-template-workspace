#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from rclpy.qos import QoSPresetProfiles

from rosgraph_msgs.msg import Clock


def main():
    rclpy.init()
    node = Node('clocky')
    clock_qos = QoSPresetProfiles.SENSOR_DATA.value
    clock_qos.history = 1
    pub = node.create_publisher(Clock, 'clock', clock_qos)

    msg = Clock()

    def pubtime():
        msg.clock.sec += 1
        pub.publish(msg)

    tmr = node.create_timer(0.2, pubtime)  # NOQA

    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == '__main__':
    main()
