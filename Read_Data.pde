
mixerChannel::mixerChannel(int _channelPin, String _channelName) {
    gestOnOff_LastTime = millis(); 
    gestOn = false;
    gestOff = false;
    gestVolUpDown_Center = 0;
    gestVolUpDown_Shift = 0;
    channelPin = _channelPin;
    newReading = 0;
    masterVolume = 0;
   for (int i = 0; i < READINGS_ARRAY_SIZE; i++) rawReadings[i] = 0;
 
 }

void mixerChannel::addNewTime(unsigned long newReading) {
  for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { timeStamps[i] = timeStamps[i-1]; }
  timeStamps[0] = newReading;
}

void mixerChannel::addNewTimedReading(unsigned long newTime) {
    addNewTime(newTime);
    addNewReading();
}


void mixerChannel::addNewReading() {
  int avgSum = 0;
  int validAvgReadings = 0;

  newReading = analogRead(channelPin);

  // move values back in array by one position
  for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { rawReadings[i] = rawReadings[i-1]; }
  for(int j = READINGS_ARRAY_SIZE-1; j > 0; j--) { avgReadings[j] = avgReadings[j-1]; }
  for(int k = AVERAGE_READING_BUFFER_SIZE-1; k > 0; k--) { avgBuffer[k] = avgBuffer[k-1]; }

  // check the readings to make sure they are valid
  if (newReading > 130 && newReading < 490) {
      rawReadings[0] = 360 - (newReading - 120);
      avgBuffer[0] = rawReadings[0];
  } else if (newReading < 130 || newReading > 490) { 
      rawReadings[0] = -1; 
      avgBuffer[0] = -1; 
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

