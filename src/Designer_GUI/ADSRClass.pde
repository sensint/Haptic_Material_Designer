public class ADSR extends Button {
  ControlPoint start;
  ControlPoint attack;
  ControlPoint decay;
  ControlPoint sustain;
  ControlPoint release;
  int xPosition;
  int yPosition;
  int xWidth;
  int yWidth;
  
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
    
    start.initialize(posX, posY + fieldHeight, 15, 15); 
    
    attack.initialize(posX + (fieldWidth / 4), posY, 15, 15);
    
    decay.initialize(posX + (fieldWidth / 4) * 2, posY + fieldHeight / 2, 15, 15);
    decay.constrainY(posY, posY + fieldHeight);
    
    sustain.initialize(posX + (fieldWidth / 4) * 3, posY + fieldHeight / 2, 15, 15);
    sustain.constrainY(posY, posY + fieldHeight);
    
    release.initialize(posX + fieldWidth, posY + fieldHeight, 15, 15);
    release.constrainY(posY + fieldHeight, posY + fieldHeight);
  }
  
  void displayControlPoints() {
    //constraints prevent movement beyond certain points
    start.constrainX(xPosition, xPosition); 
    start.constrainY(yPosition, yPosition);
    start.display();
    
    attack.constrainX(start.x(), decay.x());
    attack.constrainY(yPosition, yPosition);
    attack.display();
    
    decay.constrainX(attack.x(), sustain.x());
    decay.setY(sustain.y()); 
    decay.constrainY(sustain.y(), sustain.y());
    decay.display();
    
    sustain.constrainX(decay.x(), release.x());
    sustain.display();
    
    release.constrainX(sustain.x(), xPosition + xWidth);
    release.display();
  }
  
  void displayCurve() {
    parent.line(start.x(), start.y(), attack.x(), attack.y()); //attack
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
