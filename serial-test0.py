# Karen Wickert
# MIDI - Serial Test for drum controller project
# 3/24/2011

import serial # pySerial

# COM port number in use for drum data transfer
#PORT = 4
PORT = 7
print PORT
#BAUD = 31250 # set baud rate (MIDI = 31250)
BAUD = 9600
print BAUD

# open serial port at specified BAUD and BYTESIZE
ser = serial.Serial(PORT, BAUD, serial.EIGHTBITS)
print 'opened port ' + ser.portstr
# nonstandard (MIDI) baud rate may be blocked - use 38400 if so

x = ser.read()			  # read one byte
print 'read x'
print x

ser.close()				  # close port