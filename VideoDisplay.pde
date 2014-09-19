//import codeanticode.gsvideo.*;
public interface Display {

  public void draw();
  public void oscMessage(OscMessage theOscMessage);
  public void serialMessage(SerialEvent s);
  public void start();
  public void stop();
}

public class SerialEvent {
  public char rawData;
  public String eventName;
  public String data;
  public SerialEvent() {
  }
}


public class VideoDisplay implements Display {

  //linux
  GSCapture cam;
  //windows Capture cam;
  int numPixels;
  int[] backgroundPixels;
  //  Capture video;




  int nextScreen = 0;
  PImage currentBackground;

  String[] bgList = new String[3];
  PImage[] bgImages = new PImage[3];


  int chromaColor;
  int threshLower, threshUpper;
  int thresh = 0;
  color keyColor = color(0, 0, 255);

  CamComponent camComponent;

  public int currentBg = 0;

  long callTime = 0;
  boolean calling = false;
  int nextDisplay = 0;

  PImage callingImage, displayImage;

  PApplet parent;

  public VideoDisplay(PApplet parent) {
    this.parent = parent;

    callingImage = loadImage("incomingcall.png");

    //println(Capture.list());
    //uncomment for linux
    cam = new GSCapture(parent, 320, 240, "v4l2src", "/dev/video0", 30);
    //uncomment for windows
    //cam = new Capture(parent, 320, 240);
    cam.start();
      
    numPixels = cam.width * cam.height;
    backgroundPixels = new int[numPixels];
    //loadPixels();


    //setup chromakey
    chromaColor = (int)hue(color(0, 128, 0));
    threshLower = 0;
    threshUpper = 0;

    bgList[0] = "incomingcall.png";
    bgList[1] = "test.png";
    bgList[2] = "test2.png";
    for (int i = 0; i < bgList.length; i++) {
      bgImages[i] = loadImage(bgList[i]);
      bgImages[i].loadPixels();
    }



    displayImage = createImage(320, 240, RGB);

  }

  public void start() {

    callTime = millis();
    calling = false;
    nextDisplay = 1;
    nextScreen = 1;
  
  }

  public void stop() {
   
  }

  public void draw() {
    
    

    if (callTime + 2000 > millis()) {
      image(callingImage, 0,0, width, height);
    } else {
    
      if (camComponent != null) {
        camComponent.draw();
      }
    }
    
  }


  public void setCamComponent(CamComponent c) {
    this.camComponent = c;
  }


  public void oscMessage(OscMessage theOscMessage) {
    //     if (theOscMessage.checkAddrPattern("/display/captain/setnoise") == true) {
    //      videoNoiseLevel = theOscMessage.get(0).floatValue();
    //    }
  }

  public void serialMessage(SerialEvent s) {
  }
}

