public class DiscreteSlider extends Button {
  int sliderValue; // value between sliderMin - sliderMax
  int sliderPosition; // sliderPosition between [0 - sliderWidth]
  int sliderMin;
  int sliderMax;
  int steps;
  String name;
  color indicatorColor = color(255, 255, 255);
  boolean ticks = true;
  String unit;
  
  DiscreteSlider(PApplet parent, String name, char shortcut, int positionX, int wi) { //its built the same way, just we add a min and max value
    super(parent, name, shortcut);
    sliderValue = 0;
    sliderPosition = positionX + wi / 2;
    sliderMin = 0;
    sliderMax = 1;
    steps = 0;
  }
  
  DiscreteSlider(PApplet parent, String name, char shortcut, int min, int max, int value, int stepnumber, int wi, String mes) {
    super(parent, name, shortcut);
    sliderValue = value;
    sliderMin = min;
    sliderMax = max;
    steps = stepnumber;
    sliderPosition = (value - sliderMin) * ((wi) / (steps));
    this.name = name;
    this.unit = mes;
  }
  
  void setSliderValue(int value) {
    sliderPosition = (value - sliderMin) * (super.buttonWidth / (steps));
  }
  
  void showTicks(boolean value) {
    ticks = value;
  }
  
  void display(int x, int y, int w, int h) {
    super.display(x, y, w, h);
    
    parent.noStroke();
    
    // display indicator
    parent.fill(indicatorColor);
    parent.rect(this.indicatorPos(), super.buttonY, 3, super.buttonHeight);
    
    // display text
    parent.text(str(this.getSliderValue()), super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight / 2));
    parent.text(unit, super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight - 6));
    
    // draw lines
    if (ticks == true) {
      drawTicks();
    }
  }
  
  void drawTicks() {
    float stepWidth = super.buttonWidth / (steps);
    for (int i = 0; i < steps + 1; i++) {
      parent.stroke(255);
      parent.line(super.buttonX + int(stepWidth * i), super.buttonY + (super.buttonHeight / 2), super.buttonX + int(stepWidth * i), super.buttonHeight + super.buttonY);
    }
  }
  
  boolean isClicked() {
    if (parent.mousePressed && super.hover()) {
      clicked = true;
      sliderPosition = parent.mouseX - super.buttonX;
    } else {
      clicked = false;
    }
    return clicked;
  }
  
  void activateClick() { //instead of toggling, we move the slider
    if (parent.mousePressed && super.hover()) {
      clicked = true;
      sliderPosition = parent.mouseX - super.buttonX + 1;
    } else {
      clicked = false;
    }
  }
  
  int getSliderValue() {
    int tempVar = round(map(sliderPosition, 0, super.buttonWidth, sliderMin, sliderMax));
    return tempVar;
  }
  
  int indicatorPos() {
    int currentStep = round(((float)steps) * (sliderPosition) / super.buttonWidth);
    int correc = round(((float)super.buttonWidth) / steps * currentStep) + super.buttonX;
    return correc;
  }
}
