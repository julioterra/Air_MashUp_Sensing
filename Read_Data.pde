void addNewTime(unsigned long newVal) {
  for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { timeStamps[i] = timeStamps[i-1]; }
  timeStamps[0] = newVal;
}


void addNewReading(int newVal) {
  for(int i = READINGS_ARRAY_SIZE-1; i > 0; i--) { proxVals[i] = proxVals[i-1]; }
  if (newVal > 120 && newVal < 520) {
      proxVals[0] = 400 - (newVal - 120);
  } else if (newVal < 120 || newVal > 520) { proxVals[0] = -1; }
}

