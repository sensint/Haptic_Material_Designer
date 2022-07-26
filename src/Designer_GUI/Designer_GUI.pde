import processing.serial.*;

JSONObject data; // Data
JSONArray materialJSON;
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

// For material parameters's screen
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
int minFrecuency = 0;
int maxFrecuency = 500;
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
MaterialCollection materials; // materials: we only need one, we have limited it to twelve materials
GrainCalculator yellowGrains, redGrains, blueGrains; // grain calculation: for visualizing grains and storing eventSequences
PhysicalSlider yellowSlider, redSlider, blueSlider; // physical sliders
uniqueSelectButtons materialSelector, parameterSelector; // material selectors
Button saveButton, loadButton, clearButton, uploadButton; // button

String[] materialSelectorNames = {"M0", "M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10"};
String[] parameterSelectorNames = {"Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit", "Edit"};
int[][] sceneSwitcherPositions = new int[11][4];
int[][] materialSelectorPositions = new int[11][4];
//int[] materialGranularity = {0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
int[] materialGranularity = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
int numVerticalButtons = 10;
String selectedDesign = "";
boolean fileReaded = false;

// Colors
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
        currentMaterial.setString("phase", str(defaultDuration));
        currentMaterial.setString("grains", str(materialGranularity[i]));
        currentMaterial.setString("waveform", str(defaultWave));
        currentMaterial.setString("cv", str(defaultMode));
        materialJSON.setJSONObject(i, currentMaterial);
    }

    materials = new MaterialCollection(); // Create our materialCollection
    int[] defaultMaterialParameters = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}; // Makeup some default parameters

    // Assign with dummy values and defaults
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

    yellowSlider = new PhysicalSlider(this, numVerticalButtons);
    yellowSlider.drawSlider(200, 25, 90, 700); 
    redSlider = new PhysicalSlider(this, numVerticalButtons);
    redSlider.drawSlider(400, 25, 90, 700);
    blueSlider = new PhysicalSlider(this, numVerticalButtons);
    blueSlider.drawSlider(600, 25, 90, 700);

    saveButton = new Button(this, "Save");
    loadButton = new Button(this, "Load");
    clearButton = new Button(this, "Clear");
    uploadButton = new Button(this, "Upload");

    materialSelector = new uniqueSelectButtons(this, materialSelectorNames.length, materialSelectorNames, materialColors);
    materialSelector.defaultColor(mainColor); 
    parameterSelector = new uniqueSelectButtons(this, parameterSelectorNames.length, parameterSelectorNames, materialColors);
    parameterSelector.defaultColor(mainColor);

    yellowGrains = new GrainCalculator(this, "yellow", yellowSlider, materials, 1024); // slider to calculate, materialcollection to use, target range
    redGrains = new GrainCalculator(this, "red", redSlider, materials, 1024); // slider to calculate, materialcollection to use, target range
    blueGrains = new GrainCalculator(this, "blue", blueSlider, materials, 1024); // slider to calculate, materialcollection to use, target range
}

void draw() {

    background(mainColor);

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

        blueSlider.assignColor(yellowSlider.defaultColor);
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
    yellowSlider.drawSlider(200, 25, 90, 700);
    redSlider.drawSlider(400, 25, 90, 700);
    blueSlider.drawSlider(600, 25, 90, 700);

    // Clear button event
    if (clearButton.isClicked()) {
        yellowSlider.clearSlider();
        redSlider.clearSlider();
        blueSlider.clearSlider();
    }

    // Upload button event
    //if (uploadButton.isClicked()) {
    //    //  String[] materialPositions = getMaterialSequence(yellowSlider.toggleColor, materialColors);
    //    //  printArray(materialPositions);
    //    //  for (int i=0; i < materialPositions.length; i++) {
    //    //    // myPort.write(byte(int(materialPositions[i])));
    //    //    myPort.write(materialPositions[i]);
    //    //  }
    //    //  println("SEND IT!");

    //    // Upload grain positions
    //    myPort.write("POSITIONS");
    //    myPort.write(";");
    //    for (int i=0; i<yellowGrains.grainsPositions.size(); i++) {
    //        myPort.write(yellowGrains.grainsPositions.get(i).toString());
    //        myPort.write("-");
    //    }
    //    myPort.write(";");
    //}

    // Update grains
    yellowGrains.updateGrains();
    redGrains.updateGrains();
    blueGrains.updateGrains();

    // println(yellowSlider.state);
    //println(yellowGrains.vibrationMode);

    //println(yellowGrains.grainsPositions);
    //println(yellowGrains.grainsMaterials);
    //printArray(fromColorToMaterial(yellowGrains.grainsMaterials, materialColors));
    //println(".....");
    // println(yellowGrains.grainsPositions.size());
}

void frame2Start(int index, String name) {
    sa = new SecondApplet(name, index);
    frame2Exit = false;
}

