import processing.embroider.*;

// Hex Embroidery drawer for the PEmbroider library for Processing!
// Press 's' to save the embroidery file. Press space to clear.
// Press 'i' to insert hex (this is the default mode)
// Press 'd' to add a line dividing a hex.
PEmbroiderGraphics E;
PGraphics offscreenBuffer;
int fileNumber = 1;

PVector currentMark;
ArrayList<PVector> marks;
ArrayList<PVector> vertices;
ArrayList<ArrayList<PVector>> splits;

float SQRT3 = sqrt(3);
int ROWS = 8;
int COLS = 14;
int RADIUS = 80;
boolean OFFSCREEN = false;

// should clicks be used to divide or add/remove hexagons?
boolean divideMode = false;
PVector divideStart = null;
PVector divideEnd = null;

int WHITE = 255;
int BLACK = 0;

//===================================================
void setup() { 
  size(1000,920);
  
  println(""+width+","+height);
  E = new PEmbroiderGraphics(this, width, height);
  offscreenBuffer = createGraphics(width, height);
  
  currentMark = null;
  marks = new ArrayList<PVector>();
  vertices = new ArrayList<PVector>();
  splits = new ArrayList<ArrayList<PVector>>();
  //noLoop();
}

//===================================================
void draw() {
  background(200);

 // Draw the underlying grid
  drawGrid();

  if (OFFSCREEN) {
    offscreenBuffer.beginDraw();
    offscreenBuffer.background(BLACK);
    //offscreenBuffer.noStroke();
    offscreenBuffer.stroke(127,0,0);
    offscreenBuffer.strokeWeight(3);
    offscreenBuffer.fill(WHITE); 
  } else {
    E.beginDraw(); 
    E.clear();
    
    //E.beginCull();
    E.CULL_SPACING = 5;
    basicEmbroiderySettings();
  }
  
  drawHexes(OFFSCREEN);
  if(OFFSCREEN) {
    offscreenBuffer.fill(WHITE);
  } //else {
    //E.noFill();
  
  drawSplits(OFFSCREEN);
  
  //if (OFFSCREEN) {
  //  offscreenBuffer.endDraw();
  //  generateEmbroideryFromRasterGraphics();
  //} else {
  //  E.visualize();
  //  E.endDraw();
  //}
  
  if (divideMode && (divideStart != null)) {
    stroke(0, 127, 0);
    strokeWeight(5);
    //println("drawing line");
    line(divideStart.x, divideStart.y, divideEnd.x, divideEnd.y);
    strokeWeight(1);
    stroke(0);
  }
   //E.endCull();

  //if (!mousePressed) {
    // Very important function, produces optimized paths!
    E.optimize(); 
  //}
  // params: colors, stitches, route
  E.visualize(true, true, true);
}
  
void basicEmbroiderySettings() {
    E.stroke(BLACK);  //
    E.strokeWeight(35);  //
    //E.fill(BLACK);
    E.fill(0, 0, 255);
    E.strokeSpacing(3.0);  
    //E.noStroke(); 
    E.setRenderOrder(PEmbroiderGraphics.STROKE_OVER_FILL); // or E.FILL_OVER_STROKE
    E.strokeMode(PEmbroiderGraphics.PERPENDICULAR); //
    E.strokeLocation(PEmbroiderGraphics.INSIDE); // or E.OUTSIDE, E.INSIDE, CENTER
    //E.hatchMode(PEmbroiderGraphics.VECFIELD); //
    //E.HATCH_VECFIELD=new CrossField();
    E.hatchMode(PEmbroiderGraphics.CROSS); //
    //E.HATCH_ANGLE = radians(45);
    //E.HATCH_ANGLE2 = radians(-45);
    //E.STROKE_CAP = PConstants.SQUARE;
    //E.NO_CONNECT = true;
    E.HATCH_SPACING = 10;
    //E.satinMode(PEmbroiderGraphics.ZIGZAG);
    E.setStitch(10, 15, 0);  //
    //E.RESAMPLE_MAXTURN = 0.8f; //
    randomSeed(5);
}

void drawGrid() {
  stroke(50);
  
  for(var row = 0; row <= ROWS; row++) {
    for(var col = 0; col <= COLS; col++) {
      float x =  col*RADIUS*3/2;
      float y =  row*SQRT3*RADIUS - RADIUS*SQRT3/(1+col%2);
      
      vertices.add(new PVector(x, y));
      stroke(BLACK);
      line(x, 0, x, height);
      line(0, y, width, y);
      stroke(127,0,0);
      circle(x, y, 2);
    }
  }
}
  
void drawHexes(boolean offScreen) {
    for (int m=0; m<marks.size(); m++) {
      PVector mthMark = marks.get(m); 
      if (mthMark == null) println(m+" is null"); 
      else {
        if(offScreen) {
          offscreenBuffer.beginShape();
          for (float theta = 0; theta < TWO_PI; theta += TWO_PI/6) {
            offscreenBuffer.vertex(mthMark.x+RADIUS*cos(theta), mthMark.y+RADIUS*sin(theta));
          }
          offscreenBuffer.endShape();
        } else {
          drawHex(mthMark.x, mthMark.y);
        }
      }
    }  
}

