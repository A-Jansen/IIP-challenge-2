void updatePose() {
  if (CountdownTimerService.getCountdownTimerForId(1).isRunning() == false) {
    CountdownTimerService.getCountdownTimerForId(1).start();
    
  }
  thread("breathingCorrection");
}




void playInstruction() {
  if (testPlay() == false) {
    sounds[curImage+1].rewind();
    sounds[curImage+1].play();
  }
  else {
    delay(sounds[0].length());
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
