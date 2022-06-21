JSONObject data; // Data
JSONArray materialJSON;

// For material parameters's screen
boolean frame2Exit;
SecondApplet sa;
boolean saActive = false;

// Default values
float defaultFrecuency = 200;
int minFrecuency = 0;
int maxFrecuency = 500;
float defaultAmplitude = 0.5;
int minAmplitude = 0;
int maxAmplitude = 1;
float defaultDuration = 200;
int minDuration = 0;
int maxDuration = 1000;
float defaultBin = 30;
int minBin = 2;
int maxBin = 100;
int defaultWaveForm = 0;
float env_a = 5; // attack (ms)
float env_d = 20; // decay (ms)
float env_s = 0.9; // sustain (0-1)
float env_r = 100; // release (ms)
float defaultA = 5;
float defaultD = 20;
float defaultS = 0.9;
float defaultR = 100;
int defaultWave = 0;

// UI Elements
MaterialCollection material; // materials: we only need one, we have limited it to twelve materials
GrainCalculator yellowGrains, redGrains, blueGrains; // grain calculation: for visualizing grains and storing eventSequences
PhysicalSlider yellowSlider, redSlider, blueSlider; // physical sliders
uniqueSelectButtons materialSelector, parameterSelector; // material selectors
Button saveButton, loadButton, clearButton, uploadButton; // button

String[] materialSelectorNames = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "CV"};
String[] parameterSelectorNames = {"Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit"};
int[][] sceneSwitcherPositions = new int[10][4];
int[][] materialSelectorPositions = new int[11][4];

// Colors
color bgColor = color(18, 18, 18);
color[] guiColors = {
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
  color(5, 182, 129), 
  color(18, 18, 18)
};


// FIRST WINDOWS ---------------------------------------------------------

void settings() {
  size(760, 860);
}

void setup() {

  data = new JSONObject();
  materialJSON = new JSONArray();

  for (int i = 0; i < 11; i++) {
    JSONObject currentMaterial = new JSONObject();

    currentMaterial.setInt("id", i);
    currentMaterial.setFloat("frecuency", defaultFrecuency);
    currentMaterial.setFloat("amplitude", defaultAmplitude);
    currentMaterial.setFloat("duration", defaultDuration);
    currentMaterial.setFloat("num_bin", defaultBin);
    currentMaterial.setFloat("env_a", defaultA);
    currentMaterial.setFloat("env_d", defaultD);
    currentMaterial.setFloat("env_s", defaultS);
    currentMaterial.setFloat("env_r", defaultR);
    currentMaterial.setInt("wave", defaultWave);
    materialJSON.setJSONObject(i, currentMaterial);
  }
  

  material = new MaterialCollection(); // Create our materialCollection
  int[] newParameters = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}; // Makeup some default parameters

  // Assign with dummy values and defaults
  for (int i = 0; i < 11; i++) {
    material.assign(i, "defaultName", true, int((i) * 10), newParameters, guiColors[i]);
  }

  // Set positions of material selectors
  for (int i = 0; i < materialSelectorNames.length; i++) { 
    materialSelectorPositions[i][0] = 20;
    materialSelectorPositions[i][1] = 20 + 65 * i;
    materialSelectorPositions[i][2] = 60;
    materialSelectorPositions[i][3] = 35;
  }

  // Set positions of scene selectors
  for (int i = 0; i < parameterSelectorNames.length; i++) { 
    sceneSwitcherPositions[i][0] = 100;
    sceneSwitcherPositions[i][1] = 20 + 65 * i;
    sceneSwitcherPositions[i][2] = 40;
    sceneSwitcherPositions[i][3] = 35;
  }

  yellowSlider = new PhysicalSlider(this, 10);
  yellowSlider.drawSlider(200, 25, 90, 700); 
  redSlider = new PhysicalSlider(this, 10);
  redSlider.drawSlider(400, 25, 90, 700);
  blueSlider = new PhysicalSlider(this, 25);
  blueSlider.drawSlider(600, 25, 90, 700);

  saveButton = new Button(this, "Save");
  loadButton = new Button(this, "Load");
  clearButton = new Button(this, "Clear");
  uploadButton = new Button(this, "Upload");

  materialSelector = new uniqueSelectButtons(this, materialSelectorNames.length, materialSelectorNames, guiColors); //number of buttons, names, colors
  materialSelector.defaultColor(bgColor); //set a new default (should be same as background, probably)
  parameterSelector = new uniqueSelectButtons(this, parameterSelectorNames.length, parameterSelectorNames, guiColors); //number of buttons, names, colors
  parameterSelector.defaultColor(bgColor); //set a new default (should be same as background, probably)

  textSize(15);

  yellowGrains = new GrainCalculator(this, "yellow", yellowSlider, material, 1024); // slider to calculate, materialcollection to use, target range
  redGrains = new GrainCalculator(this, "red", redSlider, material, 1024); // slider to calculate, materialcollection to use, target range
  blueGrains = new GrainCalculator(this, "blue", blueSlider, material, 1024); // slider to calculate, materialcollection to use, target range
}

void draw() {

  background(18, 18, 18);

  // Display buttons
  saveButton.display(20, 770, 100, 35);  
  loadButton.display(140, 770, 100, 35);
  clearButton.display(260, 770, 100, 35);
  uploadButton.display(380, 770, 100, 35);

  materialSelector.display(materialSelectorPositions); // Display them and check for toggle status
  parameterSelector.display(sceneSwitcherPositions); // Display them and check for toggle status

  int toggleMaterial = materialSelector.activeButton(); // Get index of toggled button
  int toggleScene = parameterSelector.clickedButton();

  if (toggleMaterial!= -1) { // No value assigned case

    yellowSlider.assignValue(toggleMaterial);
    yellowSlider.assignColor(guiColors[toggleMaterial]); //don't do this
    redSlider.assignValue(toggleMaterial);
    redSlider.assignColor(guiColors[toggleMaterial]); //don't do this
    blueSlider.assignValue(toggleMaterial);
    blueSlider.assignColor(guiColors[toggleMaterial]); //don't do this
  } else {

    yellowSlider.assignColor(yellowSlider.defaultColor);
    yellowSlider.assignValue(toggleMaterial); //no value assigned
    redSlider.assignColor(yellowSlider.defaultColor);
    redSlider.assignValue(toggleMaterial); //no value assigned
    redSlider.assignColor(yellowSlider.defaultColor);
    redSlider.assignValue(toggleMaterial); //no value assigned
  }

  if (toggleScene!= -1) {
    if (saActive == false) {
      frame2Start(toggleScene, str(toggleScene));
      saActive = true;
    }
  } else {
  }

  yellowSlider.drawSlider(200, 25, 90, 700);
  redSlider.drawSlider(400, 25, 90, 700);
  blueSlider.drawSlider(600, 25, 90, 700);

  //if (frame2Exit)
  //{
  //  frame2Start();
  //}

  // Buttons events
  if (clearButton.isClicked()) {
    yellowSlider.clearSlider();
    redSlider.clearSlider();
    blueSlider.clearSlider();
  }

  if (saveButton.isClicked()) {
    saveJSONArray(materialJSON, "sequences/materials.json");
  }

  if (loadButton.isClicked()) {
  }

  if (uploadButton.isClicked()) {
  }

  yellowGrains.updateGrains();
  redGrains.updateGrains();
  blueGrains.updateGrains();
}

void frame2Start(int index, String name) {
  sa = new SecondApplet(name, index);
  frame2Exit = false;
}
