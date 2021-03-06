import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class noSoundInSpace extends PApplet {

// No Sound In Space V3 - 3D, Wireframe
// David Richter - 8/23/2013




OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;

Orbiter[] orbiters = new Orbiter[5];
Sun sun = new Sun();

// Stars parameters
int depth = 40;
int numStars = 5000;
int starSpeed = 5;

Stars[] tabStars = new Stars[numStars];
 
// Drawing parameters
PVector starBox = new PVector(2000, 2000, 2000);
int transparency = 255;
 
// Rotation variable
int           rotationMode = 3;
float         angle = 0;
float         delta = radians(0.25f);

// Planet properties
PVector planetDist = new PVector(0.0f, 0.0f, 0.0f);
float planetSize;

int[] planetColor = new int[] {
  color(170, 0, 0),
  color(0, 0, 170),
  color(170, 170, 0),
  color(0, 170, 0),
  color(90, 0, 170)
};

// Camera
PVector camPos = new PVector(700.0f, 2200.0f, 600.0f);
PVector camRad = new PVector(700.0f, 0.0f, 600.0f);

float cameraTan = tan(PI/8.0f);
float cameraTheta = 0;
float cameraOrbitSpeed = 0.001f;

// ===================================================================================
public void setup() {
  
  
  frameRate(60);
  
  // Stars
  for (int i = 0; i < numStars; ++i) {
    tabStars[i] = new Stars(random(-2 * width, 2 * width), 
                             random(-2 * height, 2 * height),
                            -random(depth * 255), 
                             random(1, starSpeed));
  }
  
  for (int i = 0; i < orbiters.length; ++i) {
    planetDist.x = 297 + i * 300;
    planetDist.z = 203 + i * 250;
    planetSize = random(25, 50);
    orbiters[i] = new Orbiter(new PVector(planetDist.x, 0, planetDist.z), planetSize, planetColor[i]);
  }
  

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 10000);
  // oscP52 = new OscP5(this, 10000);
  myRemoteLocation = new NetAddress("127.0.0.1", 15000);
}

// ===================================================================================
public void sendParameters() {
  for (int i = 0; i < orbiters.length; i++) {
    OscMessage planetI = new OscMessage("/planet" + i);
    planetI.add(orbiters[i].theta);           
    planetI.add(orbiters[i].orbitRadius.x);
    planetI.add(orbiters[i].orbitRadius.z);
    planetI.add(orbiters[i].position.x);
    planetI.add(orbiters[i].position.z);
    planetI.add(orbiters[i].rotation.y);
    planetI.add(orbiters[i].rotationSpeed);
    planetI.add(orbiters[i].diameter);
    planetI.add(orbiters[i].orbitSpeed);
    planetI.add(orbiters[i].orbiterColor);

    oscP5.send(planetI, myRemoteLocation);
  }  
}

// ===================================================================================
public void updateCamera() {
    // Camera
  beginCamera();
  perspective();
    
  cameraTheta += cameraOrbitSpeed;
  camPos.x = camRad.x * cos(cameraTheta);
  camPos.z = camRad.z * sin(cameraTheta);
    
  camera(camPos.x, camPos.y, camPos.z / cameraTan, width/2, height/2, 0, 0, 1, 0);
  endCamera();
}

// ===================================================================================
public void updateStars() {
    for(int i = 0; i < numStars; ++i) {
    tabStars[i].display();
  }
}

// ===================================================================================
public void draw() {
  background(0);
  updateStars();
  updateCamera();
  sun.display();

  for (Orbiter orbiter : orbiters) {
    orbiter.orbitPath(); 
    orbiter.update();
    orbiter.display();
    orbiter.planetDistance();
  }

  sendParameters();
}

// OSC Reciever from Max
public void oscEvent(OscMessage theOscMessage) {
  println(theOscMessage);
}
// Emitter

