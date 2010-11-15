// *** MIXER ELEMENT CONSTRUCTOR - VOLUME: initializes all of the variables of all mixer channel objects
MixerElement::MixerElement(int _mainPin, int _laserPin) {
    mainPin = _mainPin;
    laserPin = _laserPin;
    
    pinMode(laserPin, OUTPUT);
    controlLaser(true);
    
    // hand status related variables
    handActive = false;
    handStatusChange = false;
    handIntention = STOPPED;
    handIntentionPrevious = handIntention;

    // data input related variables
    newReading = 0;
    sensorRange = SENSOR_MAX - SENSOR_MIN;
    for (int i = 0; i < READINGS_ARRAY_SIZE; i++) rawReadings[i] = 0;
    for (int i = 0; i < PRE_READING_BUFFER_SIZE; i++) {
        preBuffer[i] = -1;
        transferBuffer[i] = -1;
    }   

    // gesture capture related variables
    gestOnOff_LastTime = millis(); 
    gestOn = false;
    gestOff = false;
    gestUpDown_Center = 0;
    gestUpDown_Shift = 0;

    // intialize VOLUME related variables
    masterVolume = 0;
    gestUpDown_Bandwidth = 40;
    gestUpDown_IgnoreRange = 70;

 } // *** END CONSTRUCTOR *** //


// *** MIXER ELEMENT CONSTRUCTOR - BPM: initializes all of the variables of all mixer channel objects
MixerElement::MixerElement(int _mainPin, int _laserPin, int _bpmBlinkPin) {
    mainPin = _mainPin;
    laserPin = _laserPin;

    pinMode(laserPin, OUTPUT);
    controlLaser(true);

    tapTempo = TapTempo();
    tapTempo.setBpmPins(_bpmBlinkPin);    

    // hand status related variables
    handActive = false;
    handStatusChange = false;
    handIntention = STOPPED;
    handIntentionPrevious = handIntention;

    // data input related variables
    newReading = 0;
    sensorRange = SENSOR_MAX - SENSOR_MIN;
    for (int i = 0; i < READINGS_ARRAY_SIZE; i++) rawReadings[i] = 0;
    for (int i = 0; i < PRE_READING_BUFFER_SIZE; i++) {
        preBuffer[i] = -1;
        transferBuffer[i] = -1;
    }   

    // gesture capture related variables
    gestOnOff_LastTime = millis(); 
    gestOn = false;
    gestOff = false;
    gestUpDown_Center = 0;
    gestUpDown_Shift = 0;

    // intialize VOLUME related variables
    masterVolume = 0;
    gestUpDown_Bandwidth = 30;
    gestUpDown_IgnoreRange = 250;

}

