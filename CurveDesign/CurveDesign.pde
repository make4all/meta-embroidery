import processing.embroider.*;
import processing.svg.PGraphicsSVG;
import controlP5.*;
import processing.core.PApplet;


// the embroidery buffer
PEmbroiderGraphics E;
// the buffer that is used for saving to svg
PGraphics offscreenBuffer;
// the non-embroidery onscreen buffer
PGraphics onscreenBuffer;
// The user interface
Interface interfaceBuffer;
// for naming each file differently during a session
int fileNumber = 1;
// the table with all the lines (or lines) that are shown on screen
LineTable marks;

// the interface is 200 pixels wide
int interfaceWidth = 200;


////////////////////////////
// HELPER VARIABLES
////////////////////////////
  
float SQRT3 = sqrt(3);
int WHITE = 255;
int BLACK = 0;
int BLUE = #0000FF;
String out = "Controls:\n" +
  "s: Save embroidery file\n" +
  "i: Insert line mode\n" +
  "t: Tile across plane\n" +
  "c: Line less mode\n" +
  "C: Line more mode\n" +
  "[space]: Clear grid";

//===================================================
// Processing runs this first. We are just setting things up here
void setup() {
  size(600, 800);
  smooth();

  int cols = round((width-interfaceWidth)/60)+1;
  int rows = round(height/60)+1;
  marks =  new LineTable(rows+1, cols+1);

  E = new PEmbroiderGraphics(this, width, height);
  E.translate(interfaceWidth, 0);
  basicEmbroiderySettings(E);

  // comment to hide embroidered paths
  // uncomment to show embroidering path  
  // marks.addBuffer(E); 

  onscreenBuffer = createGraphics(width, height);
  interfaceBuffer = new Interface(this, interfaceWidth, height);

  marks.addBuffer(onscreenBuffer);

  println(out);
}

//===================================================
void draw() {
  // color the background
  background(250);
  // draw the grid to help the user click in the right places 
  drawGrid(interfaceWidth, 0);

  pushStyle();
  // draw all the lines
  drawLines();
  popStyle();
}

void drawLines() {
  
  E.beginDraw();
  E.clear();
  
  // I'm not sure why but we have to recreate the offscreen buffer each
  // draw cycle or we get duplicate lines
  marks.removeBuffer(offscreenBuffer);
  String svgFilePath = sketchPath("lineDemo" + fileNumber + ".svg");
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
   
  image(onscreenBuffer, interfaceWidth, 0);

  E.visualize(true, true, true);
}

void basicDrawingSettings(PGraphics buffer) {
  buffer.stroke(127, 0, 0);
  buffer.strokeWeight(1);
  buffer.noFill();
}

void basicEmbroiderySettings(PEmbroiderGraphics E) {
  E.stroke(BLACK);  //
  E.strokeWeight(6);  //
  //E.fill(BLACK);
  E.fill(0, 0, 255);
  E.strokeSpacing(2.0);
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
  //E.HATCH_SPACING = 10;
  E.satinMode(PEmbroiderGraphics.ZIGZAG);
  E.setStitch(10, 15, 0);  //
  //E.RESAMPLE_MAXTURN = 0.8f; //
  randomSeed(5);
}

// converts a row and column to coordinates
// that you can draw at 
float[] toCoords(int row, int col) {
  float[] ret = new float[2];

  // the conversion depends on how many quadrants there are
  // right now only 4 and 8 quadrants is debugged
  switch(marks.quadrants) {
  case 4:
  case 8: // for 4/8 marks, just multiple times radius
    ret[0] = col*marks.RADIUS;
    ret[1] = row*marks.RADIUS;
    break;
  case 3:
  case 6: // here we need to adjust for which row we are in and 
    ret[0] = marks.RADIUS + col*marks.RADIUS*3/2;
    ret[1] = marks.RADIUS + row*SQRT3*marks.RADIUS - marks.RADIUS*SQRT3/(1+col%2);
  }
  return ret;
}

// converts an x and y coordinate
// to grid coordinates (rows and columns) plus quadrant.
int[] toGrid(int x, int y) {
  // translate to account for interface
  x = x - interfaceWidth;
  int[] ret = new int[3];
  //println("x, y" + x + "," + y);

  // the conversion depends on how many quadrants there are
  // right now only 4 and 8 quadrants is debugged
  switch(marks.quadrants) {
  case 4:
  case 8:
    // if there are 4 or 8 quadrants we're dealing with squares. 
    ret[1] = floor((x + marks.RADIUS/2)/ marks.RADIUS); // column
    ret[0] = floor((y + marks.RADIUS/2)/ marks.RADIUS); // row
    break;
  case 3:
  case 6:
    ret[0] = (x+marks.RADIUS/2)%(marks.RADIUS*3/2);
    ret[1] = floor(y%(marks.RADIUS*SQRT3));
    //ret[0] = x - ret[0]+marks.RADIUS/2;
    //ret[1] = floor(y - ret[1]+marks.RADIUS*SQRT3/2);
    if (ret[0]%marks.RADIUS==0) ret[1] = floor(ret[1] - marks.RADIUS*SQRT3/2);
    break;
  }

  // We assume the user didn't press right on a grid point
  // and we want to translate that "error" into which quadrant to
  // add a line in.

  // first, calculate where on the unit circle around the grid point they clicked
  // get the coords for this specific row and column
  float[] translate = toCoords(ret[0], ret[1]);
  // then move them to the equivalent coords for a gridpoint at (0,0)
  int xDiff = (int) (x - translate[0]);
  int yDiff = (int) (y - translate[1]);
  // then calculate the angle they clicked at
  float angle = atan2(xDiff, yDiff);
  // adjust to the correct part of the circle
  if (angle < 0) angle = 2*PI + angle;
  // calculat the degrees in each pie piece of the circle divided by the number of quadrants
  float arc = (2*PI)/marks.quadrants;
  // convert the angle they clicked at to a quadrant
  int quadrant = 0;
  switch(marks.quadrants) {
  case 4:
    quadrant = round( angle/arc)%marks.quadrants; break;
  case 8: 
    quadrant = round( arc*.5 + angle/arc)%marks.quadrants; break;
  }

  println("deg " + atan2(x, y)*180/PI  + "," + angle*180/PI + " arc " + arc*180/PI + " quadrant " + quadrant);

  // return the coordinates of the grid point nearest the click and the quadrant
  ret[2] = quadrant;
  println(ret);
  return ret;
}


