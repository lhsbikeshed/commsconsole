

public class ConsoleAudio {

  Minim minim;
  Hashtable<String, AudioPlayer> audioList;

  public boolean muteBeeps = false;
  //tone generation
  AudioOutput toneOutput;
  Oscil fm;
  Oscil wave;
  
  Oscil dialWave = new Oscil(440, 0.8, Waves.SINE);
  //AudioOutput dialOutput;

  AudioPlayer[] beepList = new AudioPlayer[4];

  public ConsoleAudio(Minim minim) {
    this.minim = minim;
    loadSounds();

   
  }



  private void loadSounds() {
    //load sounds from soundlist.cfg
    audioList = new Hashtable<String, AudioPlayer>();
    String lines[] = loadStrings("audio/soundlist.cfg");
    println("Loading " + lines.length + " SFX");
    for (int i = 0 ; i < lines.length; i++) {
      String[] parts = lines[i].split("=");
      if (parts.length == 2 && !parts[0].startsWith("#")) {
        println("loading: " + parts[1] + " as " + parts[0]);
        AudioPlayer s = minim.loadFile("audio/" + parts[1], 512);
        //move to right channel
        //s.setPan(1.0f);
        audioList.put(parts[0], s);
        println(s.getControls());
      }
    }
    for (int i = 0; i < beepList.length; i++) {

      beepList[i] = minim.loadFile("audio/buttonBeep" + i + ".wav");
      beepList[i].setPan(1.0f);
    }
  }

  public void randomBeep() {
    if (muteBeeps) {
      return;
    }
    int rand = floor(random(beepList.length));
    while (beepList[rand].isPlaying ()) {
      rand = floor(random(beepList.length));
    }
    beepList[rand].rewind();
    beepList[rand].play();
  }
  
  public void playClipForce(String name, float pan){
    AudioPlayer c = audioList.get(name);
    if (c != null) {
      c.setPan(pan);
      c.rewind();
      c.play();
    } 
    else {
      println("ALERT: tried to play " + name + " but not found");
    }
  }
  /* does a given name exist? */
  public boolean clipExists(String name){
    if(audioList.get(name) != null){
      return true;
    } else {
      return false;
    }
  }

/* forces a sound to play even when ship os powered off*/
  public void playClipForce(String name){
    
    playClipForce(name, 1.0f);
  }

  public void playClip(String name) {
    
    playClipForce(name);
  }
  
  public void playClip(String name, float pan){
   
    playClipForce(name,pan);
  }
}

