import processing.serial.*;

JSONObject data; // Data
JSONArray materialJSON;

// For material parameters's screen
boolean frame2Exit;
SecondApplet sa;
boolean saActive = false;

Serial myPort;

// Responsive screen

// Default values
int defaultFrecuency = 200;
int minFrecuency = 0;
int maxFrecuency = 500;
float defaultAmplitude = 0.5;
int minAmplitude = 0;
int maxAmplitude = 1;
float defaultDuration = 4;
int minDuration = 2;
int maxDuration = 20;
int minBin = 0;
int maxBin = 10;
int defaultWaveForm = 0;
float env_a = 5.0; // attack (ms)
float env_d = 20.0; // decay (ms)
float env_s = 0.9; // sustain (0-1)
float env_r = 100.0; // release (ms)
float defaultA = 5;
float defaultD = 20;
float defaultS = 0.9;
float defaultR = 100;
float[] defaultADSR = {defaultA, defaultD, defaultS, defaultR};
int defaultWave = 0;

// UI Elements
MaterialCollection materials; // materials: we only need one, we have limited it to twelve materials
GrainCalculator yellowGrains, redGrains, blueGrains; // grain calculation: for visualizing grains and storing eventSequences
PhysicalSlider yellowSlider, redSlider, blueSlider; // physical sliders
uniqueSelectButtons materialSelector, parameterSelector; // material selectors
Button saveButton, loadButton, clearButton, uploadButton; // button

String[] materialSelectorNames = {"M0", "M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10"};
String[] parameterSelectorNames = {"Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit"};
int[][] sceneSwitcherPositions = new int[11][4];
int[][] materialSelectorPositions = new int[11][4];
int[] materialGranularity = {0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
int numVerticalButtons = 10;

// Colors
color bgColor = color(18, 18, 18);
color[] materialColors = {
  color(248, 255, 229), 
  color(252, 226, 145), 
  color(255, 196, 61), 
  color(247, 134, 86), 
  color(239, 71, 111), 
  color(186, 92, 126), 
  color(133, 113, 141), 
  color(27, 154, 170), 
  color(17, 184, 165), 
  color(6, 214, 160), 
  color(5, 200, 129)
};

// FIRST WINDOWS ---------------------------------------------------------

String[] getMaterialSequence(color[] sliderColors, color[] materialColors) {
  String[] temp = new String[10];
  for (int i = 0; i < sliderColors.length; i++) {
    for (int j = 0; j < materialColors.length; j++) {
      if (sliderColors[i] == materialColors[j]) {
        // temp[i] = "M" + str(j);
        temp[i] = str(j);
      }
    }
  }
  return temp;
}

void settings() {
  size(int(displayWidth * 0.4), int(displayHeight * 0.8));
}

void setup() {

  textSize(15);

  println("Ports");
  printArray(Serial.list());

  myPort = new Serial(this, Serial.list()[0], 115200);
  print(Serial.list()[0]);

  data = new JSONObject();
  materialJSON = new JSONArray();

  for (int i = 0; i < materialSelectorNames.length; i++) {
    JSONObject currentMaterial = new JSONObject();

    currentMaterial.setString("id", "M" + str(i));
    currentMaterial.setFloat("frecuency", defaultFrecuency);
    currentMaterial.setFloat("amplitude", defaultAmplitude);
    currentMaterial.setFloat("duration", defaultDuration);
    currentMaterial.setFloat("grains", materialGranularity[i]);
    currentMaterial.setFloat("env_a", defaultA);
    currentMaterial.setFloat("env_d", defaultD);
    currentMaterial.setFloat("env_s", defaultS);
    currentMaterial.setFloat("env_r", defaultR);
    currentMaterial.setInt("wave", defaultWave);
    currentMaterial.setBoolean("cv", false);
    materialJSON.setJSONObject(i, currentMaterial);
  }

  materials = new MaterialCollection(); // Create our materialCollection
  int[] defaultMaterialParameters = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}; // Makeup some default parameters

  // Assign with dummy values and defaults
  for (int i = 0; i < materialSelectorNames.length; i++) {
    materials.assign(
      i, 
      "material" + str(i), 
      false, 
      materialGranularity[i], 
      defaultFrecuency, 
      defaultWaveForm, 
      defaultAmplitude, 
      defaultDuration, 
      defaultADSR, 
      defaultMaterialParameters, 
      materialColors[i]);
  }

  // Set positions of material selectors
  for (int i = 0; i < materialSelectorNames.length; i++) { 
    materialSelectorPositions[i][0] = 20;
    materialSelectorPositions[i][1] = 20 + 65 * i;
    materialSelectorPositions[i][2] = 60;
    materialSelectorPositions[i][3] = 35;
  }

  // Set positions of edit selectors
  for (int i = 0; i < parameterSelectorNames.length; i++) { 
    sceneSwitcherPositions[i][0] = 100;
    sceneSwitcherPositions[i][1] = 20 + 65 * i;
    sceneSwitcherPositions[i][2] = 40;
    sceneSwitcherPositions[i][3] = 35;
  }

  yellowSlider = new PhysicalSlider(this, numVerticalButtons);
  yellowSlider.drawSlider(200, 25, 90, 700); 
  redSlider = new PhysicalSlider(this, numVerticalButtons);
  redSlider.drawSlider(400, 25, 90, 700);
  blueSlider = new PhysicalSlider(this, numVerticalButtons);
  blueSlider.drawSlider(600, 25, 90, 700);

  saveButton = new Button(this, "Save");
  loadButton = new Button(this, "Load");
  clearButton = new Button(this, "Clear");
  uploadButton = new Button(this, "Upload", 'G');

  materialSelector = new uniqueSelectButtons(this, materialSelectorNames.length, materialSelectorNames, materialColors);
  materialSelector.defaultColor(bgColor); 
  parameterSelector = new uniqueSelectButtons(this, parameterSelectorNames.length, parameterSelectorNames, materialColors);
  parameterSelector.defaultColor(bgColor);

  yellowGrains = new GrainCalculator(this, "yellow", yellowSlider, materials, 1024); // slider to calculate, materialcollection to use, target range
  redGrains = new GrainCalculator(this, "red", redSlider, materials, 1024); // slider to calculate, materialcollection to use, target range
  blueGrains = new GrainCalculator(this, "blue", blueSlider, materials, 1024); // slider to calculate, materialcollection to use, target range
}

