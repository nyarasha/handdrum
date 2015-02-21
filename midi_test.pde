#include <MIDI.h>  //includes MIDI arduino library

// Variables: 
byte note = 60;  // The MIDI note value to be played (60 = middle C)
int inPin6 = 6;   // choose the input pin
int val6 = 0;     // variable for reading the pin status

void setup() {
  //  Set MIDI baud rate:
  //Serial.begin(31250);
  Serial.begin(38400); //closest time frame for debugging
}

void loop(){
 val6 = digitalRead(inPin6);  // read input value
 if (val6 == HIGH) {         // check if the input is HIGH
   Serial.print(1); // write "1"
   Serial.print("\n");
   //Note on channel 1 (0x90), some note value (note), middle velocity (0x45):
     noteOn(0x90, note, 0x45);
     delay(100);  // play for 100ms
     //Note on channel 1 (0x90), some note value (note), silent velocity (0x00):
     //Essentially, a note off is sent
     noteOn(0x90, note, 0x00);   
     delay(100); // wait for 100ms until next note can be triggered
 } else {
   Serial.print(0); // write "0"
   Serial.print("\n");
   
 }
}