// draw the grid of grid points so the user can see where to click
void drawGrid(int xOffset, int yOffset) {
  stroke(50);

  pushMatrix();
  translate(xOffset, yOffset);

  // if were are in tile region mode draw a square around the region to be tiled
  if (interfaceBuffer.mode() == interfaceBuffer.TILE_REGION) {
    // Top left corner is different color to indicate where to draw
    fill(245);
    stroke(BLACK);
    float[] starts = toCoords(interfaceBuffer.colStart, interfaceBuffer.rowStart);
    float[] ends = new float[2];
    if (marks.quadrants == 4 || marks.quadrants == 8) {
      ends[0] = (interfaceBuffer.colEnd-interfaceBuffer.colStart + 1)*marks.RADIUS;
      ends[1] = (interfaceBuffer.rowEnd-interfaceBuffer.rowStart + 1)*marks.RADIUS;
      rect(starts[0]-marks.RADIUS/2, starts[1]-marks.RADIUS/2, ends[0], ends[1], 28);
    } else {
      ends[0] = (interfaceBuffer.colEnd-interfaceBuffer.colStart + 1)*marks.RADIUS*3/2+marks.RADIUS/2;
      ends[1] = (interfaceBuffer.rowEnd-interfaceBuffer.rowStart + 1)*marks.RADIUS*SQRT3;
      rect(starts[0]-marks.RADIUS, starts[1]-marks.RADIUS*SQRT3/2, ends[0], ends[1], 28);
    }
    
    noFill();
  }

  // Grid lines
  for (int row = 0; row <= marks.rows; row++) {
    for (int col = 0; col <= marks.cols; col++) {
      float[] coords = toCoords(row, col);
      switch (marks.quadrants) {
      case 4:
      case 8:
        stroke(BLACK);
        line(coords[0]+marks.RADIUS/2, 0, coords[0]+marks.RADIUS/2, height);
        line(0, coords[1]+marks.RADIUS/2, width, coords[1]+marks.RADIUS/2);
        stroke(127, 0, 0);
        circle(coords[0], coords[1], 2);
        break;
      case 3:
      case 6:
        beginShape();
        for (float theta = 0; theta < TWO_PI; theta += TWO_PI/6) {
          vertex(coords[0]+(marks.RADIUS)*cos(theta), coords[1]+(marks.RADIUS)*sin(theta));
        }
        endShape();
        stroke(127, 0, 0);
        circle(coords[0], coords[1], 2);
      }
    }
  }
  popMatrix();
}


//===============================    HELPERS ===============================
public SingleLine lineFromJSON(JSONObject json) {
  if (json == null) return null;
  return new SingleLine(json.getInt("row"), json.getInt("col"), json.getInt("quadrant"), json.getInt("orientation"), json.getFloat("curvature"));
}
//=========================== INTERACTION HANDLING ==================================
//===================================================

void mouseReleased() {
  println("mouse clicked============+");

  // Create a new current mark
  int[] coords = toGrid(mouseX, mouseY);
  int row = coords[0];
  int col = coords[1];
  int quad = coords[2];

  if (row < 0 || col < 0) return;
  if ((interfaceBuffer.mode() == interfaceBuffer.TILE_REGION) &&
    !interfaceBuffer.insideTiling(row, col)) return;

  println("row " + row + ", col" + col + "quard: " + quad);
  SingleLine mark = marks.get(row, col, quad);

  if (mark == null) {
    mark = new SingleLine(coords[0], coords[1], coords[2]);
    marks.put(mark);
  } else {
    String current = interfaceBuffer.click();
    if (current == interfaceBuffer.ROTATE) {
      println(mark);
      if (mark.orientation() == 1) marks.delete(mark.row(), mark.col(), mark.quadrant());
      mark.orientation(mark.orientation+1);
    } else if (current == interfaceBuffer.JOINT_CIRCLE || current == interfaceBuffer.JOINT_SQUARE) {
      marks.flipJoint(row, col);
      marks.jointType(current);
    } else if (current == interfaceBuffer.CURVEIN) {
      mark.curvature(mark.curvature() - 0.1);
      if (mark.curvature() < -2) mark.curvature(2);
    } else {
      mark.curvature(mark.curvature() + 0.1);
      if (mark.curvature() > 2) mark.curvature(-2);
    }
  }
  if (interfaceBuffer.mode() == interfaceBuffer.TILE_REGION) marks.tile(interfaceBuffer.rowStart, interfaceBuffer.rowDist, interfaceBuffer.colStart, interfaceBuffer.colDist, true, true);
}