void drawSplits(boolean offScreen) {
  // Draw all the divisions
  
  for (int s=0; s<splits.size(); s++) {
      ArrayList<PVector> split = splits.get(s);
      if(offScreen) {
        offscreenBuffer.beginShape();
        offscreenBuffer.vertex(split.get(0).x, split.get(0).y);
        offscreenBuffer.vertex(split.get(0).x+0.01, split.get(0).y+0.01);
        offscreenBuffer.vertex(split.get(1).x+0.01, split.get(1).y+0.01);
        offscreenBuffer.vertex(split.get(1).x,split.get(1).y);
        offscreenBuffer.vertex(split.get(0).x, split.get(0).y);
        offscreenBuffer.vertex(split.get(0).x, split.get(0).y);
        offscreenBuffer.endShape();
      }
      else {
        E.beginShape();
        E.vertex(split.get(0).x, split.get(0).y);
        E.vertex(split.get(0).x+0.01, split.get(0).y+0.01);
        E.vertex(split.get(1).x+0.01, split.get(1).y+0.01);
        E.vertex(split.get(1).x,split.get(1).y);
        E.vertex(split.get(0).x, split.get(0).y);
        E.vertex(split.get(0).x, split.get(0).y);
        E.endShape();
      }
  }
}

void drawHex(float x, float y){
    E.beginShape();
    for (float theta = 0; theta < TWO_PI; theta += TWO_PI/6) {
      E.vertex(x+RADIUS*cos(theta), y+RADIUS*sin(theta));
    }
    E.endShape();
}


//--------------------------------------------
void generateEmbroideryFromRasterGraphics() {
  E.beginDraw(); 
  E.clear();

  basicEmbroiderySettings();
  
  E.stroke(127,0,0);  //

  E.image(offscreenBuffer, 0, 0); //
  //E.hatchRaster(offscreenBuffer, 0, 0);

  E.visualize();
  E.endDraw();
  
}
 
 
//===================================================
PVector findNearest(int x, int y) {
  float row = (x+RADIUS/2)%(RADIUS*3/2);
  float col = y%(RADIUS*SQRT3);
  //println("x/y"+x+","+y);
  //println("row/col"+row+","+col);
  
  row = x - row+RADIUS/2;
  col = y - col+RADIUS*SQRT3/2;
  //println("row%RADIUS"+row+","+row%RADIUS);

  if (row%RADIUS==0)col = col - RADIUS*SQRT3/2;

  //println("row/col" + row + "," + col);
  return new PVector(row,col);
}

boolean containsMark(PVector newMark) {
  if (newMark == null) return false;
  //println("checking if marks contains: " + newMark.x + "," + newMark.y);
  for (int i=0; i<marks.size(); i++) {
    var mark = marks.get(i);
    if ((mark.x == newMark.x) && (mark.y == newMark.y)) return true;
  }
  return false;
}
//===================================================
void mousePressed() {
  println("mouse pressed============+");
  // Create a new current mark
  var mark = findNearest(mouseX, mouseY);
  if (divideMode) {
    println("divideMode");
    if (containsMark(mark)) {
      divideStart = mark;
      divideEnd = mark;
    }
  } else if (mark != null) {
    print("insert mode");
    if (containsMark(mark)) {
      marks.remove(mark);
      currentMark = null;
      //println("removing mark");
    } else {
      //println("setting mark");
      currentMark = mark;
    }
  }
}

void mouseDragged() {
  if (divideMode) {
    PVector mark = findNearest(mouseX, mouseY);
    if (containsMark(mark)) {
      if(divideStart == null) {
        divideStart = divideEnd = mark;
      } else {
        divideEnd = mark; //new PVector(mouseX, mouseY);
      }
    }
  }
}

//===================================================
void mouseReleased() {
  if (divideMode) {
    if (divideStart == null) return;
    PVector mark = findNearest(mouseX, mouseY);
    if (containsMark(mark)) divideEnd = mark;
    if (divideStart.x==divideEnd.x && divideStart.y == divideEnd.y) return;
    println("saving split");
    ArrayList divide = new ArrayList<PVector>();
    divide.add(divideStart);
    divide.add(divideEnd);
    splits.add(divide);
    //divideMode = false;
  } else {
      // Add the current mark to the arrayList of marks
    if (currentMark != null) {
      marks.add(currentMark); 
      //println("adding mark: " + currentMark.x + "," + currentMark.y);
      currentMark = null;
    }
  }
  //E.printStats();
}


//===================================================
void keyPressed() {

  if (key == ' ') {
    currentMark = null; 
    marks.clear();
  } else if (key == 'o' || key == 'O') { // O to toggle drawing style
    OFFSCREEN = !OFFSCREEN;
  } else if (key == 's' || key == 'S') { // S to save
    //E.optimize(); // slow, but very good and important
    E.printStats(); 
    String outputFilePath = sketchPath("hexDemo" + fileNumber + ".dst");
    E.setPath(outputFilePath); 
    save(outputFilePath);
    
    E.endDraw(); // write out the file
    fileNumber += 1;
  } else if (key == 'd' || key == 'D') { // D to create cuts 
    println("divide mode");
    divideMode = true;
    currentMark = null;
  } else if (key == 'i' || key == 'I') { // I to switch to insert mode
    divideMode = false;
  }
}

class CrossField implements PEmbroiderGraphics.VectorField {
  float px=0;
  float py=0;
  public PVector get(float x, float y) {
    
    x *= 0.05;
    //new PVector(1, 0.5*sin(x));
    PVector pv = new PVector(px, x);
    this.px = x;
    this.py = y;
    return pv;
  }
}
