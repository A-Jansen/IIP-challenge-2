void sampleMic() {

  fft.forward(in.mix.toArray());

  float[] X = new float[numBands]; //Form a feature vector X;

  energyMax = 0; //reset the measurement of energySum
  for (int i = 0; i < HIGH_THLD-LOW_THLD; i++) {
    float x = fft.getBand(i+LOW_THLD);
    if (x>energyMax) energyMax = x;
    if (b_sampling == true) {
      if (x>X[i]) X[i] = x; //simple windowed max
      windowArray[i][sampleCnt-1] = x; //windowed statistics
    }
  }

  if (energyMax>energyThld) {
    if (b_sampling == false) { //if not sampling
      b_sampling = true; //do sampling
      sampleCnt = 0; //reset the counter
      for (int j = 0; j < numBands; j++) {
        X[j] = 0; //reset the feature vector
        for (int k = 0; k < windowSize; k++) {
          (windowArray[j])[k] = 0; //reset the window
        }
      }
    }
  } 

  if (b_sampling == true) {
    ++sampleCnt;
    if (sampleCnt == windowSize) {
      for (int j = 0; j < numBands; j++) {
        windowM[j] = Descriptive.mean(windowArray[j]); //mean
        windowSD[j] = Descriptive.std(windowArray[j], true); //standard deviation
        X[j] = max(windowArray[j]);
        
      }
      b_sampling = false;
      lastPredY = getPrediction(X);
      Y = lastPredY;
      Breath = Y.charAt(0);
      //println(Breath);
      double yID = getPredictionIndex(X);
  
      for (int n = 0; n < windowSize; n++) {
        appendArrayTail(modeArray, (float)yID);
      }
    }
  } else {
    appendArrayTail(modeArray, -1); //the class is null without mouse pressed.
  }
}