// event handling is done by the interface buffer
void controlEvent(ControlEvent theEvent) {
  if (interfaceBuffer != null)  interfaceBuffer.controlEvent(theEvent);
}


//===================================================
void keyPressed() {
  println("======= Key Pressed " + key);
  switch (key) {
  case ' ':
    marks.clear();
    onscreenBuffer = createGraphics(width, height);
    onscreenBuffer.beginDraw();
    onscreenBuffer.stroke(127, 0, 0);
    onscreenBuffer.strokeWeight(3);
    marks.addBuffer(onscreenBuffer);
    break;
  case 's':
  case 'S': // S to save
    interfaceBuffer.save();
    break;
  }
}

///////////////////// HELPER CLASSES /////////////////////

// This class holds a single line and knows how to draw it 
class SingleLine {
  // should the line be curved? by how much?
  // (getters and setters)
  private float curvature;
  public float curvature() {
    return curvature;
  }
  public void curvature(float curvature) {
    this.curvature = curvature;
    updateCoords();
  }

  // what grid location is the line in?
  // (getters and setters)
  private int row, col;
  public int row() {
    return row;
  }
  public void row(int row) {
    this.row = row;
    updateCoords();
  }
  public int col() {
    return col;
  }
  public void col(int col) {
    this.col = col;
    updateCoords();
  }

  // should the line be rotated? (currently only used for
  // angled lines in 8 quadrant mode)
  // (getters and setters)
  private int orientation;
  public int orientation() {
    return orientation;
  }
  public void orientation(int orientation) {
    this.orientation = (orientation == 2) ? 0 : orientation;
    updateCoords();
  }

  // what quadrant is the line in?
  // (getters and setters)
  private int quadrant;
  public int quadrant() {
    return quadrant;
  }
  public void quadrant(int quadrant) {
    this.quadrant = quadrant;
    updateCoords();
  }

  // What are the coordinates of the line in x/y (instead of grid) coords?
  int[] localCoords = new int[4];

  ////////// CONSTRUCTORS /////////////
  SingleLine(int row, int col) {
    this(row, col, 0, 0);
  }

  SingleLine(int row, int col, int quadrant) {
    this(row, col, quadrant, 0, 0);
  }

  SingleLine(int row, int col, int quadrant, int orientation) {
    this(row, col, quadrant, orientation, 0);
  }

  SingleLine(int row, int col, int quadrant, int orientation, float curvature) {
    this.curvature = curvature;
    this.orientation = orientation;
    this.quadrant = quadrant;
    this.row = row;
    this.col = col;
    updateCoords();
  }

  // update the local coordinates for the start and end of this line
  // assumes that the start is always the x/y coordinates of the grid point this line is
  // associated with. endXY calculates the end relative to that.
  void updateCoords() {
    int[] endAdjust = endXY(orientation, quadrant);
    if (orientation == 1) {
      this.localCoords[0] = this.col*marks.RADIUS;
      this.localCoords[1] = this.row*marks.RADIUS;
      this.localCoords[2] = this.col*marks.RADIUS + endAdjust[0];
      this.localCoords[3] = this.row*marks.RADIUS + endAdjust[1];
    } else {
      this.localCoords[0] = this.col*marks.RADIUS;
      this.localCoords[1] = this.row*marks.RADIUS + endAdjust[1];
      this.localCoords[2] = this.col*marks.RADIUS + endAdjust[0];
      this.localCoords[3] = this.row*marks.RADIUS;
    }
  }

  // return the local coordinates
  int[] localCoords() {
    return localCoords;
  }


  // udpate how this line is drawn on the screen
  void update(PGraphics buffer) {
    // get x/y instead of grid coordinates
    int[] coords = localCoords();

    // draw the line as a line if there is no curvature
    if (this.curvature == 0) {
      buffer.line(coords[0], coords[1], coords[2], coords[3]); return;
    }

    // draw the line as a bezier curve if there is curvature
    // first calculate the start and end angle of the line if there were a circle
    // centered at the line's center, with line being drawn from the grid coordinate location outward.
    float startAngle = 0, endAngle = PI;
    switch(quadrant) {
      case 0: 
         startAngle = 0; endAngle = radians(90);
         break;
      case 1: 
         startAngle = radians(90); endAngle = radians(180);
         break;
      case 2:
         startAngle = radians(180); endAngle = radians(270);
         break;
      case 3: 
         startAngle = radians(-90); endAngle = radians(0);
         break;
    }

    // next create a bezier arc for the line
    bezierArc(buffer, coords[0], coords[1], coords[2], coords[3], marks.RADIUS, startAngle, endAngle, curvature);
  }

  // TODO: this needs to be updated to do the same thing as the regular buffer update function
  // if we use pembroider
  void update(PEmbroiderGraphics ebuffer) {
    int[] coords = localCoords();
    if (this.curvature == 0) ebuffer.line(coords[0], coords[1], coords[2], coords[3]);
    //else bezierArc(ebuffer, coords[0], coords[1], coords[2], coords[3], marks.RADIUS, 0, PI, curvature);
  }

  // copy this line
  SingleLine copy() {
    return new SingleLine(this.row, this.col, this.quadrant, this.orientation, this.curvature);
  }


