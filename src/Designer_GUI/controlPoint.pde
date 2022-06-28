public class ControlPoint extends Button {

  int mouseOffsetX = 0; //distance from mouse-click to edge of controlpoint
  int mouseOffsetY = 0;
  int xMax = parent.width; // min and max possible location of controlpoint
  int yMax = parent.height;
  int xMin = 0;
  int yMin = 0;
  boolean moving = false; //true if the point is being moved

  //constructor without position
  ControlPoint(PApplet parent, String name) {
    super(parent, name);
    parent.ellipseMode(CORNER);
  }

  void initialize(int a, int b, int c, int d) {
    super.display(a - c / 2, b - d / 2, c, d);
  }

  //use this for limiting the area in which a controlpoint can move
  void constrainPosition() { 
    if (x() > xMax) {
      setX(xMax);
    } else if (x() < xMin) {
      setX(xMin);
    }

    if (y() > yMax) {
      setY(yMax);
    } else if (y() < yMin) {
      setY(yMin);
    }
  }

  void display() {

    //  fill(state? boxActive:boxInactive); //color of rectangle
    parent.ellipse(buttonX, buttonY, buttonWidth, buttonHeight);
    if (displayName) {
      //   fill(state? textActive:textInactive); //color of name
      parent.text(buttonName, buttonX + nameOffsetX, buttonY + nameOffsetY + buttonHeight);
      // fill(state? highGreen:highRed);  //color of hotkey
    }

    //check if user is interacting with it
    if (checkMouse) {
      activateClick();
    }
    if (checkKey) {
      activateKey();
    }

    if (this.isToggled()) {
      if (!moving) {
        mouseOffsetX = parent.mouseX - buttonX;
        mouseOffsetY = parent.mouseY - buttonY;
        moving = true;
      }
      println("[INFO] ControlPoint CLICKED!");
      buttonX = parent.mouseX - mouseOffsetX;
      buttonY = parent.mouseY - mouseOffsetY;
      if (!parent.mousePressed) {
        this.toggle();
        moving = false;
      }
      constrainPosition();
    }
  }

  int x() { //to get the current X position
    return buttonX + int(buttonWidth / 2);
  }

  void setX(int newX) { //set a new X position
    buttonX = newX - int(buttonWidth / 2);
  }

  void constrainX(int newXmin, int newXmax) { //constrain the X position
    xMin = newXmin;
    xMax = newXmax;
  }

  int y() {
    return buttonY + int(buttonHeight / 2);
  }

  void setY(int newY) {
    buttonY = newY - int(buttonHeight / 2);
  }

  void constrainY(int newYmin, int newYmax) {
    yMin = newYmin;
    yMax = newYmax;
  }
}
