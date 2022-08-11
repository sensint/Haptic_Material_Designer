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
String msgStartAugmentation = "32";
String msgStopAugmentation = "33";

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

String msgDeleteAllGrainSequences = "61";

String msgDestBroadcast = "0";

// For material parameters' screen
boolean frame2Exit;
SecondApplet sa;
boolean saActive = false;

// UI Colors
color mainColor = #0D1B2A;
color secondaryColor = color(88, 111, 124);
color textColor = #E0E1DD;
color whiteColor = textColor;

// Default values
int defaultFrecuency = 119;
int minFrecuency = 10;
int maxFrecuency = 400;
float defaultAmplitude = 0.5;
float ghostAmplitude = 0.0;
int minAmplitude = 0;
int maxAmplitude = 1;
// int defaultDuration = 2;
// int minDuration = 0;
// int maxDuration = 8;

int defaultPhase = 2;
int minPhase = 0;
int maxPhase = 8;

int defaultDuration = int(1000000 * (1.0 / defaultFrecuency * (defaultPhase / 2.0)));
// int defaultDuration = 10000;
// int minDuration = 2000;
// int maxDuration = 20000;
float ghostDuration = 1000; // changed from ms to us
int minBin = 1;
int maxBin = 10;
int defaultWaveForm = 0;
int defaultWave = 0;
int defaultMode = 0; // MOTION COUPLED = 0, CV = 1

// UI Elements
MaterialCollection materials;
GrainCalculator yellowGrains, redGrains, blueGrains;
PhysicalSlider yellowSlider, redSlider, blueSlider; 
uniqueSelectButtons materialSelector, parameterSelector;
Button saveButton, loadButton, clearButton, uploadButton;

String[] materialSelectorNames = {"M0", "M1", "M2", "M3", "M4", "M5", "MX"};
String[] parameterSelectorNames = {"Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit"};

int[][] sceneSwitcherPositions = new int[materialSelectorNames.length - 1][4];
int[][] materialSelectorPositions = new int[materialSelectorNames.length - 1][4];

int[] materialGranularity = {1, 2, 3, 4, 5, 6, 7};
int numVerticalButtons = 10;

// For loading and saving JSON files
String selectedDesign = "";
String filenameJSON = "";
boolean fileReaded = false;
boolean fileTyped = false;

boolean sequencesAdded = false;

// Material colors
color[] materialColors = {
  color(248, 255, 229), 
  color(255, 196, 61), 
  color(239, 71, 111), 
  color(133, 113, 141), 
  color(17, 184, 165), 
  color(5, 200, 129),
  color(255, 255, 100),
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
  size(1000, 900);
}

void setup() {

  surface.setTitle("Tactile Symbol Designer");
  textSize(15);

  println("Ports");
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 115200);
  println(Serial.list()[0]);

  data = new JSONObject();
  materialJSON = new JSONArray();

  for (int i = 0; i < materialSelectorNames.length - 1; i++) {
    JSONObject currentMaterial = new JSONObject();
    currentMaterial.setString("material_id", str(i));
    currentMaterial.setString("frecuency", str(defaultFrecuency));
    currentMaterial.setString("amplitude", str(defaultAmplitude));
    currentMaterial.setString("phase", str(defaultPhase));
    currentMaterial.setString("grains", str(materialGranularity[i]));
    currentMaterial.setString("waveform", str(defaultWave));
    currentMaterial.setString("cv", str(defaultMode));
    materialJSON.setJSONObject(i, currentMaterial);
  }

  materials = new MaterialCollection(); // Create our materialCollection
  int[] defaultMaterialParameters = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}; // Makeup some default parameters

  // Assign default values
  for (int i = 0; i < materialSelectorNames.length; i++) {
    float defAmp = defaultAmplitude;
    int defPhase = defaultPhase;
    float defDur = defaultDuration;
    if(i == materialSelectorNames.length - 1){
      defAmp = ghostAmplitude;
      defDur = ghostDuration;
      defPhase = 1;
    }

    materials.assign(
      i, 
      "material" + str(i), 
      defaultMode, 
      materialGranularity[i], 
      defaultFrecuency, 
      defaultWaveForm, 
      defAmp, 
      defPhase,
      defDur,
      defaultMaterialParameters, 
      materialColors[i]);
  }

  // Set positions of material selectors
  for (int i = 0; i < materialSelectorNames.length - 1; i++) { 
    materialSelectorPositions[i][0] = 20;
    materialSelectorPositions[i][1] = 20 + 65 * i;
    materialSelectorPositions[i][2] = 60;
    materialSelectorPositions[i][3] = 35;
  }

  // Set positions of edit selectors
  for (int i = 0; i < parameterSelectorNames.length - 1; i++) { 
    sceneSwitcherPositions[i][0] = 100;
    sceneSwitcherPositions[i][1] = 20 + 65 * i;
    sceneSwitcherPositions[i][2] = 40;
    sceneSwitcherPositions[i][3] = 35;
  }

  redSlider = new PhysicalSlider(this, numVerticalButtons, color(241, 89, 110, 50));
  redSlider.drawSlider(400, 25, 90, 700);

  yellowSlider = new PhysicalSlider(this, numVerticalButtons, color(255, 209, 102, 50));
  yellowSlider.drawSlider(600, 25, 90, 700); 

  blueSlider = new PhysicalSlider(this, numVerticalButtons, color(15, 157, 174, 50));
  blueSlider.drawSlider(200, 25, 90, 700);

  saveButton = new Button(this, "Save");
  loadButton = new Button(this, "Load");
  clearButton = new Button(this, "Clear all");
  uploadButton = new Button(this, "Upload");

  materialSelector = new uniqueSelectButtons(this, materialSelectorNames.length - 1, materialSelectorNames, materialColors);
  materialSelector.defaultColor(mainColor); 
  parameterSelector = new uniqueSelectButtons(this, parameterSelectorNames.length - 1, parameterSelectorNames, materialColors);
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
  redSlider.drawSlider(400, 25, 90, 700);
  yellowSlider.drawSlider(600, 25, 90, 700);
  blueSlider.drawSlider(200, 25, 90, 700);

  // Update grains
  yellowGrains.updateGrains();
  redGrains.updateGrains();
  blueGrains.updateGrains();

  // Display buttons
  fill(whiteColor);
  saveButton.display(20, 770, 100, 35);  
  loadButton.display(140, 770, 100, 35);
  clearButton.display(260, 770, 100, 35);
  uploadButton.display(380, 770, 100, 35);
}

