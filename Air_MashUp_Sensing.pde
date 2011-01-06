const int  multiplex16Position[4][16] = {0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
                                       0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1,
                                       0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1,
                                       0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1};
                                       

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
        #define sensor_ID                    12

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
        #define timer_interval               35
        #define bpm_max                      240
        #define bpm_min                      40
        #define bpm_led_on_time              70

        int componentNumber;
        int mainPin;
        int laserPin;
        int multiPin;
        int multiplex16ReadPin;
        int multiplex16ControlPin[4];
        boolean multiplexer;

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
        void setMultiplexerProximityPin(int, int, int);
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
        #define num_sensors              13
        #define num_digital_sensors      8
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
        #define buttonSelect             7
        #define eqHigh                   8
        #define eqMid                    9
        #define eqLow                    10
        #define rotarySelect             11
        #define proximity                12
        
        // digital LED array index
        #define monitorLED               0
        #define loopStartEndLED          1
        #define loopOnOffLED             3
        #define volLED                   4
        
        #define smoothAnalogPotReading   6

        // component number
        int componentNumber;
        
        MixerElement mixerElement;

        int multiplex16ControlPin[4];
        int multiplex16ReadPin;

        // digital input pin array
        int sensorPins[num_sensors];
        int sensorID[num_sensors];
        boolean sensorAnalog[num_sensors];
        int sensorCurVals[num_sensors];
        int sensorPrevVals[num_sensors][smoothAnalogPotReading];
        boolean sensorNewData[num_sensors];
        
        int analogMultiplexControlPin[3];
        int analogMultiplexPin;
        int digitalMultiplexControlPin[3];
        int digitalMultiplexPin;

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

        int rotaryEncoderPins[2];
        int rotaryEncoderVals[2];

        // variables for reading rotary encoder
        int oldPos;
        int oldTurn, turnCount;       
        
        // output pin array
        int LEDPins[num_digital_LEDs];
        int LEDLastState[num_digital_LEDs];
        boolean LEDpwm[num_digital_LEDs];
        
//        ControlPanel(int _componentNumber);
        ControlPanel(int _componentNumber) : mixerElement(_componentNumber) {
              componentNumber = _componentNumber;
        }        
        void initArrays();
        void setAnalogInputPins (int, int, boolean);          // first control pins, data collect pin
        void setDigitalInputPins (int);              // first pin (both control and data collect are in sync)
        void setOutputPins (int, int);               // first digital output pin, and pwm output pin
        void readData();
        void readDigitalPin(int);
        void readAnalogPin(int);
        void readRotaryEncoder(int);
//        void serialOutputDigital(int);
//        void serialOutputAnalog(int);
        boolean outputSerialData ();
        void printSetupData();

        void setInputPins (int, int);          // first control pins, data collect pin
        void readPin(int);
        boolean serialOutput(int);
};





/************************************
 ***** SETUP AND LOOP FUNCTIONS *****
 ************************************/

#define main_component               0
#define main_volume_pin              0
#define main_vol_sensor_num          0
#define smooth_main_volume           6

#define killer_switch_pin            15
#define killer_switch_sensor_num     1
#define connection_confirm_interval  2000

int main_volume;
int main_volume_previous[smooth_main_volume];
boolean new_volume_data; 

int killer_switch;
boolean new_killer_switch_data; 

ControlPanel controlPanel[4] = {ControlPanel(1), ControlPanel(2), ControlPanel(3), ControlPanel(4)};

long last_connection = 0;
long connectionStartTime = -1;
boolean connectionStarted = false;
boolean readingStarted = false;

void setup() {  
  Serial.begin(57600); 
  initMainComponent();  
  for(int i = 0; i < 4; i ++) {
      controlPanel[i].initArrays();
      if (i == 0) controlPanel[i].setInputPins(22, 1);
      if (i == 1) controlPanel[i].setInputPins(30, 2);
      if (i == 2) controlPanel[i].setInputPins(23, 3);
      if (i == 3) controlPanel[i].setInputPins(31, 4);
//    controlPanel.[i]setOutputPins (16, 11);
      controlPanel[i].printSetupData();
  }  
}


void loop() {
   if (Serial.available()) {
         char newCommand = Serial.read();
         if (newCommand == 'S' || newCommand == 's') {
           readingStarted = true; 
           connectionStartTime = millis();
           Serial.println("starting_amup_connection");
         }
         else if (newCommand == 'X' || newCommand == 'x') {
            connectionStarted = false;
            readingStarted = false;
           Serial.println("closing_amup_connection");        
         }
     }     
     
    if(readingStarted) {
        readSensors();
    }

    if (connectionStarted) {
        confirmConnectionNotice();
        printSensors();
    } 
}

void readSensors() { 
    for(int i = 0; i < 4; i ++) { controlPanel[i].readData(); }
    readMainComponent();
    if (millis() - connectionStartTime > 2000 && !connectionStarted) {
        connectionStarted = true;
        Serial.println("amup_connected");
    }
}

void printSensors() { 

        int new_data_counter = 0;
        for(int i = 0; i < 4; i ++) {               
            boolean output_status_channel = controlPanel[i].outputSerialData();
            if (output_status_channel) new_data_counter++;
        }

        boolean output_status_volume = printMainComponent(); 
        if (output_status_volume) new_data_counter++;

        if (new_data_counter > 0) last_connection = millis();
}

void confirmConnectionNotice() {
    if(millis() - last_connection > connection_confirm_interval) {
        Serial.println("confirm");    
        last_connection = millis();
    }
}

/********************************************************
 *  Main Component
 *
 *************************/

void initMainComponent() {
  main_volume = analogRead(main_volume_pin); 
  new_volume_data = false;
  pinMode(killer_switch_pin, INPUT);
  
}

void readMainComponent() {
  readVolume();
  readKiller();
}

boolean printMainComponent() {
  if (printVolume() || printKiller()) return true;
  return false;
}

void readVolume() {
      int new_volume = analogRead(main_volume_pin)/8;   // divide by 8 to convert values into MIDI range
      int volume_sum = 0;

      for (int i = smooth_main_volume - 1; i > 0; i--) {
          main_volume_previous[i] = main_volume_previous[i-1];          
          volume_sum = volume_sum + main_volume_previous[i];
      }
      main_volume_previous[0] = new_volume;        

      int calculated_volume = (volume_sum + new_volume) / smooth_main_volume;
      int offset = (float(main_volume) * 0.01) + 3;       
      if (calculated_volume < main_volume - offset || calculated_volume > main_volume + offset) {
          new_volume_data = true;
          main_volume = calculated_volume;
      }
      else new_volume_data = false;
}

boolean printVolume() {
    if (new_volume_data) {
      Serial.print(main_component);
      Serial.print(" ");  
      Serial.print(main_vol_sensor_num);
      Serial.print(" ");  
      Serial.println(main_volume);
      return true;
    }
    return false;
}

void readKiller() {
      int current_val = digitalRead(killer_switch_pin);
      current_val = (current_val * 127);
      if (killer_switch != current_val) {
          new_killer_switch_data = true;
          killer_switch = current_val;
      }
      else new_killer_switch_data = false;
}

boolean printKiller() {
    if (new_killer_switch_data) {
      Serial.print(main_component);
      Serial.print(" ");  
      Serial.print(killer_switch_sensor_num);
      Serial.print(" ");  
      Serial.println(killer_switch);
      return true;
    }
    return false;
}