void draw() {

  background(18, 18, 18);

  // Display buttons
  saveButton.display(20, 770, 100, 35);  
  loadButton.display(140, 770, 100, 35);
  clearButton.display(260, 770, 100, 35);
  uploadButton.display(380, 770, 100, 35);

  // Display material and parameter window selector
  materialSelector.display(materialSelectorPositions);
  parameterSelector.display(sceneSwitcherPositions);

  int toggleMaterial = materialSelector.activeButton(); // Get index of toggled button
  int toggleScene = parameterSelector.clickedButton();

  if (toggleMaterial!= -1) { // No value assigned case

    yellowSlider.assignValue(toggleMaterial);
    yellowSlider.assignColor(materialColors[toggleMaterial]); //don't do this
    redSlider.assignValue(toggleMaterial);
    redSlider.assignColor(materialColors[toggleMaterial]); //don't do this
    blueSlider.assignValue(toggleMaterial);
    blueSlider.assignColor(materialColors[toggleMaterial]); //don't do this
  } else {

    yellowSlider.assignColor(yellowSlider.defaultColor);
    yellowSlider.assignValue(toggleMaterial); //no value assigned
    redSlider.assignColor(yellowSlider.defaultColor);
    redSlider.assignValue(toggleMaterial); //no value assigned
    redSlider.assignColor(yellowSlider.defaultColor);
    redSlider.assignValue(toggleMaterial); //no value assigned
  }

  // Display second window
  if (toggleScene!= -1) {
    if (saActive == false) {
      frame2Start(toggleScene, str(toggleScene));
      saActive = true;
    }
  }

  // Display physical sliders
  yellowSlider.drawSlider(200, 25, 90, 700);
  redSlider.drawSlider(400, 25, 90, 700);
  blueSlider.drawSlider(600, 25, 90, 700);

  // Clear button event
  if (clearButton.isClicked()) {
    yellowSlider.clearSlider();
    redSlider.clearSlider();
    blueSlider.clearSlider();
  }

  // Save button event
  if (saveButton.isClicked()) {
    saveJSONArray(materialJSON, "sequences/materials.json");
  }

  // Load button event
  if (loadButton.isClicked()) {

    String[] materialPositions = getMaterialSequence(yellowSlider.toggleColor, materialColors);

    printArray(materialPositions);
    println(".........................");
  }

  // Upload button event
  //if (uploadButton.isClicked()) {
  //  String[] materialPositions = getMaterialSequence(yellowSlider.toggleColor, materialColors);
  //  printArray(materialPositions);
  //  for (int i=0; i < materialPositions.length; i++) {
  //    // myPort.write(byte(int(materialPositions[i])));
  //    myPort.write(materialPositions[i]);
  //  }
  //  println("SEND IT!");
  //}

  // Update grains
  yellowGrains.updateGrains();
  redGrains.updateGrains();
  blueGrains.updateGrains();

  // println(yellowGrains.grainsPositions);
}

void frame2Start(int index, String name) {
  sa = new SecondApplet(name, index);
  frame2Exit = false;
}

void mouseReleased()
{
  // Upload button event
  if (uploadButton.isClicked()) {
    String[] materialPositions = getMaterialSequence(yellowSlider.toggleColor, materialColors);
    // printArray(materialPositions);
    for (int i=0; i < materialPositions.length; i++) {
      // myPort.write(byte(int(materialPositions[i])));
      myPort.write(materialPositions[i]);
      myPort.write(",");
      println(materialPositions[i]);
    }
    println("SEND IT!");
     // myPort.clear();
  }
}