void frame2Start(int index, String name) {
  sa = new SecondApplet(name, index, materialColors[index]);
  frame2Exit = false;
}

void mouseReleased()
{
  // Clear button event
  if (clearButton.isClicked()) {
    yellowSlider.clearSlider();
    redSlider.clearSlider();
    blueSlider.clearSlider();

    sendStopAugmentation("0");
    sequencesAdded = false;
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

    // decide add or update sequences
    if (sequencesAdded == false) {
      sendAddGrainSequence("3", "blue");
      sendAddGrainSequence("4", "red");
      sendAddGrainSequence("5", "yellow");

      sendUpdateGrainSequence("3", "blue");
      sendUpdateGrainSequence("4", "red");
      sendUpdateGrainSequence("5", "yellow");

      // start augmentation
      sendStartAugmentation("0");

      sequencesAdded = true;
    } else {
      sendUpdateGrainSequence("3", "blue");
      sendUpdateGrainSequence("4", "red");
      sendUpdateGrainSequence("5", "yellow");
    }
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
        materials.materialPhases[i] = int(matLoad.getString("phase"));
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

void sendStartAugmentation(String destination) {

  String msg = "";

  println("[INFO] START SENDING: START AUGMENTATION");

  // send start String
  msg += msgStart;
  // send destination
  msg += destination;
  msg += ",";
  // send msg type
  msg += msgStartAugmentation;
  msg += ",";
  // send length
  msg += "0";
  // send dash
  msg += ",";
  msg += "-";
  // send end string 
  msg += msgEnd;

  myPort.write(msg);
  println(msg);

  println("[INFO] END SENDING: START AUGMENTATION\n");
}

void sendStopAugmentation(String destination) {
  String msg = "";

  println("[INFO] START SENDING: STOP AUGMENTATION");

  // send start String
  msg += msgStart;
  // send destination
  msg += destination;
  msg += ",";
  // send msg type
  msg += msgStopAugmentation;
  msg += ",";
  // send length
  msg += "0";
  // send dash
  msg += ",";
  msg += "-";
  // send end string 
  msg += msgEnd;

  myPort.write(msg);
  println(msg);

  println("[INFO] END SENDING: STOP AUGMENTATION\n");
}

void sendAddMaterialList() {
  println("[INFO] START SENDING LIST OF MATERIALS");
  String msg = "";

  // send start string
  msg += msgStart;

  // send destinarion: this function is for broadcasting
  msg += msgDestBroadcast;
  msg += ",";

  // send msg type
  msg += msgAddMaterialList;
  msg += ",";

  // send length
  msg += str(materialSelectorNames.length);
  msg += ",";

  // send payload: material list
  for (int i = 0; i < materialSelectorNames.length; i++) {
    msg += str(i+1);
    msg += ",";
    msg += str(materials.cvFlag[i]);
    msg += ",";
    // myPort.write(str(materials.materialGranularity[i]));
    // myPort.write(",");
    msg += str(materials.materialWaves[i]);
    msg += ",";
    msg += str(materials.materialFrecuencies[i]);
    msg += ",";
    msg += str(materials.materialAmplitudes[i]);
    msg += ",";

    if(materials.materialDurations[i] == ghostDuration){
      msg += str((int)materials.materialDurations[i]);
    } else {
      msg += str((int)materials.materialDurations[i]);
    }
    
    if (i != materialSelectorNames.length - 1) {
      msg += ",";
    }
  }
  // send end string
  // myPort.write(msgEnd);
  msg += msgEnd;

  myPort.write(msg);
  println(msg);

  println("[INFO] END SENDING LIST OF MATERIALS\n");
}

void sendUpdateGrainSequence(String destination, String slider) {
  String msg = "";

  String [] grainMaterials = {};
  ArrayList<Integer> generalGrainsPositionsStart = new ArrayList<Integer>();
  ArrayList<Integer> generalGrainsPositionsEnd = new ArrayList<Integer>();

  println("[INFO] START UPDATING LIST OF SEQUENCE");

  // send start string
  msg += msgStart;

  // send destinarion
  msg += destination;
  msg += ",";

  // send msg type
  msg += msgUpdateGrainSequence;
  msg += ",";

  switch(slider) {
  case "yellow":
    grainMaterials = fromColorToMaterial(yellowGrains.grainsMaterials, materialColors);
    generalGrainsPositionsStart = yellowGrains.grainsPositionsStart;
    generalGrainsPositionsEnd = yellowGrains.grainsPositionsEnd;
    break;
  case "red":
    grainMaterials = fromColorToMaterial(redGrains.grainsMaterials, materialColors);
    generalGrainsPositionsStart = redGrains.grainsPositionsStart;
    generalGrainsPositionsEnd = redGrains.grainsPositionsEnd;
    break;
  case "blue":
    grainMaterials = fromColorToMaterial(blueGrains.grainsMaterials, materialColors);
    generalGrainsPositionsStart = blueGrains.grainsPositionsStart;
    generalGrainsPositionsEnd = blueGrains.grainsPositionsEnd;
    break;
  default:
    break;
  }

  // send length
  msg += str(generalGrainsPositionsStart.size());
  msg += ",";

  // send sequence ID
  msg += "1";

  if (generalGrainsPositionsStart.size() != 0) {
    msg += ",";
  }

  // send data
  for (int i=0; i<generalGrainsPositionsStart.size(); i++) {

    msg += str(int(grainMaterials[i])+1);
    msg += ",";
    msg += generalGrainsPositionsStart.get(i).toString();
    msg += ",";
    msg += generalGrainsPositionsEnd.get(i).toString();

    if (i != generalGrainsPositionsStart.size() - 1) {
      msg += ",";
    }
  }

  // send end string
  msg += msgEnd;

  myPort.write(msg);
  println(msg);

  println("[INFO] END UPDATING LIST OF SEQUENCES\n");

}

void sendAddGrainSequence(String destination, String slider) {

  String msg = "";

  String [] grainMaterials = {};
  ArrayList<Integer> generalGrainsPositionsStart = new ArrayList<Integer>();
  ArrayList<Integer> generalGrainsPositionsEnd = new ArrayList<Integer>();

  println("[INFO] START ADDING LIST OF SEQUENCE");

  // send start string
  msg += msgStart;

  // send destinarion
  msg += destination;
  msg += ",";

  // send msg type
  msg += msgAddGrainSequence;
  msg += ",";

  switch(slider) {
  case "yellow":
    grainMaterials = fromColorToMaterial(yellowGrains.grainsMaterials, materialColors);
    generalGrainsPositionsStart = yellowGrains.grainsPositionsStart;
    generalGrainsPositionsEnd = yellowGrains.grainsPositionsEnd;
    break;
  case "red":
    grainMaterials = fromColorToMaterial(redGrains.grainsMaterials, materialColors);
    generalGrainsPositionsStart = redGrains.grainsPositionsStart;
    generalGrainsPositionsEnd = redGrains.grainsPositionsEnd;
    break;
  case "blue":
    grainMaterials = fromColorToMaterial(blueGrains.grainsMaterials, materialColors);
    generalGrainsPositionsStart = blueGrains.grainsPositionsStart;
    generalGrainsPositionsEnd = blueGrains.grainsPositionsEnd;
    break;
  default:
    break;
  }

  // send length
  msg += str(generalGrainsPositionsStart.size());
  msg += ",";

  // send sequence ID
  msg += "1";

  if (generalGrainsPositionsStart.size() != 0) {
    msg += ",";
  }

  // send data
  for (int i=0; i<generalGrainsPositionsStart.size(); i++) {

    msg += str(int(grainMaterials[i])+1);    
    msg += ",";
    msg += generalGrainsPositionsStart.get(i).toString();
    msg += ",";
    msg += generalGrainsPositionsEnd.get(i).toString();

      if (i != generalGrainsPositionsStart.size() - 1) {
      msg += ",";
    }
  }

  // send end string
  msg += msgEnd;

  myPort.write(msg);
  println(msg);

  println("[INFO] END ADDING LIST OF SEQUENCE\n");
}
