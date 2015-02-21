void setup() {
  //  Set MIDI baud rate:
  Serial.begin(31250);
}

void loop() {
  // play a range of notes from 0x1A = 26dec to 0x3F = 63dec
  // note - for loop doesn't work; counting up by hex probably not implemented
  for (int note = 0x1A ; note < 0x3F; note ++) {
    //Note on channel 1 (0x90), some note value (note), middle velocity (0x40) = 64decimal:
    noteOn(0x90, note, 0x40);
    delay(100);
    //Note on channel 1 (0x90), some note value (note), silent velocity (0x00):
    noteOn(0x90, note, 0x00);   
    delay(100);
  }
}

//  plays a MIDI note.  Doesn't check to see that
//  cmd is greater than 127, or that data values are  less than 127:
void noteOn(int cmd, int pitch, int velocity) {
  Serial.print(cmd, BYTE);
  Serial.print(pitch, BYTE);
  Serial.print(velocity, BYTE);
}
