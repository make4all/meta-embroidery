import processing.embroider.*;
import processing.svg.PGraphicsSVG;

// Curve Embroidery drawer for the PEmbroider library for Processing!
// Press 's' to save the embroidery file. Press space to clear.
// Press 'i' to insert curve (this is the default mode)
// Press 'd' to add a line 
// press 'c' to change to curveless mode (press again to change to placing)
// prese 'C' to change to curve more mode (press again to change to placing)
PEmbroiderGraphics E;
PGraphics offscreenBuffer;
PGraphics onscreenBuffer;
int fileNumber = 1;
CurveTable marks;

int RADIUS = 100;
int gridcols = 1;
int gridrows = 1;

int WHITE = 255;
int BLACK = 0;
String MODE = "PLACING"; // also "CURVELESS" "CURVEMORE" 

//===================================================
void setup() { 
  size(600,900);
  gridcols = floor(width/RADIUS)-1;
  gridrows = floor(height/RADIUS)-1;
  println("rows"+gridrows+", cols"+gridcols);

  E = new PEmbroiderGraphics(this, width, height);
  basicEmbroiderySettings(E);
  
  marks =  new CurveTable(gridrows, gridcols);
  //marks.addBuffer(E);
  
  onscreenBuffer = createGraphics(width, height);
  
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
  marks.removeBuffer(offscreenBuffer);
  String svgFilePath = sketchPath("curveDemo" + fileNumber + ".svg");
  offscreenBuffer = createGraphics(width, height, SVG, svgFilePath);
  marks.addBuffer(offscreenBuffer);
  offscreenBuffer.beginDraw();
  basicDrawingSettings(offscreenBuffer);
  onscreenBuffer.beginDraw();
  basicDrawingSettings(onscreenBuffer);
  onscreenBuffer.clear();

  //E.beginCull();
  E.CULL_SPACING = 5;
  
  marks.updateAll();
  onscreenBuffer.endDraw();
  
  image(onscreenBuffer,0,0);
  
  E.visualize(true, true, true);
}
  
void basicDrawingSettings(PGraphics buffer) {
  buffer.stroke(127,0,0);
  buffer.strokeWeight(1);
  buffer.noFill();
}

