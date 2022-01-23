import processing.embroider.*;

// Hex Embroidery drawer for the PEmbroider library for Processing!
// Press 's' to save the embroidery file. Press space to clear.
// Press 'i' to insert hex (this is the default mode)
// Press 'd' to add a line dividing a hex.
PEmbroiderGraphics E;
int fileNumber = 1;

PGraphics render;

PVector currentMark;
ArrayList<PVector> marks;
FloatList xs;
FloatList ys;
ArrayList<PVector> vertices;
ArrayList<ArrayList<PVector>> splits;

float SQRT3 = sqrt(3);
int ROWS = 10;
int COLS = 10;
int RADIUS = 40;
float YOFFSET = 0;
float XOFFSET = 0;

// should clicks be used to divide or add/remove hexagons?
boolean divideMode = false;
PVector divideStart = null;
PVector divideEnd = null;

//===================================================
void setup() { 
  size(900,520);
  
  println(""+width+","+height);
  E = new PEmbroiderGraphics(this, width, height);
  
  render = createGraphics(800,600);
  
  currentMark = null;
  marks = new ArrayList<PVector>();
  xs = new FloatList();
  ys = new FloatList();
  vertices = new ArrayList<PVector>();
  splits = new ArrayList<ArrayList<PVector>>();
  //noLoop();
}

//===================================================
void draw() {
  background(255);
  E.beginDraw(); 
  E.clear();
  E.fill(0, 0, 255);

  // Set some graphics properties
  E.stroke(0, 0, 0); 
  E.strokeWeight(5); 
  E.strokeSpacing(5.0); 
  E.strokeMode(PEmbroiderGraphics.PERPENDICULAR);
  E.RESAMPLE_MAXTURN = 0.8f; // 
  E.setStitch(10, 20, 0.0);
  E.hatchSpacing(10); // sets the density of adjacent runs (in machine units)

  // Draw the underlying grid
  drawGrid();

  // Draw all previous marks
  for (int m=0; m<marks.size(); m++) {
    PVector mthMark = marks.get(m); 
    if (mthMark == null) println(m+" is null"); 
    else drawHex(mthMark.x, mthMark.y);
  }

  // Draw all the divisions
  for (int d=0; d<splits.size(); d++) {
    stroke(0, 0, 127);
    ArrayList<PVector> split = splits.get(d);
    PVector start = split.get(0);
    PVector end = split.get(1);
    line(start.x, start.y, end.x, end.y);
  }

  if (divideMode && (divideStart != null)) {
    stroke(0, 127, 0);
    println("drawing line");
    line(divideStart.x, divideStart.y, divideEnd.x, divideEnd.y);
  }
  
  E.visualize();
}

void drawGrid() {
  stroke(50);
  boolean odd; 
  
  for(var row = 0; row <= ROWS; row++) {
    for(var col = 0; col <= COLS; col++) {
      float x =  col*RADIUS*3/2;
      float y =  row*SQRT3*RADIUS - RADIUS*SQRT3/(1+col%2);
      
      //println("row/col: " + row + "," + col + "x/y:" + x+","+y);
      xs.append(x);
      ys.append(y);
      vertices.add(new PVector(x, y));
      stroke(0);
      line(x, 0, x, height);
      line(0, y, width, y);
      stroke(127,0,0);
      circle(x, y, 2);
      //drawHex(x, y);
    }
  }
}
  
void drawHex(float x, float y){
    E.stroke(0, 0, 0); 
    E.hatchAngleDeg(40);  // sets the orientation for SATIN & PARALLEL (in degrees)
    E.beginShape();
    for (float theta = 0; theta < TWO_PI; theta += TWO_PI/6) {
      E.vertex(x+RADIUS*cos(theta), y+RADIUS*sin(theta));
    }
    E.endShape();
    E.noStroke();
    E.beginShape();
    E.hatchAngleDeg(130);
    for (float theta = 0; theta < TWO_PI; theta += TWO_PI/6) {
      E.vertex(x+RADIUS*cos(theta), y+RADIUS*sin(theta));
    }
    E.endShape();
    E.stroke(0, 0, 0); 
}

//===================================================
PVector findNearest(int x, int y) {
  float row = (x+RADIUS/2)%(RADIUS*3/2);
  float col = y%(RADIUS*SQRT3);
  println("x/y"+x+","+y);
  println("row/col"+row+","+col);
  
  row = x - row+RADIUS/2;
  col = y - col+RADIUS*SQRT3/2;
  println("row%RADIUS"+row+","+row%RADIUS);

  if (row%RADIUS==0)col = col - RADIUS*SQRT3/2;

  println("row/col" + row + "," + col);
  return new PVector(row,col);
}

boolean containsMark(PVector newMark) {
  if (newMark == null) return false;
  println("checking if marks contains: " + newMark.x + "," + newMark.y);
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
    divideStart = mark;
  } else if (mark != null) {
    if (containsMark(mark)) {
      marks.remove(mark);
      currentMark = null;
      println("removing mark");
    } else {
      println("setting mark");
      currentMark = mark;
    }
  }
}

void mouseMoved() {
  divideEnd =findNearest(mouseX, mouseY); //new PVector(mouseX, mouseY);
}

//===================================================
void mouseReleased() {
  // Add the current mark to the arrayList of marks
  if (currentMark != null) {
    marks.add(currentMark); 
    println("adding mark: " + currentMark.x + "," + currentMark.y);
    currentMark = null;
  }

  if (divideMode) {
    divideEnd = findNearest(mouseX, mouseY);
    ArrayList divide = new ArrayList<PVector>();
    divide.add(divideStart);
    divide.add(divideEnd);
    splits.add(divide);
    divideMode = false;
  }
  //E.printStats();
}


//===================================================
void keyPressed() {

  if (key == ' ') {
    currentMark = null; 
    marks.clear();
    
  } else if (key == 's' || key == 'S') { // S to save
    E.optimize(); // slow, but very good and important
    E.printStats(); 
    String outputFilePath = sketchPath("hexDemo" + fileNumber + ".dst");
    E.setPath(outputFilePath); 
    save(outputFilePath);
    
    E.endDraw(); // write out the file
    fileNumber += 1;
  } else if (key == 'd' || key == 'D') { // D to create cuts 
    divideMode = true;
  } else if (key == 'i' || key == 'I') { // I to switch to insert mode
    divideMode = false;
  }
}
