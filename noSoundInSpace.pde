// No Sound In Space V3 - 3D, Wireframe
// David Richter - 8/23/2013

import oscP5.*;
import netP5.*;

OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;

Orbiter[] planet = new Orbiter[5];
Sun sun = new Sun();

int zeroSun;

// Stars parameters
int           depth         = 40;
int           nbStarsMax    = 5000;
Stars[]       tabStars      = new Stars[nbStarsMax];
int           maxStarsSpeed = 5;
 
// Drawing parameters
int           sizeX = 1440;
int           sizeY = 850;
int           taille = 1;
int           transparency = 255;
 
// Rotation variable
int           rotationMode = 3;
float         angle = 0;
float         delta = radians(0.25);

// Planet properties
float planetDistanceX;
float planetDistanceZ;
float planetSize;
color[] planetColor = new color[5];
color[] moonColor = new color[5];

// Camera
float cameraX, cameraY, cameraZ;
float cameraTan;
float cameraRadX, cameraRadZ;
float cameraTheta;
float cameraOrbitSpeed;

// OSC variables
int emitter;
int pHighlight;

void setup() {
  size(1440, 850, OPENGL);
  smooth(8);
  frameRate(60);
  
  // Stars
  for(int nb=0; nb<nbStarsMax; nb++) {
    tabStars[nb] = new Stars(random(-2 * width, 2 * width), random(-2 * height, 2 * height),
                               (-random(depth * 255)), random(1, maxStarsSpeed));
  }
  
  // Emitter initialization
  emitter = 0;
  pHighlight = 0;
  
  cameraX = 700;
  cameraY = 2200;
  cameraZ = 600;
  cameraTan = tan(PI/8.0);
  cameraRadX = 700; 
  cameraRadZ = 600;
  cameraTheta = 0;
  cameraOrbitSpeed = 0.001;
  
  // Initializing planet size and orbit distance
  for (int i = 0; i < planet.length; i++) {
    planetDistanceX = 297 + i * 300;
    planetDistanceZ = 203 + i * 250;
    planetSize = random(25, 50);
    planetColor[0] = color(170, 0, 0);
    planetColor[1] = color(0, 0, 170);
    planetColor[2] = color(170, 170, 0);
    planetColor[3] = color(0, 170, 0);
    planetColor[4] = color(90, 0, 170);
    planet[i] = new Orbiter(new PVector(planetDistanceX, 0, planetDistanceZ), planetSize, planetColor[i]);
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
  if (mousePressed && mouseButton == LEFT) {
    cameraX = mouseX;
    cameraZ = mouseY;
  }
    
  cameraTheta += cameraOrbitSpeed;
  cameraX = cameraRadX * cos(cameraTheta);
  cameraZ = cameraRadZ * sin(cameraTheta);
    
  camera(cameraX, cameraY, cameraZ / cameraTan, width/2, height/2, 0, 0, 1, 0);
  endCamera();
 
  sun.display();

  // Drawing planets
  for (int i = 0; i < planet.length; i++) {
    planet[i].orbitPath(); 
    planet[i].update();
    planet[i].display();
    planet[i].planetDistance();
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
      planet[i].orbitPath();
    }
  }
  if (pHighlight == 1) {
    planet[0].distHighlight();
    planet[0].orbitHighlight();
  } 
  if (pHighlight == 2) {
    planet[1].distHighlight();
    planet[1].orbitHighlight();
  } 
  if (pHighlight == 3) {
    planet[2].distHighlight();
    planet[2].orbitHighlight();
  } 
  if (pHighlight == 4) {
    planet[3].distHighlight();
    planet[3].orbitHighlight();
  } 
  if (pHighlight == 5) {
    planet[4].distHighlight();
    planet[4].orbitHighlight();
  } 

  // OSC Sends to Max for Planets
  for (int i = 0; i < planet.length; i++) {
    OscMessage planetI = new OscMessage("/planet" + i);
    planetI.add(planet[i].theta);           // Theta
    
    planetI.add(planet[i].orbitRadius.x);            // X Radius
    planetI.add(planet[i].orbitRadius.z);            // Z Radius
    
    planetI.add(planet[i].position.x);            // X location
    planetI.add(planet[i].position.z);            // Z location
    
    planetI.add(planet[i].rotation.y);       // Y rotation
    
    planetI.add(planet[i].rotationSpeed);   // Rotation Speed
    planetI.add(planet[i].diameter);        // Planet diameter
    planetI.add(planet[i].orbitSpeed);      // Planet orbit speed
    planetI.add(planet[i].orbiterColor);     // Planet Color
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
