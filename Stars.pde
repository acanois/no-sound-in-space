class Stars {
  float x, y, z;
  float dZ;
   
  Stars(float coordX, float coordY, float coordZ, float speedZ) {
    x  = coordX; 
    y  = coordY; 
    z  = coordZ; 
    dZ = speedZ;
  }
   
  void display() {
    translate(0, 0, 20);
    pushMatrix();
    pushStyle();
    strokeWeight(3);
    stroke(250 + z / depth, transparency);
    point(x, y, z);
    popStyle();
    popMatrix();
  }
}
