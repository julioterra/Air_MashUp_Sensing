// *********************************
// GESTURE ON AND OFF 
// Function that identifies gestures that turn on and off the sound of channel
// returns false it has captured an on or off gesture within the pause interval
boolean mixerChannel::gestOnOff() {
      int timeCounter = 0;    // counter that identifies how many readings fit within the gesture interval time
      int onCounter = 0;      // counter that identifies how many readings support an on gesture
      int offCounter = 0;     // counter that identifies how many readings support an off gesture
      gestOn = false;         // boolean variable set to true if ON gesture detected
      gestOff = false;        // boolean variable set to false if OFF gesture detected
      
      // check that an on and off gesture has not been recorded recently within the pause timeframe
      if (millis() - gestOnOff_LastTime > gestOnOff_PauseInterval) {
          int counterMin = 4;
          int lookback = READINGS_ARRAY_SIZE - 1;

          if (rawReadings[0] > 0 && rawReadings[1] > 0 && rawReadings[lookback] > 0) {
              int fullDelta = rawReadings[0] - rawReadings[lookback];
              if(fullDelta > gestOnOff_FullDelta || fullDelta < (gestOnOff_FullDelta * -1)) {

                  int noiseThreshold = 2;      // the maximum number of out of order readings for the on/off gesture
                  int noiseCount = 0;          // the current count of out of order readings for the on/off gesture
                  
                  for (int j = 0; j < lookback; j++) { 
                       int gradientDelta = 0;
                       int offsetCheck = j + 1;
                    
                       if (rawReadings[offsetCheck] <= 0) {
                           for(offsetCheck; offsetCheck <= lookback; offsetCheck++) {
                               if (offsetCheck == lookback) return false;
                               else if (rawReadings[offsetCheck] >= 0) break;
                           }
                       }
                       
                       if(rawReadings[j] >= 0) { 
                           if(rawReadings[j] > 0 && rawReadings[offsetCheck] >= 0) { 
                               gradientDelta = rawReadings[j] - rawReadings[offsetCheck];
                               if(fullDelta > 0) {
                                    if (gradientDelta >= 0 && gradientDelta < gestOnOff_GradientDelta) { onCounter++; } 
                                    else { noiseCount++; }

                                } else if(fullDelta < 0) {
                                    if (gradientDelta <= 0 && gradientDelta > (gestOnOff_GradientDelta * -1)) { offCounter++; } 
                                    else { noiseCount++; }
                                }
                                if (noiseCount > noiseThreshold) break;  
                           }
                       }
                  }
              } 
          }

      if (onCounter > counterMin) { 
        gestOn = true; 
        masterVolume = TOP_VOLUME;
        gestOnOff_LastTime = millis();
//        Serial.println("Go Up!");
        return false;
      }
      
      if (offCounter > counterMin) { 
        gestOff = true; 
        masterVolume = 0;
        gestOnOff_LastTime = millis();
//        Serial.println("Go Down!");
        return false;
      }
      return true;
      } 
      return false; 
}
// END - GESTURE ON AND OFF 
// *********************************



//int mixerChannel::readingsInSequenceTime(long _timeInterval) {
//    int counter;
//    for (int i = 0; i < READINGS_ARRAY_SIZE; i++) { 
//        if(timeStamps[0]-timeStamps[i] < _timeInterval) { counter++; }
//        else { break; }
//    }
//    return counter;
//}
//

void mixerChannel::gestVolUpDown() {
    if (gestOnOff()) {
        if (avgReadings[0] > 0) {
            if (gestVolUpDown_Center == -1) { 
                  gestVolUpDown_Center = avgReadings[0];   
                  gestVolUpDown_Shift = 0;
            } else if (avgReadings[0] > (gestVolUpDown_Center + gestVolUpDown_Bandwidth)) {
                  gestVolUpDown_Shift = avgReadings[0] - (gestVolUpDown_Center + gestVolUpDown_Bandwidth);
                  gestVolUpDown_Center += gestVolUpDown_Shift; 
            } else if (avgReadings[0] < (gestVolUpDown_Center - gestVolUpDown_Bandwidth)) {
                  gestVolUpDown_Shift = avgReadings[0] - (gestVolUpDown_Center - gestVolUpDown_Bandwidth);
                  gestVolUpDown_Center += gestVolUpDown_Shift; 
            } else {
                  gestVolUpDown_Shift = 0;
                  
            }
        } else {
            gestVolUpDown_Center = -1;   
            gestVolUpDown_Shift = 0;
        }  
        changeVolume(float(gestVolUpDown_Shift));
    }
}



void mixerChannel::changeVolume(float _volChange) {
    masterVolume += (_volChange / 500.0) * TOP_VOLUME;
    if (masterVolume > TOP_VOLUME) masterVolume = TOP_VOLUME;
    else if (masterVolume < 0) masterVolume = 0;
}
