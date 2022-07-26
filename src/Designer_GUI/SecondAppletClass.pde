class SecondApplet extends PApplet {
    String materialName;
    int materialIndex;
    int sliderSep = 80;

    // UI Elements
    uniqueSelectButtons waveSelector, cvSelector;
    Button saveButton, resetButton;
    Slider amplitudeSlider, phaseSlider;
    DiscreteSlider frecuencySlider, grainSlider;

    String[] waveSelectorName = {"Sine", "Square", "Triangle", "Sawtooth"};
    String[] cvSelectorName = {"Continuous", "Motion coupled"};
    int[][] cvSelectorPositions = new int [cvSelectorName.length][4];
    int[][] waveSelectorPositions = new int[waveSelectorName.length][4];

    public SecondApplet(String materialName, int materialIndex) {
        super();
        this.materialName = materialName;
        this.materialIndex = materialIndex;
        PApplet.runSketch(new String[]{this.getClass().getName()}, this);
    }

    public void settings() {
        size(580, 600);
    }

    public void setup() {
        textSize(15);
        surface.setTitle("Custom material " + materialName);

        //print("Se inicia el slider con grains: ");
        //println(materials.materialGranularity[materialIndex] / 10);

        amplitudeSlider= new Slider(this, "Amplitude", 'r', minAmplitude, maxAmplitude, materials.materialAmplitudes[materialIndex], "");
        phaseSlider= new Slider(this, "Phase", 'r', minDuration, maxDuration, materials.materialPhases[materialIndex], "");
        //phaseSlider = new DiscreteSlider(this, "Phase", 'r', minDuration, maxDuration, materials.materialPhases[materialIndex], maxDuration - minDuration, 500);
        frecuencySlider = new DiscreteSlider(this, "Frecuency", 'f', minFrecuency, maxFrecuency, materials.materialFrecuencies[materialIndex], maxFrecuency - minFrecuency, 500, "Hz");
        frecuencySlider.showTicks(false);
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

        //if (materials.cvFlag[materialIndex] == true) {
        //  cvSelector.setValue(0);
        //}
    }

    public void draw() {
        this.background(mainColor);

        this.fill(whiteColor);
        this.text("Choose vibration mode", 15, 30);

        // Display vibration selector
        cvSelector.display(cvSelectorPositions);
        if (cvSelector.activeButton() == 1) {
            this.fill(secondaryColor); 
            this.noStroke();
            grainSlider.display(160, 45, 360, 75);
        } else if (cvSelector.activeButton() == 0) {
            this.text("Continuous vibration selected, no grains!", 200, 90);
        } else if (cvSelector.activeButton() == -1) {
            this.text("Please, choose a vibration mode.", 220, 90);
        }

        this.fill(whiteColor);
        this.text("Custom vibration parameters", 15, 170);

        // Display sliders
        this.fill(secondaryColor); 
        this.noStroke();
        frecuencySlider.display(20, 190 + sliderSep, 500, 40);
        this.fill(secondaryColor);
        amplitudeSlider.display(20, 190 + sliderSep * 2, 500, 40);
        this.fill(secondaryColor);
        phaseSlider.display(20, 190 + sliderSep * 3, 500, 40);

        // Display wave selector
        waveSelector.display(waveSelectorPositions);

        // Display buttons
        this.fill(whiteColor);
        saveButton.display(20, 510, 70, 30);
        this.fill(whiteColor);
        resetButton.display(110, 510, 70, 30);

        // Display text
        this.stroke(whiteColor);
        line(0, height-25, width, height-25);

        // Button events
        if (saveButton.isClicked()) {
            // Get data from UI
            int frecuencyValue = round(frecuencySlider.getSliderValue());
            Float amplitudeValue = amplitudeSlider.getSliderValue();
            //Float amplitudeValue = amplitudeSlider.getSliderValue() - amplitudeSlider.getSliderValue()%0.01;
            //print(amplitudeValue);
            Float phaseValue = phaseSlider.getSliderValue();
            int grainsValue = 0;
            int waveformValue = waveSelector.activeButton();
            int cvValue = cvSelector.activeButton();
            println(cvValue);
            println("---");
            if (cvSelector.activeButton() == 0) {
                grainsValue = 0;
            } else if (cvSelector.activeButton() == 1) {
                grainsValue = round(grainSlider.getSliderValue());
                //grainsValue = round(grainSlider.getSliderValue());
            }


            // Save data to JSON object -----------------------------------------------------------------------------
            JSONObject currentMaterial = new JSONObject();
            currentMaterial.setString("material_id", str(materialIndex));
            currentMaterial.setString("frecuency", str(frecuencyValue));
            currentMaterial.setString("amplitude", str(amplitudeValue));
            currentMaterial.setString("phase", str(phaseValue));
            currentMaterial.setString("grains", str(grainsValue));
            currentMaterial.setString("waveform", str(waveformValue));
            currentMaterial.setString("cv", str(cvValue));
            materialJSON.setJSONObject(materialIndex, currentMaterial);

            // Update material properties ----------------------------------------------------------------------------
            materials.materialFrecuencies[materialIndex] = frecuencyValue;
            materials.materialAmplitudes[materialIndex] = amplitudeValue;
            materials.materialPhases[materialIndex] = phaseValue;
            materials.materialWaves[materialIndex] = waveformValue;
            materials.cvFlag[materialIndex] = cvValue;
            materials.materialGranularity[materialIndex] = grainsValue;
            // if (cvSelector.activeButton() == 0) {
            //     materials.materialGranularity[materialIndex] =  0;
            // } else if (cvSelector.activeButton() == 1) {
            //     materials.materialGranularity[materialIndex] =  round(grainSlider.getSliderValue() * 10);
            // }

            //print("Se guarda el slider con grains: ");
            //println(grainsValue);

            yellowGrains.granularity[materialIndex] = materials.materialGranularity[materialIndex];
            redGrains.granularity[materialIndex] = materials.materialGranularity[materialIndex];
            blueGrains.granularity[materialIndex] = materials.materialGranularity[materialIndex];

            yellowGrains.vibrationMode[materialIndex] = materials.cvFlag[materialIndex];
            //println( yellowGrains.vibrationMode[materialIndex]);
            //println("aaaaaaaaaaaaaaaa");
            redGrains.vibrationMode[materialIndex] = materials.cvFlag[materialIndex];
            blueGrains.vibrationMode[materialIndex] = materials.cvFlag[materialIndex];

            this.text("Parameters saved.", 20, height-5);
        }

        // Reset button
        if (resetButton.isClicked()) {
            frecuencySlider.setSliderValue(defaultFrecuency);
            amplitudeSlider.setSliderValue(defaultAmplitude);
            phaseSlider.setSliderValue(defaultDuration);
            grainSlider.setSliderValue(materials.materialGranularity[materialIndex]);
            waveSelector.setValue(defaultWave);

            this.text("Parameters reseted.", 20, height-5);
        }
    }

    public void exitActual() {
        frame2Exit = true;
        saActive = false;
    }
}
