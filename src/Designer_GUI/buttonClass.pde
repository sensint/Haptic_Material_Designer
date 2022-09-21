public class Button {
  PApplet parent;
  int buttonX, buttonY, buttonWidth, buttonHeight; // position & dimensions
  int nameOffsetX, nameOffsetY; // where to draw labels
  boolean state; // on or off
  String buttonName; // name to be displayed
  char hotKey; // keyboard shortcut for toggling button
  boolean readyForClick;
  boolean clicked; // true if currently clicked
  boolean hotKeyHit; // true if the hotkey is currently being pushed
  boolean displayName;
  boolean checkMouse; // set false to deactivate mouse input
  boolean checkKey; // set false to deactivate keyboard shortcuts
  boolean debounce = false; // do not toggle multiple times with one hotkey
  boolean mouseDebounce = false; // do not toggle multiple times with one click
  color boxActive = color(0, 255, 0);
  color boxInactive = color(255, 0, 0);
  color textActive = color(255, 0, 0);
  color textInactive = color(255);
  boolean released;
  
  Button(PApplet parent, String name, char shortcut) {
    this.parent = parent;
    displayName = true;
    checkMouse = true;
    checkKey = true;
    hotKeyHit = false;
    clicked = false;
    released = false;
    buttonX = 0;
    buttonY = 0;
    buttonWidth = 100;
    buttonHeight = 100;
    nameOffsetX = 1;
    nameOffsetY = 15;
    readyForClick = false;
    buttonName = name;
    hotKey = shortcut;
    state = false;
  }
  
  Button(PApplet parent, String name) {
    this.parent = parent;
    displayName = true;
    released = false;
    checkMouse = true;
    checkKey = true;
    hotKeyHit = false;
    clicked = false;
    buttonX = 0;
    buttonY = 0;
    buttonWidth = 100;
    buttonHeight = 100;
    nameOffsetX = 3;
    nameOffsetY = 15;
    readyForClick = false;
    buttonName = name;
    state = false;
  }
  
  void display(int x, int y, int w, int h) {
    buttonX = x;
    buttonY = y;
    buttonWidth = w;
    buttonHeight = h;
    
    parent.rect(buttonX, buttonY, buttonWidth, buttonHeight, 3);
    
    if (displayName) {
      parent.text(buttonName, buttonX + nameOffsetX, buttonY + nameOffsetY + buttonHeight);
    }
    
    // check if user is interacting with it
    if (checkMouse) {
      activateClick();
    }
    if (checkKey) {
      activateKey();
    }
  }
  
  // display label or not (default is on)
  void showLabel(boolean command) {
    displayName = command;
  }
  
  // switches state
  boolean toggle() {
    return state = !state;
  }
  
  // sets state
  void setState(boolean newState) {
    state = newState;
  }
  
  // asks for state
  boolean isToggled() {
    return state;
  }
  
  boolean isClicked() {
    return clicked;
  }
  
  void activateClick() {
    if (!parent.mousePressed && hover()) {
      readyForClick = true;
      mouseDebounce = false;
    } 
    if (parent.mousePressed && readyForClick && !mouseDebounce && hover()) {
      this.toggle();
      mouseDebounce = true;
    } 
    
    if (parent.mousePressed && hover()) {
      clicked = true;
    }
    
    if (!parent.mousePressed || !hover()) {
      clicked = false;
    }
    if (!hover()) {
      readyForClick = false;
    }
  }
  
  // on press behavior
  void activateKey() {
    
    if (parent.keyPressed) {     
      if (parent.key == hotKey)
        hotKeyHit = true;
    } 
    if (hotKeyHit && !debounce) {
      toggle();
      debounce = true;
    } 
    
    if (parent.keyPressed) {
      if (parent.key != hotKey)
        hotKeyHit = false;
    } 
    
    if (!parent.keyPressed) {
      hotKeyHit = false;
      debounce = false;
    }
  }
  
  //checks if cursor is within bounds
  boolean hover() {
    return parent.mouseX > buttonX & parent.mouseX < buttonX + buttonWidth 
    & parent.mouseY > buttonY & parent.mouseY < buttonY + buttonHeight;
  }
  
  void inactiveFill(int a, int b, int c) {
    boxInactive = color(a, b, c);
  }
  
  void activeFill(int a, int b, int c) {
    boxActive = color(a, b, c);
  }
  
  void inactiveTextFill(int a, int b, int c) {
    textInactive = color(a, b, c);
  }
  
  void activeTextFill(int a, int b, int c) {
    textActive = color(a, b, c);
  }
}
