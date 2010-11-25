/*********************************
 ** READ INPUT FUNCTIONS
 ** Functions that read data from each of pins on the control panel
 *********************************/ 
void ControlPanel::readData() {
    for (int i = 0; i < num_digital_sensors; i++) { readDigitalPin(i); }
    for (int j = 0; j < num_analog_sensors; j++) { readAnalogPin(j); }
    mixerElement.addTimedReading();
    mixerElement.updateVolumeMIDI();   
}

void ControlPanel::readDigitalPin(int index_number) { 
    if (sensorDigitalPins[index_number] != -1) {
        int currentVal = digitalRead(sensorDigitalPins[index_number]);
        if (sensorDigitalCurVals[index_number] != currentVal) {
            sensorDigitalNewData[index_number] = true;
            sensorDigitalCurVals[index_number] = currentVal;
        }
        else sensorDigitalNewData[index_number] = false;
    }
}

void ControlPanel::readAnalogPin(int index_number) { 
    if (sensorAnalogPins[index_number] != -1) {
        int newVal = analogRead(sensorAnalogPins[index_number]);

        int valSum = 0;
        for (int i = smoothAnalogPotReading - 1; i > 0; i--) {
            sensorAnalogPrevVals[index_number][i] = sensorAnalogPrevVals[index_number][i-1];          
            valSum = valSum + sensorAnalogPrevVals[index_number][i];
        }
        sensorAnalogPrevVals[index_number][0] = newVal;        
        int currentVal = (valSum + newVal) / smoothAnalogPotReading;
        int offset = (float(sensorAnalogCurVals[index_number]) * 0.005) + 4;
    
        if (currentVal < sensorAnalogCurVals[index_number] - offset || currentVal > sensorAnalogCurVals[index_number] + offset) {
            sensorAnalogNewData[index_number] = true;
            sensorAnalogCurVals[index_number] = currentVal;
        }
        else sensorAnalogNewData[index_number] = false;
    }
}

/*********************************
 ** OUTPUT DATA FUNCTIONS
 ** Functions that read data from each of pins on the control panel
 *********************************/ 
void ControlPanel::outputSerialData () {
    for (int i = 0; i < num_digital_sensors; i++) { serialOutputDigital(i); }
    for (int j = 0; j < num_analog_sensors; j++) { serialOutputAnalog(j); }
    mixerElement.printMIDIVolume();
}

void ControlPanel::serialOutputDigital(int sensor_index) {
    if (sensor_index < num_digital_sensors) {
        if (sensorDigitalNewData[sensor_index]) {
            Serial.print(componentNumber);
            Serial.print(" ");
            Serial.print(sensorDigitalID[sensor_index]);
            Serial.print(" ");
            Serial.print(sensorDigitalCurVals[sensor_index]);
            Serial.println();
        }  
    }
} 

void ControlPanel::serialOutputAnalog(int sensor_index) {
    if (sensor_index < num_analog_sensors) {
        if (sensorAnalogNewData[sensor_index]) {
            Serial.print(componentNumber);
            Serial.print(" ");
            Serial.print(sensorAnalogID[sensor_index]);
            Serial.print(" ");
            Serial.print(sensorAnalogCurVals[sensor_index]);
            Serial.println();
        }  
    }
}

/*********************************
 ** PIN SET-UP FUNCTIONS
 ** Functions that set-up each of the pins on the control panel
 *********************************/ 
void ControlPanel::setProximityPin (int _proxPin) {
   mixerElement.setProximityPin(_proxPin);
  
}

void ControlPanel::setEqPins (int _pin_eqHigh, int _pin_eqMid, int _pin_eqLow) {
    // Analog Input Pins (No Call to PinMode)
    sensorAnalogPins[eqHigh] = _pin_eqHigh;
    sensorAnalogPins[eqMid] = _pin_eqMid;
    sensorAnalogPins[eqLow] = _pin_eqLow;
}

