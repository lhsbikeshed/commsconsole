

public abstract class VideoWrapper {

  boolean isPlaying = false;
  long startTime = 0;
  PApplet parent;
  public VideoWrapper(PApplet parent) {
    this.parent = parent;
  }

  public abstract void loadFile(String file);
  public abstract void play();
  public abstract void stop();
  public abstract boolean isPlaying();

  public abstract void update();
  public abstract PImage getImage();
}


public class WindowsVideoWrapper extends VideoWrapper {

  Movie movie;
  
  public WindowsVideoWrapper(PApplet parent) {
    super(parent);
  }

  public void loadFile(String file) {
    movie = new Movie(parent, file);
  }

  public void play() {
    if(movie != null){
      movie.play();
      println("duration : " + movie.duration());
    }
    isPlaying = true;
    startTime = millis();
  }

  public void stop() {
    if(movie != null){
      movie.stop();
    } 
    isPlaying = false;
    
  }

  public void update() {
    if(isPlaying && millis() - startTime > movie.duration() * 1000){
      stop();
    }
  }

  public PImage getImage() {
    return (PImage)movie;
  }

  public boolean isPlaying() {
    return isPlaying;
  }
}

/*

public class LinuxVideoWrapper extends VideoWrapper {

  GSMovie movie;
  
  public WindowsVideoWrapper(PApplet parent) {
    super(parent);
  }

  public void loadFile(String file) {
    movie = new GSMovie(parent, file);
  }

  public void play() {
    if(movie != null){
      movie.play();
      println("duration : " + movie.duration());
    }
    isPlaying = true;
    startTime = millis();
  }

  public void stop() {
    if(movie != null){
      movie.stop();
    } 
    isPlaying = false;
    
  }

  public void update() {
    if(isPlaying && millis() - startTime > movie.duration() * 1000){
      stop();
    }
  }

  public PImage getImage() {
    return (PImage)movie;
  }

  public boolean isPlaying() {
    return isPlaying;
  }
}
*/
