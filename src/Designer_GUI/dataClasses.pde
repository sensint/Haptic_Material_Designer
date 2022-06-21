
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
  boolean oneShot; //true if the material consists of discrete events, false for any continuous vibration 
  int granularity;
  int[] parameters; //the actual data
  color displayColor; //color to use in GUI

  //constructor without position
  Material() {
    parameters = new int[10];
  }
}


public class MaterialCollection {
  boolean[] assigned;
  String[] name;
  int[][] parameters; //this should just be an int array
  boolean[] oneShot;
  color[] displayColor;
  int[] granularity;

  //constructor without position
  MaterialCollection() {
    name = new String[12];
    parameters = new int[12][10];
    oneShot = new boolean[12];
    assigned = new boolean[12];
    displayColor = new color[12];
    granularity = new int[12];
    for (int i = 0; i < assigned.length; i++) {
      assigned[i] = false;
    }
  }
  void assign(int index, Material m) {
    if ((index >= 0) && (index <12)) {
      name[index] = m.name;
      oneShot[index] = m.oneShot;
      granularity[index] = m.granularity;
      parameters[index] = m.parameters;
      displayColor[index] = m.displayColor;
      assigned[index] = true;
    } else { 
      println("[ERROR] Material trying to write to an invalid materialCollection slot");
    }
  }
  void assign(int index, String newName, boolean newOneShot, int newGranularity, int[] newParameters, color newColor) {
    if ((index >= 0) && (index <12)) {
      name[index] = newName;
      oneShot[index] = newOneShot;
      granularity[index] = newGranularity;
      parameters[index] = newParameters;
      displayColor[index] = newColor;
      assigned[index] = true;
    } else { 
      println("[ERROR] material trying to write to an invalid materialCollection slot");
    }
  }
}
