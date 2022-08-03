import processing.serial.*;

JSONObject data;
JSONArray materialJSON;
JSONArray sequencesJSON;
JSONArray yellowJSON;
JSONArray redJSON;
JSONArray blueJSON;

Serial myPort;

// Delimiters
String msgStart = "<";
String msgEnd = ">";

// Message types
String msgAddMaterial = "48";
String msgUpdateMaterial = "49";
String msgDeleteMaterial = "50";

String msgAddMaterialList = "51";
String msgUpdateMaterialList = "52";
String msgDeleteMaterialList = "53";

String msgAddGrainSequence = "54";
String msgUpdateGrainSequence = "55";
String msgDeleteGrainSequence = "56";

String msgAddGrainSequenceList = "57";
String msgUpdateGrainSequenceList = "58";
String msgDeleteGrainSequenceList = "59";

int msgDestBroadcast = 0;

// For material parameters' screen
boolean frame2Exit;
SecondApplet sa;
boolean saActive = false;

// Responsive screen

// UI Colors
color mainColor = #0D1B2A;
color secondaryColor = color(88, 111, 124);
color textColor = #E0E1DD;
color whiteColor = textColor;

// Default values
int defaultFrecuency = 200;
int minFrecuency = 20;
int maxFrecuency = 400;
float defaultAmplitude = 0.5;
int minAmplitude = 0;
int maxAmplitude = 1;
int defaultDuration = 4;
int minDuration = 2;
int maxDuration = 20;
int minBin = 0;
int maxBin = 10;
int defaultWaveForm = 0;
int defaultWave = 0;
int defaultMode = 1;

// UI Elements
MaterialCollection materials;
GrainCalculator yellowGrains, redGrains, blueGrains;
PhysicalSlider yellowSlider, redSlider, blueSlider; 
uniqueSelectButtons materialSelector, parameterSelector;
Button saveButton, loadButton, clearButton, uploadButton;

String[] materialSelectorNames = {"M0", "M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10"};
String[] parameterSelectorNames = {"Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit"};

int[][] sceneSwitcherPositions = new int[11][4];
int[][] materialSelectorPositions = new int[11][4];

int[] materialGranularity = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
int numVerticalButtons = 10;

// For loading and saving JSON files
String selectedDesign = "";
String filenameJSON = "";
boolean fileReaded = false;
boolean fileTyped = false;

// Material colors
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

