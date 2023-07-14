import waypoints as wp
import kg_robot as kgr
import time
import numpy as np
import random
import serial
#from __future__ import absolute_import
import queue
import OpenEIT.backend
import matplotlib.pyplot as plt
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon


# timebefore = 1
# timedown = 1.5
# # timepressed = 2
# dt = 0.05

foldername = 'PreliminaryTests'

with open("handoutline.txt") as f:
    lines = f.readlines()
    coords = np.zeros([len(lines), 2])
    for i in range(len(lines)):
        splitline = lines[i].split("   ")
        coords[i, 0] = float(splitline[0])
        coords[i, 1] = float(splitline[1])

coords *= 3.557
coords[:, 0] -= np.min(coords[:, 0])
coords[:, 1] -= np.min(coords[:, 1])

zero_yz_robot = [-0.342286, 0.179424]
limit1 = [84.23, 0]
limit2 = [77.64, 220]
lower_bound = 1000*(0.238907-zero_yz_robot[1])

#  Connect to UR5
urnie = kgr.kg_robot(port=30010, db_host="169.254.150.50")
urnie.set_tcp([0, 0.037898, 0.12552, 0, 0, 0])  # Tip of pincher
urnie.movej([-4.23929, -1.69484, 2.50654, -4.00664, -2.11265, -1.59363], acc=0.5, vel=1.0)

com = "COM10"
ser = serial.Serial(port=com, baudrate=9600)
ser.write(str.encode('o\n'))
print("Connected to Arduino")

# # Connect to EIT board
# serial_handler = OpenEIT.backend.SerialHandler(queue.Queue())
# serial_handler.connect('COM5')
# serial_handler.setmode('c')
# serial_handler.start_recording()
# time.sleep(20)  # Give ample time to connect and start returning data


def check_side_change(coord1, coord2):
    def ccw(A, B, C):
        return (C[1]-A[1]) * (B[0]-A[0]) > (B[1]-A[1]) * (C[0]-A[0])
    plt.plot([limit1[0], limit2[0]], [limit1[1], limit2[1]], color='r')
    return ccw(coord1, limit1, limit2) != ccw(coord2, limit1, limit2) and ccw(coord1, coord2, limit1) != ccw(coord1, coord2, limit2)


def change_sides():
    current_position = urnie.getl()
    if current_position[0] < 0.18:
        urnie.movej([-4.23929, -1.69484, 2.50654, -4.00664, -2.11265, -1.59363], acc=0.5, vel=1.0)  # Leftmost
        urnie.movej([-4.37041, -1.80371, 2.13308, -3.52067, -1.97533, -1.58118], acc=0.5, vel=1.0)  # Upper
        urnie.movej([-4.37043, -1.80366, 2.13297, -3.52064, -1.97533, 1.55576], acc=2.0, vel=2.0)  # Perform rotation
        urnie.movej([-4.60221, -1.40817, 1.19664, -1.40745, -1.55043, 1.72113], acc=0.5, vel=2.0)  # To RHS
        urnie.movej([-4.63778, -0.934103, 0.832699, -0.24062, -1.4246, 1.60202], acc=0.5, vel=1.0)  # Rightmost
    else:
        urnie.movej([-4.63778, -0.934103, 0.832699, -0.24062, -1.4246, 1.60202], acc=0.5, vel=1.0)  # Rightmost
        urnie.movej([-4.60221, -1.40817, 1.19664, -1.40745, -1.55043, 1.72113], acc=0.5, vel=1.0)  # Upper vertical
        urnie.movej([-4.37043, -1.80366, 2.13297, -3.52064, -1.97533, 1.55576], acc=0.5, vel=2.0)  # To LHS
        urnie.movej([-4.37041, -1.80371, 2.13308, -3.52067, -1.97533, -1.58118], acc=2.0, vel=2.0)  # Perform rotation
        urnie.movej([-4.23929, -1.69484, 2.50654, -4.00664, -2.11265, -1.59363], acc=0.5, vel=1.0)  # Leftmost


