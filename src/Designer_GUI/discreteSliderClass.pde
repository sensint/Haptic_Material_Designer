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
        sliderPosition = positionX + wi/2;
        sliderMin = 0;
        sliderMax = 1;
        steps = 0;
    }

    //constructor without position
    DiscreteSlider(PApplet parent, String name, char shortcut, int min, int max, int value, int stepnumber, int wi, String mes) {
        super(parent, name, shortcut);
        sliderValue = value;
        sliderMin = min;
        sliderMax = max;
        steps = stepnumber;
        //sliderPosition = int(map(value, sliderMin, sliderMax, sliderMin, sliderMax));
        sliderPosition = value * (wi / (steps));
        //print("sliderPosition: ");
        //println(sliderPosition);
        //println(name + " - SLIDER POSITION 1: " + str(sliderPosition));
        //println(name + " - STEPH WITH: " + str((wi / (steps))));
        this.name = name;
        this.unit = mes;
    }

    void setSliderValue(int value) {
        sliderPosition = value * (super.buttonWidth / (steps));
    }

    void showTicks(boolean value) {
        ticks = value;
    }

    //alternate constructor, if we want to give it new coordinates
    void display(int x, int y, int w, int h) {
        super.display(x, y, w, h);

        parent.noStroke();

        // display indicator
        parent.fill(indicatorColor);
        parent.rect(this.indicatorPos(), super.buttonY, 3, super.buttonHeight);
        //print("indicatorpos: ");
        //println(this.indicatorPos());

        // display text
        parent.text(str(this.getSliderValue()), super.buttonX + super.buttonWidth + 10, super.buttonY + (super.buttonHeight/2));
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
        int tempVar = round(map(sliderPosition, 0, super.buttonWidth, sliderMin, sliderMax));
        return tempVar;
    }

    int indicatorPos() {
        int currentStep = round(((float)steps) * (sliderPosition) / super.buttonWidth);
        int correc = round(((float)super.buttonWidth) / steps * currentStep) + super.buttonX;
        //println(this.name + " - SLIDER POSITION 2: " + str(sliderPosition));
        //println(this.name + " - CORREC: " + str(correc));
        return correc;
    }
}
