import serial
import time

compwm = "COM16"  # Of Arduino
comgcode = "COM6"  # Of Printer

length = 150

# # Connect to Arduino COM port
pwm = serial.Serial(port=compwm, baudrate=9600)
gcode = serial.Serial(port=comgcode, baudrate=115200)
time.sleep(5)
gcode.write(b'G92 X0 Y0 Z0\n')
time.sleep(2)
gcode.write(b'M104 S170\n')
time.sleep(1)
print("Connected.")


# salt membrane done 2000
for speed in range(1000, 1012, 2):
    # Turn on dispenser
    pwm.write(str.encode('200\n'))
    # # Create channel
    gcode.write(b'G1 F' + str.encode(str(speed)) + b'Y' + str.encode(str(length)) + b'\n')
    time.sleep(abs(60.7*length/speed))
    # Turn off dispenser
    pwm.write(str.encode('0\n'))
    time.sleep(1)

    gcode.write(b'G0 F1000 Z10\r\n')
    time.sleep(1)

    gcode.write(b'G92 X0\r\n')
    time.sleep(1)
    gcode.write(b'G1 F1000 X20\r\n')
    time.sleep(1)
    gcode.write(b'G1 Y0\r\n')
    time.sleep(1)
    gcode.write(b'G0 Z0\r\n')
    time.sleep(10)

#

# # Return to starting position
# gcode.write(str.encode('G0 F3000 Z20\n'))
# gcode.write(str.encode('G0 F3000 Z20\n'))