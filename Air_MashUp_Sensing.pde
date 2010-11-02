#define READINGS_ARRAY_SIZE 40

int proxPin = 1;
int currentReading = 0;

unsigned long timeStamps[READINGS_ARRAY_SIZE];
int proxVals[READINGS_ARRAY_SIZE];


long gestOnOff_SequenceTime = 500;
unsigned long gestOnOff_LastTime = millis();
long gestOnOff_FullDelta = 200;
long gestOnOff_GradientDelta = 120;
long gestOnOff_PauseInterval = 300;
boolean gestOn = false;
boolean gestOff = false;


void setup() {
   Serial.begin(9600); 
   for (int i = 0; i < READINGS_ARRAY_SIZE; i++) proxVals[i] = 0;
}


void loop() {
    currentReading = analogRead(proxPin);
    
    addNewTime(millis());
    addNewReading(currentReading);
    gestOnOff();
  
    debug_print();
}


void print2serial(String _name, long _value) {
  Serial.print(_name);
  Serial.print(": ");
  Serial.print(_value, DEC);  
  Serial.print(", ");
}

void debug_print() {
  Serial.print(timeStamps[0]);
  Serial.print(": ");
  print2serial("raw ", currentReading);
  print2serial("adjusted ", proxVals[0]);
  print2serial("start ", gestOn);
  print2serial("stop ", gestOff);
  Serial.println();
}





