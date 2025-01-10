import waypoints as wp
import kg_robot as kgr
import time
import numpy as np
import random
import serial
#from __future__ import absolute_import
import queue
from datetime import datetime

com = "COM5"
ser = serial.Serial(port=com, baudrate=9600)
time.sleep(2)
print("Connected to Arduino")

time.sleep(2)

## Old goes here

zeropose = [0.67642, -0.136289, 0.0873021, 0.993058, -2.96328, -0.00987475]


#  Connect to UR5
urnie = kgr.kg_robot(port=30010, db_host="169.254.150.10")
urnie.set_tcp(wp.probing_tcp)

# print(urnie.getl())
# urnie.close()


def pressrecord(i, config):
    # Position above last state
    startingpose = np.add(zeropose, [0, 0, 0.01, 0, 0, 0])
    urnie.movel(startingpose, acc=0.03, vel=0.03)

    ser.write(str.encode(config[2:].zfill(6)+'\n'))

    time.sleep(6)

    downpose = np.add(zeropose, [0, 0, -0.005, 0, 0, 0])  # First batch was 3mm
    urnie.movel(downpose, acc=0.03, vel=0.03)


    present = datetime.now().strftime("%Y-%m-%d %H-%M-%S")
    f = open("channelresponses/" + str(i) + ".txt", "w")
    f.write(str(present) + " " + config[2:].zfill(6))
    f.close()

    time.sleep(6)


n = 10
for k in range(n):
    order = np.arange(63) + 1
    random.shuffle(order)
    for i in range(63):
        print(str(k) + ": " + str(i))
        pressrecord(i + k*63, bin(order[i]))

# print(urnie.getl())
urnie.movel(zeropose, acc=0.03, vel=0.03)
urnie.close()

ser.close()
