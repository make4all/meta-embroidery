import processing.embroider.*;
import processing.svg.PGraphicsSVG;


// Curve Embroidery drawer for the PEmbroider library for Processing!
// Press 's' to save the embroidery file. Press space to clear.
// Press 'i' to insert curve (this is the default mode)
// Press 'd' to add a line 
PEmbroiderGraphics E;
PGraphics offscreenBuffer;
PGraphics onscreenBuffer;
int fileNumber = 1;
CurveTable marks;

float SQRT3 = sqrt(3);
int RADIUS = 100;

int WHITE = 255;
int BLACK = 0;

//===================================================
void setup() { 
  size(600,900);
  String svgFilePath = sketchPath("curveDemo" + fileNumber + ".svg");
  //beginRecord(SVG, svgFilePath);
  println(""+width+","+height);
  E = new PEmbroiderGraphics(this, width, height);
  basicEmbroiderySettings();
  offscreenBuffer = createGraphics(width, height, SVG, svgFilePath);
  offscreenBuffer.beginDraw();
  offscreenBuffer.stroke(127,0,0);
  offscreenBuffer.strokeWeight(3);

  marks =  new CurveTable(width/RADIUS, height/RADIUS);
  marks.addBuffer(E);
  marks.addBuffer(offscreenBuffer);
  
  onscreenBuffer = createGraphics(width, height);
  onscreenBuffer.beginDraw();
  onscreenBuffer.stroke(127,0,0);
  onscreenBuffer.strokeWeight(3);
  marks.addBuffer(onscreenBuffer);

  //noLoop();
  println("setup done");
}

//===================================================
void draw() {
  background(200);

  drawGrid();
  E.beginDraw(); 
  E.clear();
  offscreenBuffer.beginDraw();
  onscreenBuffer.beginDraw();
  //E.beginCull();
  E.CULL_SPACING = 5;
  
  marks.updateAll();
  offscreenBuffer.endDraw();
  onscreenBuffer.endDraw();
  
  image(onscreenBuffer,0,0);
  
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
    //E.hatchMode(PEmbroiderGraphics.CROSS); //
    //E.HATCH_ANGLE = radians(45);
    //E.HATCH_ANGLE2 = radians(-45);
    //E.STROKE_CAP = PConstants.SQUARE;
    //E.NO_CONNECT = true;
    //E.HATCH_SPACING = 10;
    //E.satinMode(PEmbroiderGraphics.ZIGZAG);
    E.setStitch(10, 15, 0);  //
    //E.RESAMPLE_MAXTURN = 0.8f; //
    randomSeed(5);
}

void drawGrid() {
  stroke(50);
  
  for(var row = 0; row <= width/RADIUS; row++) {
    for(var col = 0; col <= height/RADIUS; col++) {
      float x =   col*RADIUS;
      float y =   row*RADIUS;
     
      stroke(BLACK);
      line(x, 0, x, height);
      line(0, y, width, y);
      stroke(127,0,0);
      circle(x, y, 2);
    }
  }
}
 
 
//===================================================
int[] findNearest(int x, int y) {
  int xfloor = floor(x/RADIUS);
  int yfloor = floor(y/RADIUS);
  x = x + RADIUS/2;
  y = y + RADIUS/2;
  int row = floor(x / RADIUS);
  int col = floor(y / RADIUS);
  int quadrant = 0;
  println("x/y"+x+","+y + ","+row+","+col + "floors: " + xfloor + "," + yfloor);
  if (xfloor == row && yfloor == col) quadrant = 0;
  else if (xfloor < row && yfloor == col) quadrant = 1;
  else if (xfloor == row && yfloor >= col) quadrant = 2;
  else if (xfloor >= row && yfloor == col) quadrant = 3;
  else if (xfloor < row && yfloor < col) quadrant = 2;
  else if (xfloor == row && yfloor <= col) quadrant = 3;
  else print("unknown config");
  
  int[] ret = {row, col, quadrant};
 
  return ret;
}


//===================================================
void mouseReleased() {
  println("mouse clicked============+");
  // Create a new current mark
  var coords = findNearest(mouseX, mouseY);
  var mark = marks.get(coords[0], coords[1], coords[2]);

  if (mark == null) {
      mark = new SingleCurve(coords[0], coords[1], coords[2]);
      println("create" + mark);
      marks.put(mark);
  } else {
    println("rotate\n" + marks);
    marks.delete(mark.x, mark.y, mark.quadrant);
    mark.quadrant = (mark.quadrant+1)%4;
    marks.put(mark);
    println(marks);
  } 
}


//===================================================
void keyPressed() {
  println("======= Key Pressed " + key);
  if (key == ' ') {
    marks.clear();
    onscreenBuffer = createGraphics(width, height);
    onscreenBuffer.beginDraw();
    onscreenBuffer.stroke(127,0,0);
    onscreenBuffer.strokeWeight(3);
    marks.addBuffer(onscreenBuffer);
  } else if (key == 's' || key == 'S') { // S to save
    E.optimize(); // slow, but very good and important
    E.printStats(); 
    String outputFilePath = sketchPath("curveDemo" + fileNumber + ".dst");
    E.setPath(outputFilePath); 
    save(outputFilePath);
  
    E.endDraw(); // write out the file
    fileNumber += 1;
  
    //println("offscreenBuffer" + offscreenBuffer);
    offscreenBuffer.dispose();
    offscreenBuffer.endDraw();
    fileNumber += 1;
    String svgFilePath = sketchPath("curveDemo" + fileNumber + ".svg");
    offscreenBuffer = createGraphics(width, height, SVG, svgFilePath); 
    marks.addBuffer(offscreenBuffer);
    offscreenBuffer.beginDraw();
  }

}

