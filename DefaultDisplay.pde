public class DefaultDisplay implements Display {

  PImage bgImage, evacImage;
  String dialFreq = "";
  String dialDisplay = "_____Hz";



  int currentState = CallState.WAITING;
  long dialTime = 0;
  CamComponent cam;

  public DefaultDisplay() {
    bgImage = loadImage("idlebg.png");
    evacImage = loadImage("evacAlert.png");
  }

  public void setCamComponent(CamComponent c) {
    cam = c;
  }


  public void start() {
  }
  public void stop() {
  }

  public void draw() {
    image(bgImage, 0, 0, width, height);
    textFont(font, 32);
    String s = "";
    s += dialFreq;
    s+= "Hz";
    text(s, 725, 627);


    if (currentState == CallState.DIALLING) {
      if (dialTime + 5000 > millis()) {
        textFont(font, 24);
        text("WAITING FOR RESPONSE..", 446, 696);
        //alert the modconsole that a call is coming through
        noFill();
        strokeWeight(3);
        stroke(255, 255, 0);
        float sizeMod = map(millis() % 1000, 0, 1000, 0, 1.0);
        int numBands = 3;
        int baseRadius = 100;
        int gap = 50;
        int maxRad = gap * numBands;

        for (int i = 0; i < numBands; i++) {


          int newRad = (int)(300 * sizeMod) + i * gap;
          newRad = baseRadius + newRad % maxRad;
          int alpha = (int)map(newRad, baseRadius, baseRadius + maxRad, 255, 0);
          stroke(255, 255, 0, alpha);

          arc(209, 647, newRad, newRad, radians(-30), radians(30));
          arc(209, 647, newRad, newRad, radians(-210), radians(-150));
        }
      } 
      else if (dialTime + 10000 > millis()) {
        text("NO RESPONSE", 446, 696);
      } 
      else if (dialTime + 12000 > millis()) {
        dialFreq = "";
        currentState = CallState.WAITING;
      }
    }

    if (countdownRunning) {
      if (globalBlinker) {
        image(evacImage, 25, 160);
      }
      long t = countdownDuration - millis() - countdownStartTime;
      long min = (t / 1000 / 60);
      if(min < 0){
        min = 0;
      }
      String minString = "" + min;
      long sec = (t / 1000) % 60;
      String secString = "" + sec;
      if(sec == 0){
        secString = "00";
      } else if(sec < 10){
        secString = "0" + secString;
      }
      textFont(font, 96);
      text(minString + ":" + secString, 331, 376);
    }
  }
  //for future silliness
  public void answer() {
  }

  public void hangup() {
  }

  public void dialThatShit() {
    currentState = CallState.DIALLING;
    dialTime = millis();
    OscMessage m = new OscMessage("/display/captain/dialRequest");
    m.add(dialFreq);
    oscP5.flush(m, myRemoteLocation);
    println("send diaing req...");
  }

  public void oscMessage(OscMessage theOscMessage) {
  }
  public void serialMessage(SerialEvent s) {
    if (s.eventName.equals("KEY")) {
      if (s.rawData >= '0' && s.rawData <= '9') {
        if (dialFreq.length() < 5) {
          dialFreq += s.data;
        } 
        else {
          dialFreq = "";
        }
      } 
      else if (s.rawData == 'h') {  //dial button
        dialThatShit();
      }
    }
  }
}

public static class CallState {
  public static final int WAITING = 0;
  public static final int DIALLING = 1;
  public static final int NO_REPLY = 2;
  public static final int CONNECTING = 3;
};

