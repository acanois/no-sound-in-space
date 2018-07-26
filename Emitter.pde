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
