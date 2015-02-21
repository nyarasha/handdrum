/* Karen Wickert
   Piezo test program
   3/27/11
*/

// define analog in pin number
int anPin = 8;
int val = 0;
int lastVal = 0;
int diff = 0;


void setup()
{
 // MIDI baud rate:
 //Serial.begin(31250);
 
 // 9600 for console testing:
 Serial.begin(9600);
}

void loop()
{
  lastVal = val;
  Serial.print(lastVal);
  Serial.print(0);
  Serial.print(0);
  val = analogRead(anPin);
  Serial.print(val);
  Serial.print(0);
  Serial.print(0);
  diff = val - lastVal;
  Serial.print(diff);
  Serial.print(0);
  if(abs(diff) >=2)
  {
    Serial.print(10101010);
    
  }
  Serial.print('\n');
}

