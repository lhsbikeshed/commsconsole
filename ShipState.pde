
public class ShipState {

  public int smartBombsLeft = 6;
  public boolean poweredOn = false;
  public boolean poweringOn = false ;
  public boolean areWeDead = false;
  public String deathText = "";
  public float hullState = 100.0f;

  public PVector shipPos = new PVector(0, 0, 0);
  public PVector shipRot = new PVector(0, 0, 0);
  public PVector shipVel = new PVector(0, 0, 0);


  public ShipState() {
  };

  public void resetState() {
  }
}