void ControlPanel::setLoopPins (int _pin_loopBegin, int _pin_loopEnd, int _pin_loopOnOff, int _pin_loopStartEndLED /*, int _pin_loopOnOffLED*/) {
    // input pins
    sensorDigitalPins[loopBegin] = _pin_loopBegin;
    sensorDigitalPins[loopEnd] = _pin_loopEnd;
    sensorDigitalPins[loopStartStop] = _pin_loopOnOff;
    pinMode(sensorDigitalPins[loopBegin], INPUT);
    pinMode(sensorDigitalPins[loopEnd], INPUT);
    pinMode(sensorDigitalPins[loopStartStop], INPUT);

    // output pins
    LEDPins[loopStartEndLED] = _pin_loopStartEndLED;
    pinMode(LEDPins[loopStartEndLED], OUTPUT);
/*
    LEDPins[loopOnOffLED] = _pin_loopOnOffLED;
    pinMode(LEDPins[loopOnOffLED], OUTPUT);

*/
}

void ControlPanel::setVolPins (int _pin_crossA, int _pin_crossB, int _pin_monitor, int _pin_volLock,  int _pin_monitorLED, int _pin_volLED) {

    // set digital input pin numbers
    sensorDigitalPins[crossA] = _pin_crossA;
    sensorDigitalPins[crossB] = _pin_crossB;
    sensorDigitalPins[monitor] = _pin_monitor;
    sensorDigitalPins[volLock] = _pin_volLock;
    pinMode(sensorDigitalPins[crossA], INPUT);
    pinMode(sensorDigitalPins[crossB], INPUT);
    pinMode(sensorDigitalPins[monitor], INPUT);
    pinMode(sensorDigitalPins[volLock], INPUT);

    // set digital output pins
    LEDPins[monitorLED] = _pin_monitorLED;
    pinMode(LEDPins[monitorLED], OUTPUT);

    // set analog output pins (PWM pins needed)
    LEDPins[volLED] = _pin_volLED;
    LEDpwm[volLED] = true;
    pinMode(LEDPins[volLED], OUTPUT);
}

void ControlPanel::setSelectPins (int _pin_rotarySelect /* , int _pin_buttonSelect*/) {
//    sensorDigitalPins[buttonSelect] = _pin_buttonSelect;
//    pinMode(sensorDigitalPins[buttonSelect], INPUT);

    // set analog input pin numbers 
    sensorAnalogPins[rotarySelect] = _pin_rotarySelect;
}



/*********************************
 ** ARRAY INIT FUNCTION
 ** Functions that initializes all arrrays
 *********************************/ 
ControlPanel::ControlPanel(int _componentNumber)  : mixerElement(_componentNumber) {
    int IDcounter = 1;           // counter used to assign an IDs to each sensor
    componentNumber = _componentNumber;

    // initialize all arrays associated to digital sensors      
    for (int i = 0; i < num_digital_sensors; i++) {
         sensorDigitalPins[i] = -1;                  // set pin numbers to -1 (unassigned)
         sensorDigitalCurVals[i] = 0;                // set current values to 0
         sensorDigitalNewData[i] = false;            // set new data flags to false
         sensorDigitalID[i] = IDcounter;             // assign a sensor ID to each sensor
         for (int j = smoothAnalogPotReading - 1; j >= 0; j--) sensorAnalogPrevVals[i][j] = 0;
         IDcounter++;                                // increment the sensor ID counter
     }

     // initialize all arrays associated to analog sensors      
     for (int j = 0; j < num_analog_sensors; j++) {
         sensorAnalogPins[j] = -1;                   // set pin numbers to -1 (unassigned)
         sensorAnalogCurVals[j] = 0;                 // set current values to 0
         sensorAnalogNewData[j] = false;             // set new data flags to false
         sensorAnalogID[j] = IDcounter;              // assign a sensor ID to each sensor
         IDcounter++;                                // increment the sensor ID counter
     }
    
     // initialize all arrays associated to LEDs      
     for (int k = 0; k < num_digital_LEDs; k++) {
         LEDPins[k] = -1;                            // set pin numbers to -1 (unassigned)
         LEDLastState[k] = 0;                        // set last state of the LED to 0
         LEDpwm[k] = false;                          // set pwm flags to false
     }

}
