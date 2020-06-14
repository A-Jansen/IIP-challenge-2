import ddf.minim.analysis.*;
import ddf.minim.*;
import com.dhchoi.*;

import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;

// This will keep track of whether the thread is finished
boolean finished = false;
// And how far along
float percent = 0;

CountdownTimer timer;
CountdownTimer timer2;
String timerCallbackInfo = "";

Minim minim;
AudioInput in;
AudioOutput out;
ddf.minim.analysis.FFT fft;

String [] fileNames= {"Forget-breath", "Pose-5", "Pose-6", "Pose-7"};
int numSounds = fileNames.length;
AudioPlayer [] sounds = new AudioPlayer[numSounds];
int idx;

String [] imageNames = {"plank", "up", "down"};
int numImages = imageNames.length;
PImage [] images = new PImage[numImages];
int ind;
int curImage=0;

//checkSound s1;

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
  // setup audio input

  thread("loadData");

}

void draw() {
  //image(images[3], 0, 0, width, height);
  if (!finished) {
    background(0);
    fill(255);
    textSize(32);
    textAlign(CENTER);
    fill(255);
    text("Loading", width/2, height/2);
  } else {


    background(255);
    thread("sampleMic");
    thread("updatePose");
    //thread("playInstruction");
    image(images[curImage], 0, 0, width, height);
    showInfo("Prediction: "+Y, 520+20, 20, 16);
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
    if (curImage < numImages-1) {
      println(curImage);
      curImage= curImage +1;
      thread("playInstruction");
      println("after"+ curImage);
    } else if (curImage==2) {
      curImage= 0;
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