def choose_random_point(coord):
    polygon = Polygon(coords)

    while 1:
        x = np.max(coords[:, 0])*random.random()
        y = (np.max(coords[:, 1])-lower_bound)*random.random() + lower_bound
        point = Point(x, y)

        if polygon.contains(point):
            plt.plot(*polygon.exterior.xy, color='k')
            plt.draw()
            plt.show(block=False)
            plt.scatter(x, y, color='g')
            plt.gca().set_aspect('equal')
            change = check_side_change([x, y], coord)
            plt.draw()
            plt.pause(0.0001)
            return [x, y], change


def pressrecord(x, y, savestring):
    xy = [x, y]

    currentpose = urnie.getl()
    if x > 130:
        urnie.movej([-4.63778, -0.934103, 0.832699, -0.24062, -1.4246, 1.60202], acc=0.5, vel=1.0)
        urnie.movel(np.add(currentpose, [-currentpose[0]+0.195, 0, 0, 0, 0, 0]), acc=0.02, vel=0.02)
        currentpose = urnie.getl()

    urnie.movel([currentpose[0], zero_yz_robot[0]-x/1000, zero_yz_robot[1]+y/1000, currentpose[3], currentpose[4], currentpose[5]], acc=0.02, vel=0.02)
    newpose = urnie.getl()
    ser.write(str.encode('c\n'))
    urnie.movel(np.add(newpose, [-newpose[0]+0.176, 0, 0, 0, 0, 0]), acc=0.02, vel=0.02)
    time.sleep(5)
    ser.write(str.encode('o\n'))
    urnie.movel(newpose, acc=0.02, vel=0.02)




    # serial_state = serial_handler.updater
    # while serial_handler.updater == serial_state:
    #     pass  # wait for last set of readings to end
    #
    # while serial_handler.updater != serial_state:
    #     pass  # wait for new set of readings to end
    #
    # data = OpenEIT.backend.serialhandler.parse_any_line(serial_handler.raw_text, 'c')
    #
    # np.save('responses/' + foldername + '/up_' + savestring, data)

    # downpose = np.add(zeropose, [x, y, -depth, 0, 0, 0])
    # downpose = np.add(startingpose, [0, 0, -(0.01+depth), 0, 0, 0])
    # urnie.movel(downpose, acc=0.01, vel=0.01)

   #  # Save data
   #  serial_state = serial_handler.updater
   #  while serial_handler.updater == serial_state:
   #      pass  # wait for last set of readings to end
   #
   #  while serial_handler.updater != serial_state:
   #      pass  # wait for new set of readings to end
   #
   #  data = OpenEIT.backend.serialhandler.parse_any_line(serial_handler.raw_text, 'a')
   # # print(data)
   #  np.save('Responses/' + foldername + '/position_' + savestring, xy)
   #  np.save('Responses/' + foldername + '/down_' + savestring, data)

    # urnie.movel(startingpose, acc=0.01, vel=0.01)
    if x > 130:
        currentpose = urnie.getl()
        urnie.movel(np.add(currentpose, [-currentpose[0]+0.212181, 0, 0, 0, 0, 0]), acc=0.02, vel=0.02)
        urnie.movej([-4.63778, -0.934103, 0.832699, -0.24062, -1.4246, 1.60202], acc=0.5, vel=1.0)



coord = [0, 0]
for i in range(5):
    plt.cla()
    plt.title(str(i))
    coord, change_sides_bool = choose_random_point(coord)
    time.sleep(2)
    plt.draw()
    plt.pause(0.0001)
    if change_sides_bool:
        change_sides()
    pressrecord(coord[0], coord[1], str(i))

current_position = urnie.getl()
if current_position[0] > 0.18:
    change_sides()

urnie.close()
plt.show()

