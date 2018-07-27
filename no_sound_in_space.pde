// No Sound In Space V3 - 3D, Wireframe
// David Richter - 8/23/2013

import java.util.Arrays;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;

Planet[] planets = new Planet[5];
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

  pixelDensity(2);
  
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
  for (int i = 0; i < planets.length; i++) {
    planetDistanceX = 297 + i * 300;
    planetDistanceZ = 203 + i * 250;
    planetSize = random(25, 50);
    planetColor[0] = color(170, 0, 0);
    planetColor[1] = color(0, 0, 170);
    planetColor[2] = color(170, 170, 0);
    planetColor[3] = color(0, 170, 0);
    planetColor[4] = color(90, 0, 170);
    planets[i] = new Planet(planetDistanceX, planetDistanceZ, planetSize, planetColor[i]);
  }
  

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  oscP52 = new OscP5(this, 10000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

void updateCamera() { 
  cameraTheta += cameraOrbitSpeed;
  cameraX = cameraRadX * cos(cameraTheta);
  cameraZ = cameraRadZ * sin(cameraTheta);
  camera(cameraX, cameraY, cameraZ / cameraTan, width/2, height/2, 0, 0, 1, 0);
}

void draw() {
  background(0);

  updateCamera();
 
  sun.display();

  for (Planet planet : planets) {
    planet.orbit_path();
    planet.update();
    planet.display();
    planet.planet_distance();
  }
  
  // Triggers highlights
  if (pHighlight == 0) {
    for (int i = 0; i < 5; i++) {
      planets[i].orbit_path();
    }
  }
  if (pHighlight == 1) {
    planets[0].dist_highlight();
    planets[0].orbit_highlight();
  } 
  if (pHighlight == 2) {
    planets[1].dist_highlight();
    planets[1].orbit_highlight();
  } 
  if (pHighlight == 3) {
    planets[2].dist_highlight();
    planets[2].orbit_highlight();
  } 
  if (pHighlight == 4) {
    planets[3].dist_highlight();
    planets[3].orbit_highlight();
  } 
  if (pHighlight == 5) {
    planets[4].dist_highlight();
    planets[4].orbit_highlight();
  } 

  // OSC Sends to Max for Planets
  for (Planet planet : planets) {
    OscMessage planetStats = new OscMessage("/planet" + Arrays.asList(planets).indexOf(planet));
    planetStats.add(planet.theta);           // Theta
    planetStats.add(planet.radX);            // X Radius
    planetStats.add(planet.radZ);            // Z Radius
    planetStats.add(planet.posX);            // X location
    planetStats.add(planet.posZ);            // Z location
    planetStats.add(planet.rotationY);       // Y rotation
    planetStats.add(planet.rotationSpeed);   // Rotation Speed
    planetStats.add(planet.diameter);        // Planet diameter
    planetStats.add(planet.orbitspeed);      // Planet orbit speed
    planetStats.add(planet.planetColor);     // Planet Color
    oscP5.send(planetStats, myRemoteLocation);
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