//data classes for storing information required by gui and controllers

public class HapticEventSequence {
  //not sure if needed
  String name;
  IntList eventColors;
  IntList grainID;
  IntList grainRegion;
  IntList eventStart;
  IntList eventFinished;
  IntList eventMaterial;

  //constructor without position
  HapticEventSequence(String newName) {
    name = newName;
    eventColors = new IntList(); //set(i,x); get(i); size(); clear(); append(x);  
    //eventColors.append(color(0, 255, 0));
    eventColors = new IntList();
    grainID = new IntList();
    grainRegion = new IntList();
    eventStart = new IntList();
    eventFinished = new IntList();
    eventMaterial = new IntList();
  }
}

public class Material {
  String name; //candy
  boolean oneShot; // True if the material consists of discrete events, false for any continuous vibration 
  int granularity;
  int[] parameters; // The actual data
  color displayColor; // Color to use in GUI

  // Constructor without position
  Material() {
    parameters = new int[10];
  }
}

public class MaterialCollection {
  boolean[] assigned;
  String[] name;
  int[][] parameters; // This should just be an int array
  boolean[] oneShot;
  color[] displayColor;
  int[] materialGranularity;
  int[] materialFrecuencies;
  int[] materialWaves;
  float[] materialAmplitudes;
  float[] materialDurations;
  float[][] materialADSR;

  //constructor without position
  MaterialCollection() {
    name = new String[11];
    parameters = new int[11][10];
    oneShot = new boolean[11];
    assigned = new boolean[11];
    displayColor = new color[11];
    materialGranularity = new int[11];
    materialFrecuencies = new int[11];
    materialWaves = new int[11];
    materialAmplitudes = new float[11];
    materialDurations = new float[11];
    materialADSR = new float[11][4];

    for (int i = 0; i < assigned.length; i++) {
      assigned[i] = false;
    }
  }

  void assign(int index, Material m) {
    if ((index >= 0) && (index < 11)) {
      name[index] = m.name;
      oneShot[index] = m.oneShot;
      materialGranularity[index] = m.granularity;
      parameters[index] = m.parameters;
      displayColor[index] = m.displayColor;
      assigned[index] = true;
    } else { 
      println("[ERROR] Material trying to write to an invalid materialCollection slot");
    }
  }

  void assign(int index, String newName, boolean newOneShot, int newGranularity, int newFrecuency, int newWave, float newAmplitude, float newDuration, float[] newADSR, int[] newParameters, color newColor) {
    if ((index >= 0) && (index < 11)) {
      name[index] = newName;
      oneShot[index] = newOneShot;

      parameters[index] = newParameters;
      displayColor[index] = newColor;
      assigned[index] = true;

      // Material parameters
      materialGranularity[index] = newGranularity;
      materialFrecuencies[index] = newFrecuency;
      materialWaves[index] = newWave;
      materialAmplitudes[index] = newAmplitude;
      materialDurations[index] = newDuration;
      materialADSR[index] = newADSR;
    } else { 
      println("[ERROR] material trying to write to an invalid materialCollection slot");
    }
  }
}
