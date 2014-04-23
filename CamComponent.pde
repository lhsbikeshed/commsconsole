/* run the camera, add noise etc
 * shared amongst all displays
 */
public class CamComponent {


  GSCapture cam;
  //Capture cam;
  int numPixels;
  int[] backgroundPixels;
  PImage displayImage;
  PApplet parent;
  
  
  long lastKeepAlive = 0;
  boolean inCall = false;
  
   float videoNoiseLevel = 10.0f;

  public CamComponent(PApplet parent) {
    this.parent = parent;
    cam = new GSCapture(parent, 320, 240, "v4l2src", "/dev/video0", 30);
    //cam = new Capture(parent, 320, 240);
    cam.start();

    numPixels = cam.width * cam.height;
    backgroundPixels = new int[numPixels];
    //loadPixels();

    displayImage = createImage(320, 240, RGB);
  }

  public void draw() {
    if (lastKeepAlive + 500 < millis()) {
      OscMessage m = new OscMessage("/display/captain/inCall");
      oscP5.flush(m, myRemoteLocation);
      lastKeepAlive = millis();
    }

    if (cam.available()) {
      cam.read();
      //stutter the image randomly

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


      image(displayImage, 0, 0, parent.width, parent.height);
    } 
    else {//if not cam data then just show the last frame to prevent flickering
      image(displayImage, 0, 0, parent.width, parent.height);
    }
  }

  public void setNoiseLevel(int noise) {
      videoNoiseLevel = noise;
  }
}

