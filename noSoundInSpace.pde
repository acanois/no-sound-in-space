// No Sound In Space V3 - 3D, Wireframe
// David Richter - 8/23/2013

import oscP5.*;
import netP5.*;

OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;

Orbiter[] orbiters = new Orbiter[5];
Sun sun = new Sun();

int zeroSun;

// Stars parameters
int           depth         = 40;
int           nbStarsMax    = 5000;
Stars[]       tabStars      = new Stars[nbStarsMax];
int           maxStarsSpeed = 5;
 
// Drawing parameters
PVector starBox = new PVector(2000, 2000, 2000);
int           taille = 1;
int           transparency = 255;
 
// Rotation variable
int           rotationMode = 3;
float         angle = 0;
float         delta = radians(0.25);

// Planet properties
PVector planetDist = new PVector(0.0, 0.0, 0.0);
float planetSize;

color[] planetColor = new color[] {
  color(170, 0, 0),
  color(0, 0, 170),
  color(170, 170, 0),
  color(0, 170, 0),
  color(90, 0, 170)
};

// Camera
PVector camPos = new PVector(700.0, 2200.0, 600.0);
PVector camRad = new PVector(700.0, 0.0, 600.0);
float cameraTan = tan(PI/8.0);
float cameraTheta = 0;
float cameraOrbitSpeed = 0.001;

void setup() {
  size(1280, 720, OPENGL);
  smooth(8);
  frameRate(60);
  
  // Stars
  for (int i = 0; i < nbStarsMax; ++i) {
    tabStars[i] = new Stars(random(-2 * width, 2 * width), 
                             random(-2 * height, 2 * height),
                            -random(depth * 255), 
                             random(1, maxStarsSpeed));
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

void sendParameters() {
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

void updateCamera() {
    // Camera
  beginCamera();
  perspective();
    
  cameraTheta += cameraOrbitSpeed;
  camPos.x = camRad.x * cos(cameraTheta);
  camPos.z = camRad.z * sin(cameraTheta);
    
  camera(camPos.x, camPos.y, camPos.z / cameraTan, width/2, height/2, 0, 0, 1, 0);
  endCamera();
}

void updateStars() {
    for(int i = 0; i < nbStarsMax; ++i) {
    tabStars[i].aff();
  }
}

void draw() {
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
void oscEvent(OscMessage theOscMessage) {
  println(theOscMessage);
}
