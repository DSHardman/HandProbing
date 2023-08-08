import kg_robot as kgr
import time
import numpy as np
import random
import serial
import queue
import matplotlib.pyplot as plt
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon

# Folder in which this test's data will be recorded
foldername = 'RepetitionData/Raw/'
freq = "50k"
meastype = "ADAD"

# Define robot limits
zero_yz_robot = [-0.342286, 0.179424]
lower_bound = 1000*(0.238907-zero_yz_robot[1])
limit1 = [84.23, 0]  # Limit of reach
limit2 = [77.64, 220]  # Limit of reach

savetime = 10

# Load outline of hand, scale to size, and set to origin
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
#
#  Connect to UR5 and move to starting position
urnie = kgr.kg_robot(port=30010, db_host="169.254.150.50")
urnie.set_tcp([0, 0.037898, 0.12552, 0, 0, 0])  # Tip of pincher
urnie.movej([-4.23929, -1.69484, 2.50654, -4.00664, -2.11265, -1.59363], acc=0.5, vel=1.0)

# Connect to Arduino Pro Mini controlling pinching mechanism
com = "COM10"
ser = serial.Serial(port=com, baudrate=9600)
ser.write(str.encode('o\n'))
print("Connected to Arduino")

# Connect to EIT board
com2 = "COM11"
ser2 = serial.Serial(port=com2, baudrate=11520)
print("Connected to EIT board")

# Given two consecutive probing points, does the setup need to switch sides between them?
# Decided by whether the line segment connecting them intersects with a near-centre boundary
def check_side_change(coord1, coord2):
    def ccw(A, B, C):
        return (C[1]-A[1]) * (B[0]-A[0]) > (B[1]-A[1]) * (C[0]-A[0])
    plt.plot([limit1[0], limit2[0]], [limit1[1], limit2[1]], color='r')
    return ccw(coord1, limit1, limit2) != ccw(coord2, limit1, limit2) and ccw(coord1, coord2, limit1) != ccw(coord1, coord2, limit2)


# Hardcoded positions if sides do need to change: set of steps to avoid collisions
def change_sides():
    current_position = urnie.getl()
    # Move from left to right
    if current_position[0] < 0.18:
        urnie.movej([-4.23929, -1.69484, 2.50654, -4.00664, -2.11265, -1.59363], acc=0.5, vel=1.0)  # Leftmost
        urnie.movej([-4.37041, -1.80371, 2.13308, -3.52067, -1.97533, -1.58118], acc=0.5, vel=1.0)  # Upper
        urnie.movej([-4.37043, -1.80366, 2.13297, -3.52064, -1.97533, 1.55576], acc=2.0, vel=2.0)  # Perform rotation
        urnie.movej([-4.60221, -1.40817, 1.19664, -1.40745, -1.55043, 1.72113], acc=0.5, vel=2.0)  # To RHS
        urnie.movej([-4.63778, -0.934103, 0.832699, -0.24062, -1.4246, 1.60202], acc=0.5, vel=1.0)  # Rightmost
    # Move from right to left
    else:
        urnie.movej([-4.63778, -0.934103, 0.832699, -0.24062, -1.4246, 1.60202], acc=0.5, vel=1.0)  # Rightmost
        urnie.movej([-4.60221, -1.40817, 1.19664, -1.40745, -1.55043, 1.72113], acc=0.5, vel=1.0)  # Upper vertical
        urnie.movej([-4.37043, -1.80366, 2.13297, -3.52064, -1.97533, 1.55576], acc=0.5, vel=2.0)  # To LHS
        urnie.movej([-4.37041, -1.80371, 2.13308, -3.52067, -1.97533, -1.58118], acc=2.0, vel=2.0)  # Perform rotation
        urnie.movej([-4.23929, -1.69484, 2.50654, -4.00664, -2.11265, -1.59363], acc=0.5, vel=1.0)  # Leftmost


# Main function: pinch at random location, save responses to file
def pressrecord(x, y, savestring):
    xy = [x, y]

    for repetition in range(5):
        t0 = time.time()
        lines = []
        while time.time() - t0 < savetime:
            lines.append(ser2.readline())

        change = check_side_change([x, y], coord)

        # If probing thumb area, first offset pincher to not collide during positioning
        currentpose = urnie.getl()
        if x > 130:
            urnie.movej([-4.63778, -0.934103, 0.832699, -0.24062, -1.4246, 1.60202], acc=0.5, vel=1.0)
            urnie.movel(np.add(currentpose, [-currentpose[0]+0.195, 0, 0, 0, 0, 0]), acc=0.02, vel=0.02)
            currentpose = urnie.getl()

        # Go to probe location
        urnie.movel([currentpose[0], zero_yz_robot[0]-x/1000, zero_yz_robot[1]+y/1000, currentpose[3], currentpose[4], currentpose[5]], acc=0.02, vel=0.02)
        newpose = urnie.getl()
        # Close pincher and move fixed pincher to central plane (x=0.176) simultaneously
        ser.write(str.encode('c\n'))
        urnie.movel(np.add(newpose, [-newpose[0]+0.176, 0, 0, 0, 0, 0]), acc=0.02, vel=0.02)
        time.sleep(5)

        t0 = time.time()
        while time.time() - t0 < savetime:
            lines.append(ser2.readline())

        # Release pincher and move out fixed probe
        ser.write(str.encode('o\n'))
        time.sleep(5)
        urnie.movel(newpose, acc=0.02, vel=0.02)

        # If in thumb area, reset lateral offset before continuing
        if x > 130:
            currentpose = urnie.getl()
            urnie.movel(np.add(currentpose, [-currentpose[0]+0.212181, 0, 0, 0, 0, 0]), acc=0.02, vel=0.02)
            urnie.movej([-4.63778, -0.934103, 0.832699, -0.24062, -1.4246, 1.60202], acc=0.5, vel=1.0)

        t0 = time.time()
        while time.time() - t0 < savetime:
            lines.append(ser2.readline())

        filename = foldername + "_" + freq + "_" + meastype + "_" + savestring + "_" + str(repetition+1) + ".txt"
        f = open(filename, "w")
        for line in lines:
            f.write(str(line))
            f.write("\n")
        f.close()



coord = [[0, 0], [20, 130], [45, 105], [80, 180], [170, 90], [100, 75]]

for i in range(1, len(coord)):
    if check_side_change(coord[i], coord[i-1]):
        change_sides()
    pressrecord(coord[i][0], coord[i][1], str(i))

# Return to left-hand side at end
current_position = urnie.getl()
if current_position[0] > 0.18:
    change_sides()

# Cleanup
urnie.close()
