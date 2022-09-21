public class HapticEventSequence {
  String name;
  IntList eventColors;
  IntList grainID;
  IntList grainRegion;
  IntList eventStart;
  IntList eventFinished;
  IntList eventMaterial;
  
  HapticEventSequence(String newName) {
    name = newName;
    eventColors = new IntList();
    eventColors = new IntList();
    grainID = new IntList();
    grainRegion = new IntList();
    eventStart = new IntList();
    eventFinished = new IntList();
    eventMaterial = new IntList();
  }
}

public class Material {
  String name; 
  int cvFlag; // True if the material consists of discrete events, false for any continuous vibration 
  int granularity;
  int[] parameters;
  color displayColor; // Color to use in GUI
  
  Material() {
    parameters = new int[10];
  }
}

public class MaterialCollection {
  boolean[] assigned;
  String[] name;
  int[][] parameters;
  int[] cvFlag;
  color[] displayColor;
  int[] materialGranularity;
  int[] materialFrecuencies;
  int[] materialWaves;
  float[] materialAmplitudes;
  float[] materialDurations;
  int[] materialPhases;
  
  MaterialCollection() {
    name = new String[11];
    parameters = new int[11][10];
    cvFlag = new int[11];
    assigned = new boolean[11];
    displayColor = new color[11];
    materialGranularity = new int[11];
    materialFrecuencies = new int[11];
    materialWaves = new int[11];
    materialAmplitudes = new float[11];
    materialDurations = new float[11];
    materialPhases = new int[11];
    
    for (int i = 0; i < assigned.length; i++) {
      assigned[i] = false;
      }
  }
  
  void assign(int index, Material m) {
    if ((index >= 0) && (index < 11)) {
      name[index] = m.name;
      cvFlag[index] = m.cvFlag;
      materialGranularity[index] = m.granularity;
      parameters[index] = m.parameters;
      displayColor[index] = m.displayColor;
      assigned[index] = true;
      } else { 
      println("[ERROR] Material trying to write to an invalid materialCollection slot");
      }
  }
  
  void assign(int index, String newName, int newcvFlag, int newGranularity, int newFrecuency, int newWave, float newAmplitude, int newPhase, float newDur, int[] newParameters, color newColor) {
    if ((index >= 0) && (index < 11)) {
      name[index] = newName;
      cvFlag[index] = newcvFlag;
      
      parameters[index] = newParameters;
      displayColor[index] = newColor;
      assigned[index] = true;
      
      // Material parameters
      materialGranularity[index] = newGranularity;
      materialFrecuencies[index] = newFrecuency;
      materialWaves[index] = newWave;
      materialAmplitudes[index] = newAmplitude;
      materialDurations[index] = newDur;
      materialPhases[index] = newPhase;
      } else { 
      println("[ERROR] material trying to write to an invalid materialCollection slot");
      }
  }
}
