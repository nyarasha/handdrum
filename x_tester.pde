// test for conductive thread to digital in on arduino setup
// by Karen Wickert, 12/8/2010

int inPin = 6;   // choose the input pin
int val = 0;     // variable for reading the pin status

void setup() {
  pinMode(inPin, INPUT);    // declare pushbutton as input
  Serial.begin(9600);      // open the serial port at 9600 bps:    
}

void loop(){
  val = digitalRead(inPin);  // read input value
  if (val == HIGH) {         // check if the input is HIGH
    Serial.print(1); // write "1"
    Serial.print("\n");
  } else {
    Serial.print(0); // write "0"
    Serial.print("\n");
  }
}
