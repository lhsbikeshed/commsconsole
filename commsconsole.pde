import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

//uncomment for linux
import codeanticode.gsvideo.*;

//uncomment for windows
//import processing.video.*;


import processing.serial.*;

import oscP5.*;
import netP5.*;

import java.util.*;
import java.awt.*;
import java.awt.image.BufferedImage;


boolean testMode = false;

VideoDisplay videoDisplay;
DefaultDisplay defaultDisplay;
BootDisplay bootDisplay;
DestructDisplay destructDisplay;


ConsoleAudio consoleAudio;
Minim minim;
CamComponent camComponent;

//track some of the ship state
ShipState shipState = new ShipState();


OscP5 oscP5;
String serverIP = "127.0.0.1";
NetAddress  myRemoteLocation;

int damageTimer = -1000;
PImage noiseImage;




boolean poweredOn = false;
boolean poweringOn = false;
boolean areWeDead = false;
String deathText = "";
PFont font;


long lastPanelChange = 0;

//serial stuff
String buffer = "";
int bufPtr = 0;
boolean serialEnabled = false;
Serial serialPort;  

//screens 
Hashtable<String, Display> displayMap = new Hashtable<String, Display>();
Display currentScreen;


//mission timer 
long countdownStartTime = 1000;
boolean countdownRunning = false;
long countdownDuration = 900000; //15 min default

boolean globalBlinker = false;
long blinkTime = 0;

void setup() {
  size(1024, 768, P2D);
  frameRate(30);

  //set up the camera component
  camComponent = new CamComponent(this);

  hideCursor();
  videoDisplay = new VideoDisplay(this); 
  videoDisplay.setCamComponent(camComponent);

  defaultDisplay = new DefaultDisplay();
  destructDisplay = new DestructDisplay();

  displayMap.put("idleDisplay", defaultDisplay);
  displayMap.put("selfdestruct", destructDisplay);
  displayMap.put("videoDisplay", videoDisplay);
  currentScreen = defaultDisplay;
  

  minim = new Minim(this);
  consoleAudio = new ConsoleAudio(minim);
  consoleAudio.loadSounds();
  // bootDisplay = new BootDisplay();
  font = loadFont("HanzelExtendedNormal-48.vlw");

  if (testMode) {
    oscP5 = new OscP5(this, "127.0.0.1", 12003);
    serverIP = "127.0.0.1";
    serialEnabled = false;
    poweredOn = true;
  } 
  else {

    oscP5 = new OscP5(this, "10.0.0.3", 12003);
    serialEnabled = true;
    poweredOn = false;
    serverIP = "10.0.0.100";
  }
  myRemoteLocation = new NetAddress(serverIP, 12000);
  noiseImage = loadImage("noise.png");
  if (serialEnabled) {

    serialPort = new Serial(this, "/dev/ttyUSB9", 9600);
    clearPanel();
  }

  hideCursor();

  OscMessage myMessage = new OscMessage("/game/Hello/CommStation");  
  oscP5.send(myMessage, myRemoteLocation);
}

void clearPanel() {
  if (serialEnabled) {
    serialPort.write(0);
    serialPort.write(0);
    serialPort.write(0);
    serialPort.write(0);
    serialPort.write(',');
  }
}


void processSerial(char s) {

  println("Received : " + s);
  if (poweredOn) {
    consoleAudio.randomBeep();
  }
  SerialEvent e = new SerialEvent();
  e.rawData = s;
  e.eventName = "KEY";
  e.data = "" + s;

  currentScreen.serialMessage(e);
}

void keyPressed() {
  processSerial(key);
}

void draw() {
  background(0, 0, 0);
  if (blinkTime + 750 < millis()) {
    blinkTime = millis();
    globalBlinker = ! globalBlinker;
  }
  //serial handling
  if (serialEnabled && serialPort.available() > 0) {
    char c = (char)serialPort.read();

    processSerial(c);
  }



  if (areWeDead) {
    fill(255, 255, 255);
    // textFont(font, 60);
    // text("YOU ARE DEAD", 50, 300);
    // textFont(font, 20);
    //int pos = (int)textWidth(deathText);
    //text(deathText, (width/2) - pos/2, 340);
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
        currentScreen.draw();

        if (lastPanelChange + 500 < millis()) {
          // println("in call");
          lastPanelChange = millis();
          String s = "";
          for (int i = 0; i < 4; i++) {
            char c = (char)random(255);
            if (serialEnabled) {
              serialPort.write(c);
            }
          } 
          if (serialEnabled) {
            serialPort.write(',');
          }
          
          
        }
        
      }
    }
  }

  if ( damageTimer + 1000 > millis()) {
    if (random(10) > 3) {
      image(noiseImage, 0, 0, width, height);
    }
  }
}
void mouseClicked() {
  println(mouseX + ":" + mouseY);
}


/* change visible screen, but only if its not the same as current one */
void changeDisplay(Display d) {
  if (d != currentScreen) {
    currentScreen.stop();
    currentScreen = d;
    currentScreen.start();
  }
}

void hideCursor() {
  BufferedImage cursorImg = new BufferedImage(16, 16, BufferedImage.TYPE_INT_ARGB);
  Cursor blankCursor = Toolkit.getDefaultToolkit().createCustomCursor(
  cursorImg, new Point(0, 0), "blank cursor");
  frame.setCursor(blankCursor);
}


void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/system/reactor/stateUpdate")==true) {
    int state = theOscMessage.get(0).intValue();
    if (state == 0) {
      poweredOn = false;
      poweringOn = false;
      bootDisplay.stop();
      clearPanel();
    } 
    else {


      poweredOn = true;
    }
  } 
  else if ( theOscMessage.checkAddrPattern("/clientscreen/CommsStation/changeTo") ) {
    String changeTo = theOscMessage.get(0).stringValue();
    try {
      Display d = displayMap.get(changeTo);
      println("found display for : " + changeTo);
      changeDisplay(d);
    } 
    catch(Exception e) {
      println("no display found for " + changeTo);
      changeDisplay(defaultDisplay);
    }
  }  


  else if (theOscMessage.checkAddrPattern("/scene/youaredead") == true) {
    //oh noes we died
    areWeDead = true;
    deathText = theOscMessage.get(0).stringValue();
    countdownRunning = false;
    clearPanel();
  } 
  else if (theOscMessage.checkAddrPattern("/game/reset") == true) {
    //reset the entire game
    currentScreen = defaultDisplay;
    poweredOn = false;
    poweringOn = false;
    areWeDead = false;
    countdownRunning = false;
    clearPanel();
  }  
  else if (theOscMessage.checkAddrPattern("/comms/powerState")==true) {

    if (theOscMessage.get(0).intValue() == 1) {
      poweredOn = true;
      poweringOn = false;
      bootDisplay.stop();
    } 
    else {
      poweredOn = false;
      poweringOn = false;
      clearPanel();
    }
  } 
  else if (theOscMessage.checkAddrPattern("/ship/damage")) {

    damageTimer = millis();
  } 
  else if (theOscMessage.checkAddrPattern("/ship/stats")==true) {


    shipState.hullState = theOscMessage.get(2).floatValue();
  } 
  else if (theOscMessage.checkAddrPattern("/scene/warzone/evacStart")) {
    countdownRunning = true;
    countdownStartTime = millis();
    countdownDuration = (long)theOscMessage.get(0).intValue();
  } 
  else {
    currentScreen.oscMessage(theOscMessage);
  }
}


