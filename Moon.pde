// Moon class

class Moon {
  
  float moonPosX, moonPosZ;
  float moonRadX, moonRadZ;
  float moonSize;
  float moonTheta;
  float moonOrbitSpeed;
  float moonRotationY;
  float moonRotationSpeed;
  color moonColor;
  
  Moon(float moonRadX_, float moonRadZ_, float moonSize_, color moonColor_) { 
    moonRadX = moonRadX_;
    moonRadZ = moonRadZ_;
    moonSize = moonSize_;
    moonTheta = 0;
    moonOrbitSpeed = random(5.0, 10.0);
    moonRotationY = 0;
    moonRotationSpeed = random(0.3, 1);
    moonColor = moonColor_;  
  }
  
  void update() {
    moonTheta += moonOrbitSpeed;
    moonRotationY -= moonRotationSpeed;
  }
  
  void display() {
    moonPosX = moonRadX * cos(moonTheta);
    moonPosZ = moonRadZ * sin(moonTheta);
    translate(moonPosX, 0, moonPosZ);
    pushMatrix();
    stroke(moonColor);
    // stroke(155);
    fill(moonColor);
    sphereDetail(4);
    rotateY(90);
    rotateY(radians(-moonRotationY));
    sphere(moonSize);
    popMatrix();
    
    // OSC Sends for Moons
    for (int i = 0; i < 5; i++) {
    OscMessage moonI = new OscMessage("/moon" + i);
    moonI.add(moonPosX);
    moonI.add(moonPosZ);
    moonI.add(moonRadX);
    moonI.add(moonRadZ);
    moonI.add(moonSize);
    moonI.add(moonTheta);
    moonI.add(moonOrbitSpeed);
    moonI.add(moonRotationY);
    moonI.add(moonRotationSpeed);
    moonI.add(moonColor);
    oscP5.send(moonI, myRemoteLocation);
  }
  }
}
