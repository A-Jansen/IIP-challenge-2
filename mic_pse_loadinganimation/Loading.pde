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
  
   for (int i=0; i <numWImages; i++) {
    wrongImages[i] = loadImage(wrongFiles[i] + ".png");
    println("file:" + wrongFiles[i] + " - "+ wrongImages[i]);
  }

  //Phalakasana_hol= loadImage("plank_hol.png");
  //Phalakasana_bol= loadImage("plank_bol.png");
  //Chaturanga_bad= loadImage("up_wrong.png");
  //Svanasana_bol = loadImage("down_bol.png");
  //Svanasana_hol = loadImage("down_hol.png");


  in = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  fft = new ddf.minim.analysis.FFT(in.bufferSize(), in.sampleRate());
  fft.window(ddf.minim.analysis.FFT.NONE);
  FFTHist = new float[numBands][streamSize]; //history data to show
  for (int i = 0; i < modeArray.length; i++) { //Initialize all modes as null
    modeArray[i] = -1;
  }
  // s1= new checkSound();
  timer = CountdownTimerService.getNewCountdownTimer(this).configure(100, timeNoBreath); // time after which to remember to breath
  timer2 = CountdownTimerService.getNewCountdownTimer(this).configure(100, timePose); // how long to stand in each pose

  loadTrainARFF(dataset="MicTrain.arff"); //load a ARFF dataset
  loadModel(model="LinearSVC.model"); //load a pretrained model.

  // The thread is completed!
  finished = true;
  sounds[1].play();
}
