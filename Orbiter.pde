class Orbiter {

    PVector position;
    PVector orbitRadius;
    PVector rotation;

    float theta;
    float diameter;
    float rotationSpeed;
    float orbitSpeed;

    color orbiterColor;

    Orbiter(PVector _orbitRadius, float _diameter, color _orbiterColor) {
        position = new PVector(0.0, 0.0, 0.0);
        orbitRadius = new PVector(_orbitRadius.x, _orbitRadius.y, _orbitRadius.z);
        rotation = new PVector(0.0, 0.0, 0.0);
        diameter = _diameter;
        orbiterColor = _orbiterColor;

        orbitSpeed = random(0.0025, 0.015);
        rotationSpeed = random(0.3, 1.5);

        theta = 0.0;
    }

    void update() {
        theta += orbitSpeed;
        rotation.y -= rotationSpeed;
    }

    void display() {
        pushMatrix();

            translate(width * 0.5, height * 0.5);
            position.x = orbitRadius.x * sin(theta);
            position.z = orbitRadius.z * cos(theta);

            translate(position.x, position.z);
            sphereDetail(7);
            rotateX(90);
            rotateY(radians(-rotation.y));

            pushStyle();
                stroke(orbiterColor);
                noFill();
                sphere(diameter);

                stroke(255);
                noFill();
                rotate(90);
                ellipse(0, 0, 130, 150);
            popStyle();
        
        popMatrix();
    }

    void orbitPath() {
        pushMatrix();
            translate(width/2, height/2);
            pushStyle();
                noFill();
                stroke(0, 34, 100);
                strokeWeight(1.5);
                ellipse(0, 0, orbitRadius.x * 2, orbitRadius.z * 2);
            popStyle();
        popMatrix();
    }

    void orbitHighlight() {
        pushMatrix();
            pushStyle();
                noFill();
                strokeWeight(2.5);
                stroke(orbiterColor);
                ellipse(width/2, height/2, orbitRadius.x * 2, orbitRadius.z * 2);
            popStyle();
        popMatrix();
    }

    void planetDistance() {
        pushMatrix();
            translate(width/2, height/2);
            stroke(orbiterColor);
            line(0, 0, 0, position.x, position.z, 0);
        popMatrix();
    }

    void distHighlight() {
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