  // Calculate the x and y offset in x/y (not grid) coords of the end of this line
  // relative to its start, based on which quadrent it is in and its orientation.
  // this calls different functions depnding on the number of quadrants
  int[] endXY(int orientation, int quadrant) {
    switch (marks.quadrants) {
    case 4:
      return endXY4(orientation, quadrant);
    case 8:
      return endXY8(orientation, quadrant);
    case 3:
      return endXY3(orientation, quadrant);
    default:
      return endXY6(orientation, quadrant);
    }
  }

  // may not be fulling working
  int[] endXY3(int orientation, int quadrant) {
    int [] ret = {0, 0};

    float arc = (2*PI)/marks.quadrants;
    arc = arc*quadrant;

    float len = sqrt((marks.RADIUS/2*marks.RADIUS/2)*2);
    ret[0] = int(len*sin(arc));
    ret[1] = int(len*cos(arc));
    return ret;
  }

  // may not be fully working
  int[] endXY6(int orientation, int quadrant) {
    int [] ret = {0, 0};

    float arc = (2*PI)/marks.quadrants;
    arc = arc*quadrant;

    float len = sqrt((marks.RADIUS/2*marks.RADIUS/2)*2);
    ret[0] = int(len*sin(arc));
    ret[1] = int(len*cos(arc));
    return ret;
  }

  // Eigh quadrant case
  int[] endXY8(int orientation, int quadrant) {
    int [] ret = {0, 0};

    // firts figure out the angle for this line
    float arc = (2*PI)/marks.quadrants;
    arc = arc*quadrant;

    // then calculate its length. This will differ if we are drawing a line to the
    // side (just use RADIUS/2) versus the corner (need to use pythagorean theorem) of the grid square
    float len = (float) marks.RADIUS/2; // even quadrants
    if (quadrant % 2 == 1) len = sqrt((marks.RADIUS/2*marks.RADIUS/2)*2); // odd quadrants

    // in most cases we just return the length time the angle
    int x = ret[0] = int(len*sin(arc));
    int y = ret[1] = int(len*cos(arc));

    // however if we are in an odd quadrant (pointed at a corner)
    // the line can rotate. We need to adjust for this
    if ((orientation == 1) && (quadrant % 2 == 1)) {
      if (((quadrant == 3) || (quadrant == 7)) && (orientation == 1)) {
        ret[0] = -y;
        ret[1] = -x;
      } else {
        ret[0] = y;
        ret[1] = x;
      }
    }
    return ret;
  }

  // For the 4 quadrant case, lines always go out to the side 
  int[] endXY4(int orientation, int quadrant) {
    int [] ret = {0, 0};

    float arc = (2*PI)/marks.quadrants;
    arc = arc*quadrant;

    // then calculate its length
    float len = (float) marks.RADIUS/2; // even quadrants
    // times the angle
    int x = ret[0] = int(len*sin(arc));
    int y = ret[1] = int(len*cos(arc));
    return ret;
  }

  void bezierArc(PGraphics buffer, int startx, int starty, int endx, int endy, int radius, float angleStart, float angleEnd, float curvature) {
    // assuming angleStart and angleEnd are in raians

    float centerx = (endx-startx)/2+startx;
    float centery = (endy-starty)/2+starty;
    println("finding control points for: " + centerx + "," + centery);
    // Finding the coordinates of the control points in a simplified case where the center of the circle is at [0,0]
    
    float[][] relControlPoints = getRelativeControlPoints(angleStart, angleEnd, radius/4*curvature);
    
    int[] startp = {startx, starty};
    buffer.bezier(startp[0], startp[1],
      centerx + relControlPoints[0][0], centery + relControlPoints[0][1],
      centerx + relControlPoints[1][0], centery + relControlPoints[1][1],
      endx, endy);
    buffer.circle(centerx + relControlPoints[1][0], centery + relControlPoints[1][1], 3);
    buffer.circle(centerx + relControlPoints[0][0], centery + relControlPoints[0][1], 3);
  }

  void bezierArc(PEmbroiderGraphics buffer, int centerx, int centery, int radius, float angleStart, float angleEnd, float curvature) {
    // assuming angleStart and angleEnd are in raians

    // Finding the coordinates of the control points in a simplified case where the center of the circle is at [0,0]
    float[][] relControlPoints = getRelativeControlPoints(angleStart, angleEnd, radius/2*curvature);
    int[] startp = getPointAtAngle(angleStart, centerx, centery, radius/2);
    int[] endp = getPointAtAngle(angleEnd, centerx, centery, radius/2);
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
    if (radius < 0) distToCtrPoint = distToCtrPoint * -1;
    ret[0][0] = cos(angle1) * distToCtrPoint;
    ret[0][1] = sin(angle1) * distToCtrPoint;
    ret[1][0] = cos(angle2) * distToCtrPoint;
    ret[1][1] = sin(angle2) * distToCtrPoint;
    
    return ret;
  }

  // Find the coordinates of the point at a certain angle on a circle of radius radius
  int[] getPointAtAngle(float angle, int centerx, int centery, float radius) {
    int[] ret = new int[2];
    ret[0] = floor(centerx + radius * cos(angle));
    ret[1] = floor(centery + radius * sin(angle));
    return ret;
  }

  // an estimate of K, needed for bezier curves
  float findK(float angleStart, float angleEnd) {
    float arc = angleEnd - angleStart;

    // Always choose the smaller arc
    if (abs(arc) > PI) {
      arc -= PI * 2;
      arc %= PI * 2;
    }
    return (4 / 3) * tan(arc / 4);
  }

