/*
 * Arduino Drum Controller MIDI Out
 *
 * Sends noteOns / noteOffs for conductive thread x's of position sensor
 * on djembe controller, reads FSRs and sends controller data 70-77, 
 * reads piezo value
 *
 * algorithm for conversion of sensor data into BASS / TONE / SLAP sounds
 *
 * Latest Revision 4/9/2011
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
int isOn[54]; // bool arr of whether a note 'x' is currently pressed

// define analog inputs used by FSRs
int anPin[8]; //initialized to max number of FSRs
// controller numbers
char ctrl[8]; //initialized to max number of FSRs
// state of analog input pin
int value[8]; //initialized to max number of FSRs
// current state of analog input pin
int curValue[8]; //initialized to max number of FSRs

//define threshold value of FSR noise
int noiseFloor = 1;

// initialize temp values for FSR rounding
float tval = 0;
float tval2 = 0;
int tval3 = 0;
float remainder = 0;
int intCurVal = 0;

// initialize piezo value and related
int triggered = false;

int piezoVal = 0;
int lastPiezoVal = 0;
int diff = 0;

// initializing algorithm-related variables
int onCount = 0;
int numFSRhit = 0;
int FSRsum = 0;
int avgFSRval = 0;
float tavg = 0;
int tavg2 = 0;
float avgRemainder = 0;
int r = 0;

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

void debug(String x)
{
  Serial.print(x);
  return;
}

void initArrays()
{
// assigns values to all currently-used digital inputs for x's
  for(int i = maxDigIn; i > (minDigIn-1); i--)
  {
    // assigns each inPin to its associated number
    inPin[i] = i;
    // assigns each note
    // note: a value of 60 is Middle C in the MIDI spec
    note[i] = i+35;
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
  //Serial.begin(31250); 
  Serial.begin(9600); // for testing
  // initial read to avoid triggering false note when program started
  piezoVal = analogRead(piezoIn);
}


void loop()
{
  // checks prev and current piezo val, calculates difference
  lastPiezoVal = piezoVal;
  piezoVal = analogRead(piezoIn);
  diff = piezoVal - lastPiezoVal;
  if(abs(diff) >= 120)
  {
    // piezo triggered
    triggered = true;
  }
  
  if(triggered == true)
  {
    // reset values
    triggered = false;
    numFSRhit = 0;
    FSRsum = 0;
    avgFSRval = 0;
    
    onCount = 0;
    
    debug(111111);
    debug('\n');
    
    // go through state checks for each inPin (for each x)
    for(int i = maxDigIn; i > (minDigIn-1); i--)
    {
      curState[i] = digitalRead(inPin[i]);
      // if currently conducting and previous state was not conducting, noteOn!
      if( curState[i] == HIGH && state[i] == LOW ) // x connected to foil, thus conducting +5v
        // noteOn on channel 1 (0x90), note value, middle velocity (0x45):
        //noteOn(0x90, note[i], 0x45);
        //delay(100);
        isOn[i] = true;
        onCount++;
      // if currently not conducting and previous state was conducting, noteOff!
      if( curState[i] == LOW && state[i] == HIGH ) // x separated from foil, thus insulated
        // noteOn on channel 1 (0x90), note value, silent velocity (0x00):
        //noteOn(0x90, note[i], 0x00);
        isOn[i] = false;
      state[i] = curState[i];  // update stored state of that inPin after the state check
    }
    
    // go through value checks for each anPin (FSR)
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
           value is assi
           gned properly, ie max value (at 1023) is
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
        //ctrlOn(0xB0, ctrl[i], intCurVal);
        FSRsum += intCurVal;
        numFSRhit++;
      }
      
      debug('\n');
      debug(numFSRhit);
      debug('\n');
      
      value[i] = curValue[i];  // update stored value of that anPin after the value check
      // rounding function, completes operation:
      avgFSRval = FSRsum/numFSRhit;
      tavg = (float)avgFSRval / numFSRhit;
      tavg2 = (int)tavg;
      avgRemainder = tavg - tavg2;
      if(avgRemainder >= 0.5){
       tavg2+=1;
      }
      avgFSRval = tavg2;
      
    }
    
    debug(121212);
    debug('\n');
    
    // SLAP
    if((onCount >= 0) && (onCount <= 4))
    {
      
      debug(4444444);
      debug('\n');
      
      // trigger a PP (pianissimo) sample
      if((avgFSRval >= 1) && (avgFSRval < 43))
      {
        r = random(0,5);
        switch(r)
        {
        case 0:
          noteOn(0x90, 0x42, avgFSRval);
          break;
        case 1:
          noteOn(0x90, 0x43, avgFSRval);
          break;
        case 2:
          noteOn(0x90, 0x44, avgFSRval);
          break;
        case 3:
          noteOn(0x90, 0x45, avgFSRval);
          break;
        case 4:
          noteOn(0x90, 0x46, avgFSRval);
          break;
        }
      }
      // trigger a MF (mezzoforte) sample
      else if((avgFSRval >= 43) && (avgFSRval < 85))
      {
        r = random(0,5);
        switch(r)
        {
        case 0:
          noteOn(0x90, 0x47, avgFSRval);
          break;
        case 1:
          noteOn(0x90, 0x48, avgFSRval);
          break;
        case 2:
          noteOn(0x90, 0x49, avgFSRval);
          break;
        case 3:
          noteOn(0x90, 0x4A, avgFSRval);
          break;
        case 4:
          noteOn(0x90, 0x4B, avgFSRval);
          break;
        }
      }
      // trigger a FF (fortissimo) sample
      else if((avgFSRval >= 85) && (avgFSRval <= 127))
      {
        r = random(0,5);
        switch(r)
        {
        case 0:
          noteOn(0x90, 0x4C, avgFSRval);
          break;
        case 1:
          noteOn(0x90, 0x4D, avgFSRval);
          break;
        case 2:
          noteOn(0x90, 0x4E, avgFSRval);
          break;
        case 3:
          noteOn(0x90, 0x4F, avgFSRval);
          break;
        case 4:
          noteOn(0x90, 0x50, avgFSRval);
          break;
        }
      }
    }
    
    // BASS
    else if(onCount > 10)
    {
      
      debug(222222);
      debug('\n');
      
      // trigger a PP (pianissimo) sample
      if((avgFSRval >= 1) && (avgFSRval < 43))
      {
        
        r = random(0,5);
        debug('r: ');
        debug(r);
        debug('\n');
        
        switch(r)
        {
        case 0:
          debug(220000);
          noteOn(0x90, 0x24, avgFSRval);
          break;
        case 1:
          debug(220001);
          noteOn(0x90, 0x25, avgFSRval);
          break;
        case 2:
          debug(220002);
          noteOn(0x90, 0x26, avgFSRval);
          break;
        case 3:
          debug(220003);
          noteOn(0x90, 0x27, avgFSRval);
          break;
        case 4:
          debug(220004);
          noteOn(0x90, 0x28, avgFSRval);
          break;
        }
      }
      // trigger a MF (mezzoforte) sample
      else if((avgFSRval >= 43) && (avgFSRval < 85))
      {
        r = random(0,5);
        debug('r: ');
        debug(r);
        debug('\n');
        switch(r)
        {
        case 0:
          debug(222000);
          noteOn(0x90, 0x29, avgFSRval);
          break;
        case 1:
          debug(222001);
          noteOn(0x90, 0x2A, avgFSRval);
          break;
        case 2:
          debug(222002);
          noteOn(0x90, 0x2B, avgFSRval);
          break;
        case 3:
          debug(222003);
          noteOn(0x90, 0x2C, avgFSRval);
          break;
        case 4:
          debug(222004);
          noteOn(0x90, 0x2D, avgFSRval);
          break;
        }
      }
      // trigger a FF (fortissimo) sample
      else if((avgFSRval >= 85) && (avgFSRval <= 127))
      {
        r = random(0,5);
        debug('r: ');
        debug(r);
        debug('\n');
        switch(r)
        {
        case 0:
          debug(222200);
          noteOn(0x90, 0x2E, avgFSRval);
          break;
        case 1:
          debug(222201);
          noteOn(0x90, 0x2F, avgFSRval);
          break;
        case 2:
          debug(222202);
          noteOn(0x90, 0x30, avgFSRval);
          break;
        case 3:
          debug(222203);
          noteOn(0x90, 0x31, avgFSRval);
          break;
        case 4:
          debug(222204);
          noteOn(0x90, 0x32, avgFSRval);
          break;
        }
      }
      
    }
    
    // TONE
    else if(avgFSRval == 0)
    {
      // wait until you get an FSR value in, then play tone sample
      debug(3333333);
      debug('\n');
      
      
    }
    
  }
}

