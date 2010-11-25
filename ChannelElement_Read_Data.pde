// *** ADD NEW TIMED READING ***
// add new reading with a timestamp
void MixerElement::addTimedReading() {
    if (millis() - timeStamps[0] > timer_interval) {
        addNewTime(millis());
        addNewReading();
    }
}


// *** ADD NEW TIMESTAMP ***
// add new timestamp into timestamp array
void MixerElement::addNewTime(unsigned long newReading) {
  for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { timeStamps[i] = timeStamps[i-1]; }
  timeStamps[0] = newReading;
}


// *** ADD NEW READING FUNCTION ***
// add new reading into the readings array
void MixerElement::addNewReading() {
    int avgSum = 0;
    int validAvgReadings = 0;
  
    // read new data value from sensor
    if (multiplexer) {
        digitalWrite(multiplexControlPin[0], multiPin);
        digitalWrite(multiplexControlPin[1], multiPin); 
        digitalWrite(multiplexControlPin[2], multiPin);
    }
    rawReading = analogRead(mainPin);

    
    // ****** PREPARE BUFFER AND READING ARRAYS ****** //   
    // prepare to add new value to arrays - move values back in array by one position, starting at the end of the array and moving to the beginning
    for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { 
        rawReadings[i] = rawReadings[i-1]; 
        avgReadings[i] = avgReadings[i-1]; 
    }
    for(int k = AVERAGE_READING_BUFFER_SIZE-1; k > 0; k--) { avgBuffer[k] = avgBuffer[k-1]; }
    for(int j = PRE_READING_BUFFER_SIZE-1; j > 0; j--) { preBuffer[j] = preBuffer[j-1]; }

    // ****** CHECK READING IS WITHIN RANGE AND MAP VALUE ACCORDINGLY ****** //   
    // adjust the value by checking if it is within acceptable range, and adjusting value
    if (rawReading > SENSOR_MIN && rawReading < SENSOR_MAX) { preBuffer[0] = sensorRange - (rawReading - SENSOR_MIN); }
    else if (rawReading < SENSOR_MIN) { preBuffer[0] = -1; }
    else if (rawReading > SENSOR_MAX) { preBuffer[0] = 0; }
    
    int reorderBuffer[PRE_READING_BUFFER_SIZE];
    for(int j = PRE_READING_BUFFER_SIZE-1; j > 0; j--) { reorderBuffer[j] = -2; }

    for(int i = 0; i < PRE_READING_BUFFER_SIZE; i++) {
        int orderCounter = 0;
        int repeatCounter = 0;
        for(int j = 0; j < PRE_READING_BUFFER_SIZE; j++) {
            if(preBuffer[i] < preBuffer[j]) orderCounter++;             
            if(preBuffer[i] == preBuffer[j]) repeatCounter++;             
        }    
        if (repeatCounter == 1) { reorderBuffer[orderCounter] = preBuffer[i]; } 
        else {
          for(int k = 0; k < repeatCounter; k++) {
                if(reorderBuffer[orderCounter + k] == -2) { reorderBuffer[orderCounter + k] = preBuffer[i]; }
            }
        }
    }
    
    int newReading = reorderBuffer[PRE_READING_BUFFER_SIZE/2];
    
    // ****** CHECK HAND ACTIVE STATUS ****** // 
    // check if the hand status has changed
    if (newReading < 0 && handActive == true) {
        handActive = false;
        handStatusChange = true;
    } else if (newReading >= 0  && handActive == false) {
        handActive = true;
        handStatusChange = true;
    }

    avgReadings[0] = newReading;
    rawReadings[0] = newReading;

} // *** END NEW READING FUNCTION ***



