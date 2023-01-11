import argparse
import math
import rclpy
from rclpy.node import Node
from rclpy.clock import Clock
from rclpy.time import Time
from rclpy.duration import Duration
from std_msgs.msg import (
    Bool,
    Float32,
    Int64,
    String
)
import rosbag2_py as bag
from rclpy.serialization import serialize_message

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

def dopub(args=None):
    rclpy.init(args=args)
    node = Pubby()
    rclpy.spin(node)
    rclpy.shutdown()




def writeabag():

    clock = Clock()
    writer = bag.SequentialWriter()
    opts = bag.StorageOptions(uri=args.uri, storage_id="sqlite3")
    writer.open(opts, bag.ConverterOptions())
    writer.create_topic(bag.TopicMetadata("chat", "std_msgs/String", "cdr"))

    time = Time(seconds=0.5)
    for i in range(10):
        msg = String(data=f"hi {i}")
        writer.write('chat', serialize_message(msg), time.nanoseconds)
        time += Duration(seconds=0.5)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-u", '--uri', default='testbag')
    parser.add_argument('-p', '--pub', action='store_true', help='be a publisher')
    args = parser.parse_args()

    if args.pub:
        dopub()
    else:
        writeabag()


if __name__ == '__main__':
    main()
    # writeabag()
