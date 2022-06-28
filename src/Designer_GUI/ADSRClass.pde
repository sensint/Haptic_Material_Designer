// extends buttons, uses control points
// maybe all UI elements could be buttons and controlpoints?

public class ADSR extends Button {

  ControlPoint start;
  ControlPoint attack; //controlpoints can be moved about and have functions to return their position
  ControlPoint decay;
  ControlPoint sustain;
  ControlPoint release;
  int xPosition;
  int yPosition;
  int xWidth;
  int yWidth;

  //constructor without position
  ADSR(PApplet parent, String name) {
    super(parent, name);
    start = new ControlPoint(parent, "start");
    attack = new ControlPoint(parent, "attack");
    decay = new ControlPoint(parent, "decay");
    sustain = new ControlPoint(parent, "sustain");
    release = new ControlPoint(parent, "release");
  }

  void initialize(int posX, int posY, int fieldHeight, int fieldWidth) {
    xPosition = posX;
    yPosition = posY;
    xWidth = fieldWidth;
    yWidth = fieldHeight;

    start.initialize(posX, posY + fieldHeight, 15, 15); //controlpoints are initialized with their position and dimensions
    
    attack.initialize(posX + (fieldWidth / 4), posY, 15, 15);

    decay.initialize(posX + (fieldWidth / 4) * 2, posY + fieldHeight / 2, 15, 15);
    decay.constrainY(posY, posY + fieldHeight);

    sustain.initialize(posX + (fieldWidth / 4) * 3, posY + fieldHeight / 2, 15, 15);
    sustain.constrainY(posY, posY + fieldHeight);

    release.initialize(posX + fieldWidth, posY + fieldHeight, 15, 15);
    release.constrainY(posY + fieldHeight, posY + fieldHeight);
  }

  //question: should this be updateable from within the main loop? (position)

  void displayControlPoints() {
    start.constrainX(xPosition, xPosition); //constraints prevent movement beyond certain points
    start.constrainY(yPosition, yPosition + yWidth);    
    start.display();

    attack.constrainX(start.x(), decay.x()); //preventing the control point from creating invalid states
    attack.constrainY(yPosition, yPosition);
    attack.display();

    decay.constrainX(attack.x(), sustain.x());
    decay.setY(sustain.y()); //setting the sutain point from being equal to decay
    decay.constrainY(sustain.y(), sustain.y()); //need to also constrain it so as to prevent manually moving it away
    // decay.constrainX(attack.x(), sustain.x());
    decay.display();

    //sustain.setY(decay.y()); //setting the sutain point from being equal to decay
    //sustain.constrainY(decay.y(), decay.y()); //need to also constrain it so as to prevent manually moving it away
    sustain.constrainX(decay.x(), release.x());
    sustain.display();

    release.constrainX(sustain.x(), xPosition + xWidth);
    release.display();
  }

  void displayCurve() {
    //strokeWeight(8);
    parent.line(start.x(), start.y(), attack.x(), attack.y()); //attack (these lines grab their endpoints from their corresponding controlpoints.)
    parent.line(attack.x(), attack.y(), decay.x(), decay.y()); //decay
    parent.line(decay.x(), decay.y(), sustain.x(), sustain.y()); //sustain
    parent.line(sustain.x(), sustain.y(), release.x(), release.y()); //release
  }

  // put a box around the ADSR window
  void displayBox() {
    parent.stroke(150);
    parent.line(xPosition, yPosition, xPosition, yPosition + yWidth);
    parent.line(xPosition, yPosition + yWidth, xPosition + xWidth, yPosition + yWidth);
    parent.line(xPosition + xWidth, yPosition + yWidth, xPosition + xWidth, yPosition);
    parent.line(xPosition, yPosition, xPosition + xWidth, yPosition);
  }

  void displayArea() {
    parent.beginShape();
    parent.vertex(start.x(), start.y());
    parent.vertex(attack.x(), attack.y());
    parent.vertex(decay.x(), decay.y());
    parent.vertex(sustain.x(), sustain.y());
    parent.vertex(release.x(), release.y());
    parent.endShape(CLOSE);
  }
}
