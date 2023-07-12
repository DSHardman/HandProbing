import waypoints as wp
import kg_robot as kgr
import time
import numpy as np
import random
import serial
#from __future__ import absolute_import
import queue
import OpenEIT.backend

timebefore = 1
timedown = 1.5
# timepressed = 2
dt = 0.05

zeropose = [0.247722, -0.392591, 0.0358576, -3.12646, -0.125169, -0.0300251]
foldername = 'PreliminaryTests'

#  Connect to UR5
urnie = kgr.kg_robot(port=30010, db_host="169.254.150.50")
urnie.set_tcp(wp.probing_tcp)


# Connect to EIT board
serial_handler = OpenEIT.backend.SerialHandler(queue.Queue())
serial_handler.connect('COM5')
serial_handler.setmode('c')
serial_handler.start_recording()
time.sleep(20)  # Give ample time to connect and start returning data


def pressrecord(x, y, savestring):
    xy = [x, y]

    # # Control press using defined variables
    startingpose = np.add(zeropose, [x, y, 0.01, 0, 0, 0])
    urnie.movel(startingpose, acc=0.02, vel=0.02)

    serial_state = serial_handler.updater
    while serial_handler.updater == serial_state:
        pass  # wait for last set of readings to end

    while serial_handler.updater != serial_state:
        pass  # wait for new set of readings to end

    data = OpenEIT.backend.serialhandler.parse_any_line(serial_handler.raw_text, 'c')

    np.save('responses/' + foldername + '/up_' + savestring, data)

    downpose = np.add(zeropose, [x, y, -depth, 0, 0, 0])
    # downpose = np.add(startingpose, [0, 0, -(0.01+depth), 0, 0, 0])
    urnie.movel(downpose, acc=0.01, vel=0.01)

    # Save data
    serial_state = serial_handler.updater
    while serial_handler.updater == serial_state:
        pass  # wait for last set of readings to end

    while serial_handler.updater != serial_state:
        pass  # wait for new set of readings to end

    data = OpenEIT.backend.serialhandler.parse_any_line(serial_handler.raw_text, 'a')
   # print(data)
    np.save('Responses/' + foldername + '/position_' + savestring, xy)
    np.save('Responses/' + foldername + '/down_' + savestring, data)

    urnie.movel(startingpose, acc=0.01, vel=0.01)


for i in range(5):  # Randomise within circle
    pressrecord(x, y, depth, str(i))
    print(i)

urnie.close()