color[] uiColors = {
  color(88, 111, 124), 
  color(88, 111, 124), 
  color(88, 111, 124), 
  color(88, 111, 124), 
  color(88, 111, 124), 
  color(88, 111, 124)
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

String[] fromColorToMaterial(ArrayList<Integer> rawColors, color[] materialColors) {
  String[] temp = new String[rawColors.size()];
  for (int i = 0; i < rawColors.size(); i++) {
    for (int j = 0; j < materialColors.length; j++) {
      if (rawColors.get(i) == materialColors[j]) {
        // temp[i] = "M" + str(j);
        temp[i] = str(j);
      }
    }
  }
  return temp;
}

void settings() {
  size(int(displayWidth * 0.4), int(displayHeight * 0.78));
}

void setup() {

  surface.setTitle("Tactile Symbol Designer");
  textSize(15);

  println("Ports");
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 115200);
  print(Serial.list()[0]);

  data = new JSONObject();
  materialJSON = new JSONArray();

  for (int i = 0; i < materialSelectorNames.length; i++) {
    JSONObject currentMaterial = new JSONObject();
    currentMaterial.setString("material_id", str(i));
    currentMaterial.setString("frecuency", str(defaultFrecuency));
    currentMaterial.setString("amplitude", str(defaultAmplitude));
    currentMaterial.setString("duration", str(defaultDuration));
    currentMaterial.setString("grains", str(materialGranularity[i]));
    currentMaterial.setString("waveform", str(defaultWave));
    currentMaterial.setString("cv", str(defaultMode));
    materialJSON.setJSONObject(i, currentMaterial);
  }

  materials = new MaterialCollection(); // Create our materialCollection
  int[] defaultMaterialParameters = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}; // Makeup some default parameters

  // Assign default values
  for (int i = 0; i < materialSelectorNames.length; i++) {
    materials.assign(
      i, 
      "material" + str(i), 
      defaultMode, 
      materialGranularity[i], 
      defaultFrecuency, 
      defaultWaveForm, 
      defaultAmplitude, 
      defaultDuration, 
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

  redSlider = new PhysicalSlider(this, numVerticalButtons, color(241, 89, 110, 50));
  redSlider.drawSlider(200, 25, 90, 700);

  yellowSlider = new PhysicalSlider(this, numVerticalButtons, color(255, 209, 102, 50));
  yellowSlider.drawSlider(400, 25, 90, 700); 

  blueSlider = new PhysicalSlider(this, numVerticalButtons, color(15, 157, 174, 50));
  blueSlider.drawSlider(600, 25, 90, 700);

  saveButton = new Button(this, "Save");
  loadButton = new Button(this, "Load");
  clearButton = new Button(this, "Clear all");
  uploadButton = new Button(this, "Upload");

  materialSelector = new uniqueSelectButtons(this, materialSelectorNames.length, materialSelectorNames, materialColors);
  materialSelector.defaultColor(mainColor); 
  parameterSelector = new uniqueSelectButtons(this, parameterSelectorNames.length, parameterSelectorNames, materialColors);
  parameterSelector.defaultColor(mainColor);

  redGrains = new GrainCalculator(this, "red", redSlider, materials, 1024); // slider to calculate, materialcollection to use, target range
  yellowGrains = new GrainCalculator(this, "yellow", yellowSlider, materials, 1024); // slider to calculate, materialcollection to use, target range
  blueGrains = new GrainCalculator(this, "blue", blueSlider, materials, 1024); // slider to calculate, materialcollection to use, target range
}

void draw() {

  background(mainColor);

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

    redSlider.assignColor(redSlider.defaultColor);
    redSlider.assignValue(toggleMaterial); //no value assigned

    blueSlider.assignColor(blueSlider.defaultColor);
    blueSlider.assignValue(toggleMaterial); //no value assigned
  }

  // Display second window
  if (toggleScene!= -1) {
    if (saActive == false) {
      frame2Start(toggleScene, str(toggleScene));
      saActive = true;
    }
  }

  // Display physical sliders
  redSlider.drawSlider(200, 25, 90, 700);
  yellowSlider.drawSlider(400, 25, 90, 700);
  blueSlider.drawSlider(600, 25, 90, 700);

  // Update grains
  yellowGrains.updateGrains();
  redGrains.updateGrains();
  blueGrains.updateGrains();

  // println(yellowSlider.state);
  //println(yellowGrains.vibrationMode);

  //println(yellowGrains.grainsPositions);
  //println(yellowGrains.grainsMaterials);
  //printArray(fromColorToMaterial(yellowGrains.grainsMaterials, materialColors));
  //println(yellowSlider.state);
  ///¡println(yellowSlider.toggleColor);

  // Display buttons
  fill(whiteColor);
  saveButton.display(20, 770, 100, 35);  
  loadButton.display(140, 770, 100, 35);
  clearButton.display(260, 770, 100, 35);
  uploadButton.display(380, 770, 100, 35);
}

void frame2Start(int index, String name) {
  sa = new SecondApplet(name, index);
  frame2Exit = false;
}

