

public class AudioDisplay implements Display {

 



  int nextScreen = 0;
  PImage backgroundImage, callingImage;

 
  long callTime = 0;
  boolean calling = false;
  int nextDisplay = 0;

  

  PApplet parent;

  public AudioDisplay(PApplet parent) {
    this.parent = parent;

    callingImage = loadImage("incomingcall.png");
    backgroundImage = loadImage("audioBackground.png");

  

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
    
      image(backgroundImage, 0, 0, width, height);
      
      
      stroke(255,255,0);
      strokeWeight(2);
      line(160, 320, 880, 320);
      noStroke();
      int w =720;
      int num = 20;
      for(int i = 0; i < num; i++){
        int h =(int)( sin(millis() / 500.0f + i * 0.2f ) * 100 );
        
        fill(i * (255 / 20));
        
        rect(160 + w / num * i, 320, w / num, h);
        
        
      }
      
    }
    
  }




  public void oscMessage(OscMessage theOscMessage) {
   
  }

  public void serialMessage(SerialEvent s) {
  }
}
