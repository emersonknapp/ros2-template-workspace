#!/usr/bin/env python
# license removed for brevity
import math
import rospy
from std_msgs.msg import String
from std_msgs.msg import Int32

def talker():
    pub = rospy.Publisher('/ros1/chat/int', Int32, queue_size=10)
    rospy.init_node('talker', anonymous=True)
    rate = rospy.Rate(10) # 10hz
    while not rospy.is_shutdown():
        val = math.sin(rospy.get_time()) * 100
        pub.publish(int(val))
        rate.sleep()

if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException:
        pass
