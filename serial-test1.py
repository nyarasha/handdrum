# Karen Wickert
# Serial to MIDI program
# 3/24/2011

#import sys
#import os
import serial # pySerial
#import re	  # regex

#import pygame.midi as pg

# assumed format of Arduino serial transfer:  Serial.print(BYTE) values, MIDI hex specification
# example: (0x90, 0x69, 0x45) is a note-on value with a note value and velocity value after it 

# regex definitions
# remove beginning b' from each serial read
#CLEAN = re.compile(r'^b\'(.*)\'$')

# COM port number in use for drum data transfer
#PORT = 4        #COM5
PORT = 7  #COM8
#BAUD = 31250 # set baud rate (MIDI = 31250)
BAUD = 9600

# open serial port at specified BAUD and BYTESIZE
ser = serial.Serial(PORT, BAUD, serial.EIGHTBITS)
# nonstandard (MIDI) baud rate may be blocked - use 38400 if so
x = ser.read()			  # read one byte
y = ser.read(10)			  # read up to 3 bytes (timeout)
print(x)
print(y)

ser.close()				  # close serial port