  // save this line as a JSON object
  public JSONObject toJSON() {
    JSONObject line = new JSONObject();
    line.setInt("row", row);
    line.setInt("col", col);
    line.setInt("quadrant", quadrant);
    line.setInt("orientation", orientation);
    line.setFloat("curvature", curvature);
    return line;
  }

  // for debugging
  String toString() {
    return "Line at " + row + "," + col + ":q" + quadrant + ":o"+orientation;
  }
}


//// Class for storing all the lines
class LineTable {
  // the array of lines
  SingleLine[][][] table;
  // grid points with a line on them
  boolean [][] joints;
  // the number of rows
  int rows;
  // the number of columns
  int cols;
  // the number of quadrants
  int quadrants = 4;

  // the buffers to draw on (can have more than one)
  ArrayList<PGraphics> buffers;
  // the embroidery buffers to draw on
  ArrayList<PEmbroiderGraphics> ebuffers;

  // this is a convenience data structure, it is a flat version of table
  ArrayList<SingleLine> lines;

  // the radius used for the grid
  int RADIUS = 60;

  // the radius for drawing joints at (only used for pembroider buffers)
  int JOINT_RADIUS = 36;
  // the type of joint (square or round), again only used for pembroider buffers if we decide to go that route
  String jointType;

  ////////////////////////// constructors //////////////////////////
  LineTable(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;
    this.table = new SingleLine[rows][cols][quadrants];
    this.joints = new boolean[rows][cols];

    this.buffers = new ArrayList<PGraphics>();
    this.ebuffers = new ArrayList<PEmbroiderGraphics>();
    this.lines = new ArrayList<SingleLine>();
  }

  // if row = 0, items at col 0->cols-1;
  // if row = 0 items at cols cols->2*cols-1, etc
  SingleLine get(int row, int col, int quadrant) {
    SingleLine[][][] table = this.table;
    if (table == null) {
      println("why is table null?");
      this.table = new SingleLine[this.rows][this.cols][this.quadrants];
      return null;
    }
    SingleLine[][] cols = table[row];
    SingleLine[] quadrants = cols[col];
    SingleLine line = quadrants[quadrant];
    return line;
  }

  // this does the tiling to copy the tiled region throughout the rest of the grid
  void tile(int startRow, int rowDist, int startCol, int colDist, boolean x, boolean y) {
    println("tile " + startRow + "," + startCol + "," + rowDist + "," + colDist +"," + x + "," + y);
    println(this);
    // startx/starty is the grid coordinates of the top left of the tile
    // width is the width of the tile
    // height is the height of the tile
    // x is whether to tile in x direction
    // y is whether to tile in y direction
    SingleLine tile;

    // Loop through the tile region in each quadrant
    boolean joint;
    for (int s=startRow; s<=startRow+rowDist-1; s++) {
      for (int t=startCol; t<=startCol+colDist-1; t++) {
        joint = joints[s][t];
        for (int q = 0; q<marks.quadrants; q++) {
          tile = table[s][t][q]; // the tile to be copied is at gridpoint s, t in quadrant q
          if (tile != null) {
            // loop through the table, starting at a copy of the tile located at (0,0) and moving by tile size
            for (int gridrow=1+s-startRow; gridrow+rowDist <= marks.rows; gridrow+=rowDist) {
              for (int gridcol=1+t-startCol; gridcol+colDist <= marks.cols; gridcol+=colDist) {
                if (tile != null && !interfaceBuffer.insideTiling(gridrow, gridcol)) {
                  SingleLine newtile = tile.copy();
                  newtile.col(gridcol);
                  newtile.row(gridrow);
                  println("copying " + tile+ " to " + newtile);
                  delete(gridrow, gridcol, q);
                  put(newtile);
                  joints[gridrow][gridcol] = joint;
                } else if (!interfaceBuffer.insideTiling(gridrow, gridcol)) {
                  delete(gridrow, gridcol, q); // TODO: not working for some reason
                }
              }
            }
          }
        }
      }
    }
    println(this);
    updateAll();
  }

  ////// ////// ////// //////  HELPERS ////// ////// ////// ////// //////
  void jointType(String type) {
    this.jointType = type;
  }
  
  void flipJoint(int row, int col) {
    this.joints[row][col] = !this.joints[row][col];
  }
  
  void put(SingleLine line) {
    this.table[line.row][line.col][line.quadrant] = line;
    this.lines.add(line);
  }

  void delete(int row, int col, int quadrant) {
    SingleLine line = this.table[row][col][quadrant];
    if (line == null) return;
    this.table[row][col][quadrant] = null;
    //println("lines: " + lines.size());
    lines.remove(line);
    joints[row][col] = false;
    //println("lines: " + lines.size());
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
    ebuffer.beginComposite();
    for (SingleLine line : lines) {
      line.update(ebuffer);
    }
    ebuffer.endComposite();


    // overlay the joint fixtures
    for (int row=0; row<this.rows; row++) {
      for (int col=0; col<this.cols; col++) {
        if (this.joints[row][col])  {
          float[] coords = toCoords(row, col);
          ebuffer.fill(BLUE);
          if (this.jointType.equals(interfaceBuffer.JOINT_CIRCLE)) {
            ebuffer.circle(coords[0], coords[1], JOINT_RADIUS);
          } else {
            ebuffer.rect(coords[0]-JOINT_RADIUS/2, coords[1]-JOINT_RADIUS/2,
                           JOINT_RADIUS, JOINT_RADIUS);
          }
        }
      }
    }
  }

