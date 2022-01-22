// Doodle recorder for the PEmbroider library for Processing!
// Press 's' to save the embroidery file. Press space to clear.

import processing.embroider.*;
PEmbroiderGraphics E;
int fileNumber = 1;

PGraphics render;

PVector currentMark;
ArrayList<PVector> marks;
FloatList xs;
FloatList ys;
ArrayList<PVector> vertices;

float EXT_ANGLE = 1.04719755; // 60 deg. in radians
int STARTX = 50;
int STARTY = 50;
int SIDE = 50; // SIDE length
int ROWS = 20;
int COLS = 21; // Has to be odd.

//===================================================
void setup() { 
  size (800, 600);

  E = new PEmbroiderGraphics(this, width, height);
  
  render = createGraphics(800,600);
  
  currentMark = null;
  marks = new ArrayList<PVector>();
  xs = new FloatList();
  ys = new FloatList();
  vertices = new ArrayList<PVector>();
}

//===================================================
void draw() {
  //var hexagon1 = null;
  //var signChanger = -1;
  background(255);
  drawGrid();

  E.beginDraw(); 
  E.clear();
  //E.noFill(); 
  E.fill(0, 0, 255);

  // Set some graphics properties
  E.stroke(0, 0, 0); 
  E.strokeWeight(5); 
  E.strokeSpacing(5.0); 
  E.strokeMode(PEmbroiderGraphics.PERPENDICULAR);
  E.RESAMPLE_MAXTURN = 0.8f; // 
  E.setStitch(10, 40, 0.0);
  E.hatchSpacing(20); // sets the density of adjacent runs (in machine units)

  // Draw all previous marks
  for (int m=0; m<marks.size(); m++) {
    PVector mthMark = marks.get(m); 
    if (mthMark == null) println(m+" is null"); 
    else    drawHex(mthMark.x, mthMark.y,50);
  }
  
  E.visualize();
}

void drawGrid() {
  int signChanger = -1;
  stroke(30);
  for(var i = 0; i <= ROWS; i++) {
    for(var j = 0; j <= COLS; j++) {
      float x = i * SIDE * 1.73205 + STARTY + signChanger * 0.866025 * SIDE / 2 + SIDE / 2;
      float y = STARTX + 1.5 * j * SIDE;
      xs.append(x);
      ys.append(y);
      vertices.add(new PVector(x, y));
      stroke(0);
      line(x, 0, x, height);
      line(0, y, width, y);
      stroke(127,0,0);
      point(x, y);
      signChanger = signChanger * -1;
    }
  }
  //for (int x=0; x<=width; x++) {
  //  for (int y=0; y<=height; y++) {
  //    //println(""+x*gridSize+","+0+":"+x*gridSize+","+height);
  //    line(x*gridSize, 0, x*gridSize, height);
  //    //println(""+0+","+y*gridSize+":"+width+","+y*gridSize);
  //    line(0, y*gridSize, width, y*gridSize);
  //  }
  //}
   
}
  
void drawHex(float x, float y, float radius){
    //noFill();
    //stroke(0);
      //E.hatchMode(PEmbroiderGraphics.CROSS);
    E.stroke(0, 0, 0); 
    E.hatchAngleDeg(40);  // sets the orientation for SATIN & PARALLEL (in degrees)
    E.beginShape();
    for(float a = 0; a < TWO_PI; a+=TWO_PI/6){
      float xx = sin(a) * radius + x;
      float yy = cos(a) * radius + y;
      E.vertex(xx,yy);
    }
    E.endShape();
    E.noStroke();
    E.beginShape();
    E.hatchAngleDeg(130);
    for(float a = 0; a < TWO_PI; a+=TWO_PI/6){
      float xx = sin(a) * radius + x;
      float yy = cos(a) * radius + y;
      E.vertex(xx,yy);
    }
    E.endShape();
    E.stroke(0, 0, 0); 
}

//===================================================
PVector findNearest(int x, int y) {
  
  float row = 0;
  float col = 0;
  for (int i =0; i<xs.size(); i++) {
    if (abs(x-xs.get(i)) < abs(x-row)) {
      row = xs.get(i);
    }
  }
  
  for (int j =0; j<ys.size(); j++) {
    if (abs(x-ys.get(j)) < abs(y-col)) {
      col = ys.get(j);
    }
  }
  
  return new PVector(row,col);
}

//===================================================
void mousePressed() {
  // Create a new current mark
  currentMark = findNearest(mouseX, mouseY);
  if (marks.contains(currentMark)) {
    marks.remove(currentMark);
    currentMark = null;
  }
}

//===================================================
void mouseReleased() {
  // Add the current mark to the arrayList of marks
  if (currentMark != null) marks.add(currentMark); 
  E.printStats();
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
  }
}
