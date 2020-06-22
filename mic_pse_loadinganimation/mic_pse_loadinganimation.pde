// loading animation adapted from https://www.openprocessing.org/sketch/627799

import ddf.minim.analysis.*;
import ddf.minim.*;
import com.dhchoi.*;

import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;

// Variables to change:

int timeNoBreath = 10000; // ms
int timePose = 20000; //ms

// Code to change when using the predictor in python:
// Guess is the guess from the SVM
// Comment all code in the tab keyboard!
String guess; 

// This will keep track of whether the thread is finished
boolean finished = false;

// Booleans used to play correct posture sound only once
boolean correct1 = false;
boolean correct2 = false;
boolean correct3 = false;
boolean correct4 = false;
boolean correct5 = false;



CountdownTimer timer;
CountdownTimer timer2;
String timerCallbackInfo = "";

Minim minim;
AudioInput in;
AudioOutput out;
ddf.minim.analysis.FFT fft;

// Import audio
String [] fileNames= {"Forget-breath", "Pose-5", "Pose-6", "Pose-7", "Postere--breathing", "Watch-posture"};
int numSounds = fileNames.length;
AudioPlayer [] sounds = new AudioPlayer[numSounds];
int idx;

// Import the images of the correct poses
String [] imageNames = {"plank", "up", "down"};
int numImages = imageNames.length;
PImage [] images = new PImage[numImages];
int ind;
int curImage=0;

// Import the images of the wrong poses with corrections
String [] wrongFiles = {"plank_bol", "plank_hol", "up_wrong", "down_bol", "down_hol"};
int numWImages = wrongFiles.length;
PImage [] wrongImages = new PImage[numWImages];
int wrongPose;


// The list with all possible poses, names should match with the name Python sends as prediction
String poses []= {"Chaturanga", "Chaturanga_bol", "Chaturanga_hol", "Urdhva", "Urdhva_wrong", "Svanasana", "Svanasana_bol", "Svanasana_hol"};

boolean correctPose= true;


int streamSize = 500;
float sampleRate = 44100/5;
int numBins = 1025;
int bufferSize = (numBins-1)*2;
//FFT parameters
float[][] FFTHist;
final int LOW_THLD = 1; //low threshold of band-pass frequencies
final int HIGH_THLD = 200; //high threshold of band-pass frequencies 
int numBands = HIGH_THLD-LOW_THLD+1; //number of feature
float[] modeArray = new float[streamSize]; //classification to show
float[] thldArray = new float[streamSize]; //diff calculation: substract

//segmentation parameters
float energyMax = 0;
float energyThld = 0;
float[] energyHist = new float[streamSize]; //history data to show//segmentation parameters

//window
int windowSize = 3; //The size of data window
float[][] windowArray = new float[numBands][windowSize]; //data window collection
boolean b_sampling = false; //flag to keep data collection non-preemptive
int sampleCnt = 0; //counter of samples

//Statistical Features
float[] windowM = new float[numBands]; //mean
float[] windowSD = new float[numBands]; //standard deviation

//Save
Table csvData;
boolean b_saveCSV = false;
String dataSetName = "MicTrain"; 
String[] attrNames;
boolean[] attrIsNominal;
int labelIndex = 0;

String Y;
String lastPredY = "";
char Breath;

// loading
int num = 20;
float theta;
int maxFrameCount = 120;
float t;

void setDataType() {
  attrNames =  new String[numBands+1];
  attrIsNominal = new boolean[numBands+1];
  for (int j = 0; j < numBands; j++) {
    attrNames[j] = "f_"+j;
    attrIsNominal[j] = false;
  }
  attrNames[numBands] = "label";
  attrIsNominal[numBands] = true;
}


void setup()
{
  size(800, 450, P2D);


  rectMode(CENTER);
  noStroke();
  noFill();
  smooth();

  thread("loadData");
}

void draw() {
  JSONArray json = loadJSONArray("http://127.0.0.1:5000/poses");
  guess = json.getJSONObject(0).getString("name");
  //image(images[3], 0, 0, width, height);
  if (!finished) {
    background(255);
    //fill(255);
    textSize(32);
    textAlign(CENTER);
    fill(0,104,55);
    text("Loading", width/2, height/2);
    text("Citta Yoga", 100, 60);
   

    t = (float)frameCount/maxFrameCount;
    theta = TWO_PI*t;
    translate(width/2, height/2);
    pushMatrix();
    rotate(theta/num);

    for (int i=0; i<num; i++) {

      pushMatrix();
      float offSet = TWO_PI/num*i;
      rotate(offSet);
      float sz2 = map(sin(-theta+offSet), -1, 1, 5, 30);
      float x2 = 110;
      //stroke(255);
      //fill(255);
      ellipse(x2, 0, sz2, sz2);
      //fill(#182A67);
      ellipse(x2, 0, sz2*.5, sz2*.5);

      popMatrix();
    }
    popMatrix();
  } else {

    if (correctPose) {
      image(images[curImage], 0, 0, width, height);
    } else {
      image(wrongImages[wrongPose], 0, 0, width, height);
    }
    showInfo("Prediction: "+Y, 520+20, 20, 16);
    //background(255);
    thread("sampleMic");
    thread("updatePose");
    //thread("playInstruction");

    //image(Phalakasana_hol, 0, 0, width, height);

    //println(s1.checkSoundPlaying());
  }
}

void onFinishEvent(CountdownTimer t) {
  if (t == timer) {
    timerCallbackInfo = "[finished]";
    if (testPlay() == false ) {
      sounds[0].rewind();
      sounds[0].play();
      //println(s1.checkSoundPlaying());
    }
    //timer.stop();
  }
  if (t==timer2) {
    CountdownTimerService.getCountdownTimerForId(1).reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
    correctPose = true;
    if (curImage < numImages-1) {
      println(curImage);
      curImage= curImage +1;
      thread("playInstruction");
      println("after"+ curImage);
    } else if (curImage==2) {
      curImage= 0;
      correct1=false;
      correct2=false;
      correct3=false;
      correct4=false;
      correct5=false;
      thread("playInstruction");
    }
  }
}


void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {
  timerCallbackInfo = "[tick] - timeLeft: " + timeLeftUntilFinish + "ms";
}




void stop()
{
  // always close Minim audio classes when you finish with them
  out.close();
  in.close();
  minim.stop();
  super.stop();
}
