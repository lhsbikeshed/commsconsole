public class VideoPlayer implements Display {




  PApplet parent;

  VideoWrapper movie;
  

  public VideoPlayer(PApplet parent) {
    this.parent = parent;
    movie = new WindowsVideoWrapper(parent);
    
  }

  public void start() {
  
  }

  public void stop() {
   
  }

  public void draw() {
    
     fill(0,0,0);
     rect(0,0,width,height);
     
      image(movie.getImage(), 0,0, parent.width, parent.height);
    movie.update();
   
    
  }
  
  public boolean isPlaying(){
    if(movie != null){
      return movie.isPlaying();
    } else {
      return false;
    }
  }

  public void playVideo(String name){
    println("playing movie: " + name);
    movie.loadFile(name);
    movie.play();
  }
  
   


  public void oscMessage(OscMessage msg) {
    
  }

  public void serialMessage(SerialEvent s) {
  }
}