/*class Emitter {

  float emWidth, emHeight;
  float rotationSpeed;
  float rotationX;
  color emRed, emGreen, emBlue;

  Emitter(float emWidth_, float emHeight_) {

    emWidth = emWidth_;
    emHeight = emHeight_;

    emRed = emGreen = emBlue = 255;
  }


  void display() {

    noFill();
    stroke(emRed, emGreen, emBlue);
    rotationX -= rotationSpeed;
    rotateX(radians(-rotationX));
    if (emWidth < 800) {
      ellipse(0, 0, emWidth, emHeight);
      emWidth += 5;
      emHeight += 5;
      emRed -= 2;
      emGreen -= 2;
      emBlue -= 2;
    }
  }
}
*/
// Moon class

class Moon {
  
  float moonPosX, moonPosZ;
  float moonRadX, moonRadZ;
  float moonSize;
  float moonTheta;
  float moonOrbitSpeed;
  float moonRotationY;
  float moonRotationSpeed;
  int moonColor;
  
  Moon(float moonRadX_, float moonRadZ_, float moonSize_, int moonColor_) { 
    moonRadX = moonRadX_;
    moonRadZ = moonRadZ_;
    moonSize = moonSize_;
    moonTheta = 0;
    moonOrbitSpeed = random(5.0f, 10.0f);
    moonRotationY = 0;
    moonRotationSpeed = random(0.3f, 1);
    moonColor = moonColor_;  
  }
  
  public void update() {
    moonTheta += moonOrbitSpeed;
    moonRotationY -= moonRotationSpeed;
  }
  
