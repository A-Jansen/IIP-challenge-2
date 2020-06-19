void updatePose() {

  if (curImage==0 && (guess== poses[0] || guess ==poses[1] || guess== poses[2])) {
    startTimer();
    println("Start pose 0");
    if (guess== poses[1]) {
      correctPose= false;
      wrongPose=0;
      if (correct1 == false) {
        poseCorrection();
        correct1 = true;
      }
    } else if (guess == poses[2]) {
      correctPose= false;
      wrongPose=1;
      if (correct2 == false) {
        poseCorrection();
        correct2 = true;
      }
    } else if (guess == poses[0]) {
      correctPose= true;
    }
  } else if (curImage ==1 && (guess== poses[3] || guess == poses[4])) {
    startTimer();
    println("Start pose 1");
    if (guess == poses[4]) {
      correctPose= false;
      wrongPose=2;
      if (correct3 == false) {
        poseCorrection();
        correct3 = true;
      }
    } else if (guess == poses[3]) {
      correctPose= true;
    }
  } else if (curImage ==2 &&(guess== poses[5] || guess==poses[6] || guess == poses[7])) {
    startTimer();
    println("Start pose 2");
    if (guess == poses[6]) {
      correctPose= false;
      wrongPose=3;
      if (correct4 == false) {
        poseCorrection();
        correct4 = true;
      }
    } else if (guess == poses[7]) {
      correctPose= false;
      wrongPose=4;
      if (correct5 == false) {
        poseCorrection();
        correct5 = true;
      }
    } else if (guess == poses[5]) {
      correctPose= true;
    }
  }
  //thread("poseCorrection");
  thread("breathingCorrection");
}

void poseCorrection() {
  if (testPlay() == false) {
    sounds[5].rewind();
    sounds[5].play();
  } else if (sounds[0].isPlaying()) {
    delay(sounds[0].length());
    sounds[5].rewind();
    sounds[5].play();
  }
}

void startTimer() {
  if (CountdownTimerService.getCountdownTimerForId(1).isRunning() == false) {
    CountdownTimerService.getCountdownTimerForId(1).start();
  }
}


void playInstruction() {
  if (testPlay() == false) {
    sounds[curImage+1].rewind();
    sounds[curImage+1].play();
  } else if (sounds[0].isPlaying()) {
    delay(sounds[0].length());
    sounds[curImage+1].rewind();
    sounds[curImage+1].play();
  } else if (sounds[5].isPlaying()) {
    delay(sounds[5].length());
    sounds[curImage+1].rewind();
    sounds[curImage+1].play();
  }
}

boolean testPlay() {
  for (int i = 0; i < sounds.length; i++) {
    if (sounds[i].isPlaying()) {
      return true;
    } // end if
  } // end for
  return false;
} // end testPlay

void breathingCorrection() {

  if (Breath == 'A') {
    CountdownTimerService.getCountdownTimerForId(0).reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
    //println("Out");
  }
  if (Breath == 'B') {
    // println("In");
    if (CountdownTimerService.getCountdownTimerForId(0).isRunning() == false) {
      CountdownTimerService.getCountdownTimerForId(0).start();
    }
    // println(timerCallbackInfo);
  }
}
