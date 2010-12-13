/*********************************
 ** READ INPUT FUNCTIONS
 ** Functions that read data from each of pins on the control panel
 *********************************/ 
void ControlPanel::readData() {
    for (int k = 0; k < num_sensors; k++) { readPin(k); }
    if (sensorCurVals[volLock] == 0) mixerElement.addTimedReading();
}


void ControlPanel::readPin(int index_number) { 
   if (sensorPins[index_number] > -1) {

        digitalWrite(multiplex16ControlPin[0], multiplex16Position[0][sensorPins[index_number]]);
        digitalWrite(multiplex16ControlPin[1], multiplex16Position[1][sensorPins[index_number]]); 
        digitalWrite(multiplex16ControlPin[2], multiplex16Position[2][sensorPins[index_number]]);
        digitalWrite(multiplex16ControlPin[3], multiplex16Position[3][sensorPins[index_number]]);
        
        int currentVal;
        if (sensorAnalog[index_number] == true) {
            if (index_number == rotarySelect) {
                readRotaryEncoder(index_number);
            } else {      
                int newVal = analogRead(multiplex16ReadPin) / 8;   // divide by 8 to convert values into MIDI range
    
                int valSum = 0;
                for (int i = smoothAnalogPotReading - 1; i > 0; i--) {
                    sensorPrevVals[index_number][i] = sensorPrevVals[index_number][i-1];          
                    valSum = valSum + sensorPrevVals[index_number][i];
                }
                sensorPrevVals[index_number][0] = newVal;        
    
                int currentVal = (valSum + newVal) / smoothAnalogPotReading;
                int offset = (float(sensorCurVals[index_number]) * 0.01) + 3;       
                if (currentVal < sensorCurVals[index_number] - offset || currentVal > sensorCurVals[index_number] + offset) {
                    sensorNewData[index_number] = true;
                    sensorCurVals[index_number] = currentVal;
                }
                else sensorNewData[index_number] = false;
            }
        }

       else { 
            if (multiplex16ReadPin == 0) currentVal = digitalRead(A0);
            else if (multiplex16ReadPin == 1) currentVal = digitalRead(A1);
            else if (multiplex16ReadPin == 2) currentVal = digitalRead(A2);
            else if (multiplex16ReadPin == 3) currentVal = digitalRead(A3);
            else if (multiplex16ReadPin == 4) currentVal = digitalRead(A4);
            currentVal = (currentVal * 127);
            if (sensorCurVals[index_number] != currentVal) {
                sensorNewData[index_number] = true;
                sensorCurVals[index_number] = currentVal;
            }
            else sensorNewData[index_number] = false;
        }
    }
}


void ControlPanel::readRotaryEncoder (int index_number) {
    int val[] = {0,0};
    int pos = 0;
    int turn = 0;
    sensorNewData[index_number] = false;

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
            sensorNewData[index_number] = true;
            if (turnCount > 0) sensorCurVals[index_number] = -1;
            if (turnCount < 0) sensorCurVals[index_number] = 1;
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
    for (int j = 0; j < num_sensors; j++) { serialOutput(j); }
    mixerElement.updateVolumeMIDI();   
    mixerElement.printMIDIVolume();
}

void ControlPanel::serialOutput(int sensor_index) {
    if (sensor_index < num_sensors) {
        if (sensorNewData[sensor_index]) {
            Serial.print(componentNumber);
            Serial.print(" ");
            Serial.print(sensorID[sensor_index]);
            Serial.print(" ");
            Serial.println(sensorCurVals[sensor_index]);
        }  
    }
} 


/*********************************
 ** PIN SET-UP FUNCTIONS
 ** Functions that set-up each of the pins on the control panel
 *********************************/ 

