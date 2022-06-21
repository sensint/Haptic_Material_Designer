// SECOND WINDOW ----------------------------------------------------------
class SecondApplet extends PApplet {

  String materialName;
  int materialIndex;

  // UI Elements
  uniqueSelectButtons waveSelector; // material selectors
  Button saveButton, resetButton;
  Slider frecuencySlider, amplitudeSlider, durationSlider, binSlider;
  ADSR envelope;

  String[] waveSelectorName = {"Sine", "Sawtooth", "Square", "Pulse"};
  int[][] waveSelectorPositions = new int[4][4];

  // Positions/size of the envelope box
  int xPos = 20; 
  int yPos = 400; 
  int boxHeight = 200; 
  int boxWidth = 400;

  public SecondApplet(String materialName, int materialIndex) {
    super();
    this.materialName = materialName;
    this.materialIndex = materialIndex;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(500, 700);
  }

  public void setup() {

    surface.setTitle("Material designer for Material " + materialName);

    frecuencySlider= new Slider(this, "Frequency", 'r', minFrecuency, maxFrecuency, defaultFrecuency);
    amplitudeSlider= new Slider(this, "Amplitude", 'r', minAmplitude, maxAmplitude, defaultAmplitude);
    durationSlider= new Slider(this, "Duration", 'r', minDuration, maxDuration, defaultDuration);
    binSlider= new Slider(this, "Bins", 'r', minBin, maxBin, defaultBin);

    saveButton = new Button(this, "Save", 'w');
    resetButton = new Button(this, "Reset", 'w');

    envelope = new ADSR(this, "envelope");
    envelope.initialize(xPos, yPos, boxHeight, boxWidth);

    // Set positions of wave selectors
    for (int i = 0; i < waveSelectorName.length; i++) { 
      waveSelectorPositions[i][0] = 20 + 65 * i;
      waveSelectorPositions[i][1] = 290;
      waveSelectorPositions[i][2] = 60;
      waveSelectorPositions[i][3] = 35;
    }

    waveSelector = new uniqueSelectButtons(this, waveSelectorName.length, waveSelectorName, subset(guiColors, 0, 4)); //number of buttons, names, colors
    waveSelector.defaultColor(bgColor); //set a new default (should be same as background, probably)
    waveSelector.setValue(defaultWave); // Set default value
  }

  public void draw() {

    background(18, 18, 18);

    // Display sliders
    fill(255, 100, 50);  
    frecuencySlider.display(20, 20, 300, 35); 
    fill(50, 100, 255); 
    amplitudeSlider.display(20, 90, 300, 35); 
    fill(255, 255, 50); 
    durationSlider.display(20, 150, 300, 35); 
    fill(0, 255, 0); 
    binSlider.display(20, 210, 300, 35);

    // Display wave selector
    waveSelector.display(waveSelectorPositions); // Display them and check for toggle status

    // Display ADSR
    fill(255);
    envelope.displayControlPoints(); 
    envelope.displayArea();
    envelope.displayBox();

    // Display buttons
    saveButton.display(20, 640, 70, 30);
    resetButton.display(100, 640, 70, 30);

    fill(255);
    amplitudeSlider.displayHandle(); // Display numerical value
    frecuencySlider.displayHandle();
    durationSlider.displayHandle();
    binSlider.displayHandle();

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
      currentMaterial.setFloat("num_bin", binSlider.getSliderValue());
      currentMaterial.setFloat("env_a", env_a);
      currentMaterial.setFloat("env_d", env_d);
      currentMaterial.setFloat("env_s", env_s);
      currentMaterial.setFloat("env_r", env_r);
      currentMaterial.setInt("wave", waveSelector.activeButton());
      materialJSON.setJSONObject(materialIndex, currentMaterial);
    }

    if (resetButton.isClicked()) {
      frecuencySlider.setSliderValue(defaultFrecuency);
      amplitudeSlider.setSliderValue(defaultAmplitude);
      durationSlider.setSliderValue(defaultDuration);
      binSlider.setSliderValue(defaultBin);
      waveSelector.setValue(defaultWave);
    }
  }

  public void exitActual() {
    frame2Exit = true;
    saActive = false;
  }
}
