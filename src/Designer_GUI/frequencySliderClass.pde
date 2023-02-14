public class FrequencySlider extends Button {
  float sliderValue;
  float sliderPosition;
  int sliderMin;
  int sliderMax;
  boolean active;
  color indicatorColor = color(255, 255, 255);
  String unit;
  
  FrequencySlider(PApplet parent, String name, char shortcut, int min, int max, float defaultValue, String mes) {
    super(parent, name, shortcut);
    sliderValue = defaultValue;
    sliderMin = min;
    sliderMax = max;
    active = false;
    unit = mes;
  }
  
  void display(int a, int b, int c, int d) {
    super.display(a, b, c, d);
    parent.noStroke();
    float range = sliderMax - sliderMin;
    float stepsize = c / range;
    sliderPosition = sliderValue * stepsize + a / 2 - 3;
    displayIndicator();
    parent.text(nf(sliderValue, 0, 1), super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight / 2));
    parent.text(unit, super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight - 6));
  }
  
  void displayIndicator() {
    parent.fill(indicatorColor);
    parent.rect(sliderPosition - 1, super.buttonY, 3, super.buttonHeight);
  }
  
  void setSliderValue(float target) {
    sliderValue = target;
  }
  
  void activateClick() { //instead of toggling, we move the slider
    
    if (!parent.mousePressed && super.hover()) {
      readyForClick = true;
    } else if (!parent.mousePressed) {
      readyForClick = false;
    }
    
    if (parent.mousePressed &&  readyForClick) {
      active = true;
      if (parent.mouseX > buttonX && parent.mouseX < buttonX + buttonWidth) {
        if ((parent.mouseY < buttonY) || (parent.mouseY > buttonY + buttonHeight)) {
          parent.fill(0);
        } else {
          parent.fill(255);
        }
        
        sliderPosition = parent.mouseX;
        sliderValue = this.getSliderValue();
      }
      parent.fill(255);
      
      clicked = true;
    } else {
      active = false;
    }
  }
  
  boolean sliderActive() {
    return active;
  }
  
  int getSliderValue() {
    int temp = round(map(sliderPosition, super.buttonX, super.buttonX + super.buttonWidth, sliderMin, sliderMax));
    return temp;
  }
  
  void indicatorColorFill(int a, int b, int c) {
    indicatorColor = color(a, b, c);
  }
  
  void indicatorColorFill(int a, int b, int c, int d) {
    indicatorColor = color(a, b, c, d);
  }
}
