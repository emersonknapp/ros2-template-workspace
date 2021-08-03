#!/usr/bin/env python3

import rclpy
from rclpy.node import Node

from std_msgs.msg import String

class Talker(Node):
    def __init__(self):
        super().__init__('talker')
        self.pub = self.create_publisher(String, '/chatter', 1)
        self.timer = self.create_timer(0.01, self.pub_cb)
        self.count = 0

    def pub_cb(self):
        msg = String(data=f'hello {self.count}')
        self.pub.publish(msg)
        self.count += 1

def main():
    rclpy.init()
    node = Talker()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == "__main__":
    main()
