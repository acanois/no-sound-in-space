// No Sound In Space V3 - 3D, Wireframe
// David Richter - 8/23/2013

import oscP5.*;
import netP5.*;

OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;

Planet[] planet = new Planet[5];
Sun sun = new Sun();

int zeroSun;

// Planet properties
float planetDistanceX;
float planetDistanceZ;
float planetSize;
color[] planetColor        = new color[5];
color[] moonColor          = new color[5];

// Camera
float cameraX, cameraY, cameraZ;
float cameraTan;
float cameraRadX, cameraRadZ;
float cameraTheta;
float cameraOrbitSpeed;

// OSC variables
int pHighlight;

void setup() {
  size(1440, 850, OPENGL);
  smooth(8);
  frameRate(60);
  
  // Emitter initialization
  pHighlight = 0;
  
  cameraX = 700;
  cameraY = 2200;
  cameraZ = 600;
  cameraTan = tan(PI/8.0);
  cameraRadX = 700; 
  cameraRadZ = 600;
  cameraTheta = 0;
  cameraOrbitSpeed = 0.001;
  
  color red = color(170, 0, 0);
  color green = color(0, 170, 0);
  color blue = color(0, 0, 170);
  color yellow = color(170, 170, 0);
  color purple = color(170, 0, 170);
  
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
    planet[i] = new Planet(planetDistanceX, planetDistanceZ, planetSize, planetColor[i]);
  }
  

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  oscP52 = new OscP5(this, 10000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

void draw() {
  background(0);
  
  // Camera
  beginCamera();    
  cameraTheta += cameraOrbitSpeed;
  cameraX = cameraRadX * cos(cameraTheta);
  cameraZ = cameraRadZ * sin(cameraTheta);
  camera(cameraX, cameraY, cameraZ / cameraTan, width/2, height/2, 0, 0, 1, 0);
  endCamera();
 
  sun.display();

  // Drawing planets
  for (int i = 0; i < planet.length; i++) {
    planet[i].orbit_path(); 
    planet[i].update();
    planet[i].display();
    planet[i].planet_distance();
  }
  
  // Triggers highlights
  if (pHighlight == 0) {
    for (int i = 0; i < 5; i++) {
      planet[i].orbit_path();
    }
  }
  if (pHighlight == 1) {
    planet[0].dist_highlight();
    planet[0].orbit_highlight();
  } 
  if (pHighlight == 2) {
    planet[1].dist_highlight();
    planet[1].orbit_highlight();
  } 
  if (pHighlight == 3) {
    planet[2].dist_highlight();
    planet[2].orbit_highlight();
  } 
  if (pHighlight == 4) {
    planet[3].dist_highlight();
    planet[3].orbit_highlight();
  } 
  if (pHighlight == 5) {
    planet[4].dist_highlight();
    planet[4].orbit_highlight();
  } 

  // OSC Sends to Max for Planets
  for (int i = 0; i < planet.length; i++) {
    OscMessage planetI = new OscMessage("/planet" + i);
    planetI.add(planet[i].theta);           // Theta
    
    planetI.add(planet[i].radX);            // X Radius
    planetI.add(planet[i].radZ);            // Z Radius
    
    planetI.add(planet[i].posX);            // X location
    planetI.add(planet[i].posZ);            // Z location
    
    planetI.add(planet[i].rotationY);       // Y rotation
    
    planetI.add(planet[i].rotationSpeed);   // Rotation Speed
    planetI.add(planet[i].diameter);        // Planet diameter
    planetI.add(planet[i].orbitspeed);      // Planet orbit speed
    planetI.add(planet[i].planetColor);     // Planet Color
    oscP5.send(planetI, myRemoteLocation);
  }  
}

// OSC Reciever from Max
void oscEvent(OscMessage theOscMessage) {
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