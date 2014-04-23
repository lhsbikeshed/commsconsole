public class DefaultDisplay implements Display {

  PImage bgImage;
  String dialFreq = "";
  String dialDisplay = "_____Hz";



  int currentState = CallState.WAITING;
  long dialTime = 0;

  public DefaultDisplay() {
    bgImage = loadImage("hold.png");
  }


  public void start() {
  }
  public void stop() {
  }

  public void draw() {
    image(bgImage, 190, 0, bgImage.width * 2, bgImage.height*2);
    textFont(font, 48);
    String s = "Enter freq: ";
    s += dialFreq + dialDisplay.substring(dialFreq.length(), dialDisplay.length());
    text(s, 88, 518);

    if (currentState == CallState.DIALLING) {
      if (dialTime + 5000 > millis()) {
        text("WAITING FOR RESPONSE..", 52, 596);
        //alert the modconsole that a call is coming through
        
      } 
      else if (dialTime + 7000 > millis()) {
        text("NO RESPONSE", 52, 596);
        
      }
    }
  }

  public void dialThatShit() {
    currentState = CallState.DIALLING;
    dialTime = millis();
    OscMessage m = new OscMessage("/display/captain/dialRequest");
    m.add(dialFreq);
    oscP5.flush(m, myRemoteLocation);
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
      else if (s.rawData == 'K') {  //dial button
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

