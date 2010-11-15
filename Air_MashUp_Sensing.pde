

class TapTempo {    
    private:  
      #define timer_array_length       4
      #define bpm_max                  240
      #define bpm_min                  40
      #define bpm_led_on_time          70
      #define debounce_interval        120
      
      int blinkPin;                                        // holds pin assignment for bpm pin

      boolean tapActive;                                   // flag that identifies whether bpm is being set (new data is arriving)
      boolean newTap;                                      // flag that identfies when specific new taps are received
      unsigned long debounceTime;                          // holds the time when data is received for debouncing purposes

      // variables for calculating the bpm
      unsigned long tapIntervals[timer_array_length];      // array of most recent tap counts 
      unsigned long lastTapTime;                           // time when the last tap or gesture happened 
      long avgTapInterval;                                 // average interval between beats (used to calculate bpm)
      int tapState;                                        // current state of the tap button or gesture
      int lastTapState;                                    // last tap button or gesture state 

      // variable for controling bpm light
      boolean lightOn;                                  // flag regarding current state of the bpm light
      unsigned long lightOnTime;                        // holds the next time when the light is scheduled to turn on
      unsigned long previousLightOnTime;                // holds the last time that the light came on
      
      void readData(int);                                  // function that processes the input data to make sure it is debounced  

    public:
      float bpm;                                           // holds current beats per minute

      TapTempo();
      void setBpmPins(int);
      void catchTap(int);           
      void setTempo();
      void bpmBlink();
  
};


        
class MixerElement {
    private: 
        #define READINGS_ARRAY_SIZE          10
        #define AVERAGE_READING_BUFFER_SIZE  6
        #define PRE_READING_BUFFER_SIZE      6

        #define SENSOR_MIN                   125
        #define SENSOR_MAX                   520
        #define TOP_VOLUME                   127

        #define gestOnOff_SequenceTime       300
        #define gestOnOff_FullDelta          220
        #define gestOnOff_GradientDelta      120
        #define gestOnOff_PauseInterval      450
        
        #define UP                           0
        #define DOWN                         1
        #define STOPPED                     -1
        #define GEST_ON                      1
        #define GEST_OFF                     0
        
        #define timer_array_length           4
        #define bpm_max                      240
        #define bpm_min                      40
        #define bpm_led_on_time              70

        int mainPin;
        int laserPin;

        int sensorRange;
        float masterVolume;

        // hand sensing variables
        boolean handActive;
        boolean handStatusChange;
        int handIntentionPrevious;

        // On/Off Gesture
        unsigned long gestOnOff_LastTime;
        boolean gestOn;
        boolean gestOff;
        
        // GEST_UP/Down Gesture
        int gestUpDown_Center;
        int gestUpDown_Shift;
        int gestUpDown_Bandwidth;
        int gestUpDown_IgnoreRange;

        void volumeUpDownMIDI();
        boolean volumeOnOffMIDI();
        int gestOnOff();
        int gestUpDown();
        void addNewTime(unsigned long);
        boolean recursiveCheck(int, int**, int**, int, int, int);

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

        int handIntention;

        // bpm calculation object instance
        TapTempo tapTempo;

        void captureTempo();
        void displayTempo();
        void setTempo();

        MixerElement(int, int);
        MixerElement(int, int, int);
        void addTimedReading(unsigned long); 
        void addNewReading();
        void updateVolumeMIDI();
        void controlLaser(boolean);
        void printTimestamp();
        void printMIDIVolume();
        void printBPM();
        
};


 boolean connectionStarted = false;
 MixerElement channel1 = MixerElement(3, 1);
 MixerElement channel2 = MixerElement(1, 3, 2);


void setup() {  
  Serial.begin(9600); 
}



void loop() {
    if (Serial.available()) {
        Serial.read();
        connectionStarted = true; 
    }
    
    unsigned long currentTime = millis();
    if (connectionStarted) {
        channel2.addTimedReading(currentTime);
        channel2.captureTempo();
        channel1.addTimedReading(currentTime);
        channel1.updateVolumeMIDI();   
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
  channel2.printBPM();
//  Serial.print(" hand intention ");
//  Serial.print(channel2.handIntention);
//  Serial.print(" raw ");
//  Serial.print(channel2.rawReadings[0]);
  Serial.println();

}