void basicEmbroiderySettings(PEmbroiderGraphics E) {
    E.stroke(BLACK);  //
    E.strokeWeight(10);  //
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
  
  for(var row = 0; row <= gridrows; row++) {
    for(var col = 0; col <= gridcols; col++) {
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
 
 
//===============================    HELPERS ===============================
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

int[] adjustXY(int orientation, int quadrant) {
  int [] ret = {0, 0};
  
  switch (orientation) {
      case 0:  {
         switch (quadrant) {
          case 1: ret[0] = -RADIUS/2; break;
          case 2: ret[0] = -RADIUS/2; ret[1] = -RADIUS/2; break;
          case 3: ret[1] = -RADIUS/2; 
         }
         return ret;
      }
      case 1: {
        switch (quadrant) {
          case 0: ret[0] =  RADIUS/2; break;
          case 2: ret[1] = -RADIUS/2; break;
          case 3: ret[0] = RADIUS/2; ret[1] = -RADIUS/2; 
         }
        return ret;
      }
      case 2: {
        switch (quadrant) {
          case 0: ret[0] = ret[1] =  RADIUS/2; break;
          case 1: ret[1] = RADIUS/2; break;
          case 3: ret[0] = RADIUS/2; 
        }
      return ret;
    }
      case 3: {
        switch (quadrant) {
          case 0: ret[1] =  RADIUS/2; break;
          case 1: ret[0] = -RADIUS/2; ret[1] = RADIUS/2; break;
          case 2: ret[0] = -RADIUS/2; 
         }
         return ret;
      }
    } 
  return ret;
}

void bezierArc(PGraphics buffer, int centerx, int centery,  int radius, float angleStart, float angleEnd, float curvature) {
    // assuming angleStart and angleEnd are in raians

    // Finding the coordinates of the control points in a simplified case where the center of the circle is at [0,0]
    var relControlPoints = getRelativeControlPoints(angleStart, angleEnd, radius/2*curvature);
    var startp = getPointAtAngle(angleStart, centerx, centery, radius/2);
    var endp = getPointAtAngle(angleEnd, centerx, centery, radius/2);
    buffer.bezier(startp[0], startp[1], 
                   centerx + relControlPoints[0][0], centery + relControlPoints[0][1],
                   centerx + relControlPoints[1][0], centery + relControlPoints[1][1],
                   endp[0], endp[1]);
}

void bezierArc(PEmbroiderGraphics buffer, int centerx, int centery,  int radius, float angleStart, float angleEnd, float curvature) {
    // assuming angleStart and angleEnd are in raians

    // Finding the coordinates of the control points in a simplified case where the center of the circle is at [0,0]
    var relControlPoints = getRelativeControlPoints(angleStart, angleEnd, radius/2*curvature);
    var startp = getPointAtAngle(angleStart, centerx, centery, radius/2);
    var endp = getPointAtAngle(angleEnd, centerx, centery, radius/2);
    buffer.bezier(startp[0], startp[1], 
                   centerx + relControlPoints[0][0], centery + relControlPoints[0][1],
                   centerx + relControlPoints[1][0], centery + relControlPoints[1][1],
                   endp[0], endp[1]);
}


float[][] getRelativeControlPoints(float angleStart, float angleEnd, float radius) {
    // factor is the commonly reffered parameter K in the articles about arc to cubic bezier approximation 
    float factor = findK(angleStart, angleEnd);

    // Distance from [0, 0] to each of the control points. Basically this is the hypotenuse of the triangle [0,0], a control point and the projection of the point on Ox
    float distToCtrPoint = sqrt(radius * radius * (1 + factor * factor));
    // Angle between the hypotenuse and Ox for control point 1.
    float angle1 = angleStart + atan(factor);
    // Angle between the hypotenuse and Ox for control point 2.
    float angle2 = angleEnd - atan(factor);
    float[][] ret = new float[2][2];
    ret[0][0] = cos(angle1) * distToCtrPoint;
    ret[0][1] = sin(angle1) * distToCtrPoint;
    ret[1][0] = cos(angle2) * distToCtrPoint;
    ret[1][1] = sin(angle2) * distToCtrPoint;
    return ret;
}


int[] getPointAtAngle(float angle, int centerx, int centery, float radius) {
  int[] ret = new int[2];
  ret[0] = floor(centerx + radius * cos(angle));
  ret[1] = floor(centery + radius * sin(angle));
  return ret;
}

float findK(float angleStart, float angleEnd) {
   float arc = angleEnd - angleStart;

    // Always choose the smaller arc
    if (abs(arc) > PI) {
        arc -= PI * 2;
        arc %= PI * 2;
    }
    return (4 / 3) * tan(arc / 4);
}

//=========================== INTERACTION HANDLING ==================================
//===================================================
void mouseReleased() {
  println("mouse clicked============+");
  // Create a new current mark
  var coords = findNearest(mouseX, mouseY);
  var mark = marks.get(coords[0], coords[1], coords[2]);

  if (mark == null) {
      print(coords[2]);
      mark = new SingleCurve(coords[0], coords[1], coords[2]);
      println("create" + mark);
      marks.put(mark);
  } else if (MODE == "PLACING") {
    println("rotate\n" + marks);
    if (mark.orientation == 3) marks.delete(mark.x, mark.y, mark.quadrant);
    mark.orientation = (mark.orientation+1)%4;
    println(marks);
  } else if (MODE ==  "CURVELESS") {
    println("reducing curve") ;
    mark.curvature -= 0.1;
    if (mark.curvature < 0) mark.curvature = 1;
  } else if (MODE == "CURVEMORE") {
    println("increasing curve");
    mark.curvature += 0.1;
    if (mark.curvature > 1) mark.curvature = 0;
  }
}


//===================================================
void keyPressed() {
  println("======= Key Pressed " + key);
  switch (key) {
    case ' ':
    marks.clear();
    onscreenBuffer = createGraphics(width, height);
    onscreenBuffer.beginDraw();
    onscreenBuffer.stroke(127,0,0);
    onscreenBuffer.strokeWeight(3);
    marks.addBuffer(onscreenBuffer);
    break;
  case 's':
  case 'S': // S to save
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
    break;
  case 't':
  case 'T':
    marks.tile(1, 1, 1, 1, true, true);
    break;
  case 'c': 
    if (MODE == "CURVELESS") MODE = "PLACING";
    else MODE = "CURVELESS";
    break;
  case 'C':
    if (MODE == "CURVEMORE") MODE = "PLACING";
    else MODE = "CURVEMORE";
    break;
  }

}

class SingleCurve {
  public float curvature;
  int radius, x, y;
  public int orientation;
  public int quadrant;
  
  // quadrant 0 from 0 t PI/2. 1 is the next quarter, 
  // 2 is the next, and 3 is the final quarter of a circle
  SingleCurve(int x, int y) {
    this(x, y, 0, 0, RADIUS);
  }
  
  SingleCurve(int x, int y, int quadrant) {
    this(x, y, quadrant, 0, RADIUS, 1);
  }
  
  SingleCurve(int x, int y, int quadrant, int orientation) {
    this(x, y, quadrant, orientation, RADIUS, 1);
  }
  SingleCurve(int x, int y, int quadrant, int orientation, int radius) {
    this(x, y, quadrant, orientation, radius, 1);
  }
  SingleCurve(int x, int y, int quadrant, int orientation, int radius, float curvature) {
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
    var adjust = adjustXY(orientation, quadrant);
    var localx = this.x*RADIUS + adjust[0];
    var localy = this.y*RADIUS + adjust[1];
    
    switch (orientation) {
      case 0: bezierArc(buffer, localx, localy, radius, radians(0), radians(90), curvature); break;
      case 1: bezierArc(buffer, localx, localy, radius, radians(90), radians(180), curvature); break;
      case 2: bezierArc(buffer, localx, localy, radius, radians(180), radians(270), curvature); break;
      case 3: bezierArc(buffer, localx, localy, radius,  radians(-90), radians(0), curvature);
    }
  }
  
  void update(PEmbroiderGraphics ebuffer) {
    //println("drawing pgraphic for: " + this);
    //rect(x, y, radius, radius);
    var adjust = adjustXY(orientation, quadrant);
    var localx = this.x*RADIUS + adjust[0];
    var localy = this.y*RADIUS + adjust[1];
    
    //println("quadrant: "+ quadrant + ", orientation: " + orientation);
    switch (orientation) {
      case 0: bezierArc(ebuffer, localx, localy, radius, radians(0), radians(90), curvature); break;
      case 1: bezierArc(ebuffer, localx, localy, radius, radians(90), radians(180), curvature); break;
      case 2: bezierArc(ebuffer, localx, localy, radius,radians(180), radians(270), curvature); break;
      case 3: bezierArc(ebuffer, localx, localy, radius,  radians(-90), radians(0), curvature);
    }
  }
  
  SingleCurve copy() {
    return new SingleCurve(this.x, this.y, this.quadrant, this.orientation, this.radius, this.curvature);
  }
  
  String toString() {
    return "Curve at " + x + "," + y + ":q" + quadrant + ":o"+orientation;
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
  
  
  void tile(int startx, int starty, int tilewidth, int tileheight, boolean x, boolean y) {
    println("tile " + startx + "," + starty + "," + tilewidth + "," + tileheight +"," + x + "," + y);
    println("[" + table.length +"][" + table[0].length +"]");
    // startx/starty is the grid coordinates of the top left of the tile
    // width is the width of the tile
    // height is the height of the tile
    // x is whether to tile in x direction
    // y is whether to tile in y direction
    SingleCurve tile;
    
    println(this);
    
    // Loop through the grid by tile size in x and y
    for (int q = 0; q<4;  q++) {
      for (int i = startx;  i+tilewidth < gridrows; i+=tilewidth) {
        for (int j = starty;  j+tileheight < gridcols; j+=tileheight) {
          println("q, i, j" + q + ","+ i + "," + j);
          for (int s = 0;  s<=tilewidth; s++) {
            for (int t = 0; t<=tileheight; t++ ) {
              tile = table[q][s+startx][t+starty];
              //println(tile);
              if (tile != null) {
                 tile = tile.copy();
                 tile.x = t+j;
                 tile.y = i+s;
                 //println("q, s, t" + q + "," + s + "," + t + " to: " + (i+s) + "," + (j+t) + tile);
                 table[q][i+s][j+t] = tile;
              }
            }
          }
        }
      }
    }
  }
  
  ////// ////// ////// //////  HELPERS ////// ////// ////// ////// ////// 
  
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
