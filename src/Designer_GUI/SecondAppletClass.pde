// SECOND WINDOW ----------------------------------------------------------
class SecondApplet extends PApplet {

  String materialName;
  int materialIndex;

  // UI Elements
  uniqueSelectButtons waveSelector; // material selectors
  Button saveButton, resetButton, cvButton;
  Slider frecuencySlider, amplitudeSlider, durationSlider, grainSlider;
  DiscreteSlider theSlider;
  ADSR envelope;

  String[] waveSelectorName = {"Sine", "Sawtooth", "Square", "Pulse"};
  int[][] waveSelectorPositions = new int[4][4];

  // Positions/size of the envelope box
  int xPos = 20; 
  int yPos = 470; 
  int boxHeight = 200; 
  int boxWidth = 520;

  public SecondApplet(String materialName, int materialIndex) {
    super();
    this.materialName = materialName;
    this.materialIndex = materialIndex;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(700, 800);
  }

  public void setup() {

    textSize(15);
    surface.setTitle("Material designer for Material " + materialName);

    frecuencySlider= new Slider(this, "Frequency", 'r', minFrecuency, maxFrecuency, materials.materialFrecuencies[materialIndex]);
    amplitudeSlider= new Slider(this, "Amplitude", 'r', minAmplitude, maxAmplitude, materials.materialAmplitudes[materialIndex]);
    durationSlider= new Slider(this, "Duration", 'r', minDuration, maxDuration, materials.materialDurations[materialIndex]);
    grainSlider= new Slider(this, "Grains", 'r', minBin, maxBin, materials.materialGranularity[materialIndex] / 10);

    // Discrete slider
    theSlider = new DiscreteSlider(this, "Discrete", 'r', 300, 35);
    theSlider.assignSteps(10);
    theSlider.assignRange(0, 10);

    saveButton = new Button(this, "Save", 'w');
    resetButton = new Button(this, "Reset", 'w');
    cvButton = new Button(this, "CV", 'w');

    envelope = new ADSR(this, "envelope");
    envelope.initialize(xPos, yPos, boxHeight, boxWidth);

    // Set positions of wave selectors
    for (int i = 0; i < waveSelectorName.length; i++) { 
      waveSelectorPositions[i][0] = 20 + 100 * i;
      waveSelectorPositions[i][1] = 370;
      waveSelectorPositions[i][2] = 100;
      waveSelectorPositions[i][3] = 40;
    }

    waveSelector = new uniqueSelectButtons(this, waveSelectorName.length, waveSelectorName, subset(materialColors, 0, 4));
    waveSelector.defaultColor(bgColor); //set a new default (should be same as background, probably)
    waveSelector.setValue(materials.materialWaves[materialIndex]); // Set default value
  }

