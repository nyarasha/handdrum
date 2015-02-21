/* Karen Wickert
   Reason Sampler Test Program
   4/2/2011
*/

void setup() {
  //  Set MIDI baud rate:
  Serial.begin(31250);
}

void loop() {
  for(int i = 0x24; i <= 0x41; i++)
  { 
    //Note on channel 1 (0x90), number (0x30) = 16, velocity (0x40) = 64:
    noteOn(0x90, i, 0x40);
    delay(100);
    noteOn(0x90, i, 0x00);
    delay(300);
  }
}

//  plays a MIDI note.  Doesn't check to see that
//  cmd is greater than 127, or that data values are  less than 127:
// bytes must be sent as binary values (hence the BYTE argument)
void noteOn(int cmd, int data1, int data2) {
  Serial.print(cmd, BYTE);
  Serial.print(data1, BYTE);
  Serial.print(data2, BYTE);
}
