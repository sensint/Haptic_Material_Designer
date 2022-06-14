void setup() {
  size(400, 400);
}


void draw() {
  if (mousePressed) {
    fill(0);
    ellipse(mouseX, mouseY, 3, 3);
  }
}
