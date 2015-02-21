/* Karen Wickert
   Single FSR Testing Program
   Reads the value of the FSR in analog input specified;
   Prints to console at given baud
   (Prints both raw value and processed value, dropped
   down to the 0 - 127 range from 0 - 1023 raw
   
   Offset value while no load = about 20
   */

// Define analog input used by FSR
int anIn = 0;
// initialize sensor value
int val = 0;
float val2 = 0;
float val3 = 0;
int val4 = 0;
float remainder = 0;

void setup()
{
  Serial.begin(9600);
}

void loop()
{
  val = analogRead(anIn);
  Serial.print(val);
  // using 0 as a spacer value
  Serial.print(0);
  val2 = (float)val / 1023;
  val3 = val2*127;
  val4 = (int)val3;
  // rounding function implemented
  remainder = val3 - val4;
  if(remainder >= 0.5){
    val4+=1;
  }
  Serial.print(val4);
  Serial.print('\n');
}