  public void draw() {

    this.background(32, 36, 48);

    // Display sliders
    int sliderSep = 70;
    this.fill(78, 89, 111);  
    frecuencySlider.display(20, 20, 500, 35);
    this.fill(78, 89, 111); 
    amplitudeSlider.display(20, 20 + sliderSep, 500, 35);
    this.fill(78, 89, 111); 
    durationSlider.display(20, 20 + sliderSep * 2, 500, 35);
    this.fill(78, 89, 111); 
    grainSlider.display(70, 20 + sliderSep * 3, 550, 35);

    this.fill(112, 180, 175); 
    theSlider.display(20, 20 + sliderSep * 4, 500, 35);

    // Display wave selector
    this.fill(112, 190, 175); 
    waveSelector.display(waveSelectorPositions); 

    // Display ADSR
    this.fill(78, 89, 111);
    envelope.displayArea();
    this.fill(255, 255, 255);
    envelope.displayControlPoints();

    envelope.displayBox();

    // Display buttons
    this.fill(132, 120, 175);
    saveButton.display(20, 740, 70, 30);
    this.fill(112, 150, 175);
    resetButton.display(100, 740, 70, 30);

    cvButton.display(20, 20 + sliderSep * 3, 35, 35);

    // slider 
    // theSlider.displayHandle();

    // Button events
    if (saveButton.isClicked()) {

      // Calculate envelope values --------------------------------------------------------------------      
      float sValue_y_mapped, aValue_mapped, dValue_mapped, rValue_mapped, aRatio, dRatio, rRatio; // declare some local variables for calculations

      sValue_y_mapped = map((yPos - envelope.sustain.y()), -boxHeight, 0, 0, boxHeight);
      env_s = sValue_y_mapped / boxHeight; // easy, sustain is a ratio of amplitude, which is also the box height in this case

      // more tricky, scale positions for timing, according to duration
      // sValue_x_mapped = map((xPos - envelope.sustain.x()), -boxWidth, 0, boxWidth, 0); // scale everything to the size of the box
      aValue_mapped = map((xPos - envelope.attack.x()), -boxWidth, 0, boxWidth, 0);
      dValue_mapped = map((xPos - envelope.decay.x()), -boxWidth, 0, boxWidth, 0);
      rValue_mapped = map((xPos - envelope.release.x()), -boxWidth, 0, boxWidth, 0);

      //duration = sValue_x_mapped - aValue_mapped; // user-set duration is actually the time from attack to end of sustain
      //durationRatio = duration / boxWidth;         // calculate how much of the box is the set duration
      //// get the proportion of the box of each timing and convert to ms, start with the attack
      aRatio = aValue_mapped / boxWidth;                  // get the proportion of the box
      env_a = aRatio * durationSlider.getSliderValue();  // multiply the ratio by the duration

      dRatio = dValue_mapped / boxWidth;
      env_d = dRatio * durationSlider.getSliderValue();

      rRatio = rValue_mapped / boxWidth;
      env_r = rRatio * durationSlider.getSliderValue();

      // -------------------------------------------------------------------------------------------------------

      JSONObject currentMaterial = new JSONObject();
      currentMaterial.setInt("id", materialIndex);
      currentMaterial.setFloat("frecuency", frecuencySlider.getSliderValue());
      currentMaterial.setFloat("amplitude", amplitudeSlider.getSliderValue());
      currentMaterial.setFloat("duration", durationSlider.getSliderValue());
      currentMaterial.setFloat("num_bin", grainSlider.getSliderValue());
      currentMaterial.setFloat("env_a", env_a);
      currentMaterial.setFloat("env_d", env_d);
      currentMaterial.setFloat("env_s", env_s);
      currentMaterial.setFloat("env_r", env_r);
      currentMaterial.setInt("wave", waveSelector.activeButton());
      materialJSON.setJSONObject(materialIndex, currentMaterial);

      // --------------------------------------------------------------------------------------------------------

      // Update material properties
      // materialGranularity[materialIndex] = int(grainSlider.getSliderValue());
      materials.materialGranularity[materialIndex] =  round(grainSlider.getSliderValue() * 10);
      materials.materialFrecuencies[materialIndex] = round(frecuencySlider.getSliderValue());
      materials.materialAmplitudes[materialIndex] = amplitudeSlider.getSliderValue();
      materials.materialWaves[materialIndex] = waveSelector.activeButton();

      yellowGrains.granularity[materialIndex] = materials.materialGranularity[materialIndex];
      redGrains.granularity[materialIndex] = materials.materialGranularity[materialIndex];
      blueGrains.granularity[materialIndex] = materials.materialGranularity[materialIndex];
    }

    if (resetButton.isClicked()) {
      frecuencySlider.setSliderValue(defaultFrecuency);
      amplitudeSlider.setSliderValue(defaultAmplitude);
      durationSlider.setSliderValue(defaultDuration);
      grainSlider.setSliderValue(float(materialGranularity[materialIndex] + 1));
      waveSelector.setValue(defaultWave);
    }
  }

  public void exitActual() {
    frame2Exit = true;
    saActive = false;
  }
}
