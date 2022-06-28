public class DiscreteSlider extends Button {
  int sliderValue; // value between sliderMin - sliderMax
  int sliderPosition; // sliderPosition between [0 - sliderWidth]
  int sliderMin;
  int sliderMax;
  int steps;
  color indicatorColor = color(255, 255, 255);

  DiscreteSlider(PApplet parent, String name, char shortcut, int positionX, int wi) { //its built the same way, just we add a min and max value
    super(parent, name, shortcut);
    sliderValue = 0;
    sliderPosition = positionX + wi/2;
    sliderMin = 0;
    sliderMax = 1;
    steps = 0;
  }

  //constructor without position
  DiscreteSlider(PApplet parent, String name, char shortcut) {
    super(parent, name, shortcut);
  }

  void assignSteps(int stepnumber) {
    steps = stepnumber;
  }

  void assignRange(int min, int max) { //we tell the slider what its range is here
    sliderMin = min;
    sliderMax = max;
    sliderValue = min;
  }

  //alternate constructor, if we want to give it new coordinates
  void display(int x, int y, int w, int h) {
    super.display(x, y, w, h);

    // parent.stroke(255);

    // float currentSliderPosition = (this.getSliderValue() / float(steps-1)) * super.buttonWidth;
    float currentSliderPosition = this.getSliderValue();
    println("[INFO] CurrentSliderPosition: " + str(currentSliderPosition));

    // draw indicator
    // parent.strokeWeight(1);
    // int correctedPos = round(((super.buttonWidth)/steps * this.getSliderValue2()) + super.buttonX;

    // display indicator
    parent.fill(indicatorColor);
    // parent.rect(super.buttonX + currentSliderPosition, super.buttonY, 2, super.buttonHeight);
    parent.rect(this.correctedPos(), super.buttonY, 2, super.buttonHeight);
    // parent.rect(correctedPos, super.buttonY, 5, super.buttonHeight);
    
    // display text
    parent.text(str(this.getSliderValueFinal()), super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight/2)); //add the value, so you know what you're doing
    
    // draw lines
    float stepWidth = super.buttonWidth / (steps);
    for (int i = 0; i < steps + 1; i++) {
        parent.stroke(255);
        parent.line(super.buttonX + int(stepWidth * i), super.buttonY + (super.buttonHeight/2), super.buttonX + int(stepWidth * i), super.buttonHeight + super.buttonY);
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

  // not sure what to use the keyboard shortct for. kinda pointless here
  void activateClick() { //instead of toggling, we move the slider
    if (parent.mousePressed && super.hover()) {
      clicked = true;
      sliderPosition = parent.mouseX - super.buttonX + 1;
    //   if(parent.mouseX >= super.buttonWidth){
    //     sliderPosition = super.buttonX;
    //   } else if (parent.mouseX <= super.buttonX){
    //     sliderPosition = 0;
    //   }

    } else {
      clicked = false;
    }
  }

  int getSliderValue() {
    float tempPosition = map(sliderPosition, super.buttonX, super.buttonX + super.buttonWidth, sliderMin, sliderMax);
    sliderValue = int(tempPosition * float(steps));
    println("Slider position: " + sliderPosition + " Slidervalue: " + sliderValue + " Temp value: " +  tempPosition + " Slidermax: " + sliderMax);
    // return sliderValue;
    return sliderPosition;
  }

  int getSliderValueFinal(){
    int tempVar = round(map(sliderPosition, 0, super.buttonWidth, sliderMin, sliderMax));
    println("LALALA --- " + str(sliderPosition));
    println("MAPMAP --- " + str(tempVar));
    return tempVar;
  }

  int correctedPos(){
    int currentStep = round(((float)steps)*(sliderPosition)/super.buttonWidth);
    int correc = round(((float)super.buttonWidth)/steps*currentStep) + super.buttonX;
    return correc;
  }
}
