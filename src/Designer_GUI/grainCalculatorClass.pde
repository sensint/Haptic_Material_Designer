public class GrainCalculator {
  
  //globalGrainVariables;
  PApplet parent;
  int binNumber;
  float segmentSize;
  int lineIndexStart = 0;
  int lineIndexEnd = 0;
  int regionCounter = 0;
  int globalGrainID = 0;
  float scalarForOutput;
  int[] granularity;
  int[] granularityPointer;
  int[] vibrationMode;
  color[] displayColor;
  String name;
  
  ArrayList<Integer> grainsPositionsStart = new ArrayList<Integer>();
  ArrayList<Integer> grainsPositionsEnd = new ArrayList<Integer>();
  ArrayList<Integer> grainsMaterials = new ArrayList<Integer>();
  int[] grainsGlobalIds;
  
  int xPosition;
  int yPosition;
  
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

    lineIndexStart = 0;
    lineIndexEnd = 0;
    regionCounter = 0;
    globalGrainID = 0;
    
    grainsPositionsStart.clear();
    grainsPositionsEnd.clear();
    grainsMaterials.clear();
    
    for (int i = 0; i < binNumber; i++) { 
      
      if (i == granularityPointer.length - 1) {
        
        lineIndexEnd = i + 1; 
        
        if (granularityPointer[i] >= 0) {
          globalGrainID = this.drawGrains(i, this.globalGrainID);
        } 
        
      } else if (granularityPointer[i + 1] != granularityPointer[i]) { 
        lineIndexEnd = i + 1; 
        regionCounter = regionCounter + 1;
        if (granularityPointer[i] >= 0) {
          
          globalGrainID = this.drawGrains(i, this.globalGrainID); 
        }
        
        lineIndexStart = lineIndexEnd;
        
      }
    } 
    parent.stroke(0);
  }
  
  
  int drawGrains(int i, int grainID) {
    float grainSpacing = int(segmentSize * (float(binNumber) / float(this.granularity[this.granularityPointer[i]] * 10))); 
    float grainNumber = (lineIndexEnd - lineIndexStart) * segmentSize / grainSpacing;
    parent.stroke(255);
    
    if (vibrationMode[granularityPointer[i]] == 0) {
      
      parent.line(xPosition, lineIndexStart * segmentSize + yPosition, xPosition, lineIndexEnd * segmentSize + yPosition); 
      for (int y = 0; y < grainNumber; y++) {
        parent.fill(255);
        
        if (granularityPointer[i] != -1) { 
          float grainPosition = ((lineIndexStart * segmentSize) + (grainSpacing * y) + (grainSpacing * 0.5));
          
          if (grainPosition > lineIndexEnd * segmentSize) {
          } else {          
            grainsPositionsStart.add(int(grainPosition * scalarForOutput));
            grainsPositionsEnd.add(int(grainPosition * scalarForOutput));
            grainsMaterials.add(int(displayColor[granularityPointer[i]]));
            
            parent.stroke(displayColor[granularityPointer[i]]);
            drawGrain(xPosition, grainPosition + yPosition, 13, 7); 
            grainID = grainID + 1;
          }
        }
      }
    } else if (vibrationMode[granularityPointer[i]] == 1) {
      int frecMultiplier = int((lineIndexEnd - lineIndexStart));
      PVector p1 = new PVector(xPosition, lineIndexStart * segmentSize + yPosition);
      PVector p2 = new PVector(xPosition, lineIndexEnd * segmentSize + yPosition);
      
      int disGhost = 6;
      
      // Ghost grain 1
      grainsPositionsStart.add(int((lineIndexStart * segmentSize) * scalarForOutput) - disGhost);
      grainsPositionsEnd.add(int((lineIndexStart * segmentSize) * scalarForOutput) - disGhost);
      grainsMaterials.add(int(displayColor[6]));
      
      grainsPositionsStart.add(int((lineIndexStart * segmentSize) * scalarForOutput));
      grainsPositionsEnd.add(int((lineIndexEnd * segmentSize) * scalarForOutput));
      grainsMaterials.add(int(displayColor[granularityPointer[i]]));
      
      // Ghost grain 2
      grainsPositionsStart.add(int((lineIndexEnd * segmentSize) * scalarForOutput) + disGhost);
      grainsPositionsEnd.add(int((lineIndexEnd * segmentSize) * scalarForOutput) + disGhost);
      grainsMaterials.add(int(displayColor[6]));
      
      drawWave(p1, p2, frecMultiplier);
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
  }
  
  void drawWave(PVector p1, PVector p2, int frecMul) {
    float freq = 4 * frecMul;
    float amp = 10; // amplitude in pixels
    float d = PVector.dist(p1, p2);
    float a = atan2(p2.y - p1.y, p2.x - p1.x);
    parent.stroke(255);
    parent.noFill();
    parent.pushMatrix();
    parent.translate(p1.x, p1.y);
    parent.rotate(a);
    parent.beginShape();
    for (float k = 0; k <= d; k += 1) {
      parent.vertex(k, sin(k * TWO_PI * freq / d) * amp);
    }
    parent.endShape();
    parent.popMatrix();
  }
}
