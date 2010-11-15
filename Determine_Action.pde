// ***** MIDI VOLUME FUNCTIONS ***** // 

// Function calls other two functions that actually handle two main types of gestures - on/off gesture, and smooth up/down gesture
void MixerElement::updateVolumeMIDI() {
   if (!volumeOnOffMIDI()) volumeUpDownMIDI(); 
}


// function that converts up and down gesture values into a MIDI volume between 0 and 127 
void MixerElement::volumeUpDownMIDI() {
    float gestureUpDown = float(gestUpDown());
    masterVolume += (gestureUpDown / 500.0) * TOP_VOLUME;
    if (masterVolume > TOP_VOLUME) masterVolume = TOP_VOLUME;
    else if (masterVolume < 0) masterVolume = 0;
}

// function that converts that converts on and off shift values into a MIDI value between 0 and 127 
boolean MixerElement::volumeOnOffMIDI(){
   int gestureOnOff = gestOnOff();
   if(gestureOnOff == GEST_ON) {
         masterVolume = TOP_VOLUME;
         return true;
    } else if(gestureOnOff == GEST_OFF) {
         masterVolume = 0;
         return true;
    }
    return false; 
 }

void MixerElement::printMIDIVolume() {
  Serial.print(int(masterVolume));
  Serial.print(" ");  
}


// ***** BPM FUNCTIONS *****//

void MixerElement::captureTempo() {
  gestUpDown();
  tapTempo.catchTap(handIntention);
  tapTempo.setTempo();
  tapTempo.bpmBlink();
}

void MixerElement::printBPM() {
  Serial.print(tapTempo.bpm);
  Serial.print(" ");  
}


// ***** CONTROL LASER FUNCTIONS ***** //

// function that enables the laser to be turned on and off
void MixerElement::controlLaser(boolean laserOn) {
   if (laserOn) digitalWrite(laserPin, HIGH); 
   else digitalWrite(laserPin, LOW);  
}



