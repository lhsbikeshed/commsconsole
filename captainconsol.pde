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

void setup() {
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

void draw() {
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
void mouseClicked(){
  println(mouseX + ":" + mouseY);
}
void oscEvent(OscMessage theOscMessage) {
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
  else if (theOscMessage.checkAddrPattern("/system/reactor/stateUpdate")==true) {
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

