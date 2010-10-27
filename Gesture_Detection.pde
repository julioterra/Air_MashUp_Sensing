// Function that identifies gestures to turn on and off the sound of channel
void checkGestStartStop() {
  int timeCounter = 0;    // counter that identifies how many readings fit within the gesture interval time
  int onCounter = 0;      // counter that identifies how many readings support an on gesture
  int offCounter = 0;     // counter that identifies how many readings support an off gesture
  gestOn = false;         // boolean variable set to true if on gesture detected
  gestOff = false;        // boolean variable set to false if off gesture detected

  // check that an on and off gesture has not been recorded recently within the pause timeframe
  if (millis() - gestOnOffPreviousMillis > gestOnOffPause) {

      // check how many readings fall within the time interval to capture a start/stop gesture
      for (int i = 0; i < READINGS_ARRAY_SIZE; i++) { 
        if(timeStamps[0]-timeStamps[i] < gestTimeInterval) { timeCounter++; }
        else { continue; }
      }
    
        for (int j = 0; j < timeCounter; j++) { 
          int delta = 0;
          int fullDelta = 0;
          if(proxVals[j] > 0 && proxVals[j+1] > 0) { delta = proxVals[j] - proxVals[j+1]; }
          if(proxVals[0] > 0 && proxVals[j+1] > 0) { fullDelta = proxVals[0] - proxVals[j+1]; }
          if(fullDelta > gestOnOffDelta && delta < gestOnOffGrade)  { onCounter++; }
          else { continue; }
        } 
        if (onCounter > 3) { 
          gestOn = true; 
          Serial.println();
          Serial.println("TURN ON");      
          gestOnOffPreviousMillis = millis();
          return;
        }

      for (int j = 0; j < timeCounter; j++) { 
          int delta = 0;
          int fullDelta = 0;
          if(proxVals[j] > 0 && proxVals[j+1] > 0) { delta = proxVals[j+1] - proxVals[j]; }
          if(proxVals[0] > 0 && proxVals[j+1] > 0) { fullDelta = proxVals[j+1] - proxVals[0]; }
          if(fullDelta > gestOnOffDelta && delta < gestOnOffGrade)  { offCounter++; }
          else { continue; }
        } 
        if (offCounter > 3) { 
          gestOff = true; 
          Serial.println();
          Serial.println("TURN OFF");      
          gestOnOffPreviousMillis = millis();
          return;
        }
  }  

}
