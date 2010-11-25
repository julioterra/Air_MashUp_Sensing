/*********************************
 ** READ INPUT FUNCTIONS
 ** Functions that read data from each of pins on the control panel
 *********************************/ 
void ControlPanel::readData() {
    for (int i = 0; i < num_digital_sensors; i++) { readDigitalPin(i); }
    for (int j = 0; j < num_analog_sensors; j++) { readAnalogPin(j); }
//    mixerElement.addTimedReading();
//    mixerElement.updateVolumeMIDI();   
}

void ControlPanel::readDigitalPin(int index_number) { 
   if (sensorDigitalPins[index_number] > -1) {

        digitalWrite(digitalMultiplexControlPin[0], multiplexPosition[0][sensorDigitalPins[index_number]]);
        digitalWrite(digitalMultiplexControlPin[1], multiplexPosition[1][sensorDigitalPins[index_number]]); 
        digitalWrite(digitalMultiplexControlPin[2], multiplexPosition[2][sensorDigitalPins[index_number]]);
        int currentVal = digitalRead(digitalMultiplexPin);

        if (sensorDigitalCurVals[index_number] != currentVal) {
            sensorDigitalNewData[index_number] = true;
            sensorDigitalCurVals[index_number] = currentVal;
        }
        else sensorDigitalNewData[index_number] = false;
    }
}

void ControlPanel::readAnalogPin(int index_number) { 
    if (sensorAnalogPins[index_number] > -1) {

        digitalWrite(analogMultiplexControlPin[0], multiplexPosition[0][sensorAnalogPins[index_number]]);
        digitalWrite(analogMultiplexControlPin[1], multiplexPosition[1][sensorAnalogPins[index_number]]); 
        digitalWrite(analogMultiplexControlPin[2], multiplexPosition[2][sensorAnalogPins[index_number]]);
        int newVal = analogRead(analogMultiplexPin);

//        Serial.print(" pin position control ");
//        Serial.print(analogMultiplexControlPin[0]);
//        Serial.print(analogMultiplexControlPin[1]);
//        Serial.print(analogMultiplexControlPin[2]);
//        Serial.print(" pin number on multiplex ");
//        Serial.print(sensorAnalogPins[index_number]);
//        Serial.print(" value ");
//        Serial.println(newVal);

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
//    mixerElement.printMIDIVolume();
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

void ControlPanel::setAnalogInputPins (int _analogMultiplexControlPin, int _analogMultiplexPin) {
    for (int i = 0; i < 3; i++) {
        analogMultiplexControlPin[i] = _analogMultiplexControlPin + i;
        pinMode(analogMultiplexControlPin[i], OUTPUT);
    }
    analogMultiplexPin = _analogMultiplexPin;
    
    // Analog Input Pins (No Call to PinMode)
    sensorAnalogPins[eqHigh] = 0;
    sensorAnalogPins[eqMid] = 2;
    sensorAnalogPins[eqLow] = 4;
    sensorAnalogPins[rotarySelect] = 6;
//    mixerElement.setProximityPin(1);
}

void ControlPanel::setDigitalInputPins (int _digitalMultiplexControlPin) {
    for (int i = 0; i < 3; i++) {
       digitalMultiplexControlPin[i] = _digitalMultiplexControlPin + i;
        pinMode(digitalMultiplexControlPin[i], OUTPUT);
    }
    digitalMultiplexPin = _digitalMultiplexControlPin + 3;
    pinMode(digitalMultiplexPin, INPUT);

    sensorDigitalPins[loopBegin] = 0;
    sensorDigitalPins[loopEnd] = 2;
    sensorDigitalPins[loopStartStop] = 4;
    sensorDigitalPins[monitor] = 6;

    sensorDigitalPins[crossA] = 1;
    sensorDigitalPins[crossB] = 3;
    sensorDigitalPins[volLock] = 5;
//    sensorDigitalPins[buttonSelect] = 7;

}

void ControlPanel::setOutputPins(int _firstLEDPin, int _pwmPin) {
    LEDPins[loopStartEndLED] = _firstLEDPin;
//    LEDPins[loopOnOffLED] = _firstLEDPin + 1;
    LEDPins[monitorLED] = _firstLEDPin + 2;
    LEDPins[volLED] = _pwmPin;
    LEDpwm[volLED] = true;

// SOURCE OF THE ISSUE IS HERE
//    pinMode(LEDPins[loopStartEndLED], OUTPUT);
//    pinMode(LEDPins[loopOnOffLED], OUTPUT);
//    pinMode(LEDPins[monitorLED], OUTPUT);
//    pinMode(LEDPins[volLED], OUTPUT);
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
