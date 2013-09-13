

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

