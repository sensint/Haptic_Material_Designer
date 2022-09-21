public class PhysicalSlider { 
  PApplet parent;
  multiButton[] buttonArray; 
  int multiButtonCount;
  int[] state;
  float buttonHeight;
  int sliderHeight;
  color[] toggleColor;
  color defaultColor;
  int xPosition;
  int yPosition;
  int sliderWidth;
  color dividerColor = #0a1420; 
  
  PhysicalSlider(PApplet parent, int numberOfButtons, color mainColor) {
    this.parent = parent;
    multiButtonCount = numberOfButtons;
    buttonArray = new multiButton[numberOfButtons]; 
    state = new int[numberOfButtons];
    toggleColor = new color[numberOfButtons];
    this.defaultColor = mainColor;
    
    for (int i = 0; i < buttonArray.length; i++) {
      buttonArray[i] = new multiButton(parent, "");
      state[i] = -1;
      toggleColor[i] = defaultColor;
    }
  }
  
  void drawSlider(int x, int y, int sWidth, int sHeight) {
    xPosition = x;
    yPosition = y;
    sliderWidth = sWidth;
    sliderHeight = sHeight;
    buttonHeight = sHeight / multiButtonCount;
    
    for (int i = 0; i < buttonArray.length; i++) {
      
      parent.fill(toggleColor[i]);
      buttonArray[i].display(xPosition, int(yPosition + (i * buttonHeight)), sliderWidth, int(buttonHeight)); 
      if (state[i]!= 0) {
        parent.fill(255); 
      }
    }
  }
  
  void clearSlider() {
    for (int i = 0; i < state.length; i++) {
      state[i]= -1;
      toggleColor[i] = defaultColor;
    }
  }
  
  void assignValue(int newValue) {
    
    parent.strokeWeight(2);
    parent.stroke(dividerColor);
    for (int i = 0; i < buttonArray.length; i++) {
      
      if (buttonArray[i].isToggled()) {
        state[i] = newValue;
      }
    }
  }
  
  void assignColor(color newColor) {
    
    parent.strokeWeight(2);
    parent.stroke(dividerColor);
    for (int i = 0; i < buttonArray.length; i++) {
      
      if (buttonArray[i].isToggled()) {
        toggleColor[i] = newColor;
      }
    }
  }
  
  void defaultColor(color newDefault) {
    defaultColor = newDefault;
  }
}
