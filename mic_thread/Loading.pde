void loadData() {
  // The thread is not completed
  finished = false;
  minim = new Minim(this);
  for (int idx = 0; idx < numSounds; idx++) {
    sounds[idx] = minim.loadFile(fileNames[idx] +".wav");
    println("file:" + fileNames[idx] + " - "+sounds[idx]);
  }

  for (int ind=0; ind <numImages; ind++) {
    images[ind] = loadImage(imageNames[ind] + ".png");
    println("file:" + imageNames[ind] + " - "+images[ind]);
  }
  in = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  fft = new ddf.minim.analysis.FFT(in.bufferSize(), in.sampleRate());
  fft.window(ddf.minim.analysis.FFT.NONE);
  FFTHist = new float[numBands][streamSize]; //history data to show
  for (int i = 0; i < modeArray.length; i++) { //Initialize all modes as null
    modeArray[i] = -1;
  }
    // s1= new checkSound();
  timer = CountdownTimerService.getNewCountdownTimer(this).configure(100, 7000); // time after which to remember to breath
  timer2 = CountdownTimerService.getNewCountdownTimer(this).configure(100, 20000); // how long to stand in each pose

  loadTrainARFF(dataset="MicTrain.arff"); //load a ARFF dataset
  loadModel(model="LinearSVC.model"); //load a pretrained model.

  // The thread is completed!
  finished = true;
  sounds[1].play();
}
