import math
import rclpy
from rclpy.node import Node
from std_msgs.msg import (
    Bool,
    Float32,
    Int64,
    String
)


class Pubby(Node):
    def __init__(self):
        super().__init__("publy")
        self.string_count = 0
        self.string_timer = self.create_timer(0.5, self.pub_string)
        self.string_pub = self.create_publisher(String, '/chat/str', 10)

        self.int_timer = self.create_timer(0.2, self.pub_int)
        self.int_pub = self.create_publisher(Int64, '/chat/int', 10)

    def pub_string(self):
        msg = String()
        msg.data = f'Hi {self.string_count}'
        self.string_pub.publish(msg)
        self.string_count += 1

    def pub_int(self):
        msg = Int64()
        now_s = self.get_clock().now().nanoseconds / 1e9
        msg.data = int(math.sin(now_s) * 100)
        self.int_pub.publish(msg)


def main(args=None):
    rclpy.init(args=args)
    node = Pubby()
    rclpy.spin(node)
    rclpy.shutdown()

if __name__ == '__main__':
    main()
