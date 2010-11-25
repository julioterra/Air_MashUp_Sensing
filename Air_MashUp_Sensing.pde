const int  multiplexPin1 [] = {0, 1, 0, 1, 0, 1, 0, 1};
const int  multiplexPin2 [] = {0, 0, 1, 1, 0, 0, 1, 1};
const int  multiplexPin3 [] = {0, 0, 0, 0, 1, 1, 1, 1};

/**********************************
 * TEMPO TAP CLASS
 **********************************/
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
      boolean catchTap(int);           
      void catchGe(int);
      void setTempo();
      void bpmBlink(); 
};
    
    
/**********************************
 * MIXER ELEMENT CLASS
 **********************************/    
class MixerElement {
    private: 
        #define READINGS_ARRAY_SIZE          6
        #define AVERAGE_READING_BUFFER_SIZE  1
        #define PRE_READING_BUFFER_SIZE      3      

        #define SENSOR_MIN                   125
        #define SENSOR_MAX                   520
        #define TOP_VOLUME                   127
        #define sensor_ID                    0

        #define gestOnOff_SequenceTime       300
        #define gestOnOff_FullDelta          150
        #define gestOnOff_GradientDelta      100
        #define gestOnOff_PauseInterval      450
        
        #define UP                           0
        #define DOWN                         1
        #define STOPPED                     -1
        #define GEST_ON                      1
        #define GEST_OFF                     0
        
        #define timer_array_length           4
        #define timer_interval               30
        #define bpm_max                      240
        #define bpm_min                      40
        #define bpm_led_on_time              70

        int componentNumber;
        int mainPin;
        int laserPin;

        int sensorRange;
        float masterVolume;
        boolean newData;

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

        void captureTempoTap();
        void captureTempoGest();
        void displayTempo();
        void setTempo();

        MixerElement(int);
        MixerElement(int, int);
        MixerElement(int, int, int);
        void setProximityPin(int);
        void addTimedReading(); 
        void addNewReading();
        void updateVolumeMIDI();
        void controlLaser(boolean);
        void printTimestamp();
        void printMIDIVolume();
        void printBPM();
        
};


/**********************************
 * CONTROL PANEL CLASS
 **********************************/
class ControlPanel {
    public:
        #define num_digital_sensors      7
        #define num_analog_sensors       4
        #define num_digital_LEDs         5

        // sensor array index
        #define loopBegin                0
        #define loopEnd                  1
        #define loopStartStop            2
        #define monitor                  3
        #define crossA                   4
        #define crossB                   5
        #define volLock                  6
        //#define buttonSelect           7
        
        #define eqHigh                   0
        #define eqMid                    1
        #define eqLow                    2
        #define rotarySelect             3
        
        // digital LED array index
        #define monitorLED               0
        #define loopStartEndLED          1
        #define loopOnOffLED             3
        #define volLED                   4
        
        #define smoothAnalogPotReading   10

        // component number
        int componentNumber;
        
        MixerElement mixerElement;

        // digital input pin array
        int sensorDigitalPins[num_digital_sensors];
        int sensorDigitalID[num_digital_sensors];
        int sensorDigitalCurVals[num_digital_sensors];
        boolean sensorDigitalNewData[num_digital_sensors];
        
        // analog input pin array
        int sensorAnalogPins[num_analog_sensors];
        int sensorAnalogID[num_analog_sensors];
        int sensorAnalogCurVals[num_analog_sensors];
        boolean sensorAnalogNewData[num_analog_sensors];
        int sensorAnalogPrevVals[num_analog_sensors][smoothAnalogPotReading];
        
        // output pin array
        int LEDPins[num_digital_LEDs];
        int LEDLastState[num_digital_LEDs];
        boolean LEDpwm[num_digital_LEDs];
        
        ControlPanel(int _componentNumber);
        void setProximityPin (int);
        void setEqPins (int, int, int);
        void setLoopPins (int, int, int, int/*, int*/);
        void setVolPins (int, int, int, int,  int, int);
        void setSelectPins (int /*, int*/);
        void readData();
        void readDigitalPin(int);
        void readAnalogPin(int);
        void serialOutputDigital(int);
        void serialOutputAnalog(int);
        void outputSerialData ();
};










/************************************
 ***** SETUP AND LOOP FUNCTIONS *****
 ************************************/

ControlPanel controlPanel = ControlPanel(2);

 boolean connectionStarted = false;
// MixerElement channel1 = MixerElement(1, 1);
// MixerElement channel2 = MixerElement(2, 2);
// MixerElement channel3 = MixerElement(3, 4, 5);

void setup() {  
  Serial.begin(9600); 
    controlPanel.setProximityPin(5);  
    controlPanel.setEqPins(4, 3, 2);  
    controlPanel.setLoopPins(6, 8, 5, 10);
    controlPanel.setVolPins(4, 3, 9, 2, 11, 12);  
    controlPanel.setSelectPins(1);
}


void loop() {
    if (Serial.available()) {
         char newCommand = Serial.read();
         if (newCommand == 'S' || newCommand == 's') connectionStarted = true; 
         if (newCommand == 'X' || newCommand == 'x') connectionStarted = false;
     }     
     
    unsigned long currentTime = millis();
    if (connectionStarted) {
//        channel1.addTimedReading();
//        channel2.addTimedReading();
//        channel1.updateVolumeMIDI();   
//        channel2.updateVolumeMIDI();  
//        channel1.printMIDIVolume();
//        channel2.printMIDIVolume();
         controlPanel.readData();
         controlPanel.outputSerialData();
    }
}


