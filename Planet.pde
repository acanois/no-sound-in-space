//// Planet Class

class Planet {
  float posX, posZ;  // X and Z position for planets
  float radX, radZ;  // X and Z orbit radii for planets
  float rotationY;   // Planet rotation
  float rotationSpeed;
  float diameter;    // Diameter of planet
  float theta;       // Angle of rotation
  float orbitspeed;  // Theta incrementer
  float pRed;
  float pBlue;
  float pGreen;
  color planetColor;
  color[] moonColor = new color[5];
  
  int zeroSun;

  // Emitter variables
  float emWidth, emHeight;
  float emAlpha;
  color emRed, emGreen, emBlue;

  Moon moon;

  Planet(float radX_, float radZ_, float diameter_, color planetColor_) {
    // Planet Color
    planetColor = planetColor_;
    // Initializing planet positions
    posX = 0;
    posZ = 0;
    // Initializing function parameters to planet radii
    radX = radX_;
    radZ = radZ_;
    rotationY = 0;
    // Initializing fuction diameter_ parameter to diameter variable
    diameter = diameter_;
    // Initialize angle of rotation to 0 degrees
    theta = 0;
    // Sets orbit speed to random value, so planets orbit at different speeds.
    orbitspeed = random(0.0025, 0.015);
    // Set color to random value for each planet when the program is run.
    rotationSpeed = random(0.3, 1.5);
    pRed = random(70, 255);
    pGreen = random(70, 255);
    pBlue = random(70, 255);
    
    // Initialize emitter
    emWidth = 250;
    emHeight = 250;
    emRed = emGreen = emBlue = 255;
    emAlpha = 255;
    
    moon = new Moon(65, 75, 15, planetColor);
  }

  void update() {
    theta += orbitspeed;
    rotationY -= rotationSpeed;
  }

  void display() {
    pushMatrix();

    // Set relative orbit point to center
    translate(width/2, height/2);

    // Sets orbital path
    posX = radX * sin(theta);
    posZ = radZ * cos(theta);

    //Render planets along orbital path
    translate(posX, posZ);
    sphereDetail(7);
    rotateX(90);
    rotateY(radians(-rotationY)); 
    // Rotates the spheres.  Move this to different point in draw(),
    // make everything go CRAY CRAY. 

    // Draws the planet
    stroke(planetColor);
    //fill(c);
    //fill(planetColor);
    sphere(diameter);
    noFill();
    stroke(255);
    rotateX(90);
    ellipse(0, 0, 130, 150);

    // Attaches a moon
    moon.display();
    popMatrix();
    
    // Sun Rays
    pushMatrix();
    translate(width/2, height/2);
    noFill();
    stroke(255, 175, 0);
    ellipse(0, 0, posX/3.0, posZ/3.0);
    stroke(210, 100, 0);
    rotateY(90);
    ellipse(0, 0, posX/2.5, posZ/2.5);
    stroke(210, 0, 0);
    rotateY(90);
    ellipse(0, 0, posX/2, posZ/2);
    popMatrix();
    
  }
  
  private void initialize_emitter() {
    if (emWidth > 200) {
      emWidth = 50;
      emHeight = 50;
      emRed = emGreen = emBlue = 255;
    }
  }

  void emitter_display() {
    if (emWidth == 800) {
      initialize_emitter();
    }
    pushMatrix();
      pushStyle();
//        noFill();
//        strokeWeight(5);
//        stroke(planetColor);
//        translate(width/2, height/2);
//        ellipseMode(CENTER);
//        ellipse(posX, posZ, emWidth, emHeight);
//        emWidth *= 1.05;
//        emHeight *= 1.05;
//        emRed *= 0.95;
//        emGreen *= 0.95;
//        emBlue *= 0.95;
//        if (emWidth > 200) emWidth = emHeight = 50;
      translate(width/2, height/2);
      stroke(planetColor);
      strokeWeight(5);
      ellipseMode(CENTER);
      ellipse(posX, posZ, emWidth, emHeight);
      popStyle();
    popMatrix();
  }
  
  void emitter_fade() {
    pushMatrix();
    pushStyle();
    noFill();
    strokeWeight(5);
    stroke(planetColor);
    translate(width/2, height/2);
    ellipseMode(CENTER);
    ellipse(posX, posZ, emWidth, emHeight);
    popStyle();
    popMatrix();
  }
    
  void orbit_path() {
    pushMatrix();
    translate(width/2, height/2);
    pushStyle();
    noFill();
    stroke(0, 34, 100);
    strokeWeight(1.5);
    ellipse(0, 0, radX * 2, radZ * 2);
    popStyle();
    popMatrix();
  }
  
   void orbit_highlight() {
    println("Hightlight");
    pushMatrix();
    pushStyle();
    noFill();
    strokeWeight(2.5);
    stroke(planetColor);
    ellipse(width/2, height/2, radX * 2, radZ * 2);
    popStyle();
    popMatrix();
  }
  
  void planet_distance() {
    pushMatrix();
    translate(width/2, height/2);
    stroke(planetColor);
    line(0, 0, 0, posX, posZ, 0);
    popMatrix();
  }
  
  void dist_highlight() {
    pushMatrix();
    pushStyle();
    translate(width/2, height/2);
    stroke(planetColor);
    strokeWeight(3);
    line(0, 0, 0, posX, posZ, 0);
    popStyle();
    popMatrix();
  }
  
  void oscEvent(OscMessage theOscMessage) {
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
