/*********************************
 ** READ INPUT FUNCTIONS
 ** Functions that read data from each of pins on the control panel
 *********************************/ 
void ControlPanel::readData() {
    for (int i = 0; i < num_digital_sensors; i++) { readDigitalPin(i); }
    for (int j = 0; j < num_analog_sensors; j++) { readAnalogPin(j); }
    mixerElement.addTimedReading();
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
        if (index_number == rotarySelect) {
            readRotaryEncoder(index_number);
        } else {      
            digitalWrite(analogMultiplexControlPin[0], multiplexPosition[0][sensorAnalogPins[index_number]]);
            digitalWrite(analogMultiplexControlPin[1], multiplexPosition[1][sensorAnalogPins[index_number]]); 
            digitalWrite(analogMultiplexControlPin[2], multiplexPosition[2][sensorAnalogPins[index_number]]);
            int newVal = analogRead(analogMultiplexPin);
    
            int valSum = 0;
            for (int i = smoothAnalogPotReading - 1; i > 0; i--) {
                sensorAnalogPrevVals[index_number][i] = sensorAnalogPrevVals[index_number][i-1];          
                valSum = valSum + sensorAnalogPrevVals[index_number][i];
            }
            sensorAnalogPrevVals[index_number][0] = newVal;        
            int currentVal = (valSum + newVal) / smoothAnalogPotReading;
            int offset = (float(sensorAnalogCurVals[index_number]) * 0.01) + 11;
        
            if (currentVal < sensorAnalogCurVals[index_number] - offset || currentVal > sensorAnalogCurVals[index_number] + offset) {
                sensorAnalogNewData[index_number] = true;
                sensorAnalogCurVals[index_number] = currentVal;
            }
            else sensorAnalogNewData[index_number] = false;
        }
    }
}

void ControlPanel::readRotaryEncoder (int index_number) {
    int val[] = {0,0};
    int pos = 0;
    int turn = 0;
    sensorAnalogNewData[index_number] = false;

    val[0] = digitalRead(rotaryEncoderPins[0]);
    val[1] = digitalRead(rotaryEncoderPins[1]);
  
    if ( val[0] != rotaryEncoderVals[0] || val[1] != rotaryEncoderVals[1]) {
        //for each pair there's a position out of four
        if      ( val[0] == 1 && val[1] == 1 ) pos = 0;
        else if ( val[0] == 0 && val[1] == 1 ) pos = 1;
        else if ( val[0] == 0 && val[1] == 0 ) pos = 2;
        else if ( val[0] == 1 && val[1] == 0 ) pos = 3;
        
        turn = pos - oldPos;
        
        if (abs(turn) != 2) { // impossible to understand where it's turning otherwise.
            if (turn == -1 || turn == 3)       turnCount++;
            else if (turn == 1 || turn == -3)  turnCount--;
        }
        
        if (pos == 0 && turnCount != 0) {      // only assume a complete step on stationary position
            sensorAnalogNewData[index_number] = true;
            sensorAnalogCurVals[index_number] = turnCount;
            turnCount = 0;
        }
        
        rotaryEncoderVals[0] = val[0];
        rotaryEncoderVals[1] = val[1];
        oldPos  = pos;
        oldTurn = turn;
    }

}

/*********************************
 ** OUTPUT DATA FUNCTIONS
 ** Functions that read data from each of pins on the control panel
 *********************************/ 