void mouseReleased()
{
  // Clear button event
  if (clearButton.isClicked()) {
    yellowSlider.clearSlider();
    redSlider.clearSlider();
    blueSlider.clearSlider();
  }

  // Save button event
  if (saveButton.isClicked()) {

    selectOutput("Type the name of the design:", "fileSelectedJSON", dataFile( ".json" ));

    while (fileTyped == false) {
      println("No filename saved yet.");
    }

    if (filenameJSON != "") {

      // Get data from physical sliders
      yellowJSON = new JSONArray();
      for (int i = 0; i < yellowSlider.state.length; i++) {
        JSONObject _slider = new JSONObject();
        _slider.setString("material", str(yellowSlider.state[i]));
        _slider.setString("color", str(yellowSlider.toggleColor[i]));
        yellowJSON.setJSONObject(i, _slider);
      }

      redJSON = new JSONArray();
      for (int i = 0; i < redSlider.state.length; i++) {
        JSONObject _slider = new JSONObject();
        _slider.setString("material", str(redSlider.state[i]));
        _slider.setString("color", str(redSlider.toggleColor[i]));
        redJSON.setJSONObject(i, _slider);
      }

      blueJSON = new JSONArray();
      for (int i = 0; i < blueSlider.state.length; i++) {
        JSONObject _slider = new JSONObject();
        _slider.setString("material", str(blueSlider.state[i]));
        _slider.setString("color", str(blueSlider.toggleColor[i]));
        blueJSON.setJSONObject(i, _slider);
      }

      // Save data
      data.setJSONArray("materials", materialJSON);
      data.setJSONArray("yellow", yellowJSON);
      data.setJSONArray("red", redJSON);
      data.setJSONArray("blue", blueJSON);

      filenameJSON = filenameJSON.replace("\\", "/");
      // println(filenameJSON);
      saveJSONObject(data, filenameJSON);
    }
    
    fileTyped = false;
  }

  // Upload button event
  if (uploadButton.isClicked()) {

    sendAddMaterialList();
    sendAddGrainSequence(0, "red");
    sendAddGrainSequence(1, "yellow");
    sendAddGrainSequence(2, "blue");
  }

  // Load button event
  if (loadButton.isClicked()) {
    
    println("Load cliecke");

    selectInput("Select a file to process:", "fileSelected", dataFile( "*.json" ));

    int aa = 0;
    while (fileReaded == false) {
      println("No selected loaded yet: " + str(aa));
      aa+=1;
    }

    if (selectedDesign != "") {

      yellowSlider.clearSlider();
      redSlider.clearSlider();
      blueSlider.clearSlider();

      JSONObject dataLoad = loadJSONObject(selectedDesign);
      JSONArray materialsLoad = dataLoad.getJSONArray("materials");
      JSONArray yellowLoad = dataLoad.getJSONArray("yellow");
      JSONArray redLoad = dataLoad.getJSONArray("red");
      JSONArray blueLoad = dataLoad.getJSONArray("blue");

      // Load materials
      for (int i = 0; i < materialsLoad.size(); i++) {

        JSONObject matLoad = materialsLoad.getJSONObject(i);
        materials.materialFrecuencies[i] = int(matLoad.getString("frecuency"));
        materials.materialAmplitudes[i] = float(matLoad.getString("amplitude"));
        materials.materialDurations[i] = float(matLoad.getString("duration"));
        materials.materialWaves[i] = int(matLoad.getString("waveform"));
        materials.materialGranularity[i] = int(matLoad.getString("grains"));
        materials.cvFlag[i] = int(matLoad.getString("cv"));
      }

      // Load yellow sequence
      for (int i = 0; i < yellowLoad.size(); i++) {
        JSONObject reLoad = yellowLoad.getJSONObject(i);
        yellowSlider.state[i] = int(reLoad.getString("material"));
        yellowSlider.toggleColor[i] = int(reLoad.getString("color"));
      }

      // Load red sequence
      for (int i = 0; i < redLoad.size(); i++) {
        JSONObject reLoad = redLoad.getJSONObject(i);
        redSlider.state[i] = int(reLoad.getString("material"));
        redSlider.toggleColor[i] = int(reLoad.getString("color"));
      }

      // Load red sequence
      for (int i = 0; i < blueLoad.size(); i++) {
        JSONObject reLoad = blueLoad.getJSONObject(i);
        blueSlider.state[i] = int(reLoad.getString("material"));
        blueSlider.toggleColor[i] = int(reLoad.getString("color"));
      }

      //String[] materialPositions = getMaterialSequence(yellowSlider.toggleColor, materialColors);
      //printArray(materialPositions);
      //println(".........................");
    }
  }
  
  fileReaded = false;
}

void fileSelected(File selection) {
  if (selection == null) {
    selectedDesign = "";
  } else {
    selectedDesign = selection.getAbsolutePath();
  }
  fileReaded = true;
}

void fileSelectedJSON(File selection) {
  if (selection == null) {
    //println("Window was closed or the user hit cancel.");
    filenameJSON = "";
  } else {
    filenameJSON = selection.getAbsolutePath();
    //println("User selected " + filenameJSON);
  }
  fileTyped = true;
}

