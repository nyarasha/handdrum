/*
 * Arduino Drum Controller MIDI Out
 *
 * Sends noteOns / noteOffs for conductive thread x's of position sensor
 * on djembe controller, reads FSRs and sends controller data 70-77
 *
 * Latest Revision 3/27/2011
 * Karen Wickert
 */

// define max and min digital inputs of the array of x's on the arduino
int minDigIn = 5;
int maxDigIn = 53;
// define max and min analog inputs of the FSRs
int minAnIn = 0;
int maxAnIn = 7;
// define analog input of the piezo
int piezoIn = 8;

// define digital inputs used by conductive x's
int inPin[54]; //initialized to max number of possible digital input pins
// MIDI note numbers
char note[54]; //initialized to max number of digital inputs
// state of digital input pin
int state[54]; //initialized to max number of digital inputs
// current state of digital input pin
int curState[54]; //initialized to max number of digital inputs

// define analog inputs used by FSRs
int anPin[8]; //initialized to max number of FSRs
// controller numbers
char ctrl[8]; //initialized to max number of FSRs
// state of analog input pin
int value[8]; //initialized to max number of FSRs
// current state of analog input pin
int curValue[8]; //initialized to max number of FSRs

//define threshold value of FSR noise
int noiseFloor = 0;

// initialize piezo value
piezoVal = 0;

// TODO WITH PIEZO:
// (1) if piezo triggered, AND NOT FSR(s) triggered --> side of drum hit event caused
// use this data to tell what kind of djembe hit has been attempted;
// if side-hit first, then FSR(s) hit, then SLAP
// if side-hit basically coincident with FSR / surface hit,
//   IF area = relatively small (only fingers), then TONE
//   ELSE IF area = relatively large (whole hand / palm), then BASS
// Acts as a gating event for the rest of the events ; filters out noise
// Controls the range of noteout value/number sent out

// TODO WITH X's:
// Area mapping -> use to distinguish between hit types (tap / slap / bass / tone / side only / etc)
// Control the range of noteout value/number sent out

// TODO WITH FSRs:
// Velocity mapping -> control the velocity out of the final output note(s) triggered

void initArrays()
{
// assigns values to all currently-used digital inputs for x's
  for(int i = maxDigIn; i > (minDigIn-1); i--)
  {
    // assigns each inPin to its associated number
    inPin[i] = i;
    // assigns each note
    // note: a value of 60 is Middle C in the MIDI spec
    note[i] = i+50;
    // initialize state and current state of each digital input pin
    state[i] = LOW;
    curState[i] = LOW;
  }
  
// assigns values to all analog inputs used for FSRs
  for(int i = maxAnIn - minAnIn; i >= 0; i--)
  {
    // assigns each anPin to its associated number
    anPin[i] = i;
    // assigns each anPin to one of the controller numbers 70-77
    // These controllers are UNDEFINED in the MIDI spec 
    ctrl[i] = i+69;
    // initialize state and current value of each analog input pin;
    // range = (0-1023) for each of the FSRs
    value[i] = 0;
    curValue[i] = 0;
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

// function to send a MIDI controller value
// via serial / MIDI connection
void ctrlOn(char cmd, char data1, char data2)
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

// initialize temp values for rounding
float tval = 0;
float tval2 = 0;
int tval3 = 0;
float remainder = 0;
int intCurVal = 0;

void loop()
{
  // checks piezo value
  piezoVal = analogRead(piezoIn);
  
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
  
  // go through value checks for each anPin
  for(int i = maxAnIn - minAnIn; i >= 0; i--)
  {
    curValue[i] = analogRead(anPin[i]);
    if(curValue[i] > noiseFloor)
    {  
      /* send MIDI controller data on channel 1 (0xB0), 
         controller number (1-8), controller value (0-127)
         curValue is divided to change the range of the FSR
         from 0-1023 to 0-127 to be compatible with the 0-127
         range of MIDI controllers; rounding ensures that the
         value is assigned properly, ie max value (at 1023) is
         127 and no greater.
      */
      tval = (float)curValue[i] / 1023;
      tval2 = tval*127;
      tval3 = (int)tval2;
      remainder = tval2 - tval3;
      if(remainder >= 0.5){
       tval3+=1;
      }
      intCurVal = tval3;
      
      ctrlOn(0xB0, ctrl[i], intCurVal);
    }
    value[i] = curValue[i];  // update stored value of that anPin after the value check 
  }
}
