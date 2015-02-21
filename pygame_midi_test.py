# Karen Wickert
# MIDI test program
# 3/6/2011
# 
# see usage() function for info on how to format command-line calls

import sys
import os

import pygame.midi as pg

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
		
#		print ("%2i: interface :%s:, name :%s:, opened :%s:  %s" %
#				(i, interf, name, opened, in_out))
		print ("%2i: %s:, opened: %s:  %s" %
				(i, name, opened, in_out))

# input handler - needs to be tested 
def input_main(device_id = None):
	pg.init()
	
	_print_device_info()
	
	if device_id is None:
		input_id = pg.get_default_input_id()
	else:
		input_id = device_id
	
	print ("using input_id: %s:" % input_id)
	i = pg.Input( input_id )
	
	going = True
	while going:
		events = event_get()
		for e in events:
			if e.type in [QUIT]:
				going = False
			if e.type in [KEYDOWN]:
				going = False
			if e.type in [pg.MIDIIN]:
				print(e)
		
		if i.poll():
			midi_events = i.read(10)
	
	del i
	pg.quit()

def output_main(device_id):
	pg.init()
	
	if device_id is None:
		port = pg.get_default_output_id()
	else:
		port = device_id
		
	print ("using output_id: %s:" % port)
	
	midi_out = pg.Output(port, 0)
	
#	going = True
#	while going:
	note = 63
	velocity = 41
	midi_out.note_on(note, velocity, 0)
	midi_out.note_off(note)
	
	pg.quit()
	
# helps user input the correct args
def usage():
	print ("\nSeems like you could use some help:\n")
	print ("--input [device_id] : Input MIDI")
	print ("--output [device_id] : Output MIDI")
	print ("--list : list available midi devices")
	print ("shortened commands work : -i ; -o ; -l")
	
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
