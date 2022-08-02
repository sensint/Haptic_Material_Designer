public class GrainCalculator {

    //globalGrainVariables;
    PApplet parent;
    int binNumber;
    float segmentSize;
    int lineIndexStart = 0;
    int lineIndexEnd = 0;
    int regionCounter = 0;
    int globalGrainID = 0; //todo: increment everytime y is incremented
    float scalarForOutput;
    int[] granularity;
    int[] granularityPointer;
    int [] vibrationMode;
    color[] displayColor;
    String name; // <----- update and use for debug

    ArrayList<Float> grainsPositions = new ArrayList<Float>();
    ArrayList<Integer> grainsMaterials = new ArrayList<Integer>();
    int[] grainsGlobalIds;
    //int[] grainsMaterials;

    int xPosition;
    int yPosition;

    //visualizer
    //int xPosition;
    //int yPosition;

    GrainCalculator(PApplet parent, String newName, PhysicalSlider s, MaterialCollection m, float targetRange) {
        this.parent = parent;
        this.granularity = m.materialGranularity;
        this.vibrationMode = m.cvFlag;
        this.binNumber = s.state.length;
        this.segmentSize = s.buttonHeight;
        this.granularityPointer = s.state;
        this.scalarForOutput = targetRange / s.sliderHeight;
        this.displayColor = m.displayColor;
        this.xPosition = s.xPosition + s.sliderWidth + 20;
        this.yPosition = s.yPosition;
        this.name = newName;
    }

    void updateGrains() {

        // this function searches for new sections
        lineIndexStart = 0;
        lineIndexEnd = 0;
        regionCounter = 0;
        globalGrainID = 0;

        // println("[INFO] Begin ARRAY " + this.name);

        grainsPositions.clear();
        grainsMaterials.clear();


        //printArray(vibrationMode);
        //println("FIN DE ARRAY MODE");
        //printArray(granularity);
        //println("FIN DE ARRAY GRAINS");

        for (int i = 0; i < binNumber; i++) { //loop through the array

            //this is just what happens at the end of the array. the logic starts after this check
            if (i == granularityPointer.length - 1) { //if its one before the last line

                //  println("*************Last chance******************");
                lineIndexEnd = i + 1; //then the end of the section is the end of the index

                if (granularityPointer[i] >= 0) { //if its not -1 (-1 is the default value)

                    //                    if (vibrationMode[granularityPointer[i]] == 1) {
                    //                        //println("ES MOTION COUPLED");
                    //                        //the nextline is where all the assignements happen       
                    //                        globalGrainID = this.drawGrains(i, this.globalGrainID); //returns the number of grains. calculates and prints their position
                    //                        //here
                    //                    } else if (vibrationMode[granularityPointer[i]] == 0) {
                    //                        //println("ES CV");

                    //                        PVector p1 = new PVector(xPosition, lineIndexStart * segmentSize + yPosition);
                    //                        PVector p2 = new PVector(xPosition, lineIndexEnd * segmentSize + yPosition);

                    //                        //println(p1);
                    //                        //println(p2);

                    //                        drawWave(p1, p2);
                    //                    }
                    //println("FIN PRINLN -------------------");
                    globalGrainID = this.drawGrains(i, this.globalGrainID);
                } 

                //Unless nothing is selected, the loop starts here
            } else if (granularityPointer[i + 1] != granularityPointer[i]) { //if there is a new region
                //   println("difference found");
                lineIndexEnd = i + 1;  //we set an end to our line (so between lineIndexStart and lineIndex end we have something to work with.
                regionCounter = regionCounter + 1; //lets count how many regions we have
                // line(xPosition, lineIndexStart*segmentSize+ yPosition, xPosition, lineIndexEnd*segmentSize+ yPosition); //lets draw that region, for sanity

                //draw the grains per line:
                if (granularityPointer[i] >= 0) {

                    //if (vibrationMode[granularityPointer[i]] == 1) {
                    //    println("It is MOTION COUPLED");

                    //    //the nextline is where all the assignements happen
                    //    globalGrainID = this.drawGrains(i, this.globalGrainID); //returns the number of grains. calculates and prints their position
                    //} else if (vibrationMode[granularityPointer[i]] == 0) {
                    //    println("It is CV");
                    //    PVector p1 = new PVector(xPosition, lineIndexStart * segmentSize + yPosition);
                    //    PVector p2 = new PVector(xPosition, lineIndexEnd * segmentSize + yPosition);

                    //    //println(p1);
                    //    //println(p2);
                    //    drawWave(p1, p2);
                    //}
                    globalGrainID = this.drawGrains(i, this.globalGrainID); //returns the number of grains. calculates and prints their position
                }

                // think about what happens here
                lineIndexStart = lineIndexEnd;

                //end previous line, start new line
            }
        } // end of for loop

        // println("[INFO] End ARRAY");
        parent.stroke(0);
    }

    //when anew segment is identified this function updates all the grains
    int drawGrains(int i, int grainID) {

        // println("*************drawing "+ this.name+ "******************");
        //revertthe logic. the slider should store the index to the grain, not the other way around
        float grainSpacing = int(segmentSize * (float(binNumber) / float(this.granularity[this.granularityPointer[i]] * 10))); //pixels between grains
        //ifthere are 20 segments, and there are 20 grains over the entire range, then there is 1 segment per grain
        //then the distance between grains is the segmentsize.
        // println("Last grainSpacing "+ grainSpacing);
        float grainNumber = (lineIndexEnd - lineIndexStart) * segmentSize / grainSpacing; //number of grains
        //float visualizationRange = (lineIndexEnd - lineIndexStart) * segmentSize; //number of grains

        //  println("*************grainsTodraw "+  grainNumber + "******************");
        //lineIndexEnd and lineIndexStart are the INDEXES of where lines start. They need to be multiplied by segment size for dimensionality
        //  println("Last grainNumber "+ grainSpacing);
        parent.stroke(255);
        parent.line(xPosition, lineIndexStart * segmentSize + yPosition, xPosition, lineIndexEnd * segmentSize + yPosition); //draw that line

        if (vibrationMode[granularityPointer[i]] == 1) {
            println("It is MOTION COUPLED");

            //the nextline is where all the assignements happen
            for (int y = 0; y < grainNumber; y++) {
                parent.fill(255);

                if (granularityPointer[i] != -1) { //if there is a grain
                    float grainPosition = ((lineIndexStart * segmentSize) + (grainSpacing * y) + (grainSpacing * 0.5));

                    if (grainPosition > lineIndexEnd * segmentSize) {
                    } else {

                        // the beginning of its area
                        // the offset from the start (first one is at zero)
                        // half its grain spacing (move the first one up half a step to centre it)

                        //(startof segment + exact position within segment + scaler for range of 0 to 1000
                        //print("grainRegion: " + regionCounter + " localGrainID: " + y);
                        //print("," +  "\t" + " GrainID " +  grainID);
                        //print(", " +  "\t" + " at " + grainPosition * scalarForOutput);
                        //println("," +  "\t" + " \t" + " with material " + granularityPointer[i]);

                        grainsPositions.add(grainPosition * scalarForOutput);
                        grainsMaterials.add(displayColor[granularityPointer[i]]);

                        // Save Grain Data

                        //todo: find the modulo (?) and add half of it to the beginning, so grains are spaced evenly
                        parent.stroke(displayColor[granularityPointer[i]]);
                        // drawGrain(xPosition, grainPosition + yPosition, 19, 11); //uneven numbers re prettier
                        drawGrain(xPosition, grainPosition + yPosition, 13, 7); // uneven numbers re prettier
                        grainID = grainID + 1;
                    }
                }
            }
        } else if (vibrationMode[granularityPointer[i]] == 0) {
            println("It is CV");
            PVector p1 = new PVector(xPosition, lineIndexStart * segmentSize + yPosition);
            PVector p2 = new PVector(xPosition, lineIndexEnd * segmentSize + yPosition);

            //println(p1);
            //println(p2);
            drawWave(p1, p2);
        }

        return grainID;
    }

    void drawGrain(float grainX, float graynY, float grainWidth, float grainHeight) {
        parent.strokeWeight(1);
        parent.line(grainX - (grainWidth / 2) + 6, graynY - 5, grainX + (grainWidth / 2) - 6, graynY - 5);
        parent.line(grainX - (grainWidth / 2) + 4, graynY - 4, grainX + (grainWidth / 2) - 4, graynY - 4);
        parent.line(grainX - (grainWidth / 2) + 3, graynY - 3, grainX + (grainWidth / 2) - 3, graynY - 3);
        parent.line(grainX - (grainWidth / 2) + 2, graynY - 2, grainX + (grainWidth / 2) - 2, graynY - 2);
        parent.line(grainX - (grainWidth / 2) + 1, graynY - 1, grainX + (grainWidth / 2) - 1, graynY - 1);
        parent.line(grainX - (grainWidth / 2) - 2, graynY, grainX + (grainWidth / 2) + 2, graynY);
        parent.line(grainX - (grainWidth / 2) + 1, graynY + 1, grainX + (grainWidth / 2) - 1, graynY + 1);
        parent.line(grainX - (grainWidth / 2) + 2, graynY + 2, grainX + (grainWidth / 2) - 2, graynY + 2);
        parent.line(grainX - (grainWidth / 2) + 3, graynY + 3, grainX + (grainWidth / 2) - 3, graynY + 3);
        parent.line(grainX - (grainWidth / 2) + 4, graynY + 4, grainX + (grainWidth / 2) - 4, graynY + 4);
        parent.line(grainX - (grainWidth / 2) + 6, graynY + 5, grainX + (grainWidth / 2) - 6, graynY + 5);
        parent.ellipse(grainX, graynY, grainHeight, grainHeight);
        parent.stroke(255);

        //  beginShape();
        //  vertex(grainX-(grainWidth/2), graynY);
        //  vertex(grainX, graynY-(grainHeight/2));
        //  vertex(grainX+(grainWidth/2), graynY);
        //  vertex(grainX, graynY+(grainHeight/2));
        //  vertex(grainX-(grainWidth/2), graynY);
        //  endShape();
    }

    void drawWave(PVector p1, PVector p2) {
        float freq = 10; // frequency
        float amp = 10; // amplitude in pixels
        float d = PVector.dist(p1, p2);
        float a = atan2(p2.y-p1.y, p2.x-p1.x);
        parent.stroke(255);
        parent.noFill();
        parent.pushMatrix();
        parent.translate(p1.x, p1.y);
        parent.rotate(a);
        parent.beginShape();
        for (float k = 0; k <= d; k += 1) {
            parent.vertex(k, sin(k*TWO_PI*freq/d)*amp);
        }
        parent.endShape();
        parent.popMatrix();
    }
}
