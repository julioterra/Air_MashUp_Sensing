//#include <MIDI.h>

        #define READINGS_ARRAY_SIZE          8
        #define AVERAGE_READING_BUFFER_SIZE  6
        #define PRE_READING_BUFFER_SIZE      6

        #define SENSOR_MIN                   125
        #define SENSOR_MAX                   520
        #define TOP_VOLUME                   127

        #define gestOnOff_SequenceTime       300
        #define gestOnOff_FullDelta          180
        #define gestOnOff_GradientDelta      120
        #define gestOnOff_PauseInterval      450
        
        #define gestUpDown_Bandwidth         30
        #define gestUpDown_IgnoreRange       60
        
        #define UP                           1
        #define DOWN                        -1
        #define STOPPED                      0
        #define GEST_ON                      1
        #define GEST_OFF                    -1
        
class mixerChannel {
    public:
        // data capture and processing variables
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
        float masterVolume;

        // hand sensing variables
        boolean handActive;
        boolean handStatusChange;
        int handIntention;
        int handIntentionPrevious;

        // On/Off Gesture
        unsigned long gestOnOff_LastTime;
        boolean gestOn;
        boolean gestOff;
        
        // Up/Down Gesture
        int gestUpDown_Center;
        int gestUpDown_Shift;

        mixerChannel(int, String);
        void addTimedReading(unsigned long); 
        void updateVolumeMIDI();
        void controlLaser(int, boolean);
        void printTimestamp();
        void printMIDIVolume();
      
    private: 
        void volumeUpDownMIDI();
        boolean volumeOnOffMIDI();
        int gestOnOff();
        int gestUpDown();
        void addNewReading();
        void addNewTime(unsigned long);
        boolean recursiveCheck(int, int**, int**, int, int, int);
  
};


boolean connectionStarted = false;
 mixerChannel channel1 = mixerChannel(1, "ch1");
 mixerChannel channel2 = mixerChannel(2, "ch2");


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
        channel1.addTimedReading(currentTime);
        channel2.addTimedReading(currentTime);
        channel1.updateVolumeMIDI();   
        channel2.updateVolumeMIDI();   
        sendSerialData();
    }
}


void print2serial(String _name, long _value) {
  Serial.print(_name);
  Serial.print(": ");
  Serial.print(_value, DEC);  
  Serial.print(", ");
}


void sendSerialData() {
  Serial.print(channel1.timeStamps[0]);
  Serial.print(" ");  
  channel1.printMIDIVolume();
//  channel2.printMIDIVolume();
  Serial.print(" raw readings ");
  Serial.print(channel1.rawReadings[0]);
  Serial.println();

}




