// Function that identifies gestures to turn on and off the sound of channel
// returns false if it is paused (due to a gesture having recently been captured)
boolean mixerChannel::gestOnOff() {
      int timeCounter = 0;    // counter that identifies how many readings fit within the gesture interval time
      int onCounter = 0;      // counter that identifies how many readings support an on gesture
      int offCounter = 0;     // counter that identifies how many readings support an off gesture
      gestOn = false;         // boolean variable set to true if ON gesture detected
      gestOff = false;        // boolean variable set to false if OFF gesture detected
      
      // check that an on and off gesture has not been recorded recently within the pause timeframe
      if (millis() - gestOnOff_LastTime > gestOnOff_PauseInterval) {
    
          // check how many readings fall within the time interval to capture a start/stop gesture
          timeCounter = readingsInSequenceTime(gestOnOff_SequenceTime);
        
          int lookback = 8;
          int counterMin = 4;
          if (rawReadings[0] > 0 && rawReadings[lookback] > 0) {
          int fullDelta = rawReadings[0] - rawReadings[lookback];

          if(fullDelta > gestOnOff_FullDelta || fullDelta < (gestOnOff_FullDelta * -1)) {
              for (int j = 0; j < lookback; j++) { 
                  int gradientDelta = 0;
                  if(rawReadings[j] > 0 && rawReadings[j+1] > 0) { 
                      gradientDelta = rawReadings[j] - rawReadings[j+1];
                      if(gradientDelta > 0 && gradientDelta < gestOnOff_GradientDelta && fullDelta > 0) {
                          onCounter++; 
                        Serial.println();
                        Serial.print(" counter ");
                        Serial.print(onCounter);
                        Serial.print(" gradientDelta ");
                        Serial.print(gradientDelta);
                        Serial.print(" fullDelta ");
                        Serial.print(fullDelta);
                        Serial.print(" readings ");
                        Serial.print(rawReadings[j]);
                        Serial.print(" new readings ");
                        Serial.println(rawReadings[0]);
                      } else if(gradientDelta < 0 && gradientDelta > (gestOnOff_GradientDelta * -1) && fullDelta < 0) {
                          offCounter++; 
                        Serial.println();
                        Serial.print(" counter ");
                        Serial.print(onCounter);
                        Serial.print(" gradientDelta ");
                        Serial.print(gradientDelta);
                        Serial.print(" fullDelta ");
                        Serial.print(fullDelta);
                        Serial.print(" readings ");
                        Serial.print(rawReadings[j]);
                        Serial.print(" new readings ");
                        Serial.println(rawReadings[0]);
                      } //else { break; }
                  }
              }
          } 
          }


            if (onCounter > counterMin) { 
              gestOn = true; 
//              Serial.println("TURN ON");      
              masterVolume = TOP_VOLUME;
              gestOnOff_LastTime = millis();
              return false;
            }


            if (offCounter > counterMin) { 
              gestOff = true; 
//              Serial.println("TURN OFF");      
              masterVolume = 0;
              gestOnOff_LastTime = millis();
              return false;
            }
      return true;
      } 
      return false; 
}


int mixerChannel::readingsInSequenceTime(long _timeInterval) {
    int counter;
    for (int i = 0; i < READINGS_ARRAY_SIZE; i++) { 
        if(timeStamps[0]-timeStamps[i] < _timeInterval) { counter++; }
        else { break; }
    }
    return counter;
}


void mixerChannel::gestVolUpDown() {
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

void mixerChannel::changeVolume(float _volChange) {
    masterVolume += (_volChange / 400.0) * TOP_VOLUME;
    if (masterVolume > TOP_VOLUME) masterVolume = TOP_VOLUME;
    else if (masterVolume < 0) masterVolume = 0;
}