void ControlPanel::setInputPins (int _multiplexControlPin, int _multiplexReadPin) {
   for (int i = 0; i < 4; i++) {
        multiplex16ControlPin[i] = _multiplexControlPin + (i*2);
        pinMode(multiplex16ControlPin[i], OUTPUT);
    }
    multiplex16ReadPin = _multiplexReadPin;

    sensorPins[monitor] = 0;
    sensorPins[loopStartStop] = 1;
    sensorPins[loopBegin] = 2;
    sensorPins[loopEnd] = 3;

    sensorPins[buttonSelect] = 4;
    sensorPins[crossA] = 5;
    sensorPins[crossB] = 6;
    sensorPins[volLock] = 7;

    // Analog Input Pins (No Call to PinMode)
    sensorPins[eqHigh] = 8;
    sensorPins[eqMid] = 9;
    sensorPins[eqLow] = 10;
    mixerElement.setMultiplexerProximityPin(11, _multiplexControlPin, multiplex16ReadPin);
    sensorPins[rotarySelect] = 100;

    if (componentNumber % 2 == 1) { rotaryEncoderPins[0] = multiplex16ControlPin[3] + 10; }
    else if (componentNumber % 2 == 0) { rotaryEncoderPins[0] = multiplex16ControlPin[3] + 6; }
    rotaryEncoderPins[1] = rotaryEncoderPins[0] + 2;
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
//ControlPanel::ControlPanel(int _componentNumber) : mixerElement(_componentNumber) {
//    componentNumber = _componentNumber;
//}

void ControlPanel::initArrays() {
    int IDcounter = 0;           // counter used to assign an IDs to each sensor
    int multi16IDcounter = 0;           // counter used to assign an IDs to each sensor
    oldPos = 0;
    oldTurn = 0; 
    turnCount = 0;       

    Serial.print(" Component Number from init Arrays ");
    Serial.println(componentNumber);
    
    // initialize all arrays associated to sensors      
    for (int i = 0; i < num_sensors; i++) {
         sensorPins[i] = -1;                  // set pin numbers to -1 (unassigned)
         sensorCurVals[i] = 0;                // set current values to 0
         sensorNewData[i] = false;            // set new data flags to false
         sensorID[i] = multi16IDcounter;             // assign a sensor ID to each sensor
         if (i < num_digital_sensors) sensorAnalog[i] = false; 
             else sensorAnalog[i] = true;
         for (int j = smoothAnalogPotReading - 1; j >= 0; j--) 
             sensorPrevVals[i][j] = 0;
         multi16IDcounter++;                                // increment the sensor ID counter
     }
    
     // initialize all arrays associated to LEDs      
     for (int k = 0; k < num_digital_LEDs; k++) {
         LEDPins[k] = -1;                            // set pin numbers to -1 (unassigned)
         LEDLastState[k] = 0;                        // set last state of the LED to 0
         LEDpwm[k] = false;                          // set pwm flags to false
     }

}


void ControlPanel::printSetupData() {

    Serial.println("===========================");
    Serial.print("Component Number: ");
    Serial.println(componentNumber);

    Serial.print("Multiplex Reading pin: ");
    Serial.println(multiplex16ReadPin);
    Serial.print("Multiplex control pins: ");
    Serial.print(multiplex16ControlPin[0]);
    Serial.print(" - ");
    Serial.print(multiplex16ControlPin[1]);
    Serial.print(" - ");
    Serial.print(multiplex16ControlPin[2]);
    Serial.print(" - ");
    Serial.print(multiplex16ControlPin[3]);
    Serial.println("");

    Serial.println("Sensor Overview: ");
    for (int i = 0; i < num_sensors; i++) {
         Serial.print(" sensor number ");
         Serial.print(i);
         Serial.print(" digital sensor ID ");
         Serial.print(sensorID[i]);
         Serial.print(" sensor Pin ");
         Serial.print(sensorPins[i]);
         Serial.println(" ");
    }
     
         Serial.print(" rotary encoder - pin one ");
         Serial.print(rotaryEncoderPins[0]);
         Serial.print(" pin two ");
         Serial.print(rotaryEncoderPins[1]);
         Serial.println(" ");
   
     
}

