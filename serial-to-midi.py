# Karen Wickert
# Serial to MIDI program
# 3/12/2011

import sys
import os
import serial # pySerial
import re	  # regex

import pygame.midi as pg

# assumed format of Arduino serial transfer:  Serial.print(BYTE) values, MIDI hex specification
# example: (0x90, 0x69, 0x45) is a note-on value with a note value and velocity value after it 

# regex definitions
# remove beginning b' from each serial read
CLEAN = re.compile(r'^b\'(.*)\'$')

# COM port number in use for drum data transfer
#PORT = 4        #COM5
PORT = 2  #COM3
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

# TODO:
# - create logic that parses MIDI into strings (of 2/3/4 bytes) depending on first byte
# - output midi note-ons to MIDI-YOKE (output 10)
# - output controller messages to MIDI-YOKE (output 10)

def print_device_info():
	pg.init()
	_print_device_info()
	pg.quit()

def _print_device_info():
	print ("\nMIDI Input and Output Ports Available:\n")
	for i in range( pg.get_count() ):
		r = pg.get_device_info(i)
		(interf, name, input, output, opened) = r
		
		in_out = ""
		if input:
			in_out = "(input)"
		if output:
			in_out = "(output)"
		
		print ("%2i: %s:, opened: %s:  %s" %
				(i, name, opened, in_out))

def output_main(device_id):
	pg.init()
	
	if device_id is None:
		port = pg.get_default_output_id()
	else:
		port = device_id
		
	print ("using output_id: %s:" % port)
	
	midi_out = pg.Output(port, 0)
	
	note = 63
	velocity = 41
	midi_out.note_on(note, velocity, 0)
	midi_out.note_off(note)
	
	pg.quit()

	# TODO:
	# -create a function to retrieve the note, velocity, and channel values from the arduino output, parsed by regex
	
# helps user input the correct args
def usage():
	print ("\nSeems like you could use some help:\n")
	print ("--input [device_id] : Input MIDI")
	print ("--output [device_id] : Output MIDI")
	print ("--list : list available midi devices")
	print ("shortened commands work : -i ; -o ; -l")

	
ser.close()				  # close serial port


# TODO:
# - encapsulate all functionality into main() and into constituent, portable functions

if __name__ == '__main__':
	
	try:
		# get device id from 1st command line arg
		device_id = int( sys.argv[-1] )
	except:
		device_id = None
		
	# for debugging
	print ("\ndevice_id:")
	print (device_id)
	
	if "--input" in sys.argv or "-i" in sys.argv:
		input_main(device_id)
	elif "--output" in sys.argv or "-o" in sys.argv:
		output_main(device_id)
	elif "--list" in sys.argv or "-l" in sys.argv:	
		print_device_info()
	else:
		usage()