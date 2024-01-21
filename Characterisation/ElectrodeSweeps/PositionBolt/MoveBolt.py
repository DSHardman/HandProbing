import waypoints as wp
import kg_robot as kgr
import time
import numpy as np
import random
import serial
#from __future__ import absolute_import
import queue
from datetime import datetime

zeropose = [0.548304, -0.546316, -0.00462642, -1.76427, 2.59369, -0.030198]


#  Connect to UR5
urnie = kgr.kg_robot(port=30010, db_host="169.254.150.50")
urnie.set_tcp(wp.probing_tcp)

print(urnie.getl())

def pressrecord(x, y, xold, yold, savestring):
    # Position above last state
    startingpose = np.add(zeropose, [xold, yold, 0.05, 0, 0, 0])
    urnie.movel(startingpose, acc=0.03, vel=0.03)

    # Pick up from last state
    downpose = np.add(zeropose, [xold, yold, 0, 0, 0, 0])
    urnie.movel(downpose, acc=0.03, vel=0.03)
    urnie.set_tool_digital_out(0, 1)
    time.sleep(1)
    uppose = np.add(zeropose, [xold, yold, 0.02, 0, 0, 0])
    urnie.movel(uppose, acc=0.03, vel=0.03)

    # Drop in new state and move up
    acrosspose = np.add(zeropose, [x, y, 0.02, 0, 0, 0])
    urnie.movel(acrosspose, acc=0.03, vel=0.03)
    downpose = np.add(zeropose, [x, y, 0, 0, 0, 0])
    urnie.movel(downpose, acc=0.03, vel=0.03)
    urnie.set_tool_digital_out(0, 0)
    time.sleep(1)
    uppose = np.add(zeropose, [x, y, 0.05, 0, 0, 0])
    urnie.movel(uppose, acc=0.03, vel=0.03)

    present = datetime.now().strftime("%Y-%m-%d %H-%M-%S")
    f = open("responses/" + str(i) + ".txt", "w")
    f.write(str(present) + " " + str(x) + " " + str(y))
    f.close()


xold = 0
yold = 0
for i in range(5000):  # Randomise within circle

    radius = 35

    # Select from random distribution within circle
    rho = radius*2
    while rho > radius:
        x = (random.random()*2*radius-radius)/1000
        y = (random.random()*2*radius-radius)/1000
        rho = np.sqrt((x*1000)**2 + (y*1000)**2)

    pressrecord(x, y, xold, yold, '_bolt_' + str(i))
    xold = x
    yold = y
    print(i)
    time.sleep(3)

urnie.close()
