// ***** MIDI VOLUME FUNCTIONS ***** // 

// Function calls other two functions that actually handle two main types of gestures - on/off gesture, and smooth up/down gesture
void mixerChannel::updateVolumeMIDI() {
   if (!volumeOnOffMIDI()) volumeUpDownMIDI(); 
}


// function that converts up and down gesture values into a MIDI volume between 0 and 127 
void mixerChannel::volumeUpDownMIDI() {
    float gestureUpDown = float(gestUpDown());
    masterVolume += (gestureUpDown / 500.0) * TOP_VOLUME;
    if (masterVolume > TOP_VOLUME) masterVolume = TOP_VOLUME;
    else if (masterVolume < 0) masterVolume = 0;
}

// function that converts that converts on and off shift values into a MIDI value between 0 and 127 
boolean mixerChannel::volumeOnOffMIDI(){
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



// ***** BPM CAPTURE FUNCTIONS *****//


// ***** CONTROL LASER FUNCTIONS ***** //

// function that enables the laser to be turned on and off
void mixerChannel::controlLaser(int pinNumber, boolean laserOn) {
   pinMode(pinNumber, OUTPUT);
   if (laserOn) digitalWrite(pinNumber, HIGH); 
   else digitalWrite(pinNumber, LOW);  
}



