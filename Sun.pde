// Sun

class Sun {
  // Sun properties
  float sunSize;
  float sunRotationY;
  float sunRotationSpeed;
  color sunColor;
  int zeroSun;
  float sBurstW, sBurstH;
  int burstRed, burstGreen, burstBlue;
  
  Sun() {
    // Initializes sun
    sunSize = 95;
    sunColor = color(218, 219, 0);
    sunRotationSpeed = random(0.5, 2.0);
    sunRotationY = 0;
    zeroSun = 1;
    sBurstW = 90;
    sBurstH = 60;
    burstRed = 255;
    burstGreen = 175;
    burstBlue = 0;
  }
  
  void display() {
    pushMatrix(); 
    translate(width/2, height/2);
    //fill(sunColor);
    stroke(255, 175, 0);
    sphereDetail(10);
    rotateX(90);
    sunRotationY -= sunRotationSpeed;
    rotateY(radians(-sunRotationY));
    sphere(sunSize);
    popMatrix();
    
    // OSC Sends for sun
    OscMessage sunn = new OscMessage("/sun");
    sunn.add(sunSize);
    sunn.add(sunRotationY);
    sunn.add(sunRotationSpeed);
    oscP5.send(sunn, myRemoteLocation);
  }
  
  void burst() {
    noFill();
    stroke(burstRed, burstGreen, burstBlue);
    if (sBurstW < width * 2) { 
      pushMatrix();
      pushStyle();
      strokeWeight(5);
      //translate(width/2, height/2);
      ellipseMode(CENTER);
      ellipse(width/2, height/2, sBurstW, sBurstH);
      sBurstW *= 1.015;
      sBurstH *= 1.015;
      burstRed -= 1;
      burstGreen -= 1;
      popStyle();
      popMatrix();
    } 
    if (sBurstW > 800) {
      sBurstW = 60;
      sBurstH = 90;
      burstRed = 255;
      burstGreen = 175;
      burstBlue = 0;
    }
    
    if (zeroSun == 0) {
      burst(); 
    }
    if (zeroSun == 1) {
      //sun.burst_initialize();
  }
      
  }
  
  void burst_initialize() {
    sBurstW = 60;
    sBurstH = 90;
    burstRed = 255;
    burstGreen = 175;
    burstBlue = 0;
  }
  
  void oscEvent(OscMessage theOscMessage) {
    // Sunburst
    if (theOscMessage.checkAddrPattern("/zeroSun") == true) {
      zeroSun = 0;
    }
    if (theOscMessage.checkAddrPattern("/oneSun") == true) {
      zeroSun = 1;
    }
    println("### received an osc message. with address pattern "+
          theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
  }
}
