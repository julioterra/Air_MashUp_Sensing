// Function that identifies gestures to turn on and off the sound of channel
void gestOnOff() {
      int timeCounter = 0;    // counter that identifies how many readings fit within the gesture interval time
      int onCounter = 0;      // counter that identifies how many readings support an on gesture
      int offCounter = 0;     // counter that identifies how many readings support an off gesture
      gestOn = false;         // boolean variable set to true if ON gesture detected
      gestOff = false;        // boolean variable set to false if OFF gesture detected
    
      // check that an on and off gesture has not been recorded recently within the pause timeframe
      if (millis() - gestOnOff_LastTime > gestOnOff_PauseInterval) {
    
          // check how many readings fall within the time interval to capture a start/stop gesture
          timeCounter = readingsInSequenceTime(gestOnOff_SequenceTime);
        
            for (int j = 0; j < timeCounter; j++) { 
                int gradientDelta = 0;
                int fullDelta = 0;
                if(proxVals[j] > 0 && proxVals[j+1] > 0) { gradientDelta = proxVals[j] - proxVals[j+1]; }
                if(proxVals[0] > 0 && proxVals[j+1] > 0) { fullDelta = proxVals[0] - proxVals[j+1]; }
                if(fullDelta > gestOnOff_FullDelta && gradientDelta < gestOnOff_GradientDelta)  { onCounter++; }
                else { continue; }
            } 
            if (onCounter > 3) { 
              gestOn = true; 
              Serial.println();
              Serial.println("TURN ON");      
              gestOnOff_LastTime = millis();
              return;
            }
    
          for (int j = 0; j < timeCounter; j++) { 
              int gradientDelta = 0;
              int fullDelta = 0;
              if(proxVals[j] > 0 && proxVals[j+1] > 0) { gradientDelta = proxVals[j+1] - proxVals[j]; }
              if(proxVals[0] > 0 && proxVals[j+1] > 0) { fullDelta = proxVals[j+1] - proxVals[0]; }
              if(fullDelta > gestOnOff_FullDelta && gradientDelta < gestOnOff_GradientDelta)  { offCounter++; }
              else { continue; }
            } 
            if (offCounter > 3) { 
              gestOff = true; 
              Serial.println();
              Serial.println("TURN OFF");      
              gestOnOff_LastTime = millis();
              return;
            }
      }  
}

int readingsInSequenceTime(long _timeInterval) {
    int counter;
    for (int i = 0; i < READINGS_ARRAY_SIZE; i++) { 
        if(timeStamps[0]-timeStamps[i] < _timeInterval) { counter++; }
        else { break; }
    }
    return counter;
}

void checkGestureSmoothUpDown() {
}