void mouseReleased()
{
    // Save button event
    if (saveButton.isClicked()) {

        data.setJSONArray("materials", materialJSON);
        String filename = "design_" + String.valueOf(day()) + "-" + String.valueOf(month())
            + "-" + String.valueOf(year()) + "_" + String.valueOf(hour())
            + String.valueOf(minute());
        println(filename);
        //saveJSONArray(materialJSON, "sequences/" + filename + ".json");
        saveJSONObject(data, "sequences/" + filename + ".json");
    }

    // Upload button event
    if (uploadButton.isClicked()) {

        // // Send slider name
        // myPort.write("YELLOW");
        // myPort.write(";");

        // // Send material properties
        // myPort.write("MATERIALS");
        // myPort.write(";");


        // // Send grain positions
        // String [] grainMaterials = fromColorToMaterial(yellowGrains.grainsMaterials, materialColors);
        // myPort.write("POSITIONS");
        // myPort.write(";");
        // for (int i=0; i<yellowGrains.grainsPositions.size(); i++) {
        //     myPort.write(yellowGrains.grainsPositions.get(i).toString());
        //     myPort.write("-");
        //     myPort.write(grainMaterials[i]);
        //     myPort.write("-");
        // }
        // myPort.write(";");


        // String[] materialPositions = getMaterialSequence(yellowSlider.toggleColor, materialColors);
        // // printArray(materialPositions);
        // for (int i=0; i < materialPositions.length; i++) {
        //     // myPort.write(byte(int(materialPositions[i])));
        //     myPort.write(materialPositions[i]);
        //     myPort.write(",");
        //     println(materialPositions[i]);
        // }
        // println("SEND IT!");
        // // myPort.clear();

        // Send materials
        sendAddMaterialList();
        //sendAddGrainSequenceList();
    }

    // Load button event
    if (loadButton.isClicked()) {

        // Select file from the file explorer
        selectInput("Select a file to process:", "fileSelected", dataFile( "*.json" ));

        while (fileReaded == false) {
            //println("No seleccionado aun");
        }

        // Cargar el JSON
        //JSONArray materialsLoad = loadJSONArray(selectedDesign);
        JSONObject dataLoad = loadJSONObject(selectedDesign);
        JSONArray materialsLoad = dataLoad.getJSONArray("materials");

        for (int i = 0; i < materialsLoad.size(); i++) {

            JSONObject matLoad = materialsLoad.getJSONObject(i);

            materials.materialFrecuencies[i] = int(matLoad.getString("frecuency"));
            materials.materialAmplitudes[i] = float(matLoad.getString("amplitude"));
            materials.materialPhases[i] = float(matLoad.getString("phase"));
            materials.materialWaves[i] = int(matLoad.getString("waveform"));
            materials.materialGranularity[i] = int(matLoad.getString("grains"));
            materials.cvFlag[i] = int(matLoad.getString("cv"));
        }

        //String[] materialPositions = getMaterialSequence(yellowSlider.toggleColor, materialColors);
        //printArray(materialPositions);
        //println(".........................");
    }
}

void fileSelected(File selection) {
    if (selection == null) {
        selectedDesign = "";
    } else {
        selectedDesign = selection.getAbsolutePath();
    }
    fileReaded = true;
    // println(selectedDesign);
}

void sendAddMaterialList() {
    println("[INFO] START SENDING LIST OF MATERIALS");
    //myPort.write(msgStart);
    //myPort.write(msgEnd);

    //// send start string
    //myPort.write(msgStart);
    //myPort.write(",");

    //// send destinarion: this function is for broadcasting
    //myPort.write(msgDestBroadcast);
    //myPort.write(",");

    //// send msg type
    //myPort.write(msgAddMaterialList);
    //myPort.write(",");

    //// send length
    //myPort.write(str(materialSelectorNames.length));
    //myPort.write(",");

    //// send payload: material list
    //for (int i = 0; i < materialSelectorNames.length; i++) {
    //    myPort.write(str(i));
    //    myPort.write(",");
    //    myPort.write(str(materials.cvFlag[i]));
    //    myPort.write(",");
    //    myPort.write(str(materials.materialGranularity[i]));
    //    myPort.write(",");
    //    myPort.write(str(materials.materialFrecuencies[i]));
    //    myPort.write(",");
    //    myPort.write(str(materials.materialAmplitudes[i]));
    //    myPort.write(",");
    //    myPort.write(str(materials.materialPhases[i]));
    //    myPort.write(",");
    //    myPort.write(str(materials.materialWaves[i]));
    //    myPort.write(",");
    //}

    //// send end string
    //myPort.write(msgEnd);
    //myPort.write(",");

    // --------------------

    myPort.write(str(materials.materialFrecuencies[0]));
    myPort.write(",");

    println("[INFO] END SENDING LIST OF MATERIALS");
}

void sendAddGrainSequenceList() {
    println("[INFO] START SENDING LIST OF SEQUENCE");
    //myPort.write("<");
    //myPort.write(">");
    println("[INFO] END SENDING LIST OF SEQUENCE");
}
