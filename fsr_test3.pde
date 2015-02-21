/* Karen Wickert
   FSR Testing Program
   
   Currently uses analog inputs 0 - 7
   
   Make sure you're using a voltage divider on your FSRs so they
   have a consistent ground state!
   */
   
// define max and min analog inputs of the FSRs
int minAnIn = 0;
int maxAnIn = 7;

// define analog inputs used by FSRs
int anPin[8]; //initialized to max number of FSRs
// controller numbers
char ctrl[8]; //initialized to max number of FSRs
// state of analog input pin
int value[8]; //initialized to max number of FSRs
// current state of analog input pin
int curValue[8]; //initialized to max number of FSRs

// define threshold value of FSR noise
int noiseFloor = 0;

// initialize temp values for rounding
float tval = 0;
float tval2 = 0;
int tval3 = 0;
float remainder = 0;
int intCurVal = 0;


// assigns values to all analog inputs used for FSRs
void initArrays()
{
  for(int i = maxAnIn - minAnIn; i >= 0; i--)
  {
    // assigns each anPin to its associated number
    anPin[i] = i;
    // assigns each anPin to one of the controller numbers 70-77
    // (These are Undefined on the MIDI spec)
    ctrl[i] = i+69;
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
/*
  Serial.print(cmd, BYTE);
  Serial.print(data1, BYTE);
  Serial.print(data2, BYTE);
*/

}

void setup()
{
  initArrays();
  
 // MIDI baud rate:
 //Serial.begin(31250);
 // 9600 for console testing:
 Serial.begin(9600);
}

void loop()
{
  // go through value checks for each anPin
  
  for(int i = maxAnIn - minAnIn; i >= 0; i--)
  {
    curValue[i] = analogRead(anPin[i]);
    if(curValue[i] > noiseFloor)
    {
      //Serial.print(curValue[i]);
      // Make sure these are off when testing MIDI
      // (Will interfere with detection of MIDI bytes)
      //Serial.print(curValue[i]);
      //Serial.print('\n');
      
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
      //Serial.print(curValue[i]);
      //Serial.print(0); 
      
      Serial.print(intCurVal);
      Serial.print('\n');

      ctrlOn(0xB0, ctrl[i], intCurVal);
//      ctrlOn(0xB0, ctrl[i], 100);
    }
    //value[i] = curValue[i];  // update stored value of that anPin after the value check
  }
}
