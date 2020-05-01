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

// OSC variables
int emitter;
int pHighlight;

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
  
  // Emitter initialization
  emitter = 0;
  pHighlight = 0;
  
  // Initializing planet size and orbit distance
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

void draw() {
  background(0);
  
  translate(width/2, height/2);
  for(int nb = 0; nb < nbStarsMax; nb++) {
    tabStars[nb].aff();
  }
  // Camera
  beginCamera();
  perspective();
    
  cameraTheta += cameraOrbitSpeed;
  camPos.x = camRad.x * cos(cameraTheta);
  camPos.z = camRad.z * sin(cameraTheta);
    
  camera(camPos.x, camPos.y, camPos.z / cameraTan, width/2, height/2, 0, 0, 1, 0);
  endCamera();
 
  sun.display();

  for (Orbiter orbiter : orbiters) {
    orbiter.orbitPath(); 
    orbiter.update();
    orbiter.display();
    orbiter.planetDistance();
  }
  
  // Triggers emitters
  /*if (emitter ==;
  if (emitter == 2) planet[1].emitter_display();
  if (emitter == 3) planet[2].emitter_display();
  if (emitter == 4) planet[3].emitter_display();
  if (emitter == 5) planet[4].emitter_display();*/
  
  // Triggers highlights
  if (pHighlight == 0) {
    for (int i = 0; i < 5; i++) {
      orbiters[i].orbitPath();
    }
  }
  if (pHighlight == 1) {
    orbiters[0].distHighlight();
    orbiters[0].orbitHighlight();
  } 
  if (pHighlight == 2) {
    orbiters[1].distHighlight();
    orbiters[1].orbitHighlight();
  } 
  if (pHighlight == 3) {
    orbiters[2].distHighlight();
    orbiters[2].orbitHighlight();
  } 
  if (pHighlight == 4) {
    orbiters[3].distHighlight();
    orbiters[3].orbitHighlight();
  } 
  if (pHighlight == 5) {
    orbiters[4].distHighlight();
    orbiters[4].orbitHighlight();
  } 

  // OSC Sends to Max for Planets
  for (int i = 0; i < orbiters.length; i++) {
    OscMessage planetI = new OscMessage("/planet" + i);
    planetI.add(orbiters[i].theta);           // Theta
    
    planetI.add(orbiters[i].orbitRadius.x);            // X Radius
    planetI.add(orbiters[i].orbitRadius.z);            // Z Radius
    
    planetI.add(orbiters[i].position.x);            // X location
    planetI.add(orbiters[i].position.z);            // Z location
    
    planetI.add(orbiters[i].rotation.y);       // Y rotation
    
    planetI.add(orbiters[i].rotationSpeed);   // Rotation Speed
    planetI.add(orbiters[i].diameter);        // Planet diameter
    planetI.add(orbiters[i].orbitSpeed);      // Planet orbit speed
    planetI.add(orbiters[i].orbiterColor);     // Planet Color
    oscP5.send(planetI, myRemoteLocation);
  }  
}

// OSC Reciever from Max
void oscEvent(OscMessage theOscMessage) {
  // Check if theOscMessage has the address pattern we are looking for. 
  if (theOscMessage.checkAddrPattern("/emit1") == true) {
    emitter = 1;
  }
  if (theOscMessage.checkAddrPattern("/emit2") == true) {
    emitter = 2; 
  }
  if (theOscMessage.checkAddrPattern("/emit3") == true) {
    emitter = 3;
  }
  if (theOscMessage.checkAddrPattern("/emit4") == true) {
    emitter = 4;
  }
  if (theOscMessage.checkAddrPattern("/emit5") == true) {
    emitter = 5;
  }
  
  // Planet highlights
  if (theOscMessage.checkAddrPattern("/highlight0") == true) {
    pHighlight = 0;
  }
  if (theOscMessage.checkAddrPattern("/highlight1") == true) {
    pHighlight = 1;
  }
  if (theOscMessage.checkAddrPattern("/highlight2") == true) {
    pHighlight = 2;
  }
  if (theOscMessage.checkAddrPattern("/highlight3") == true) {
    pHighlight = 3;
  }
  if (theOscMessage.checkAddrPattern("/highlight4") == true) {
    pHighlight = 4;
  }
  if (theOscMessage.checkAddrPattern("/highlight5") == true) {
    pHighlight = 5;
  }
}