void ControlPanel::outputSerialData () {
    for (int i = 0; i < num_digital_sensors; i++) { serialOutputDigital(i); }
    for (int j = 0; j < num_analog_sensors; j++) { serialOutputAnalog(j); }
    mixerElement.updateVolumeMIDI();   
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

void ControlPanel::setAnalogInputPins (int _analogMultiplexControlPin, int _analogMultiplexPin, boolean _firstSide) {
    for (int i = 0; i < 3; i++) {
        analogMultiplexControlPin[i] = _analogMultiplexControlPin + i;
        pinMode(analogMultiplexControlPin[i], OUTPUT);
    }
    analogMultiplexPin = _analogMultiplexPin;
    
    if (_firstSide) {
        // Analog Input Pins (No Call to PinMode)
        sensorAnalogPins[eqHigh] = 2;
        sensorAnalogPins[eqMid] = 4;
        sensorAnalogPins[eqLow] = 6;
        mixerElement.setMultiplexerProximityPin(_analogMultiplexPin, _analogMultiplexControlPin, 0);
        sensorAnalogPins[rotarySelect] = 100;
        rotaryEncoderPins[0] = analogMultiplexControlPin[2] + 1;
        rotaryEncoderPins[1] = rotaryEncoderPins[0] + 1;
    } else {
        // Analog Input Pins (No Call to PinMode)
        sensorAnalogPins[eqHigh] = 3;
        sensorAnalogPins[eqMid] = 5;
        sensorAnalogPins[eqLow] = 7;
        mixerElement.setMultiplexerProximityPin(_analogMultiplexPin, _analogMultiplexControlPin, 1);
        sensorAnalogPins[rotarySelect] = 100;
        rotaryEncoderPins[0] = analogMultiplexControlPin[2] + 3;
        rotaryEncoderPins[1] = rotaryEncoderPins[0] + 1;
    }
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
    sensorDigitalPins[loopStartStop] = 6;
    sensorDigitalPins[monitor] = 4;

    sensorDigitalPins[crossA] = 1;
    sensorDigitalPins[crossB] = 3;
    sensorDigitalPins[volLock] = 7;
    sensorDigitalPins[buttonSelect] = 5;
}

void ControlPanel::setOutputPins(int _firstLEDPin, int _pwmPin) {
    LEDPins[loopStartEndLED] = _firstLEDPin;
    LEDPins[loopOnOffLED] = _firstLEDPin + 1;
    LEDPins[monitorLED] = _firstLEDPin + 2;
    LEDPins[volLED] = _pwmPin;
    LEDpwm[volLED] = true;

    Serial.print("loop start and end pin ");
    Serial.println(LEDPins[loopStartEndLED]);
    Serial.print("loop on and off pin ");
    Serial.println(LEDPins[loopOnOffLED]);
    Serial.print("monitor on and off pin ");
    Serial.println(LEDPins[monitorLED]);
    Serial.print("vol LED pin ");
    Serial.println(LEDPins[volLED]);


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
    componentNumber = _componentNumber;
}

void ControlPanel::initArrays() {
    int IDcounter = 1;           // counter used to assign an IDs to each sensor
    oldPos = 0;
    oldTurn = 0; 
    turnCount = 0;       

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

void ControlPanel::printSetupData() {

    Serial.print("Digital: multiplex reading pin ");
    Serial.print(digitalMultiplexPin);
    Serial.print(" multiplex control pins ");
    Serial.print(digitalMultiplexControlPin[0]);
    Serial.print(" - ");
    Serial.print(digitalMultiplexControlPin[1]);
    Serial.print(" - ");
    Serial.print(digitalMultiplexControlPin[2]);
    Serial.println("");

    for (int i = 0; i < num_digital_sensors; i++) {
         Serial.print(" digital sensor number ");
         Serial.print(i);
         Serial.print(" digital sensor ID ");
         Serial.print(sensorDigitalID[i]);
         Serial.print(" digital sensor Pin ");
         Serial.print(sensorDigitalPins[i]);
         Serial.println(" ");
    }
     
    Serial.print("Analog: multiplex reading pin ");
    Serial.print(analogMultiplexPin);
    Serial.print(" multiplex control pins ");
    Serial.print(analogMultiplexControlPin[0]);
    Serial.print(" - ");
    Serial.print(analogMultiplexControlPin[1]);
    Serial.print(" - ");
    Serial.print(analogMultiplexControlPin[2]);
    Serial.println("");
    
     for (int j = 0; j < num_analog_sensors; j++) {         
         Serial.print(" analog sensor number ");
         Serial.print(j);
         Serial.print(" analog sensor ID ");
         Serial.print(sensorAnalogID[j]);
         Serial.print(" analog sensor Pin ");
         Serial.print(sensorAnalogPins[j]);
         Serial.println(" ");
     }
}
