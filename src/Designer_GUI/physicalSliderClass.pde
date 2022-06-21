public class PhysicalSlider {

  //this is the representation of the physical slider, which we will "color"
  PApplet parent;
  multiButton[] buttonArray; 
  int multiButtonCount;
  int[] state;
  float buttonHeight;
  int sliderHeight;
  color[] toggleColor;
  color defaultColor = color(18, 18, 18);
  int xPosition;
  int yPosition;
  int sliderWidth;

  PhysicalSlider(PApplet parent, int numberOfButtons) {
    this.parent = parent;
    multiButtonCount = numberOfButtons;
    buttonArray = new multiButton[numberOfButtons];  // create the buttons for chosing colors
    state = new int[numberOfButtons]; // create an array for updating the status of the slider
    toggleColor = new color[numberOfButtons];

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
      //fill(state[i]);
      parent.fill(toggleColor[i]);
      buttonArray[i].display(xPosition, int(yPosition + (i * buttonHeight)), sliderWidth, int(buttonHeight)); 
      if (state[i]!= 0) {
        parent.fill(255); //white text
      }
      //   text(state[i], x+sliderWidth+7, y + (buttonHeight*3/4)+(i*buttonHeight));
    }
  }

  void clearSlider() {
    for (int i = 0; i < state.length; i++) {
      state[i]= -1;
      toggleColor[i] = defaultColor;
    }
  }

  void assignValue(int newValue) {

    parent.stroke(100);
    for (int i =0; i < buttonArray.length; i++) {

      if (buttonArray[i].isToggled()) {

        //if a buttonis newly toggled, we check what our currently active color
        //we then write the color value to the array where we keep track of all colors
        state[i] = newValue;

        //<--- assign properties to array here
      }
    }
  }

  void assignColor(color newColor) {

    parent.stroke(100);
    for (int i = 0; i < buttonArray.length; i++) { //<>//

      if (buttonArray[i].isToggled()) {

        //if a button is newly toggled, we check what our currently active color
        //we then write the color value to the array where we keep track of all colors
        toggleColor[i] =newColor;

        //<--- assign properties to array here
      }
    }
  }

  void defaultColor(color newDefault) {
    defaultColor = newDefault;
  }
}
