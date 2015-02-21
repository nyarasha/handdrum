void setup() {
  //  Set MIDI baud rate:
  Serial.begin(31250);
}

void loop() {
  //Ctrl on channel 1 (0xB0), controller number (0x10) = 16, controller value (0x40) = 64:
  ctrlOn(0xB0, 0x10, 0x40);
  delay(100);
}

//  plays a MIDI controller.  Doesn't check to see that
//  cmd is greater than 127, or that data values are  less than 127:
// bytes must be sent as binary values (hence the BYTE argument)
void ctrlOn(int cmd, int data1, int data2) {
  Serial.print(cmd, BYTE);
  Serial.print(data1, BYTE);
  Serial.print(data2, BYTE);
}

