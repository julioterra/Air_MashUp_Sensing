#define READINGS_ARRAY_SIZE 20

int proxPin = 1;

unsigned long timeStamps[READINGS_ARRAY_SIZE];
int proxVals[READINGS_ARRAY_SIZE];


unsigned long gestOnOffPreviousMillis = millis();
long gestTimeInterval = 500;
long gestOnOffDelta = 200;
long gestOnOffGrade = 120;
long gestOnOffPause = 300;
boolean gestOn = false;
boolean gestOff = false;


void setup() {
 Serial.begin(9600); 
 for (int i = 0; i < READINGS_ARRAY_SIZE; i++) proxVals[i] = 0;
}


void loop() {
  addNewTime(millis());
  addNewReading(analogRead(proxPin));
  checkGestStartStop();

  Serial.print(timeStamps[0]);
  Serial.print(": ");
  print2serial("adjusted ", proxVals[0]);
  print2serial("start ", gestOn);
  print2serial("stop ", gestOff);
  Serial.println();
//  delay(100);
}


void print2serial(String _name, long _value) {
  Serial.print(_name);
  Serial.print(": ");
  Serial.print(_value, DEC);  
  Serial.print(", ");
}

void addNewTime(unsigned long newVal) {
  for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { timeStamps[i] = timeStamps[i-1]; }
  timeStamps[0] = newVal;
}


void addNewReading(int newVal) {
  for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { proxVals[i] = proxVals[i-1]; }
  if (newVal > 120 && newVal < 520) {
      proxVals[0] = 400 - (newVal - 120);
  } else if (newVal < 120) { proxVals[0] = -1; }
}




