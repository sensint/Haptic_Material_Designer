//these allow creating a bunch of buttons where only one or none can be toggled at once
//very much WIP

public class uniqueSelectButtons {
  PApplet parent;
  Button[] uniqueButtons;
  color[] colorList;
  color defaultColor = color(255, 255, 250);
  color currentColor;
  boolean buttonActive = false;

  // This constructor creates a bunch of buttons
  uniqueSelectButtons(PApplet parent, int numberOfButtons, String[] names, color[] newColors) {

    this.parent = parent;
    uniqueButtons = new Button[numberOfButtons];  // Create the buttons for chosing colors
    for (int i = 0; i < uniqueButtons.length; i++) {
      uniqueButtons[i] = new Button(parent, names[i]);
    }
    colorList = newColors;
  }

  // Makes sure only one button can be selected
  void display(int[][] coordinates) {

    buttonActive = false;
    for (int i = 0; i < uniqueButtons.length; i++) {

      //on click, we need to make sure that only one button is toggled
      if (uniqueButtons[i].isClicked()) { 
        for (int y = 0; y < uniqueButtons.length; y++) {
          if (y!= i) { //all buttons which are not the one currently clicked (so not i)
            if (uniqueButtons[y].isToggled()) { //  will be de-toggled, if they are toggled
              uniqueButtons[y].toggle();
            }
          }
        }
      }

      //for the button that is toggled, we need to chack what color it stores
      //then we make that color be our currently active one
      if (uniqueButtons[i].isToggled()) {
        parent.strokeWeight(1);
        parent.stroke(255);
        parent.fill(colorList[i]);
        buttonActive = true;
        
      } else {  
        parent.fill(colorList[i]);
        parent.strokeWeight(10);
        parent.stroke(defaultColor);
      }
      
      uniqueButtons[i].display(coordinates[i][0], coordinates[i][1], coordinates[i][2], coordinates[i][3]);
    }

    if (!buttonActive) {
    }

    parent.strokeWeight(1);
    parent.stroke(255);
  }

  int activeButton() { //returns -1 for no toggle, otherwise the index of each button

    for (int i = 0; i < uniqueButtons.length; i++) {
      if (uniqueButtons[i].isToggled()) {
        return i;
      }
    }
    return - 1;
  }

  int clickedButton() {
    for (int i = 0; i < uniqueButtons.length; i++) {
      if (uniqueButtons[i].isClicked()) {
        return i;
      }
    }
    return - 1;
  }

  void defaultColor(color newDefault) {
    defaultColor = newDefault;
  }
  
  void setValue(int value){
    uniqueButtons[value].state = true;
  }
}
