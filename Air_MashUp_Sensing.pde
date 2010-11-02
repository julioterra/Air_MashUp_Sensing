
int proxPin = 1;
int currentReading = 0;


#define READINGS_ARRAY_SIZE 40
#define AVERAGE_READING_BUFFER_SIZE 10
unsigned long timeStamps[READINGS_ARRAY_SIZE];
int rawReadings[READINGS_ARRAY_SIZE];
int avgReadings[READINGS_ARRAY_SIZE];
int avgBuffer[AVERAGE_READING_BUFFER_SIZE];

// Sudden Volume On/Off
#define gestOnOff_SequenceTime      500
#define gestOnOff_FullDelta         200
#define gestOnOff_GradientDelta     140
#define gestOnOff_PauseInterval     300
unsigned long gestOnOff_LastTime = millis();
boolean gestOn = false;
boolean gestOff = false;

// Smooth Volume Up/Down
#define gestVolUpDown_Bandwidth     20
#define gestVolUpDown_IgnoreRange   120
int gestVolUpDown_Center = 0;
int gestVolUpDown_Shift = 0;

// SMOOTH VOLUME LOGIC
// the center variable holds the current center of the volume range
// the bandwidth determines how far up or down the readings need to go in order to move the volume up or down
// the ignore range helps reduce noise by ignoring any large sudden jumps in the sensor readings



void setup() {
   Serial.begin(9600); 
   for (int i = 0; i < READINGS_ARRAY_SIZE; i++) rawReadings[i] = 0;
}


void loop() {
    currentReading = analogRead(proxPin);
    
    addNewTime(millis());
    addNewReading(currentReading);

    gestOnOff();
    gestVolUpDown();
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
  print2serial("adjusted ", rawReadings[0]);
  print2serial("avg readings ", avgReadings[0]);  
  print2serial("center ", gestVolUpDown_Center);
  print2serial("shift ", gestVolUpDown_Shift);
  print2serial("start ", gestOn);
  print2serial("stop ", gestOff);


  Serial.println();
}