void sendAddMaterialList() {
  println("[INFO] START SENDING LIST OF MATERIALS");

  // send start string
  myPort.write(msgStart);

  // send destinarion: this function is for broadcasting
  myPort.write(msgDestBroadcast);
  myPort.write(",");

  // send msg type
  myPort.write(msgUpdateMaterialList);
  myPort.write(",");

  // send length
  myPort.write(str(materialSelectorNames.length));
  myPort.write(",");

  // send payload: material list
  for (int i = 0; i < materialSelectorNames.length; i++) {
    myPort.write(str(i));
    myPort.write(",");
    myPort.write(str(materials.cvFlag[i]));
    myPort.write(",");
    myPort.write(str(materials.materialGranularity[i]));
    myPort.write(",");
    myPort.write(str(materials.materialWaves[i]));
    myPort.write(",");
    myPort.write(str(materials.materialFrecuencies[i]));
    myPort.write(",");
    myPort.write(str(materials.materialAmplitudes[i]));
    myPort.write(",");
    myPort.write(str(materials.materialDurations[i]));

    if (i != materialSelectorNames.length - 1) {
      myPort.write(",");
    }
  }

  // send end string
  myPort.write(msgEnd);

  // PRINTING SECTION -----------------------
  // send start string
  print(msgStart);

  // send destinarion: this function is for broadcasting
  print(msgDestBroadcast);
  print(",");

  // send msg type
  print(msgUpdateMaterialList);
  print(",");

  // send length
  print(str(materialSelectorNames.length));
  print(",");

  // send payload: material list
  for (int i = 0; i < materialSelectorNames.length; i++) {
    print(str(i));
    print(",");
    print(str(materials.cvFlag[i]));
    print(",");
    print(str(materials.materialGranularity[i]));
    print(",");
    print(str(materials.materialWaves[i]));
    print(",");
    print(str(materials.materialFrecuencies[i]));
    print(",");
    print(str(materials.materialAmplitudes[i]));
    print(",");
    print(str(materials.materialDurations[i]));

    if (i != materialSelectorNames.length - 1) {
      print(",");
    }
  }

  // send end string
  print(msgEnd);
  // ----------------------------------------

  println("[INFO] END SENDING LIST OF MATERIALS");
}

void sendAddGrainSequence(int destination, String slider) {

  String [] grainMaterials = {};
  ArrayList<Float> generalGrainsPositions = new ArrayList<Float>();

  println("[INFO] START SENDING LIST OF SEQUENCE");
  // send start string
  myPort.write(msgStart);

  // send destinarion
  myPort.write(destination);
  myPort.write(",");

  // send msg type
  myPort.write(msgUpdateGrainSequence);
  myPort.write(",");

  switch(slider) {
  case "yellow":
    grainMaterials = fromColorToMaterial(yellowGrains.grainsMaterials, materialColors);
    generalGrainsPositions = yellowGrains.grainsPositions;
    break;
  case "red":
    grainMaterials = fromColorToMaterial(redGrains.grainsMaterials, materialColors);
    generalGrainsPositions = redGrains.grainsPositions;
    break;
  case "blue":
    grainMaterials = fromColorToMaterial(blueGrains.grainsMaterials, materialColors);
    generalGrainsPositions = blueGrains.grainsPositions;
    break;
  default:
    break;
  }

  // send length
  myPort.write(str(generalGrainsPositions.size()));
  myPort.write(",");

  // send data
  for (int i=0; i<generalGrainsPositions.size(); i++) {
    myPort.write(grainMaterials[i]);
    myPort.write(",");
    myPort.write(generalGrainsPositions.get(i).toString());
    myPort.write(",");
    myPort.write(generalGrainsPositions.get(i).toString());

    if (i != generalGrainsPositions.size() - 1) {
      myPort.write(",");
    }
  }

  // send end string
  myPort.write(msgEnd);

  // PRINTING SECCION -------------------------------------
  // send start string
  print(msgStart);

  // send destinarion
  print(destination);
  print(",");

  // send msg type
  print(msgUpdateGrainSequence);
  print(",");

  // send length
  print(str(generalGrainsPositions.size()));
  print(",");

  // send data
  for (int i=0; i<generalGrainsPositions.size(); i++) {
    print(grainMaterials[i]);
    print(",");
    print(generalGrainsPositions.get(i).toString());
    print(",");
    print(generalGrainsPositions.get(i).toString());

    if (i != generalGrainsPositions.size() - 1) {
      print(",");
    }
  }

  // send end string
  print(msgEnd);

  // -----------------------------------------------

  println("[INFO] END SENDING LIST OF SEQUENCE");
}
