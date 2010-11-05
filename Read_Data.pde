
// *** MIXER CHANNEL CONSTRUCTOR: initializes all of the variables of all mixer channel objects
mixerChannel::mixerChannel(int _channelPin, String _channelName) {
    channelPin = _channelPin;
    masterVolume = 0;
    handActive = false;
    handStatusChange = false;
    newReading = 0;
    sensorRange = SENSOR_MAX - SENSOR_MIN;
    gestOnOff_LastTime = millis(); 
    gestOn = false;
    gestOff = false;
    gestVolUpDown_Center = 0;
    gestVolUpDown_Shift = 0;
    for (int i = 0; i < READINGS_ARRAY_SIZE; i++) rawReadings[i] = 0;
    for (int i = 0; i < PRE_READING_BUFFER_SIZE; i++) {
        preBuffer[i] = -1;
        transferBuffer[i] = -1;
    }
    
 }
// *** END CONSTRUCTOR

void mixerChannel::addNewTimedReading(unsigned long newTime) {
    addNewTime(newTime);
    addNewReading();
}

void mixerChannel::addNewTime(unsigned long newReading) {
  for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { timeStamps[i] = timeStamps[i-1]; }
  timeStamps[0] = newReading;
}


// *** ADD NEW READING FUNCTION ***
// add new reading into the readings array
void mixerChannel::addNewReading() {
    int avgSum = 0;
    int validAvgReadings = 0;
  
    // read new data value from sensor
    rawReading = analogRead(channelPin);
  
    // prepare to add new value to arrays - move values back in array by one position, starting at the end of the array and moving to the beginning
    for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { 
        rawReadings[i] = rawReadings[i-1]; 
        avgReadings[i] = avgReadings[i-1]; 
    }
    for(int k = AVERAGE_READING_BUFFER_SIZE-1; k > 0; k--) { avgBuffer[k] = avgBuffer[k-1]; }
    for(int j = PRE_READING_BUFFER_SIZE-1; j > 0; j--) { preBuffer[j] = preBuffer[j-1]; }
  
    // adjust the value by checking if it is within acceptable range, and adjusting value
    if (rawReading > SENSOR_MIN && rawReading < SENSOR_MAX) { preBuffer[0] = sensorRange - (rawReading - SENSOR_MIN); }
    else if (rawReading < SENSOR_MIN) { preBuffer[0] = -1; }
    else if (rawReading > SENSOR_MAX) { preBuffer[0] = 0; }
    
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

    if(handStatusChange == true) {
        for(int i = 0; i < PRE_READING_BUFFER_SIZE; i++) { preBuffer[i] = -1; }
        handStatusChange = false;
    } 
    
    rawReadings[0] = preBuffer[PRE_READING_BUFFER_SIZE-1];
    if (!(abs(rawReadings[0]-rawReadings[1]) > gestVolUpDown_GradientDelta)) avgBuffer[0] = rawReadings[0];


    
    // calculate the average readings for the average array
    for(int l = 0; l < AVERAGE_READING_BUFFER_SIZE; l++) { 
       if (avgBuffer[l] > 0) {
            avgSum = avgBuffer[l] + avgSum;
            validAvgReadings++;
        }
    }
    if (validAvgReadings > AVERAGE_READING_BUFFER_SIZE/3) avgReadings[0] = avgSum / validAvgReadings;
    else avgReadings[0] = -1;
}
// *** END NEW READING FUNCTION ***

