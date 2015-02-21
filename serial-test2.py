# Karen Wickert
# Serial to MIDI program
# 3/24/2011

#import sys
#import os
import serial # pySerial
#import re	  # regex

import pygame.midi as pg

# assumed format of Arduino serial transfer:  Serial.print(BYTE) values, MIDI hex specification
# example: (0x90, 0x69, 0x45) is a note-on value with a note value and velocity value after it 

# regex definitions
# remove beginning b' from each serial read
#CLEAN = re.compile(r'^b\'(.*)\'$')

# define MIDI output functions, always assuming channel 0

def noteOut(device_id, note, velocity):
	pg.init()
	
	if device_id is None:
		port = pg.get_default_output_id()
	else:
		port = device_id
		
	print ("using output_id: %s:" % port)
	
	# using channel 0
	midi_out = pg.Output(port, 0)
	
	midi_out.note_on(note, velocity, 0)
	# sending a note-off right after the note-on for now
	midi_out.note_off(note)
	
	pg.quit()
	
def ctrlOut(device_id, number, value):
	pg.init()
	
	if device_id is None:
		port = pg.get_default_output_id()
	else:
		port = device_id
		
	print ("using output_id: %s:" % port)
	
	# using channel 0
	midi_out = pg.Output(port, 0)
	
	midi_out.write_short(0xb0, number, value)
	
	pg.quit()

# COM port number in use for drum data transfer
#PORT = 4        #COM5
PORT = 7  #COM8
BAUD = 31250 # set baud rate (MIDI = 31250)
#BAUD = 9600
# specify which MIDI output to use (here, using MIDI YOKE)
OUTPUT = 10

# open serial port at specified BAUD and BYTESIZE
ser = serial.Serial(PORT, BAUD, serial.EIGHTBITS)
# nonstandard (MIDI) baud rate may be blocked - use 38400 if so
x = ser.read()			  # read one byte
#y = ser.read(10)			  # read up to 3 bytes (timeout)
print(x)
#print(y)

x = str(x) # need to convert type to compare
#print 'string x: ' + x

# define case functions (what to do in each case)
# logic that parses MIDI into strings (of 2/3/4 bytes) depending on first byte
def noteOn():
	print 'note on\n'
	# TODO: output midi note-ons to MIDI-YOKE (output 10)
	note = ser.read(1)
	print 'note: ' + note
	#TODO: map all values to corresponding ints, ie, 0x69 -> 69
	#options: a regex to strip out prefix '\x' ; another dict
	note = strip[note]
	print 'stripped note: ' + str(note)
	
	velocity = ser.read(1)
	print 'velocity: ' + velocity
	#TODO: map all values to corresponding ints, ie, 0x69 -> 69
	# should not be any ELSE case; avoiding performance overhead by not using an IF
	velocity = strip[velocity]
	print 'stripped velocity: ' + str(velocity)
	noteOut(OUTPUT, note, velocity)

def ctrlOn():
	print 'ctrl on\n'
	# TODO: output controller messages to MIDI-YOKE (output 10)
	number = ser.read(1)
	print 'number: ' + number
	#TODO: map all values to corresponding ints, ie, 0x69 -> 69
	number = strip[number]
	print 'stripped number: ' + str(number)
	value = ser.read(1)
	print 'value: ' + value
	#TODO: map all values to corresponding ints, ie, 0x69 -> 69
	value = strip[value]
	print 'stripped value: ' + str(value)
	ctrlOut(OUTPUT, number, value)

#case-switch statement, determines whether note-on or ctrl-on byte has been sent, etc
whatIs = {'\x90':noteOn, 
		  '\xB0':ctrlOn,
		  
}

#another dict, to change \x69 values to 69 (strip the \x)
strip = {'\x00':0,
		 '\x01':1,
		 '\x02':2,
		 '\x03':3,
		 '\x04':4,
		 '\x05':5,
		 '\x06':6,
		 '\x07':7,
		 '\x08':8,
		 '\x09':9,
		 '\x10':10,
		 '\x11':11,
		 '\x12':12,
		 '\x13':13,
		 '\x14':14,
		 '\x15':15,
		 '\x16':16,
		 '\x17':17,
		 '\x18':18,
		 '\x19':19,
		 '\x20':20,
		 '\x21':21,
		 '\x22':22,
		 '\x23':23,
		 '\x24':24,
		 '\x25':25,
		 '\x26':26,
		 '\x27':27,
		 '\x28':28,
		 '\x29':29,
		 '\x30':30,
		 '\x31':31,
		 '\x32':32,
		 '\x33':33,
		 '\x34':34,
		 '\x35':35,
		 '\x36':36,
		 '\x37':37,
		 '\x38':38,
		 '\x39':39,
		 '\x40':40,
		 '\x41':41,
		 '\x42':42,
		 '\x43':43,
		 '\x44':44,
		 '\x45':45,
		 '\x46':46,
		 '\x47':47,
		 '\x48':48,
		 '\x49':49,
		 '\x50':50,
		 '\x51':51,
		 '\x52':52,
		 '\x53':53,
		 '\x54':54,
		 '\x55':55,
		 '\x56':56,
		 '\x57':57,
		 '\x58':58,
		 '\x59':59,
		 '\x60':60,
		 '\x61':61,
		 '\x62':62,
		 '\x63':63,
		 '\x64':64,
		 '\x65':65,
		 '\x66':66,
		 '\x67':67,
		 '\x68':68,
		 '\x69':69,
		 '\x70':70,
		 '\x71':71,
		 '\x72':72,
		 '\x73':73,
		 '\x74':74,
		 '\x75':75,
		 '\x76':76,
		 '\x77':77,
		 '\x78':78,
		 '\x79':79,
		 '\x80':80,
		 '\x81':81,
		 '\x82':82,
		 '\x83':83,
		 '\x84':84,
		 '\x85':85,
		 '\x86':86,
		 '\x87':87,
		 '\x88':88,
		 '\x89':89,
		 '\x90':90,
		 '\x91':91,
		 '\x92':92,
		 '\x93':93,
		 '\x94':94,
		 '\x95':95,
		 '\x96':96,
		 '\x97':97,
		 '\x98':98,
		 '\x99':99,
		 '\x100':100,
		 '\x101':101,
		 '\x102':102,
		 '\x103':103,
		 '\x104':104,
		 '\x105':105,
		 '\x106':106,
		 '\x107':107,
		 '\x108':108,
		 '\x109':109,
		 '\x110':110,
		 '\x111':111,
		 '\x112':112,
		 '\x113':113,
		 '\x114':114,
		 '\x115':115,
		 '\x116':116,
		 '\x117':117,
		 '\x118':118,
		 '\x119':119,
		 '\x120':120,
		 '\x121':121,
		 '\x122':122,
		 '\x123':123,
		 '\x124':124,
		 '\x125':125,
		 '\x126':126,
		 '\x127':127,
}

# call dictionary, do something with serial input depending on what it is
if x in whatIs:
	whatIs[x]()
#else:
	#print 'x not in whatIs, moving on...'
	
ser.close()				  # close serial port