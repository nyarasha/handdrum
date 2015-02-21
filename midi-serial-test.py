# Karen Wickert
# MIDI - Serial Test for drum controller project
# 2/27/2011

import serial # pySerial
import re	  # regex

# regex definitions
# remove beginning b' from each serial read
CLEAN = re.compile(r'^b\'(.*)\'$')

# COM port number in use for drum data transfer
#PORT = 4
PORT = 2
BAUD = 31250 # set baud rate (MIDI = 31250)

# open serial port at specified BAUD and BYTESIZE
ser = serial.Serial(PORT, BAUD, serial.EIGHTBITS)
# nonstandard (MIDI) baud rate may be blocked - use 38400 if so
x = ser.read()			  # read one byte
y = ser.read(3)			  # read up to 3 bytes (timeout)
print(x)
print(y)

x = str(x) # need to convert type to compare
print(x)
result = re.search(CLEAN, x)
print('Match?')
print(result)
x = result.group(1)
print('Clean: ')
print(x)
if x == '\\x90':
	print('Yes')
	print(x)
else:
	print('No')
	print(x)

print('-------------')

print('y:')
print(y)
y = str(y)
result = re.search(CLEAN, y)
print('Match?')
print(result)
y = result.group(1)
print('Clean: ')
print(y)
if x == '\\x90':
	print('Yes')
	print(y)
else:
	print('No')
	print(y)
	
ser.close()				  # close port