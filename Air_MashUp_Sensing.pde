//#include <MIDI.h>



class mixerChannel {
    public:
        #define READINGS_ARRAY_SIZE 100
        #define AVERAGE_READING_BUFFER_SIZE 15
        unsigned long timeStamps[READINGS_ARRAY_SIZE];
        int rawReadings[READINGS_ARRAY_SIZE];
        int avgReadings[READINGS_ARRAY_SIZE];
        int avgBuffer[AVERAGE_READING_BUFFER_SIZE];

        #define TOP_VOLUME      127
        int channelPin;
        int newReading;
        float masterVolume;

        // Sudden Volume On/Off
        #define gestOnOff_SequenceTime      300
        #define gestOnOff_FullDelta         180
        #define gestOnOff_GradientDelta     100
        #define gestOnOff_PauseInterval     450
        unsigned long gestOnOff_LastTime;
        boolean gestOn;
        boolean gestOff;
        
        // Smooth Volume Up/Down
        #define gestVolUpDown_Bandwidth     20
        #define gestVolUpDown_IgnoreRange   120
        int gestVolUpDown_Center;
        int gestVolUpDown_Shift;

        mixerChannel(int, String);
        boolean gestOnOff();
        void gestVolUpDown();
        void addNewTimedReading(unsigned long); 
        void changeVolume(float);
      
    private: 
        void addNewReading();
        void addNewTime(unsigned long);
        int readingsInSequenceTime(long);
  
};


// SMOOTH VOLUME LOGIC
// the center variable holds the current center of the volume range
// the bandwidth determines how far up or down the readings need to go in order to move the volume up or down
// the ignore range helps reduce noise by ignoring any large sudden jumps in the sensor readings


mixerChannel channel1 = mixerChannel(1, "ch1");

void setup() {
  Serial.begin(9600); 
}


void loop() {
    channel1.addNewTimedReading(millis());
    if (channel1.gestOnOff())
      channel1.gestVolUpDown();
    
    debug_print();
}


void print2serial(String _name, long _value) {
  Serial.print(_name);
  Serial.print(": ");
  Serial.print(_value, DEC);  
  Serial.print(", ");
}


void debug_print() {
  Serial.print(int(channel1.masterVolume));
//  Serial.print(int(channel1.masterVolume), BYTE);

  Serial.print(" millis ");
  Serial.print(channel1.timeStamps[0]);
  Serial.print(" - ");
//  Serial.print(": ");
//  print2serial("raw ", channel1.newReading);

  print2serial("adjusted ", channel1.rawReadings[0]);

//  print2serial("avg readings ", channel1.avgReadings[0]);  
//  print2serial("center ", channel1.gestVolUpDown_Center);
//  print2serial("shift ", channel1.gestVolUpDown_Shift);
//  print2serial("start ", channel1.gestOn);
//  print2serial("stop ", channel1.gestOff);

  Serial.println();
}





