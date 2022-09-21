public class multiButton extends Button {
  float sliderValue;
  int sliderMin;
  int sliderMax;
  int sliderPosition;
  boolean active;
  color handle = color(255, 255, 255);
  
  multiButton(PApplet parent, String name) {
    super(parent, name);
    displayName = false;
  }
  
  void display(int a, int b, int c, int d) {
    super.display(a, b, c, d);
  }
  
  void activateClick() { 
    if (!parent.mousePressed) {
      if (this.isToggled()) {
        this.toggle();
        }
      mouseDebounce = false;
      
      } 
    if (parent.mousePressed && !mouseDebounce && hover()) {
      this.toggle();
      mouseDebounce = true;
      
      } 
    
    if (parent.mousePressed && hover()) {
      clicked = true;
      
      }
  }
}
