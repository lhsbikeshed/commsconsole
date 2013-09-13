import processing.core.*; 
import processing.xml.*; 

import oscP5.*; 
import netP5.*; 
import ddf.minim.signals.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.ugens.*; 
import java.awt.Frame; 
import java.awt.BorderLayout; 
import processing.video.*; 
import codeanticode.gsvideo.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class captainconsol extends PApplet {


















Display[] displayList = new Display[2];
int currentDisplay = 0;
VideoDisplay videoDisplay;
DefaultDisplay defaultDisplay;
BootDisplay bootDisplay;


OscP5 oscP5;


boolean poweredOn = false;
boolean poweringOn = false;
boolean areWeDead = false;
String deathText = "";
PFont font;

public void setup() {
  size(1024, 768, P2D);
  frameRate(30);
  videoDisplay = new VideoDisplay(this); 
  videoDisplay.setBg(0);
  defaultDisplay = new DefaultDisplay();
  displayList[0] = defaultDisplay;
  displayList[1] = videoDisplay;
  bootDisplay = new BootDisplay();
  font = loadFont("HanzelExtendedNormal-48.vlw");


  oscP5 = new OscP5(this, "10.0.0.3", 12003);
}

public void draw() {
  background(0, 0, 0);


  if (areWeDead) {
    fill(255, 255, 255);
    textFont(font, 60);
    text("YOU ARE DEAD", 50, 300);
    textFont(font, 20);
    int pos = (int)textWidth(deathText);
    text(deathText, (width/2) - pos/2, 340);
  } 
  else {

    if (areWeDead) {
      fill(255, 255, 255);
      textFont(font, 60);
      text("YOU ARE DEAD", 50, 300);
      textFont(font, 20);
      int pos = (int)textWidth(deathText);
      text(deathText, (width/2) - pos/2, 340);
    } 
    else {
      if (poweredOn) {
        displayList[currentDisplay].draw();
      } 
      else {
        if (poweringOn) {
          bootDisplay.draw();
          if (bootDisplay.isReady()) {
            poweredOn = true;
            poweringOn = false;
          }
        }
      }
    }
  }
}
public void mouseClicked(){
  println(mouseX + ":" + mouseY);
}
public void oscEvent(OscMessage theOscMessage) {
 // println(theOscMessage);
  
  if(theOscMessage.checkAddrPattern("/display/captain/incomingCall")==true) {
    displayList[currentDisplay].stop();
    currentDisplay = 1;
    displayList[currentDisplay].start();
    displayList[currentDisplay].oscMessage(theOscMessage);
  } else if(theOscMessage.checkAddrPattern("/display/captain/hangup")==true) {
    displayList[currentDisplay].oscMessage(theOscMessage);
    displayList[currentDisplay].stop();
    currentDisplay = 0;
    displayList[currentDisplay].start();
    
  
  }else if (theOscMessage.checkAddrPattern("/display/captain/change")==true) {
    displayList[currentDisplay].stop();
    currentDisplay = theOscMessage.get(0).intValue();
    displayList[currentDisplay].start();

    return;
  }
  else if (theOscMessage.checkAddrPattern("/reactor/state")==true) {
    int state = theOscMessage.get(0).intValue();
    if (state == 0) {
      poweredOn = false;
      poweringOn = false;
      bootDisplay.stop();
    } 
    else {


      if (!poweredOn ) {
        poweringOn = true;
        bootDisplay.start();
      }
    }
  } 
  else if (theOscMessage.checkAddrPattern("/scene/youaredead") == true) {
    //oh noes we died
    areWeDead = true;
    deathText = theOscMessage.get(0).stringValue();
  } 
  else if (theOscMessage.checkAddrPattern("/game/reset") == true) {
    //reset the entire game
    currentDisplay = 0;
    poweredOn = false;
    poweringOn = false;
    areWeDead = false;
    
  }  else if (theOscMessage.checkAddrPattern("/comms/powerState")==true) {
    
    if (theOscMessage.get(0).intValue() == 1) {
      poweredOn = true;
      poweringOn = false;
      bootDisplay.stop();
    } 
    else {
      poweredOn = false;
      poweringOn = false;
    }
  }
  else {
    displayList[currentDisplay].oscMessage(theOscMessage);
  }
}



public class BootDisplay implements Display {

  PImage bgImage;
  public  int bootCount = 0;
  PFont font;

  public BootDisplay() {
    font = loadFont("HanzelExtendedNormal-48.vlw");
    bgImage = loadImage("bootlogo.png");
  }


  public void start() {
    bootCount = 0;
  }
  public void stop() {
    bootCount = 0;
  }

  public boolean isReady() {
    return bootCount > 200 ? true : false;
  }

  public void draw() {
    //image(bgImage, 0,0,width,height);
    background(0, 0, 0);
    bootCount ++;
    if (bootCount < 100) {
      textFont(font, 10);
      fill(0, 255, 0);
      String dots = ".";
      for (int i = 0; i < bootCount / 10; i++) {
        dots += ".";
      }
      text("startup " + dots, 30, 30);
    } 
    else {
      fill(0, 0, 255);
      rect(353, 454, map(bootCount, 100, 400, 0, 330), 30);
      image(bgImage, 0, 0, width, height );
    }
  }

  public void oscMessage(OscMessage theOscMessage) {
  }

  public void serialEvent(String evt) {
  }

  public void keyPressed() {
  }
  public void keyReleased() {
  }
}

public class DefaultDisplay implements Display {
  
  PImage bgImage;
  
  public DefaultDisplay(){
    bgImage = loadImage("hold.png");
  }
  
  
  public void start(){}
  public void stop(){}

  public void draw(){
    image(bgImage, 0,0,width,height);
    
  }
  
  public void oscMessage(OscMessage theOscMessage){
   
  }

}

public interface Display {

  public void draw();
  public void oscMessage(OscMessage theOscMessage);
  public void start();
  public void stop();
}

public class VideoDisplay implements Display {
  

  GSCapture cam;
  int numPixels;
  int[] backgroundPixels;
//  Capture video;
  
  
  
  PImage currentBackground;

  String[] bgList = new String[3];
  PImage[] bgImages = new PImage[3];
  PImage displayImage;

  int chromaColor;
  int threshLower, threshUpper;
  int thresh = 0;
  int keyColor = color(0,0,255);
  
  
  float videoNoiseLevel = 0.0f;
  public int currentBg = 0;

  long callTime = 0;
  boolean calling = false;
  int nextDisplay = 0;
     

  //sound
  Minim minim;
  LiveInput input;
  AudioOutput output;
  WhiteNoise s;
  BitCrush b;
  Constant resLevel;
  Gain gainControl;
  long disableTime = 0;
  long disableDuration = 0;

  PApplet parent;

  public VideoDisplay(PApplet parent) {
    this.parent = parent;
    //println(Capture.list());
    cam = new GSCapture(parent, 320, 240, "v4l2src", "/dev/video0", 30);
  cam.start();
    //video = new Capture(parent, 640, 480);
    //video.start();  
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

    //saaaand
   // minim = new Minim(parent);
   // output = minim.getLineOut(Minim.MONO, 1024, 16000, 16);
   // input = new LiveInput( minim.getInputStream(output.getFormat().getChannels(), output.bufferSize(), output.sampleRate(), output.getFormat().getSampleSizeInBits()) );
//
    // input.enableMonitoring();
  //  s = new WhiteNoise(0.1);
    //output.addSignal(s);
  //  GranulateSteady grain = new GranulateSteady();
   // b = new BitCrush();
    // patch the input through the grain effect to the output
   // resLevel = new Constant(16);
   // resLevel.setConstant(16);
   // resLevel.patch(b.bitRes);
   // gainControl = new Gain(0);
    //input.patch(b).patch(gainControl).patch(output);
    
  }

  public void start() {
    
    callTime = 0;
    calling = false;
    nextDisplay = 0;
    setBg(0);
  }

  public void stop() {
    setBg(0);
  }

  public void draw() {
  
    if(callTime + 2000 < millis()){
      setBg(nextDisplay);
    }
    
    if (cam.available()) {
      cam.read();
      //stutter the image randomly
      //resLevel.setConstant(map(videoNoiseLevel, 0, 100, 14, 4) - 3);
      if (random(100) < videoNoiseLevel ) {
        image(displayImage, 0, random(10) - 5,800,600);
        disableTime = millis();
        disableDuration = (long)random(200);


        return;
      }

      if (disableTime + disableDuration < millis()) {
      }

      displayImage.loadPixels();
      //video.read(); // Read a new video frame
      cam.loadPixels(); // Make the pixels of video available

      for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...

        int currColor = cam.pixels[i];
        if (currentBg != 0) {
          
          if (abs(hue(currColor) - red(keyColor)) < thresh && abs(saturation(currColor) - blue(keyColor)) < green(keyColor)) {
          //if(abs(red(currColor) - red(keyColor)) < thresh && abs(green((int)threshLower) - green(keyColor)) < thresh && abs(blue((int)currColor) - blue(keyColor)) < thresh){
            displayImage.pixels[i] = bgImages[currentBg].pixels[i];
          }
          else {

            displayImage.pixels[i] = currColor;
          }
        } 
        else {
          displayImage.pixels[i] = bgImages[0].pixels[i];
        }
        //if (random(100) < videoNoiseLevel / 10.0f) {
        //  displayImage.pixels[i] = color(255, 255, 255);
        //}
      }
      //fuck up a row
      /*
      int randomRows = (int)random(videoNoiseLevel * 2.0);
      for (int r = 0; r < randomRows; r++) {
        int rSrc = (int)random(470);
        int rDst = (int)random(470);
        arrayCopy(displayImage.pixels, rSrc * 320, displayImage.pixels, rDst * 320, 320 * 10);
      }*/
      displayImage.updatePixels();
      image(displayImage, 0, 0,parent.width,parent.height);
      
    } else {//if not cam data then just show the last frame to prevent flickering
      image(displayImage,0,0,parent.width,parent.height);
    }
   
  }
  
  public void setBg(int bg) {
    currentBg = bg;
    if (bg == 0) {
      //gainControl.setValue(-60);
    } 
    else {
      //gainControl.setValue(0);
    }
  }
  public void oscMessage(OscMessage theOscMessage) {
    if (theOscMessage.checkAddrPattern("/display/captain/setbg")==true) {
     setBg(theOscMessage.get(0).intValue());
   } else if (theOscMessage.checkAddrPattern("/display/captain/setnoise") == true){
     videoNoiseLevel = theOscMessage.get(0).floatValue();
   } else if (theOscMessage.checkAddrPattern("/display/captain/chromaparams") == true){
     int r = theOscMessage.get(0).intValue(); //hue
     int g = theOscMessage.get(1).intValue(); //lowert
     int b = theOscMessage.get(2).intValue(); //lowert
     thresh = theOscMessage.get(3).intValue(); 
     keyColor = color(r,g,b);
     
   } else if(theOscMessage.checkAddrPattern("/display/captain/incomingCall")==true) {
     callTime = millis();
     calling = true;
     nextDisplay = theOscMessage.get(0).intValue();
     setBg(0);
   } else if(theOscMessage.checkAddrPattern("/display/captain/hangup") == true){
     setBg(0);
   }
     
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#000000", "--hide-stop", "captainconsol" });
  }
}
