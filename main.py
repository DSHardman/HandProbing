import numpy as np
import matplotlib.pyplot as plt
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon
import random
import time


def choose_random_point(coords, coord):
    polygon = Polygon(coords)

    while 1:
        x = np.max(coords[:, 0])*random.random()
        y = np.max(coords[:, 1]) * random.random()
        point = Point(x, y)

        if polygon.contains(point):
            plt.plot(*polygon.exterior.xy, color='k')
            plt.draw()
            plt.show(block=False)
            plt.scatter(x, y, color='g')
            plt.gca().set_aspect('equal')
            plt.draw()
            plt.pause(0.0001)
            return [x, y], 0


def change_sides(coord):
    return


# plt.vlines(np.max(coords[:, 0])/2, 0, np.max(coords[:, 1]))
# plt.show()


###

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


coord = [0, 0]
for i in range(5):
    plt.cla()
    plt.title(str(i))
    # record/save unpressed state
    coord, change_sides_bool = choose_random_point(coords, coord)
    # save random coordinates
    if change_sides_bool:
        change_sides(coord)

    # translate to location
    # close pincher
    # move forwards
    time.sleep(3)
    # record/save pressed state

plt.show()
    # release
    # move backwards

# Toolpoint offset 115.82 vertically, 37.898 horizontally