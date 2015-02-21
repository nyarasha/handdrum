/* Karen Wickert
   FSR Testing Program
   */
   
// define max and min analog inputs of the FSRs
int maxAnIn = 7;
int minAnIn = 0;

// define analog inputs used by FSRs
int anPin[8]; //initialized to max number of FSRs
// controller numbers
char ctrl[8]; //initialized to max number of FSRs
// state of analog input pin
int value[8]; //initialized to max number of FSRs
// current state of analog input pin
int curValue[8]; //initialized to max number of FSRs

//define threshold value of FSR noise
int noiseFloor = 38;

// assigns values to all analog inputs used for FSRs
void initArrays()
{
  for(int i = maxAnIn; i >= minAnIn; i--)
  {
    // assigns each anPin to its associated number
    anPin[i] = i;
    // assigns each anPin to one of the controller numbers 1-8
    ctrl[i] = i+1;
    // initialize state and current value of each analog input pin;
    // range = (0-1023) for each of the FSRs
    value[i] = 0;
    curValue[i] = 0;
  }
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
 Serial.begin(31250);
 //Serial.begin(9600);
}

void loop()
{
  // go through value checks for each anPin
  for(int i = maxAnIn; i >= minAnIn; i--)
  {
    curValue[i] = analogRead(anPin[i]);
//    if(curValue[i] > noiseFloor)
//    {
      //Serial.print(curValue[i]);
      //Serial.print('\n');
      
      // send MIDI controller data on channel 1 (0xB0), controller number (1-8),
      // controller value (0-127)
      // curValue is divided to change the range of the FSR from 0-1023 to 0-127
      // to be compatible with the 0-127 range of MIDI controllers; floor function
      // ensures that the max value (at 1023) is 127 and no greater.
//      ctrlOn(0xB0, ctrl[i], (int)((curValue[i]/1023)*127));
      ctrlOn(0xB0, ctrl[i], 100);
//    }
    value[i] = curValue[i];  // update stored value of that anPin after the value check
  }
}
