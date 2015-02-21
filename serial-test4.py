# Karen Wickert
# Serial to MIDI program
# 3/24/2011

import sys
import os
import serial # pySerial

import pygame.midi as pg

# assumed format of Arduino serial transfer:  Serial.print(BYTE) values, MIDI hex specification
# example: (0x90, 0x3F, 0x45) is a note-on value with a note value and velocity value after it 

# functions to print MIDI I/O info for the user to use in assigning a device_id number
# for the MIDI output
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


# define MIDI output helper functions, always assuming channel 0

def noteOut(OUTPUT, note, velocity):
	pg.init()
	
	if OUTPUT is None:
		port = pg.get_default_output_id()
	else:
		port = OUTPUT
		
	print ("using output_id: %s:" % port)
	
	# using channel 0
	midi_out = pg.Output(port, 0)
	
	midi_out.note_on(note, velocity, 0)
	# sending a note-off right after the note-on for now
	midi_out.note_off(note)
	
	pg.quit()
	
def ctrlOut(OUTPUT, number, value):
	pg.init()
	
	if OUTPUT is None:
		port = pg.get_default_output_id()
	else:
		port = OUTPUT
		
	print ("using output_id: %s:" % port)
	
	# using channel 0
	midi_out = pg.Output(port, 0)
	
	midi_out.write_short(0xb0, number, value)
	
	pg.quit()

# define helper dictionary

#dict to change \x(hex) values to decimal (strip the \x and convert)
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
		 '\x0A':10,
		 '\x0B':11,
		 '\x0C':12,
		 '\x0D':13,
		 '\x0E':14,
		 '\x0F':15,
		 '\x10':16,
		 '\x11':17,
		 '\x12':18,
		 '\x13':19,
		 '\x14':20,
		 '\x15':21,
		 '\x16':22,
		 '\x17':23,
		 '\x18':24,
		 '\x19':25,
		 '\x1A':26,
		 '\x1B':27,
		 '\x1C':28,
		 '\x1D':29,
		 '\x1E':30,
		 '\x1F':31,
		 '\x20':32,
		 '\x21':33,
		 '\x22':34,
		 '\x23':35,
		 '\x24':36,
		 '\x25':37,
		 '\x26':38,
		 '\x27':39,
		 '\x28':40,
		 '\x29':41,
		 '\x2A':42,
		 '\x2B':43,
		 '\x2C':44,
		 '\x2D':45,
		 '\x2E':46,
		 '\x2F':47,
		 '\x30':48,
		 '\x31':49,
		 '\x32':50,
		 '\x33':51,
		 '\x34':52,
		 '\x35':53,
		 '\x36':54,
		 '\x37':55,
		 '\x38':56,
		 '\x39':57,
		 '\x3A':58,
		 '\x3B':59,
		 '\x3C':60,
		 '\x3D':61,
		 '\x3E':62,
		 '\x3F':63,
		 '\x40':64,
		 '\x41':65,
		 '\x42':66,
		 '\x43':67,
		 '\x44':68,
		 '\x45':69,
		 '\x46':70,
		 '\x47':71,
		 '\x48':72,
		 '\x49':73,
		 '\x4A':74,
		 '\x4B':75,
		 '\x4C':76,
		 '\x4D':77,
		 '\x4E':78,
		 '\x4F':79,
		 '\x50':80,
		 '\x51':81,
		 '\x52':82,
		 '\x53':83,
		 '\x54':84,
		 '\x55':85,
		 '\x56':86,
		 '\x57':87,
		 '\x58':88,
		 '\x59':89,
		 '\x5A':90,
		 '\x5B':91,
		 '\x5C':92,
		 '\x5D':93,
		 '\x5E':94,
		 '\x5F':95,
		 '\x60':96,
		 '\x61':97,
		 '\x62':98,
		 '\x63':99,
		 '\x64':100,
		 '\x65':101,
		 '\x66':102,
		 '\x67':103,
		 '\x68':104,
		 '\x69':105,
		 '\x6A':106,
		 '\x6B':107,
		 '\x6C':108,
		 '\x6D':109,
		 '\x6E':110,
		 '\x6F':111,
		 '\x70':112,
		 '\x71':113,
		 '\x72':114,
		 '\x73':115,
		 '\x74':116,
		 '\x75':117,
		 '\x76':118,
		 '\x77':119,
		 '\x78':120,
		 '\x79':121,
		 '\x7A':122,
		 '\x7B':123,
		 '\x7C':124,
		 '\x7D':125,
		 '\x7E':126,
		 '\x7F':127,
}

