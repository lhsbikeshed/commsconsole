import processing.video.*;

import processing.serial.*;

import oscP5.*;
import netP5.*;

import java.util.*;
import processing.video.*;


VideoDisplay videoDisplay;
DefaultDisplay defaultDisplay;
BootDisplay bootDisplay;
DestructDisplay destructDisplay;


OscP5 oscP5;
String serverIP = "10.0.0.100";
NetAddress  myRemoteLocation = new NetAddress(serverIP, 12000);

int damageTimer = -1000;
PImage noiseImage;

boolean poweredOn = false;
boolean poweringOn = false;
boolean areWeDead = false;
String deathText = "";
PFont font;

//serial stuff
String buffer = "";
int bufPtr = 0;
boolean serialEnabled = false;
Serial serialPort;  

//screens 
Hashtable<String, Display> displayMap = new Hashtable<String, Display>();
Display currentScreen;


void setup() {
  size(1024, 768, P2D);
  frameRate(30);
  videoDisplay = new VideoDisplay(this); 
  videoDisplay.setBg(0);
  defaultDisplay = new DefaultDisplay();
  destructDisplay = new DestructDisplay();

  displayMap.put("idleDisplay", defaultDisplay);
  displayMap.put("selfdestruct", destructDisplay);
  displayMap.put("videoDisplay", videoDisplay);
  currentScreen = defaultDisplay;

  // bootDisplay = new BootDisplay();
  font = loadFont("HanzelExtendedNormal-48.vlw");


  oscP5 = new OscP5(this, "10.0.0.3", 12003);
  noiseImage = loadImage("noise.png");
  if (serialEnabled) {
    serialPort = new Serial(this, "/dev/ttyUSB0", 9600);
  }

  OscMessage myMessage = new OscMessage("/game/Hello/CommStation");  
  oscP5.send(myMessage, myRemoteLocation);
}


void processSerial(String s) {
  String[] params = s.split(":");
  String cmd = params[0];
  if (cmd.equals("i") ) {      //disk inserted but its not correct
    OscMessage msg = new OscMessage("/scene/nebula/diskInsert");
    msg.add(0);
    oscP5.flush(msg, myRemoteLocation);
  } 
  else if (cmd.equals("I")) {    //disk inserted and it was correct
    println("Disk good");
    OscMessage msg = new OscMessage("/scene/nebula/diskInsert");
    msg.add(1);
    oscP5.flush(msg, myRemoteLocation);
  }

  println("Received : " + s);
}

void draw() {
  background(0, 0, 0);

  //serial handling
  if (serialEnabled && serialPort.available() > 0) {
    char c = (char)serialPort.read();
    if (c == ',') {
      processSerial(buffer);
      buffer = "";
    } 
    else {
      buffer += c;
    }
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

void changeDisplay(Display d) {
  currentScreen.stop();
  currentScreen = d;
  currentScreen.start();
}


void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/system/reactor/stateUpdate")==true) {
    int state = theOscMessage.get(0).intValue();
    if (state == 0) {
      poweredOn = false;
      poweringOn = false;
      bootDisplay.stop();
      if (serialEnabled) {
        serialPort.write("p,");
      }
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
  } 
  else if (theOscMessage.checkAddrPattern("/game/reset") == true) {
    //reset the entire game
    currentScreen = defaultDisplay;
    poweredOn = false;
    poweringOn = false;
    areWeDead = false;
    if (serialEnabled) {
      serialPort.write("p,");
    }
  }  
  else if (theOscMessage.checkAddrPattern("/comms/powerState")==true) {

    if (theOscMessage.get(0).intValue() == 1) {
      poweredOn = true;
      poweringOn = false;
      bootDisplay.stop();
      if (serialEnabled) {
        serialPort.write("P,");
      }
    } 
    else {
      poweredOn = false;
      poweringOn = false;
      if (serialEnabled) {
        serialPort.write("p,");
      }
    }
  } 
  else if (theOscMessage.checkAddrPattern("/ship/damage")) {
    if (serialEnabled) {
      serialPort.write("d,");
    }
    damageTimer = millis();
  } 
  else {
    currentScreen.oscMessage(theOscMessage);
  }
}

