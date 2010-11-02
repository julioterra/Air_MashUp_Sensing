// Function that identifies gestures to turn on and off the sound of channel
// returns false if it is paused (due to a gesture having recently been captured)
boolean gestOnOff() {
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
                if(rawReadings[j] > 0 && rawReadings[j+1] > 0) { gradientDelta = rawReadings[j] - rawReadings[j+1]; }
                if(rawReadings[0] > 0 && rawReadings[j+1] > 0) { fullDelta = rawReadings[0] - rawReadings[j+1]; }
                if(fullDelta > gestOnOff_FullDelta && gradientDelta < gestOnOff_GradientDelta)  { onCounter++; }
                else { continue; }
            } 
            if (onCounter > 3) { 
              gestOn = true; 
              Serial.println();
              Serial.println("TURN ON");      
              gestOnOff_LastTime = millis();
              return false;
            }
    
          for (int j = 0; j < timeCounter; j++) { 
              int gradientDelta = 0;
              int fullDelta = 0;
              if(rawReadings[j] > 0 && rawReadings[j+1] > 0) { gradientDelta = rawReadings[j+1] - rawReadings[j]; }
              if(rawReadings[0] > 0 && rawReadings[j+1] > 0) { fullDelta = rawReadings[j+1] - rawReadings[0]; }
              if(fullDelta > gestOnOff_FullDelta && gradientDelta < gestOnOff_GradientDelta)  { offCounter++; }
              else { continue; }
            } 
            if (offCounter > 3) { 
              gestOff = true; 
              Serial.println();
              Serial.println("TURN OFF");      
              gestOnOff_LastTime = millis();
              return false;
            }
      return true;
      } 
      return false; 
}


int readingsInSequenceTime(long _timeInterval) {
    int counter;
    for (int i = 0; i < READINGS_ARRAY_SIZE; i++) { 
        if(timeStamps[0]-timeStamps[i] < _timeInterval) { counter++; }
        else { break; }
    }
    return counter;
}


void gestVolUpDown() {
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
}