# main MIDI output function
def output_main(device_id, comPort):
	# COM port number in use for drum data transfer
	# COM1 = 0, COM2 = 1, etc so subtract 1 from the user's input to get the COM port number
	if comPort == None:
		print 'Error: No COM Port specified. Using COM1.'
		comPort = 1
	PORT = comPort - 1
	# for debugging
	print '\nCOM port used: '
	print comPort
		
	BAUD = 31250 # set baud rate (MIDI = 31250)
	# specify which MIDI output to use (virtual or real - see listed MIDI outputs for help)
	OUTPUT = device_id

	# open serial port at specified BAUD and BYTESIZE
	ser = serial.Serial(PORT, BAUD, serial.EIGHTBITS)

	# define case functions (what to do in each case)
	# logic that parses MIDI into strings (of 2/3/4 bytes) depending on first byte
	def noteOn():
		print 'note on\n'
		# TODO: output midi note-ons to MIDI-YOKE (output 10)
		note = ser.read(1)
		print 'note: ' + note
		# map all hex byte values to corresponding decimal ints, ie, 0x69 -> 105
		note = strip[note]
		print 'stripped note: ' + str(note)
		
		velocity = ser.read(1)
		print 'velocity: ' + velocity
		# map all hex byte values to corresponding decimal ints, ie, 0x69 -> 105
		# should not be any ELSE case; avoiding performance overhead by not using an IF
		velocity = strip[velocity]
		print 'stripped velocity: ' + str(velocity)
		noteOut(OUTPUT, note, velocity)

	def ctrlOn():
		print 'ctrl on\n'
		# TODO: output controller messages to MIDI-YOKE (output 10)
		number = ser.read(1)
		print 'number: ' + number
		# map all hex byte values to corresponding decimal ints, ie, 0x69 -> 105
		number = strip[number]
		print 'stripped number: ' + str(number)
		value = ser.read(1)
		print 'value: ' + value
		# map all hex byte values to corresponding decimal ints, ie, 0x69 -> 105
		value = strip[value]
		print 'stripped value: ' + str(value)
		ctrlOut(OUTPUT, number, value)

	# define helper dictionary
	#case-switch statement, determines whether note-on or ctrl-on byte has been sent, etc
	whatIs = {'\x90':noteOn, 
			  '\xB0':ctrlOn,		  
	}

	cont = True
	
	while cont == True:
		# nonstandard (MIDI) baud rate may be blocked - use 38400 if so
		x = ser.read()			  # read one byte
		print(x)

		x = str(x) # need to convert type to compare
		#print 'string x: ' + x
		
		# call dictionary, do something with serial input depending on what it is
		if x in whatIs:
			whatIs[x]()
		#else:
			#print 'x not in whatIs, moving on...'
	
	ser.close()				  # close serial port


# helps user input the correct args to this program via the command line
def usage():
	print ("\nSeems like you could use some help:\n")
	print ("--output [device_id] [COM port number] : Output MIDI")
	print ("--list : list available MIDI I/O devices")
	print ("shortened commands work : -i ; -o ; -l")

if __name__ == '__main__':
	try:
		# get device id from 1st command line arg
		device_id = int( sys.argv[-2] )
	except:
		device_id = None
	# for debugging
	print "\ndevice_id: "
	print device_id
	
	try:
		# get COM port number from 2nd command line arg
		comPort = int( sys.argv[-1] )
	except:
		comPort = None
	# for debugging
	print "\ncomPort: "
	print comPort
	
	if "--output" in sys.argv or "-o" in sys.argv:
		output_main(device_id, comPort)
	elif "--list" in sys.argv or "-l" in sys.argv:	
		print_device_info()
	else:
		usage()