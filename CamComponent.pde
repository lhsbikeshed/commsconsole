/* run the camera, add noise etc
 * shared amongst all displays
 */
public class CamComponent {


  GSCapture cam;
  // Capture cam;
  int numPixels;
  int[] backgroundPixels;
  PImage displayImage;
  PApplet parent;
  
  
  long lastKeepAlive = 0;
  boolean inCall = false;
  
   float videoNoiseLevel = 10.0f;

  PVector pos, size;
  
  boolean movieMode = false;
  GSMovie movieFile;

  public CamComponent(PApplet parent) {
    this.parent = parent;
    if(onLinux){
      cam = new GSCapture(parent, 320, 240, "v4l2src", "/dev/video0", 30);
    } else {
      cam = new GSCapture(parent, 320, 240, "BisonCam, NB Pro");
    }
    cam.start();

    numPixels = cam.width * cam.height;
    backgroundPixels = new int[numPixels];
    //loadPixels();

    displayImage = createImage(320, 240, RGB);
    pos = new PVector(0,0);
    size = new PVector(width, height);
  }

  public void draw() {
    if (lastKeepAlive + 500 < millis()) {
      OscMessage m = new OscMessage("/display/captain/inCall");
      oscP5.flush(m, myRemoteLocation);
      lastKeepAlive = millis();
    }

    if(movieMode){
      doMovie();
    } else {
      doCamera();
    }
  
  }
  
  public void doMovie(){
    if(movieFile == null){
      return;
    }
    if(movieFile.available()){
      movieFile.read();
    }
    image(movieFile, 0,0, parent.width, parent.height);
   
  }
  
  public void doCamera(){
    if (cam.available()) {
      cam.read();
      //stutter the image randomly
      videoNoiseLevel = (int)map(shipState.hullState, 0, 100, 15, 2);
      if (random(100) < videoNoiseLevel ) {
        image(displayImage, 0, random(10) - 5, parent.width, parent.height);
        return;
      }

      displayImage.loadPixels();
      //video.read(); // Read a new video frame
      cam.loadPixels(); // Make the pixels of video available

      for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...

        color currColor = cam.pixels[i];

        displayImage.pixels[i] = currColor;
        
        //fuck with it
        if (random(100) < videoNoiseLevel / 10.0f) {
          displayImage.pixels[i] = color(255, 255, 255);
        }
      }
      //fuck up a row

      int randomRows = (int)random(videoNoiseLevel * 2.0);
      for (int r = 0; r < randomRows; r++) {
        int rSrc = (int)random(230);
        int rDst = (int)random(230);
        arrayCopy(displayImage.pixels, rSrc * 320, displayImage.pixels, rDst * 320, 320 * 10);
      }

      displayImage.updatePixels();


      image(displayImage, pos.x, pos.y, size.x, size.y);
    } 
    else {//if not cam data then just show the last frame to prevent flickering
      image(displayImage, pos.x, pos.y, size.x, size.y);
    }
  }
  
  public void useCamera(){
    movieMode = false;
    println("using camera");
  }
  
  public void setMovie(String name){
    if(movieFile != null){
      movieFile.dispose();
    }
    movieFile = new GSMovie(parent, name);
    println("queued movie: " + name);
  }
  
  public void stopMovie(){
    if(movieFile != null){
      movieFile.stop();
    }
  }
  
  public void playMovie(){
    
    movieMode = true;
    if(movieFile != null){
      movieFile.play();
    }
  }
    

  public void setNoiseLevel(int noise) {
      videoNoiseLevel = noise;
  }
}

