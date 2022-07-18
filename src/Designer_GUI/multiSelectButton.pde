//these will form the basics of assigning matrials to sliders. 
//they detoggle right away
//very much WIP
public class multiButton extends Button {
    float sliderValue;
    int sliderMin;
    int sliderMax;
    int sliderPosition;
    boolean active;
    color handle = color(255, 255, 255);

    //constructor without position
    multiButton(PApplet parent, String name) {
        super(parent, name);
        displayName = false;
    }

    void display(int a, int b, int c, int d) {
        super.display(a, b, c, d);
    }

    void activateClick() { //it detoggles IMMEDIATLY!

        //gotta check if another one is not still clicked
        if (!parent.mousePressed) {
            if (this.isToggled()) {
                this.toggle();
            }
            mouseDebounce = false;
            // println("not pressed + hover");
        } 
        if (parent.mousePressed && !mouseDebounce && hover()) {
            this.toggle();
            mouseDebounce = true;
            //   println("all the things");
        } 

        //see if its being pressed
        if (parent.mousePressed && hover()) {
            clicked = true;
            //     println("pressed + hover");
        }
    }
}
