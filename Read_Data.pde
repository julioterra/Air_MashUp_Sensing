// *** ADD NEW TIMED READING ***
// add new reading with a timestamp
void MixerElement::addTimedReading(unsigned long newTime) {
    addNewTime(newTime);
    addNewReading();
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
    
    // ****** CHECK HAND ACTIVE STATUS ****** // 
    // check if the hand status has changed
    int handActiveCounter = 0;
    for(int i = 0; i < PRE_READING_BUFFER_SIZE-2; i++) {
        if(preBuffer[i] < 0) handActiveCounter--; 
        else if(preBuffer[i] > 0) handActiveCounter++;       
    }
    if (handActiveCounter <= ((PRE_READING_BUFFER_SIZE-2)*-1) && handActive == true) {
        handActive = false;
        handStatusChange = true;
    } else if (handActiveCounter >= (PRE_READING_BUFFER_SIZE-2) && handActive == false) {
        handActive = true;
        handStatusChange = true;
    }

    // ****** REMOVE NOISE FROM READINGS ****** // 
    // if the hand status has changed then clean out noise from readings
    if(handStatusChange == true) {
        for(int i = 0; i < PRE_READING_BUFFER_SIZE; i++) { preBuffer[i] = -1; }
        handStatusChange = false;
    } 
    
    // clean out noise from avgBuffer (only add readings that do not jump more than delta limit)
    rawReadings[0] = preBuffer[PRE_READING_BUFFER_SIZE-1];
    if (!(abs(rawReadings[0]-rawReadings[1]) > gestUpDown_IgnoreRange)) avgBuffer[0] = rawReadings[0];


    // ****** CALCULATE VALUES FOR SMOOTH VOLUME INCREASE/DECREASE ****** // 
    // calculate the average readings for the volume up and down gesture
    for(int l = 0; l < AVERAGE_READING_BUFFER_SIZE; l++) { 
       if (avgBuffer[l] > 0) {
            avgSum = avgBuffer[l] + avgSum;
            validAvgReadings++;
        }
    }
    // if there are more than 2 valid readings then add the new averaged reading to the avgReadings array
    if (validAvgReadings > AVERAGE_READING_BUFFER_SIZE/3) avgReadings[0] = avgSum / validAvgReadings;
    else avgReadings[0] = -1;
} // *** END NEW READING FUNCTION ***



