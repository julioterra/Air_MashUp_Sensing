/**** DESIGN CONSIDERATIONS: *****
 * 
 * BPM Tap Sketch
 * created by Julio Terra
 * 
 * Simple sketch that takes input from a button to set the tempo of a blinking LED.
 * Developed to be incorporated into my Air Mash-up Project, being developed for 
 * the New Instruments for Musical Expressions class.
 * 
 *****/

TapTempo::TapTempo(){
  for (int i = timer_array_length - 1; i >= 0; i--) tapIntervals[i] = 0;       

  lastTapTime = 0;                     
  tapState = LOW;
  lastTapState = LOW;                            
  bpm = 0;  
  avgTapInterval = 0; 
  newTap = false; 
  tapActive = false; 

  lightOn = false;
  lightOnTime = 0;
  previousLightOnTime = lightOnTime;
}


void TapTempo::setBpmPins(int _bpmPin) {
    blinkPin = _bpmPin;
    pinMode(blinkPin, OUTPUT); 
}


void TapTempo::catchTap(int _newData){
    readData(_newData);

    // if the tapState is LOW and the previous tap state was different then
    if(lastTapState == LOW && tapState != lastTapState) {       
        for (int i = timer_array_length - 1; i > 0; i--)    // re-initialize the array to make space for the new reading 
            tapIntervals[i] = tapIntervals[i-1];       
        tapIntervals[0] = millis() - lastTapTime;               // calculate current timer by subtracting time of previous tap (lastTapTime) from current time 
        lastTapTime = millis();                                 // set current time as time of previous tap (lastTapTimeTime)
        newTap = true;
        tapActive = true;
        lightOn = true;
        lightOnTime = millis();
    } else if (millis() - lastTapTime > avgTapInterval) { tapActive = false; }
    lastTapState = tapState;            // set lastTapTimeTimeState variable using current tapState
}           

void TapTempo::setTempo(){
    if (newTap) {
        int tempoCounter = 0;      // variable is incremented for each valid reading
        float tempoSum = 0;        // variable that holds the sum of all valid readings    
    
        // loop through each element in the array 
        for (int i = timer_array_length - 1; i >= 0; i--) {    
            if (60000/tapIntervals[i] > bpm_min && 60000/tapIntervals[i] < bpm_max) {    // confirm if reading is valid
                tempoSum += tapIntervals[i];                                             // sum valid readings
                tempoCounter ++;                                                         // increment counter for each valid reading
            }
        }
    
        // if there were more than two valid readings in the array then calculate bpm
        if (tempoCounter >= 3) {
            avgTapInterval = tempoSum / tempoCounter;              // calculate the average time in milliseconds between each tap
            bpm = float(60000)/float(avgTapInterval);                                   // calculate the bpm based on the millisecond averages
        }    
        newTap = false;
    }
}

void TapTempo::bpmBlink(){
    pinMode(blinkPin, OUTPUT); 
    // check if it is time to turn off the light by seeing if sufficient time has passed since light was turned on
    if (millis() > (lightOnTime + bpm_led_on_time)) {
        lightOnTime += avgTapInterval;
        lightOn = false;
    } 

    // if the button is not currently being used to set the tempo, and it is time to blink the LED, then turn it on
    else if(!tapActive && millis() > lightOnTime) lightOn = true;

    // control the actual blinking of the lights based on the state of the lightOn flag variable
    if (!lightOn) {
      digitalWrite(blinkPin, LOW);
    }
    else if(millis() > lightOnTime) {
 
      digitalWrite(blinkPin, HIGH);
    }
}


void TapTempo::readData(int _newData){
    if (millis() - debounceTime > debounce_interval) {
        tapState = _newData;          // assign new data to the tapState variable 
        debounceTime = millis();      // set the time when data was collect to debounce (ensure that double readings don't happen)
    }
}

