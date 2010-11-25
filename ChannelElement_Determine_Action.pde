// ***** MIDI VOLUME FUNCTIONS ***** // 

// Function calls other two functions that actually handle two main types of gestures - on/off gesture, and smooth up/down gesture
void MixerElement::updateVolumeMIDI() {
   if (!volumeOnOffMIDI()) volumeUpDownMIDI(); 
}


// function that converts up and down gesture values into a MIDI volume between 0 and 127 
void MixerElement::volumeUpDownMIDI() {
    float gestureUpDown = gestUpDown();
    int lastMasterVolume = masterVolume;
    masterVolume += (gestureUpDown / 500) * TOP_VOLUME;
    if (masterVolume > TOP_VOLUME) masterVolume = TOP_VOLUME;
    else if (masterVolume < 0) masterVolume = 0;
    if(lastMasterVolume != int(masterVolume)) {
        newData = true;
    }
}

// function that converts that converts on and off shift values into a MIDI value between 0 and 127 
boolean MixerElement::volumeOnOffMIDI(){
   int gestureOnOff = gestOnOff();
   if(gestureOnOff == GEST_ON) {
         masterVolume = TOP_VOLUME;
         newData = true;
         return true;
    } else if(gestureOnOff == GEST_OFF) {
         masterVolume = 0;
         newData = true;
         return true;
    }
    return false; 
 }

void MixerElement::printMIDIVolume() {
  if (newData) {
      Serial.print(componentNumber);
      Serial.print(' ');  
      Serial.print(sensor_ID);
      Serial.print(' ');  
      Serial.print(int(masterVolume));
      Serial.println();  
      newData = false;
  }
}


// ***** BPM FUNCTIONS *****//

void MixerElement::captureTempoTap() {
  gestUpDown();
  newData = tapTempo.catchTap(handIntention);
  tapTempo.setTempo();
  tapTempo.bpmBlink();
}

void MixerElement::printBPM() {
    if (newData) {
      Serial.print(componentNumber);
      Serial.print(' ');  
      Serial.print(sensor_ID);
      Serial.print(' ');  
      Serial.print(tapTempo.bpm);
      Serial.print(" ");  
    }
}


// ***** CONTROL LASER FUNCTIONS ***** //

// function that enables the laser to be turned on and off
void MixerElement::controlLaser(boolean laserOn) {
//   if (laserOn) digitalWrite(laserPin, HIGH); 
//   else digitalWrite(laserPin, LOW);  
}