class SingleCurve {
  float curvature;
  int radius, x, y;
  public int orientation;
  public int quadrant;
  
  // quadrant 0 from 0 t PI/2. 1 is the next quarter, 
  // 2 is the next, and 3 is the final quarter of a circle
  SingleCurve(int x, int y) {
    this(x, y, 0, 0, RADIUS);
  }
  
  SingleCurve(int x, int y, int orientation) {
    this(x, y, orientation, orientation, RADIUS);
  }
  
  SingleCurve(int x, int y, int orientation, int quadrant) {
    this(x, y, orientation, quadrant, RADIUS);
  }
  SingleCurve(int x, int y, int orientation, int quadrant, int radius) {
    this(x, y, orientation, quadrant, radius, 1);
  }
  SingleCurve(int x, int y, int orientation, int quadrant, int radius, float curvature) {
    this.curvature = curvature;
    this.orientation = orientation;
    this.radius = radius;
    this.quadrant = quadrant;
    this.x = x;
    this.y = y;
  }
  
  void update(PGraphics buffer) {
    // draw a square onscreen for reference
    //rect(x, y, radius, radius);
    switch (quadrant) {
      case 0: x = RADIUS*x; y = RADIUS*y; break;
      case 1: 
    }
    switch (orientation) {
      case 0: buffer.arc(RADIUS*x,RADIUS*y, radius, radius, radians(0), radians(90)); break;
      case 1: buffer.arc(RADIUS*x,RADIUS*y, radius, radius, radians(90), radians(180)); break;
      case 2: buffer.arc(RADIUS*x,RADIUS*y, radius, radius,radians(180), radians(270)); break;
      case 3: buffer.arc(RADIUS*x,RADIUS*y, radius, radius,  radians(-90), radians(0));
    }
    
  }
  void update(PEmbroiderGraphics ebuffer) {
    //println("drawing pgraphic for: " + this);
    //rect(x, y, radius, radius);
    switch (orientation) {
      case 0: ebuffer.arc(RADIUS*x,RADIUS*y, radius, radius, radians(0), radians(90)); break;
      case 1: ebuffer.arc(RADIUS*x,RADIUS*y, radius, radius, radians(90), radians(180)); break;
      case 2: ebuffer.arc(RADIUS*x,RADIUS*y, radius, radius,radians(180), radians(270)); break;
      case 3: ebuffer.arc(RADIUS*x,RADIUS*y, radius, radius,  radians(-90), radians(0));
    }
  }
  String toString() {
    return "Curve at " + x + "," + y + ":q" + quadrant + ":c"+curvature;
  }
}

class CurveTable {

  
  SingleCurve[][][] table;
  int rows; 
  int cols;  
  int quadrants = 4;
  ArrayList<PGraphics> buffers;
  ArrayList<PEmbroiderGraphics> ebuffers;
 
  
  CurveTable(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;
    this.table = new SingleCurve[quadrants][rows][cols];

    this.buffers = new ArrayList<PGraphics>();
    this.ebuffers = new ArrayList<PEmbroiderGraphics>();
  }
  
  // if row = 0, items at col 0->cols-1; 
  // if row = 0 items at cols cols->2*cols-1, etc
  SingleCurve get(int row, int col, int quadrant) {
    return this.table[quadrant][row][col];
  }
  
  void put(SingleCurve curve) {
    this.table[curve.quadrant][curve.x][curve.y] = curve;
  }
  
  void delete(int row, int col, int quadrant) {
    this.table[quadrant][row][col] = null;
  }
  
  void addBuffer(PGraphics buffer) {
    buffers.add(buffer);
  }
  void addBuffer(PEmbroiderGraphics ebuffer) {
    ebuffers.add(ebuffer);
  }
  void removeBuffer(PGraphics buffer) {
    buffers.remove(buffer);
  }
  void removeBuffer(PEmbroiderGraphics ebuffer) {
    ebuffers.remove(ebuffer);
  }
  
  void updateAll() {
    for (PGraphics buffer : buffers) {
      updateAll(buffer);
    }
    for (PEmbroiderGraphics ebuffer : ebuffers) {
      updateAll(ebuffer);
    }
    
  }
  
  void updateAll(PEmbroiderGraphics ebuffer) {
    //println("======= Update All Onscreen " + this);
    for (SingleCurve[][] rows : this.table) {
      for (SingleCurve[] col : rows) {
        for (SingleCurve curve : col) {
          if (curve != null) {
            //System.out.println("curve at:" + curve);
            curve.update(ebuffer);
          }
        }
      }
    }
  }
  void updateAll(PGraphics buffer) {
    //println("======= Update All Offscreen " + this);
    for (SingleCurve[][] rows : this.table) {
      for (SingleCurve[] col : rows) {
        for (SingleCurve curve : col) {
          if (curve != null) {
            //System.out.println("curve at:" + curve);
            curve.update(buffer);
          }
        }
      }
    }
  }
  
  void clear() {
    this.table = new SingleCurve[quadrants][rows][cols];
  }
  
  String toString() {
    String ret = "";
    int i = 0;
    for (SingleCurve[][] rows : this.table) {
      ret += "q"+i + ":[";
      i += 1;
      for (SingleCurve[] col : rows) {
        ret += "[";
        for (SingleCurve curve : col) {
          if (curve != null) {
            //System.out.println("curve at:" + curve);
            ret += curve + ",";
          } else ret += ",";
        }
        ret +="],";
      }
      ret +="]\n";
    }
    return ret;
  }
}