  void updateAll(PGraphics buffer) {

    // draw the lines
    buffer.beginShape();
    for (SingleLine line : lines) line.update(buffer);
    buffer.endShape();
    
    // overlay the joint fixtures
    for (int row=0; row<this.rows; row++) {
      for (int col=0; col<this.cols; col++) {
        if (this.joints[row][col])  {
          float[] coords = toCoords(row, col);
          buffer.stroke(BLUE);
          if (this.jointType.equals(interfaceBuffer.JOINT_CIRCLE)) {
            buffer.circle(coords[0], coords[1], JOINT_RADIUS);
          } else  {
            buffer.rect(coords[0]-JOINT_RADIUS/2, coords[1]-JOINT_RADIUS/2,
                       JOINT_RADIUS, JOINT_RADIUS);
          }
        }
      }
    }
    }

  void clear() {
    //println("clearing table");
    String symmetry = interfaceBuffer.symmetry();
    if (symmetry == interfaceBuffer.THREE_WAY) quadrants = 3;
    if (symmetry == interfaceBuffer.FOUR_WAY) quadrants = 4;
    if (symmetry == interfaceBuffer.SIX_WAY) quadrants = 6;
    if (symmetry == interfaceBuffer.EIGHT_WAY) quadrants = 8;
    if (quadrants == 4 || quadrants == 8) RADIUS = 60;
    else RADIUS = 30;
    cols = round((width-interfaceWidth)/RADIUS)+1;
    rows = round(height/RADIUS)+1;

    this.table = new SingleLine[rows][cols][quadrants];
    this.joints = new boolean[rows][cols];
    this.lines = new ArrayList<SingleLine>();
    //println("made table rows: " + rows + ", cols: " + cols + ", quadrants " + quadrants);
  }

  String toString() {
    String ret = "";
    int i = 0;
    for (SingleLine[][] cols : this.table) {
      ret += "q"+i + ":[";
      i += 1;
      for (SingleLine[] quadrants : cols) {
        ret += "[";
        for (SingleLine line : quadrants) {
          if (line != null) {
            //System.out.println("line at:" + line);
            ret += line + ":" + joints[line.row][line.col] + ",";
          } else ret += ",";
        }
        ret +="],";
      }
      ret +="]\n";
    }
    return ret;
  }

  public void saveTiling(int rowStart, int rowEnd, int colStart, int colEnd) {
    JSONObject json = new JSONObject();
    json.setInt("rowStart", rowStart);
    json.setInt("rowEnd", rowEnd);
    json.setInt("colStart", colStart);
    json.setInt("colEnd", colEnd);
    json.setString("symmetry", interfaceBuffer.symmetry());
    json.setString("mode", interfaceBuffer.mode());

    JSONArray cells = new JSONArray();
    int i = 0;
    for (int q = 0; q < quadrants; q++) {
      for (int row = rowStart; row <= rowEnd; row++) {
        for (int col = colStart; col <= colEnd; col++) {
          SingleLine cell = table[row][col][q];
          if (cell != null) {
            JSONObject cellJSON = cell.toJSON();
            cells.setJSONObject(i, cellJSON);
            i += 1;
          }
        }
      }
    }
    json.setJSONArray("cells", cells);
    saveJSONObject(json, "tile.JSON");
  }

  public void loadTiling() {
    JSONObject values = loadJSONObject("tile.JSON");
    JSONArray cells = values.getJSONArray("cells");
    int rowStart = values.getInt("rowStart");
    int rowEnd = values.getInt("rowEnd");
    int colStart = values.getInt("colStart");
    int colEnd = values.getInt("colEnd");
    interfaceBuffer.symmetry(values.getString("symmetry"));
    interfaceBuffer.mode(values.getString("mode"));
    tileFromJSON(cells, rowStart, rowEnd, colStart, colEnd);
  }

  public void tileFromJSON(JSONArray cells, int rowStart, int rowEnd, int colStart, int colEnd) {
    interfaceBuffer.setTiling(rowStart, rowEnd, colStart, colEnd);
    interfaceBuffer.mode(interfaceBuffer.TILE_REGION);
    for (int i = 0; i<cells.size(); i++) {
      SingleLine cell = lineFromJSON(cells.getJSONObject(i));
      if (interfaceBuffer.insideTiling(cell.row, cell.col)) {
        marks.put(cell);
      } else println ("ERROR JSON had items outside tiling region specified in JSON object");
    }
    
    marks.tile(interfaceBuffer.rowStart, interfaceBuffer.rowDist, interfaceBuffer.colStart, interfaceBuffer.colDist, true, true);    
  }
}

class Interface extends PGraphics {
  ControlP5 cp5;
  Group settings;

  RadioButton mode;

  RadioButton symmetry;
  final String THREE_WAY = "Three Way Symmetry";
  final String FOUR_WAY = "Four Way Symmetry";
  final String SIX_WAY = "Six Way Symmetry";
  final String EIGHT_WAY = "Eight Way Symmetry";

  RadioButton click;
  final String ROTATE = "Place and Rotate Lines";
  final String JOINT_CIRCLE = "Fix Joint (circle)";
  final String JOINT_SQUARE = "Fix Joint (square)";
  final String CURVEIN = "Curve Line Inward";
  final String CURVEOUT = "Curve Line Outward";

