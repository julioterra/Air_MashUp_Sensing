//#include <MIDI.h>

        #define READINGS_ARRAY_SIZE          12
        #define AVERAGE_READING_BUFFER_SIZE  6
        #define PRE_READING_BUFFER_SIZE      6

        #define SENSOR_MIN                   125
        #define SENSOR_MAX                   520
        #define TOP_VOLUME                   127

        #define gestOnOff_SequenceTime       300
        #define gestOnOff_FullDelta          160
        #define gestOnOff_GradientDelta      110
        #define gestOnOff_PauseInterval      450
        
        #define gestVolUpDown_Bandwidth      30
        #define gestVolUpDown_IgnoreRange    120
        #define gestVolUpDown_GradientDelta  60
        


class mixerChannel {
    public:
        unsigned long timeStamps[READINGS_ARRAY_SIZE];
        int rawReadings[READINGS_ARRAY_SIZE];
        int avgReadings[READINGS_ARRAY_SIZE];
        int preBuffer[PRE_READING_BUFFER_SIZE];
        int transferBuffer[PRE_READING_BUFFER_SIZE];
        int avgBuffer[AVERAGE_READING_BUFFER_SIZE];
        int rawReading;
        int newReading;

        int sensorRange;
        int channelPin;
        boolean handActive;
        boolean handStatusChange;
        float masterVolume;

        // Sudden Volume On/Off
        unsigned long gestOnOff_LastTime;
        boolean gestOn;
        boolean gestOff;
        
        // Smooth Volume Up/Down
        int gestVolUpDown_Center;
        int gestVolUpDown_Shift;

        mixerChannel(int, String);
        boolean gestOnOff();
        void gestVolUpDown();
        void addNewTimedReading(unsigned long); 
        void changeVolume(float);
        void controlLaser(int, boolean);
      
    private: 
        void addNewReading();
        void addNewTime(unsigned long);
        boolean recursiveCheck(int, int**, int**, int, int, int);
  
};


// SMOOTH VOLUME LOGIC
// the center variable holds the current center of the volume range
// the bandwidth determines how far up or down the readings need to go in order to move the volume up or down
// the ignore range helps reduce noise by ignoring any large sudden jumps in the sensor readings

boolean connectionStarted = false;
 mixerChannel channel1 = mixerChannel(1, "ch1");
 mixerChannel channel2 = mixerChannel(2, "ch2");
// mixerChannel channel3 = mixerChannel(3, "ch2");
// mixerChannel channel4 = mixerChannel(4, "ch2");

void setup() {
  Serial.begin(9600); 
  channel1.controlLaser(3, true);
}


void loop() {
    if (Serial.available()) {
        Serial.read();
        connectionStarted = true; 
    }
    
    unsigned long currentTime = millis();
    if (connectionStarted) {
        channel1.addNewTimedReading(currentTime);
        channel2.addNewTimedReading(currentTime);
        channel1.gestVolUpDown();   
        channel2.gestVolUpDown();   
        debug_print();
//        debug_print2();
    }
}


void print2serial(String _name, long _value) {
  Serial.print(_name);
  Serial.print(": ");
  Serial.print(_value, DEC);  
  Serial.print(", ");
}


void debug_print() {
//  Serial.print(int(channel1.masterVolume), BYTE);

//  Serial.print(" ");
//  Serial.print("Sensor 1 ");  
  Serial.print(channel1.timeStamps[0]);
  Serial.print(" ");  
  Serial.print(int(channel1.masterVolume));
  Serial.print(" ");  
  Serial.print(int(channel2.masterVolume));
//  Serial.print(" ");  
//  Serial.print(int(channel1.rawReadings[0]));
//  Serial.print(int(channel1.masterVolume));
//  print2serial(" - adjusted ", channel1.rawReadings[0]);
//  print2serial(" - prebuffer ", channel1.preBuffer[PRE_READING_BUFFER_SIZE-1]);
//  print2serial(" - raw ", channel1.newReading);
  Serial.println();

//  Serial.print(": ");
//  Serial.print("Sensor 1 ");  
//  Serial.print("Sensor 2 ");  

//  Serial.print("Sensor 1 ");  
//  print2serial(" - avg readings ", channel1.avgReadings[0]); 
//  Serial.print("Sensor 2 ");  
//  print2serial(" - avg readings ", channel2.avgReadings[0]);  

//  print2serial("center ", channel1.gestVolUpDown_Center);
//  print2serial(" - shift ", channel1.gestVolUpDown_Shift);
//  print2serial("start ", channel1.gestOn);
//  print2serial("stop ", channel1.gestOff);
//  delay(25);
}




