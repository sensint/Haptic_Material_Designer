//TODO: needs a 'void setSliderValue(int x)' function
//needs some method of entering a precise value by keyboard
//maybe also constraining it to certain step sizes (using integer instead of float might already fix stuff

//slider value is in percent (float between 0 and 1)
//slider POSITION is pixels (int between sliderMin and sliderMax);

//might need some more options to edit the indicatorColor appearence

//a slider is a button that does not toggle, instead it returns a value

public class FrequencySlider extends Button {
    float sliderValue;
    float sliderPosition;
    int sliderMin;
    int sliderMax;
    boolean active;
    color indicatorColor = color(255, 255, 255);
    String unit;

    // Constructor without position
    FrequencySlider(PApplet parent, String name, char shortcut, int min, int max, float defaultValue, String mes) {
        super(parent, name, shortcut);
        //sliderValue = 0.5;
        //sliderMin = 0;
        //sliderMax = 1;
        sliderValue = defaultValue;
        sliderMin = min;
        sliderMax = max;
        active = false;
        unit = mes;
    }

    void display(int a, int b, int c, int d) {

        super.display(a, b, c, d);
        parent.noStroke();
        float range = sliderMax-sliderMin;
        float stepsize = c/range;
        println("superX = " + super.buttonX + ", a = "+ a );
        println("superX = " + super.buttonWidth + ", c = "+ c );
        sliderPosition = sliderValue * stepsize + a/2 -3;
       // sliderPosition = int(super.buttonWidth * ((sliderValue - sliderMin)/(sliderMax - sliderMin))) + super.buttonX;
        displayIndicator();
        parent.text(nf(sliderValue, 0, 1), super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight/2));
        //parent.text(sliderValue, super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight/2 + 6));
        parent.text(unit, super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight - 6));
    }

    void displayIndicator() {
        parent.fill(indicatorColor);
        parent.rect(sliderPosition-1, super.buttonY, 3, super.buttonHeight);
    }

    //create the slider
    //void display(int x, int y, int w, int h) {
    //  buttonX = x;
    //  buttonY = y;
    //  buttonWidth = w;
    //  buttonHeight = h;
    //  sliderPosition = int(buttonWidth*sliderValue)+buttonX;

    //  fill(state? boxActive:boxInactive); //color of rectangle
    //  rect(buttonX, buttonY, buttonWidth, buttonHeight);
    //  stroke(255, 0, 0);
    //  fill(indicatorColor);
    //  rect(sliderPosition-2, buttonY, 4, buttonHeight);

    //  if (this.checkMouse) {
    //    this.activateClick();
    //  }
    //  if (this.checkKey) {
    //    this.activateKey();
    //  }
    //  if (displayName) {
    //    fill(state? textActive:textInactive); //color of name
    //    text(buttonName, buttonX+nameOffsetX, buttonY+nameOffsetY+buttonHeight);
    //    // fill(state? highGreen:highRed);  //color of hotkey
    //  }
    //}

    void setSliderValue(float target) {
        sliderValue = target;
    }

    // not sure what to use the keyboard shortct for. kinda pointless here
    //I changed it around, so the curser can drift out of the slider
    void activateClick() { //instead of toggling, we move the slider

        if (!parent.mousePressed && super.hover()) {
            readyForClick = true;
        } else if (!parent.mousePressed) {
            readyForClick = false;
        }

        if (parent.mousePressed &&  readyForClick) {
            active= true;
            if (parent.mouseX > buttonX && parent.mouseX < buttonX+buttonWidth) {
                if ((parent.mouseY < buttonY) || (parent.mouseY > buttonY + buttonHeight)) {
                    parent.fill(0);
                } else {
                    parent.fill(255);
                }

                sliderPosition = parent.mouseX;
                // parent.text(str(this.getSliderValue()), parent.mouseX + 10, parent.mouseY + 10);
                // parent.text(str(this.getSliderValue()), super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight/2 + 6));
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

    int getSliderValue() { // Here we ask what its value is
        int temp = round(map(sliderPosition, super.buttonX, super.buttonX + super.buttonWidth, sliderMin, sliderMax));
        return temp;
        //return round(sliderValue * 1000) / 1000;
        //return sliderValue - sliderValue % 0.1;
        //return sliderValue;
    }

    void indicatorColorFill(int a, int b, int c) {
        indicatorColor = color(a, b, c);
    }

    void indicatorColorFill(int a, int b, int c, int d) {
        indicatorColor = color(a, b, c, d);
    }
}