  Group tiling;
  MyRange col_range;
  public int colStart=1;
  public int colEnd=1;
  public int colDist = 1;
  MyRange row_range;
  public int rowStart=1;
  public int rowEnd=1;
  public int rowDist = 1;
  Button saveTiling;
  Button loadTiling;
  final String TILE_REGION = "Tile Region";
  final String FREE_ENTRY = "Free Entry";
  final String TILE_REGION_TO_REGION = "Tile Region to Region";

  public Button save;

  int INSET = 10;
  int ITEM_HEIGHT = 20;
  int SPACING = 5;

  PGraphics myGraphics;
  
  Interface(PApplet app, int width, int height) {
    super();

    this.myGraphics = app.getGraphics();
    
    this.setSize(width, height);
    cp5 = new ControlP5(app);
    cp5.isUpdate();
    textAlign(CENTER, CENTER);

    fill(255);
    stroke(0);
    fill(0);

    // STOPPED HERE. PROBLEM IS THAT RADIO BUTTONS ARE "connected" both in space and also only one can be selected
    // need to figure out how to do this right in cp5.

    settings = cp5.addGroup("MODE Settings", INSET, INSET*2);

    // set up the radio buttons for tiling mode
    mode = cp5.addRadioButton("TILING MODE");
    mode.setGroup(settings);
    mode.setItemHeight(ITEM_HEIGHT);
    mode.setPosition(0, SPACING);
    mode.addItem(FREE_ENTRY, 0);
    mode.addItem(TILE_REGION, 1);
    mode.getItem(TILE_REGION).setValue(true);
    mode.addItem(TILE_REGION_TO_REGION, 2);
    mode.setColorLabels(BLACK);
    for (Toggle item : mode.getItems()) {
      item.setBroadcast(true);
    }
    
    Textlabel label = cp5.addTextlabel(" ");
    label.setHeight(ITEM_HEIGHT);

    // set up the radio buttons for tiling mode
    symmetry = cp5.addRadioButton("Symmetry");
    symmetry.setGroup(settings);
    symmetry.setPosition(0, 80);
    symmetry.setItemHeight(ITEM_HEIGHT);
    symmetry.addItem(THREE_WAY, 0);
    symmetry.addItem(FOUR_WAY, 1);
    symmetry.getItem(FOUR_WAY).setValue(true);
    symmetry.addItem(SIX_WAY, 2);
    symmetry.addItem(EIGHT_WAY, 3);
    symmetry.setColorLabels(BLACK);
    for (Toggle item : symmetry.getItems()) {
      item.setBroadcast(true);
    }

    // set up click mode as rotation or curve modification
    // set up the radio buttons for tiling mode
    click = cp5.addRadioButton("ClickMode");
    click.setGroup(settings);
    click.setPosition(0, 180);
    click.setItemHeight(ITEM_HEIGHT);
    click.addItem(ROTATE, 0);
    click.getItem(ROTATE).setValue(true);
    click.addItem(JOINT_CIRCLE, 1);
    click.addItem(JOINT_SQUARE, 2);
    click.addItem(CURVEIN, 3);
    click.addItem(CURVEOUT, 4);
    click.setColorLabels(BLACK);

    tiling = cp5.addGroup("Tiling", INSET, 350);
    col_range = new MyRange(cp5, "Row Start and End ", true);
    col_range.setGroup(tiling);
    col_range.setSize(interfaceWidth-INSET*2, ITEM_HEIGHT);
    col_range.setRange(1, marks.cols);
    col_range.setRangeValues(1, 1);
    col_range.setNumberOfTickMarks(marks.cols);
    col_range.snapToTickMarks(true);
    col_range.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    col_range.setPosition(0, SPACING);
    col_range.setColorCaptionLabel(BLACK);

    row_range = new MyRange(cp5, "Column Start and End", true);
    row_range.setGroup(tiling);
    row_range.setSize(interfaceWidth-INSET*2, ITEM_HEIGHT);
    row_range.setPosition(0, ITEM_HEIGHT*2+SPACING*2);
    row_range.setRange(1, marks.rows);
    row_range.setRangeValues(1, 1);
    row_range.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    row_range.setColorCaptionLabel(BLACK);

    saveTiling = new Button(cp5, "Save Tiling Info");
    saveTiling.setGroup(tiling);
    saveTiling.setPosition(0, ITEM_HEIGHT*4+SPACING*4);
    saveTiling.setHeight(ITEM_HEIGHT);
    loadTiling = new Button(cp5, "Load Tiling Info");
    loadTiling.setGroup(tiling);
    loadTiling.setPosition(100, ITEM_HEIGHT*4+SPACING*4);
    loadTiling.setHeight(ITEM_HEIGHT);

    //for(Toggle t:mode.getItems()) {
    //   t.getCaptionLabel().setColorBackground(color(255,80));
    //   t.getCaptionLabel().getStyle().moveMargin(-7,0,0,-3);
    //   t.getCaptionLabel().getStyle().movePadding(7,0,0,3);
    //   t.getCaptionLabel().getStyle().backgroundWidth = 45;
    //   t.getCaptionLabel().getStyle().backgroundHeight = 13;
    //}



    save = cp5.addButton("Save");
    save.setPosition(INSET, height-ITEM_HEIGHT-INSET);
    save.setHeight(ITEM_HEIGHT);
    save.setValue(0);
    save.activateBy(ControlP5.RELEASE);
  }

