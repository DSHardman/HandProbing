import serial
import time
import numpy as np

compwm = "COM16"  # Of Arduino
comgcode = "COM6"  # Of Printer

length = 90

# # Connect to Arduino COM port
pwm = serial.Serial(port=compwm, baudrate=9600)
gcode = serial.Serial(port=comgcode, baudrate=115200)
time.sleep(5)
gcode.write(b'G92 X0 Y0 Z0\n')
time.sleep(2)
gcode.write(b'M104 S170\n')
time.sleep(1)
print("Connected.")

for i in range(4):
    gcode.write(b'G1 F2000 Z-3\n')
    time.sleep(0.5)
    for i in range(10):
        zheight = np.min([48 - np.sqrt(45**2 - (i*5)**2), 45])
        gcode.write(b'G1 F20000 Y' + str.encode(str(-i*5)) + b' Z-' + str.encode(str(zheight)) + b'\n')
        time.sleep(0.2)

    gcode.write(b'G1 F2000 Z0\n')
    time.sleep(3)
    gcode.write(b'G1 F2000 Y55\n')
    time.sleep(1)
    gcode.write(b'G1 F2000 Z-13\n')

    input("Press Enter to continue...")
    gcode.write(b'G92 X0 Y0 Z0\n')
    # Turn on dispenser
    pwm.write(str.encode('200\n'))
    for i in range(9):
        zheight = np.min([48 - np.sqrt(45**2 - (i*5)**2), 43])
        gcode.write(b'G1 F20000 Y' + str.encode(str(i*5)) + b' Z-' + str.encode(str(zheight)) + b'\n')
        time.sleep(0.2)

    gcode.write(b'G1 F2000 Y70\n')
    input("Press Enter to continue...")
    # Turn off dispenser
    pwm.write(str.encode('0\n'))
    gcode.write(b'G1 F2000 Z13\n')
    gcode.write(b'G1 F2000 Y-55\n')
    input("Press Enter to continue...")
    gcode.write(b'G92 X0 Y0 Z0\n')

# gcode.write(b'G1 F2000 Y-70\n')
# time.sleep(2)
#
#

#

# # Return to starting position
# gcode.write(str.encode('G0 F3000 Z20\n'))
# gcode.write(str.encode('G0 F3000 Z20\n'))