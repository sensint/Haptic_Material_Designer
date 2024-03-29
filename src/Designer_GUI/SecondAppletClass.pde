class SecondApplet extends PApplet {
  String materialName;
  int materialIndex;
  color materialColor;
  int sliderSep = 80;
  
  // UI Elements
  uniqueSelectButtons waveSelector, cvSelector;
  Button saveButton, resetButton;
  Slider amplitudeSlider;
  DiscreteSlider phaseSlider, grainSlider;
  FrequencySlider frecuencySlider;
  
  String[] waveSelectorName = {"Sine", "Sawtooth", "Square", "Triangle"};
  String[] cvSelectorName = {"Motion coupled", "Continuous"};
  int[][] cvSelectorPositions = new int[cvSelectorName.length][4];
  int[][] waveSelectorPositions = new int[waveSelectorName.length][4];
  
  public SecondApplet(String materialName, int materialIndex, color materialColor) {
    super();
    this.materialName = materialName;
    this.materialIndex = materialIndex;
    this.materialColor = materialColor;
    PApplet.runSketch(new String[]{this.getClass().getName()} , this);
  }
  
  public void settings() {
    size(620, 610);
  }
  
  public void setup() {
    textSize(15);
    surface.setTitle("Customize material " + materialName);
    
    amplitudeSlider = new Slider(this, "Amplitude", 'r', minAmplitude, maxAmplitude, materials.materialAmplitudes[materialIndex], "");
    phaseSlider = new DiscreteSlider(this, "Phase/Duration", 'r', minPhase, maxPhase, defaultPhase, maxPhase - minPhase, 504, ""); //"π Radians")
    frecuencySlider = new FrequencySlider(this, "Frecuency", 'r', minFrecuency, maxFrecuency, materials.materialFrecuencies[materialIndex], "Hz");// 
    grainSlider = new DiscreteSlider(this, "Grains", 'g', minBin, maxBin, materials.materialGranularity[materialIndex], maxBin - minBin, 360, "grains");
    
    saveButton = new Button(this, "Save", 's');
    resetButton = new Button(this, "Reset", 'r');
    
    // Set positions of wave selectors
    for (int i = 0; i < waveSelectorName.length; i++) { 
      waveSelectorPositions[i][0] = 20 + 85 * i;
      waveSelectorPositions[i][1] = 190;
      waveSelectorPositions[i][2] = 70;
      waveSelectorPositions[i][3] = 40;
    }
    
    for (int i = 0; i < cvSelectorName.length; i++) { 
      cvSelectorPositions[i][0] = 20;
      cvSelectorPositions[i][1] = 50 * i + 45;
      cvSelectorPositions[i][2] = 125;
      cvSelectorPositions[i][3] = 25;
    }
    
    waveSelector = new uniqueSelectButtons(this, waveSelectorName.length, waveSelectorName, subset(uiColors, 0, 6));
    waveSelector.defaultColor(mainColor);
    waveSelector.setValue(materials.materialWaves[materialIndex]);
    
    cvSelector = new uniqueSelectButtons(this, cvSelectorName.length, cvSelectorName, subset(uiColors, 0, cvSelectorName.length));
    cvSelector.defaultColor(mainColor);
    cvSelector.setValue(materials.cvFlag[materialIndex]);
    
  }
  
  public void draw() {
    this.background(materialColor); //make the colours super obvious
    fill(mainColor,210);
    rect(10, 10, width - 20, height - 20);
    
    this.fill(whiteColor);
    this.text("Choose vibration mode", 15, 30);
    
    // Display vibration selector
    cvSelector.display(cvSelectorPositions);
    
    // if selector is 1 means MOTION COUPLED
    if (cvSelector.activeButton() == 0) {
      this.fill(secondaryColor); 
      this.noStroke();
      grainSlider.display(160, 45, 360, 75);
    } else if (cvSelector.activeButton() == 1) {
      // if selector is 0 means CONTINUOUS VIBRATION
      this.text("Continuous vibration selected, no grains!", 200, 90);
    } else if (cvSelector.activeButton() == -1) {
      this.text("Please, choose a vibration mode.", 220, 90);
    }
    
    this.fill(whiteColor);
    this.text("Parameters of vibration", 15, 170);
    
    // Display sliders
    this.fill(secondaryColor); 
    this.noStroke();
    frecuencySlider.display(20, 190 + sliderSep, 500, 40);
    this.fill(secondaryColor);
    amplitudeSlider.display(20, 190 + sliderSep * 2, 500, 40);
    float msFloat = 1000 * (1.0 / int(frecuencySlider.getSliderValue()) * (phaseSlider.getSliderValue() / 2.0));
    
    String ms = "0";
    ms = String.format("%.2f", msFloat);
    
    this.text(ms + " ms", 533, 230 + sliderSep * 3);
    this.fill(secondaryColor);
    phaseSlider.display(20, 190 + sliderSep * 3, 504, 40);
    
    // Display wave selector
    waveSelector.display(waveSelectorPositions);
    
    // Display buttons
    this.fill(whiteColor);
    saveButton.display(20, 510, 70, 30);
    this.fill(whiteColor);
    resetButton.display(110, 510, 70, 30);
    
    // Display text
    this.stroke(whiteColor);
    
    // Button events
    if (saveButton.isClicked()) {
      // Get data from UI
      int frecuencyValue = int(frecuencySlider.getSliderValue());
      Float amplitudeValue = amplitudeSlider.getSliderValue();
      int durationValue = int(1000000 * (1.0 / float(frecuencyValue) * (phaseSlider.getSliderValue() / 2.0)));
      int phaseValue = phaseSlider.getSliderValue();
      int grainsValue = 0;
      int waveformValue = waveSelector.activeButton();
      int cvValue = cvSelector.activeButton();
      if (cvSelector.activeButton() == 1) {
        // if cvSelector is 0 means CV
        grainsValue = 0;
      } else if (cvSelector.activeButton() == 0) {
        // if cvSelector is 1 means MOTION COUPLED
        grainsValue = round(grainSlider.getSliderValue());
      }
      
      
      // Save data to JSON object -----------------------------------------------------------------------------
      JSONObject currentMaterial = new JSONObject();
      currentMaterial.setString("material_id", str(materialIndex));
      currentMaterial.setString("frecuency", str(frecuencyValue)); // double check please
      currentMaterial.setString("amplitude", str(amplitudeValue));
      currentMaterial.setString("phase", str(phaseValue));
      currentMaterial.setString("grains", str(grainsValue));
      currentMaterial.setString("waveform", str(waveformValue));
      currentMaterial.setString("cv", str(cvValue));
      materialJSON.setJSONObject(materialIndex, currentMaterial);
      
      // Update material properties ----------------------------------------------------------------------------
      materials.materialFrecuencies[materialIndex] = frecuencyValue;
      materials.materialAmplitudes[materialIndex] = amplitudeValue;
      materials.materialDurations[materialIndex] = durationValue;
      materials.materialWaves[materialIndex] = waveformValue;
      materials.cvFlag[materialIndex] = cvValue;
      materials.materialGranularity[materialIndex] = grainsValue;
      materials.materialPhases[materialIndex] = phaseValue;
      
      yellowGrains.granularity[materialIndex] = materials.materialGranularity[materialIndex];
      redGrains.granularity[materialIndex] = materials.materialGranularity[materialIndex];
      blueGrains.granularity[materialIndex] = materials.materialGranularity[materialIndex];
      
      yellowGrains.vibrationMode[materialIndex] = materials.cvFlag[materialIndex];
      redGrains.vibrationMode[materialIndex] = materials.cvFlag[materialIndex];
      blueGrains.vibrationMode[materialIndex] = materials.cvFlag[materialIndex];
      
      this.text("Parameters saved.", 20, height - 20);
    }
    
    // Reset button
    if (resetButton.isClicked()) {
      frecuencySlider.setSliderValue(defaultFrecuency);
      amplitudeSlider.setSliderValue(defaultAmplitude);
      phaseSlider.setSliderValue(defaultPhase);
      grainSlider.setSliderValue(materials.materialGranularity[materialIndex]);
      waveSelector.setValue(defaultWave);
      
      this.text("Parameters reseted.", 20, height - 20);
    }
  }
  
  public void exitActual() {
    frame2Exit = true;
    saActive = false;
  }
}
