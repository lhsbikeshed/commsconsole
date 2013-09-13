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
