
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
  newReading = analogRead(channelPin);

  // move values back in array by one position, starting at the end of the array and moving to the beginning
  for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { 
    rawReadings[i] = rawReadings[i-1]; 
    avgReadings[i] = avgReadings[i-1]; 
  }
  for(int k = AVERAGE_READING_BUFFER_SIZE-1; k > 0; k--) { avgBuffer[k] = avgBuffer[k-1]; }

  // convert the raw readings into appropriate range, remove values that are outside the range
  if (newReading > SENSOR_MIN && newReading < SENSOR_MAX) {
      rawReadings[0] = sensorRange - (newReading - SENSOR_MIN);
      avgBuffer[0] = rawReadings[0];
  } else if (newReading < SENSOR_MIN || newReading > SENSOR_MAX) { 
      rawReadings[0] = -1; 
      avgBuffer[0] = -1; 
  }
  
  // check if the hand status has changed
  int handActiveCounter = 0;
  int handActiveRequirement = 3;
  for(int i = 0; i <= handActiveRequirement; i++) {
      if(rawReadings[i] < 0) handActiveCounter--; 
      if(rawReadings[i] > 0) handActiveCounter++;       
  }
  if (handActiveCounter < (handActiveRequirement*-1) && handActive == true) {
    handActive = false;
    handStatusChange = true;
    Serial.println(" hand status changed to inactive ");
  } else if (handActiveCounter > handActiveRequirement && handActive == false) {
    handActive = true;
    handStatusChange = true;
    Serial.println(" hand status changed to active ");
  }
  
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