  public void display() {
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
class Orbiter {

    PVector position;
    PVector orbitRadius;
    PVector rotation;

    float theta;
    float diameter;
    float rotationSpeed;
    float orbitSpeed;

    int orbiterColor;

    Orbiter(PVector _orbitRadius, float _diameter, int _orbiterColor) {
        position = new PVector(0.0f, 0.0f, 0.0f);
        orbitRadius = new PVector(_orbitRadius.x, _orbitRadius.y, _orbitRadius.z);
        rotation = new PVector(0.0f, 0.0f, 0.0f);
        diameter = _diameter;
        orbiterColor = _orbiterColor;

        orbitSpeed = random(0.0025f, 0.015f);
        rotationSpeed = random(0.3f, 1.5f);

        theta = 0.0f;
    }

    public void update() {
        theta += orbitSpeed;
        rotation.y -= rotationSpeed;
    }

    public void display() {
        pushMatrix();

            translate(width * 0.5f, height * 0.5f);
            position.x = orbitRadius.x * sin(theta);
            position.z = orbitRadius.z * cos(theta);



            pushStyle();
                translate(position.x, position.z);
                sphereDetail(7);
                rotateX(90);
                rotateY(radians(-rotation.y));
                stroke(orbiterColor);
                noFill();
                sphere(diameter);
            popStyle();

            pushStyle();
                stroke(100);
                noFill();
                rotateX(90);
                ellipse(0, 0, 130, 150);
            popStyle();
        
        popMatrix();
    }

    public void orbitPath() {
        pushMatrix();
            translate(width/2, height/2);
            pushStyle();
                noFill();
                stroke(0, 34, 100);
                strokeWeight(1.5f);
                ellipse(0, 0, orbitRadius.x * 2, orbitRadius.z * 2);
            popStyle();
        popMatrix();
    }

    public void orbitHighlight() {
        pushMatrix();
            pushStyle();
                noFill();
                strokeWeight(2.5f);
                stroke(orbiterColor);
                ellipse(width/2, height/2, orbitRadius.x * 2, orbitRadius.z * 2);
            popStyle();
        popMatrix();
    }

    public void planetDistance() {
        pushMatrix();
            translate(width/2, height/2);
            stroke(orbiterColor);
            line(0, 0, 0, position.x, position.z, 0);
        popMatrix();
    }

    public void distHighlight() {
        pushMatrix();
            pushStyle();
                translate(width/2, height/2);
                stroke(orbiterColor);
                strokeWeight(3);
                line(0, 0, 0, position.x, position.z, 0);
            popStyle();
        popMatrix();
    }
}
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
  int planetColor;
  int[] moonColor = new int[5];
  
  int zeroSun;

  // Emitter variables
  float emWidth, emHeight;
  float emAlpha;
  int emRed, emGreen, emBlue;

  Moon moon;

  Planet(float radX_, float radZ_, float diameter_, int planetColor_) {
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
    orbitspeed = random(0.0025f, 0.015f);
    // Set color to random value for each planet when the program is run.
    rotationSpeed = random(0.3f, 1.5f);
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

  public void update() {
    theta += orbitspeed;
    rotationY -= rotationSpeed;
  }

  public void display() {
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
    ellipse(0, 0, posX/3.0f, posZ/3.0f);
    stroke(210, 100, 0);
    rotateY(90);
    ellipse(0, 0, posX/2.5f, posZ/2.5f);
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

  public void emitter_display() {
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
  
  public void emitter_fade() {
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
    
  public void orbit_path() {
    pushMatrix();
    translate(width/2, height/2);
    pushStyle();
    noFill();
    stroke(0, 34, 100);
    strokeWeight(1.5f);
    ellipse(0, 0, radX * 2, radZ * 2);
    popStyle();
    popMatrix();
  }
  
   public void orbit_highlight() {
    println("Hightlight");
    pushMatrix();
    pushStyle();
    noFill();
    strokeWeight(2.5f);
    stroke(planetColor);
    ellipse(width/2, height/2, radX * 2, radZ * 2);
    popStyle();
    popMatrix();
  }
  
  public void planet_distance() {
    pushMatrix();
    translate(width/2, height/2);
    stroke(planetColor);
    line(0, 0, 0, posX, posZ, 0);
    popMatrix();
  }
  
  public void dist_highlight() {
    pushMatrix();
    pushStyle();
    translate(width/2, height/2);
    stroke(planetColor);
    strokeWeight(3);
    line(0, 0, 0, posX, posZ, 0);
    popStyle();
    popMatrix();
  }
  
  public void oscEvent(OscMessage theOscMessage) {
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
class Stars {
  float x, y, z;
  float dZ;
   
  Stars(float coordX, float coordY, float coordZ, float speedZ) {
    x  = coordX; 
    y  = coordY; 
    z  = coordZ; 
    dZ = speedZ;
  }
   
  public void display() {
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
// Sun

class Sun {
  // Sun properties
  float sunSize;
  float sunRotationY;
  float sunRotationSpeed;
  int sunColor;
  int zeroSun;
  float sBurstW, sBurstH;
  int burstRed, burstGreen, burstBlue;
  
  Sun() {
    // Initializes sun
    sunSize = 95;
    sunColor = color(218, 219, 0);
    sunRotationSpeed = random(0.5f, 2.0f);
    sunRotationY = 0;
    zeroSun = 1;
    sBurstW = 90;
    sBurstH = 60;
    burstRed = 255;
    burstGreen = 175;
    burstBlue = 0;
  }
  
  public void display() {
    pushMatrix(); 
      translate(width/2, height/2);
      pushStyle();
        stroke(255, 175, 0);
        noFill();
        sphereDetail(10);
        rotateX(90);
        sunRotationY -= sunRotationSpeed;
        rotateY(radians(-sunRotationY));
        sphere(sunSize);
      popStyle();
    popMatrix();
    
    // OSC Sends for sun
    OscMessage sunn = new OscMessage("/sun");
    sunn.add(sunSize);
    sunn.add(sunRotationY);
    sunn.add(sunRotationSpeed);
    oscP5.send(sunn, myRemoteLocation);
  }
  
  public void burst() {
    noFill();
    stroke(burstRed, burstGreen, burstBlue);
    if (sBurstW < width * 2) { 
      pushMatrix();
      pushStyle();
      strokeWeight(5);
      //translate(width/2, height/2);
      ellipseMode(CENTER);
      ellipse(width/2, height/2, sBurstW, sBurstH);
      sBurstW *= 1.015f;
      sBurstH *= 1.015f;
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
  
  public void burst_initialize() {
    sBurstW = 60;
    sBurstH = 90;
    burstRed = 255;
    burstGreen = 175;
    burstBlue = 0;
  }
  
  public void oscEvent(OscMessage theOscMessage) {
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
  public void settings() {  size(1280, 720, OPENGL);  smooth(8); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "noSoundInSpace" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
