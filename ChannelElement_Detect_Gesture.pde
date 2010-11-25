
// ***** GESTURE ON AND OFF ***** // 
// Function that identifies gestures that turn on and off the sound of channel
// returns false it has captured an on or off gesture within the pause interval
int MixerElement::gestOnOff() {
      int timeCounter = 0;    // counter that identifies how many readings fit within the gesture interval time
      int onCounter = 0;      // counter that identifies how many readings support an on gesture
      int offCounter = 0;     // counter that identifies how many readings support an off gesture
      gestOn = false;         // boolean variable set to true if ON gesture detected
      gestOff = false;        // boolean variable set to false if OFF gesture detected
      
      // check that an on and off gesture has not been recorded recently 
      if (millis() - gestOnOff_LastTime > gestOnOff_PauseInterval) {
          int counterMin = 4;                        // set minimum number of requirements that need to be met to identify a gesture
          int lookback = READINGS_ARRAY_SIZE - 1;    // set how many readings will be read from the array to identify gesture

          // check that the most current and last readings are valid (they do not equal -1)
          if (rawReadings[0] > 0 && rawReadings[lookback] > 0) {
              int fullDelta = rawReadings[0] - rawReadings[lookback];
              if(fullDelta > gestOnOff_FullDelta || fullDelta < (gestOnOff_FullDelta * -1)) {

                  int noiseThreshold = 2;      // the maximum number of out of order readings for the on/off gesture
                  int noiseCount = 0;          // the current count of out of order readings for the on/off gesture
                  
                  // loop through each element in rawReadings array to see which ones meet requirements
                  for (int j = 0; j < lookback; j++) { 
                       int gradientDelta = 0;
                       int offsetCheck = j + 1;

                       if(rawReadings[j] > 0) { 
                        
                           // if rawReadings value at offsetCheck equals less than 0, then loop through array to until you find the next value that is greater than 0 
                           if (rawReadings[offsetCheck] < 0) {
                               for(offsetCheck; offsetCheck <= lookback; offsetCheck++) {
                                   if (offsetCheck == lookback) return false;
                                   else if (rawReadings[offsetCheck] >= 0) break;
                               }
                           }
                       
                           // if a rawReadings value has been found that is more than or equal to 0 then check if the delta meets requirements 
                           if(rawReadings[offsetCheck] > 0) { 
                               gradientDelta = rawReadings[j] - rawReadings[offsetCheck];
                               if(fullDelta > 0) {
                                    if (gradientDelta >= 0 && gradientDelta < gestOnOff_GradientDelta) { onCounter++; } 
                                    else if (gradientDelta >= gestOnOff_GradientDelta) { break; }
                                    else { noiseCount++; }

                                } else if(fullDelta < 0) {
                                    if (gradientDelta <= 0 && gradientDelta > (gestOnOff_GradientDelta * -1)) { offCounter++; } 
                                    else if (gradientDelta <= (gestOnOff_GradientDelta * -1)) { break; }
                                    else { noiseCount++; }
                                }
                                if (noiseCount >= noiseThreshold) break;  
                           }
                       }
                  }
              } 
          }

          if (onCounter > counterMin) { 
              gestOn = true; 
              masterVolume = TOP_VOLUME;
              gestOnOff_LastTime = millis();
              handIntention = UP;
              return GEST_ON;
          }
          
          if (offCounter > counterMin) { 
              gestOff = true; 
              masterVolume = 0;
              gestOnOff_LastTime = millis();
              handIntention = DOWN;
              return GEST_OFF;
          }
          return STOPPED;
      } 
      return STOPPED; 
} // ****** END - GESTURE ON AND OFF ****** //



// ***** GESTURE VOLUME UP AND DOWN ***** // 
int MixerElement::gestUpDown() {
        if (avgReadings[0] > 0) {
            if (gestUpDown_Center == -1) { 
                  gestUpDown_Center = avgReadings[0];   
                  gestUpDown_Shift = 0;
                  handIntention = STOPPED;                  
            } else if (avgReadings[0] > (gestUpDown_Center + gestUpDown_Bandwidth)) {
                  gestUpDown_Shift = avgReadings[0] - (gestUpDown_Center + gestUpDown_Bandwidth);
                  gestUpDown_Center += gestUpDown_Shift; 
                  handIntention = UP;
            } else if (avgReadings[0] < (gestUpDown_Center - gestUpDown_Bandwidth)) {
                  gestUpDown_Shift = avgReadings[0] - (gestUpDown_Center - gestUpDown_Bandwidth);
                  gestUpDown_Center += gestUpDown_Shift; 
                  handIntention = DOWN;
            } else {
                  gestUpDown_Shift = 0;
                  handIntention = STOPPED;                  
            }
        } else {
            gestUpDown_Center = -1;   
            gestUpDown_Shift = 0;
            handIntention = STOPPED;                  
        }  
        return gestUpDown_Shift;
}

