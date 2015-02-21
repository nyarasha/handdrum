/*
 * Arduino Drum Controller MIDI Out
 *
 * Sends noteOns / noteOffs for conductive thread x's of position sensor
 * on djembe controller
 *
 * Latest Revision 12/12/2010
 * Karen Wickert
 */

// define max and min digital inputs of the array of x's on the arduino
int maxDigIn = 53;
int minDigIn = 5;

// define digital inputs used by conductive x's
int inPin[54]; //initialized to max number of possible digital input pins
// general midi notes
char note[54]; //initialized to max number of digital inputs
// state of digital input pin
int state[54]; //initialized to max number of digital inputs
// current state of digital input pin
int curState[54]; //initialized to max number of digital inputs

// assigns values to all currently-used digital inputs for x's
void initArrays() {
  for(int i = maxDigIn; i > (minDigIn-1); i--)
  {
    // assigns each inPin to its associated number
    inPin[i] = i;
    // assigns each note to its associated number, since the notes' values don't matter
    // for sample playback (only for synthesis), and then they can be reassigned in pd
    // note: a value of 60 is Middle C in the MIDI spec
    note[i] = 1;
    // initialize state and current state of each digital input pin
    state[i] = LOW;
    curState[i] = LOW;
  }
}
// function to send a MIDI noteOn (or effectively noteOff, if velocity==0)
// via serial / MIDI connection
void noteOn(char cmd, char data1, char data2)
{
  Serial.print(cmd, BYTE);
  Serial.print(data1, BYTE);
  Serial.print(data2, BYTE);
}

void setup()
{
  // assigns values to all currently-used digital inputs for x's
  for(int i = maxDigIn; i > (minDigIn-1); i--)
  {
    // set the states of the I/O pins - all are used as inputs, here
    pinMode(inPin[i], INPUT);
  }
  initArrays();
  // set MIDI baud rate as per MIDI spec
  Serial.begin(31250); 

}

void loop()
{

  // go through state checks for each inPin
  for(int i = maxDigIn; i > (minDigIn-1); i--)
  {
    curState[i] = digitalRead(inPin[i]);
    // if currently conducting and previous state was not conducting, noteOn!
    if( curState[i] == HIGH && state[i] == LOW ) // x connected to foil, thus conducting +5v
      //noteOn on channel 1 (0x90), note value, middle velocity (0x45):
      noteOn(0x90, note[i], 0x45);
    // if currently not conducting and previous state was conducting, noteOff!
    if( curState[i] == LOW && state[i] == HIGH ) // x separated from foil, thus insulated
      //noteOn on channel 1 (0x90), note value, silent velocity (0x00):
      noteOn(0x90, note[i], 0x00);
    state[i] = curState[i];  // update stored state of that inPin after the state check
  }

}