  public String mode() {
    for (Toggle item : this.mode.getItems()) {
      if (item.getBooleanValue()) {
        return item.getName();
      }
    }
    return "";
  }


  public void mode(String val) {
    println("changing mode to " + val);
    for (Toggle item : this.mode.getItems()) {
      if (item.getName().equals(val)) item.setValue(true);
      else item.setValue(false);
    }
  }


  public String symmetry() {
    for (Toggle item : this.symmetry.getItems()) {
      if (item.getBooleanValue()) {
        return item.getName();
      }
    }
    return "";
  }


  public void symmetry(String val) {
    println("changing symmetry to " + val);
    Toggle selected;
    for (Toggle item : this.symmetry.getItems()) {
      if (item.getName().equals(val)) {
        println(item.getName() + " updating value");
        item.setUpdate(true);
        item.setValueSelf(1);
        //item.setMouseOver(true);
        //item.setMousePressed(true);
        //item.onPress();
        //item.broadcast();
        item.updateDisplayMode(Toggle.DEFAULT);
        item.draw(myGraphics);
        selected = item;
      } else item.setState(false);
    }
    controlEvent(new ControlEvent(this.symmetry));
    cp5.draw();
  }


  public String click() {
    for (Toggle item : this.click.getItems()) {
      if (item.getBooleanValue()) {
        return item.getName();
      }
    }
    return "";
  }


  public void click(String val) {
    println("changing click: " + val);
    for (Toggle item : this.click.getItems()) {
      println(item.getName() + item.getName().equals(val));
      println(item.getName() + item.getState());
      if (item.getName().equals(val))  item.setState(true);
      else item.setState(false);
      println(item.getName() + item.getState());
    }
    cp5.update();
  }



  public void save() {
    E.optimize(); // slow, but very good and important
    E.printStats();
    String outputFilePath = sketchPath("lineDemo" + fileNumber + ".dst");
    E.setPath(outputFilePath);
    save(outputFilePath);

    E.endDraw(); // write out the file
    fileNumber += 1;

    //println("offscreenBuffer" + offscreenBuffer);
    offscreenBuffer.dispose();
    offscreenBuffer.endDraw();
    fileNumber += 1;
    String svgFilePath = sketchPath("lineDemo" + fileNumber + ".svg");
    offscreenBuffer = createGraphics(width, height, SVG, svgFilePath);
    marks.addBuffer(offscreenBuffer);
    offscreenBuffer.beginDraw();
  }

  public void setTiling(int rowStart, int rowEnd, int colStart, int colEnd) {
    row_range.setRangeValues(rowStart, rowEnd);
    col_range.setRangeValues(colStart, colEnd);
  }

  // are x/y inside the tiling rect?
  public  boolean insideTiling(int row, int col) {
    //println("row, col" + row + "," + col);
    //println(this);
    return (row >= rowStart && row <= rowEnd && col >= colStart && col <= colEnd);
  }

  public void controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(this.mode)) {
      //setMode(mode.getItem(int(theEvent.getValue())).getName());
      println("\t "+theEvent.getValue());
    }

    if (theEvent.isFrom(this.save)) save();
    if (theEvent.isFrom(this.symmetry)) marks.clear();
    else if (theEvent.isFrom(this.col_range) ) {
      colStart = round(theEvent.getArrayValue(0));
      colEnd = round(theEvent.getArrayValue(1));
      colDist = colEnd-colStart+1;
    } else if (theEvent.isFrom(this.row_range)) {
      rowStart = round(theEvent.getArrayValue(0));
      rowEnd = round(theEvent.getArrayValue(1));
      rowDist = rowEnd-rowStart+1;
    } else if (theEvent.isFrom(this.saveTiling)) {
      marks.saveTiling(rowStart, rowEnd, colStart, colEnd);
    } else if (theEvent.isFrom(this.loadTiling)) {
      marks.loadTiling();
    }
  }

  public String toString() {
    String ret;
    ret = "interface state: Tiling: rowStart: " + rowStart + ", rowEnd: " + rowEnd + ", colStart: " + colStart + ", colEnd: " + colEnd;
    return ret;
  }
}

/// implementing our own range class to make sure we snap to whole numbers
public class MyRange extends Range {

  boolean snapToIntegers;

  public MyRange(ControlP5 cp5, String name, boolean snapToIntegers) {
    super(cp5, name);
    this.snapToIntegers = snapToIntegers;
  }

  // important to override these -- ideally only if snapping is on.
  public Range update() {
    if (!this.snapToIntegers) return super.update();
    //println("in update" + _myArrayValue[1]);
    _myArrayValue[ 0 ] = map( minHandle, handleSize, getWidth( ) - handleSize, _myMin, _myMax );
    _myArrayValue[ 1 ] = map( maxHandle, handleSize, getWidth( ) - handleSize, _myMin, _myMax );
    _myArrayValue[ 0 ] = round(_myArrayValue[0]);
    _myArrayValue[ 1 ] = round(_myArrayValue[1]);
    _myHighValueLabel.set( adjustValue( _myArrayValue[ 1 ] ) );
    _myValueLabel.set( adjustValue( _myArrayValue[ 0 ] ) );
    mr = maxHandle - minHandle;
    return setValue( _myValue );
  }

  public Range setValue(float theValue) {
    if (!this.snapToIntegers) return super.setValue(theValue);
    ///println("in setValue" + theValue);
    _myValue = round(theValue);
    broadcast(ARRAY);
    return this;
  }
}
