import processing.embroider.*;
import processing.svg.PGraphicsSVG;
import controlP5.*;
import processing.core.PApplet;


PEmbroiderGraphics E;
PGraphics offscreenBuffer;
PGraphics onscreenBuffer;
Interface interfaceBuffer;
int fileNumber = 1;
CurveTable marks;

int interfaceWidth = 200;
int RADIUS = 50;
float SQRT3 = sqrt(3);
int gridcols = 1;
int gridrows = 1;

int WHITE = 255;
int BLACK = 0;
String out = "Controls:\n" +
                "s: Save embroidery file\n" +
                "i: Insert curve mode\n" +
                "t: Tile across plane\n" + 
                "c: Curve less mode\n" +
                "C: Curve more mode\n" +
                "[space]: Clear grid";               
             
//===================================================
void setup() { 
  size(600,800);
  smooth();

  gridcols = round((width-interfaceWidth)/RADIUS)+1;
  gridrows = round(height/RADIUS)+1;
  println("rows"+gridrows+", cols"+gridcols);

  E = new PEmbroiderGraphics(this, width, height);
  basicEmbroiderySettings(E);
  
  marks =  new CurveTable(gridrows, gridcols);
  //marks.addBuffer(E); // uncomment to show embroidering path
  
  onscreenBuffer = createGraphics(width, height);
  interfaceBuffer = new Interface(this, interfaceWidth, height);
  
  marks.addBuffer(onscreenBuffer);

  //noLoop();
  
  println(out);
}

//===================================================
void draw() {
  background(250);
  drawGrid(interfaceWidth, 0);
  pushStyle();
  drawCurves();
  popStyle();
}

void drawCurves() {
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
  
  image(onscreenBuffer, interfaceWidth,0);
  
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

float[] toCoords(int row, int col) {
  float[] ret = new float[2];
  switch(marks.quadrants) {
    case 4:
    case 8:
      ret[0] = col*RADIUS;
      ret[1] = row*RADIUS;
      break;
    case 3:
    case 6:
      ret[0] = RADIUS/2 + col*(RADIUS/2)*3/2;
      ret[1] = RADIUS/2 + row*SQRT3*(RADIUS/2) - (RADIUS/2)*SQRT3/(1+col%2);
  }
  return ret;
}

int[] toGrid(int x, int y) {
  // translate
  x = x - interfaceWidth;
  int[] ret = new int[3];
  
  // won't need these once I fix the angle calculation
  int xfloor = floor(x/RADIUS);
  int yfloor = floor(y/RADIUS);ret[2] = 0; // quadrant
    
  switch(marks.quadrants) {
    case 4:
    case 8:
      x = x + RADIUS/2;
      y = y + RADIUS/2;
      ret[1] = floor(x / RADIUS); // column
      ret[0] = floor(y / RADIUS); // row
      break;
    case 3: 
    case 6:
      ret[0] = (x+RADIUS/2)%(RADIUS*3/2);
      ret[1] = floor(y%(RADIUS*SQRT3));
      ret[0] = x - ret[0]+RADIUS/2;
      ret[1] = floor(y - ret[1]+RADIUS*SQRT3/2);
      if (ret[0]%RADIUS==0) ret[1] = floor(ret[1] - RADIUS*SQRT3/2);
      break;
  }
  
    // now find the quadrant 
    // should do the following:
    // 1) draw a line through x, y from the center of the circle (tocoords(row, col))
    // 2) intersect that line with a circle of radius 1?
    // 3) calculate the angle of that line
    // 4) divide 360 by num quadrants and figure out which quadrant that line is in (I think)
    
    
    println("x/y"+x+","+y + ","+ret[0]+","+ret[1] + "floors: " + xfloor + "," + yfloor);
    if (yfloor == ret[0] && xfloor == ret[1]) ret[2] = 0;
    else if (yfloor < ret[0] && xfloor == ret[1]) ret[2] = 3;
    else if (yfloor == ret[0] && xfloor >= ret[1]) ret[2] = 2;
    else if (yfloor >= ret[0] && xfloor == ret[1]) ret[2] = 1;
    else if (yfloor < ret[0] && xfloor < ret[1]) ret[2] = 2;
    else if (yfloor == ret[0] && xfloor <= ret[1]) ret[2] = 1;
    else print("unknown config");
    return ret;
 }

void drawGrid(int xOffset, int yOffset) {
  stroke(50);

  pushMatrix();
  translate(xOffset, yOffset);
  
  if (interfaceBuffer.mode() == interfaceBuffer.TILE_REGION) {
    // Top left corner is different color to indicate where to draw
    fill(245);
    stroke(BLACK);
    var starts = toCoords(interfaceBuffer.rowStart, interfaceBuffer.colStart);
    rect(starts[0] - RADIUS/2 ,  starts[1] - RADIUS/2 , RADIUS*interfaceBuffer.colDist, RADIUS*interfaceBuffer.rowDist);
    noFill();
  }
  
  // Grid lines
  for(var row = 0; row <= gridrows; row++) {
    for(var col = 0; col <= gridcols; col++) {
      var coords = toCoords(row, col);
      switch (marks.quadrants) {
        case 4:
        case 8:
          stroke(BLACK);
          line(coords[0], 0, coords[0], height);
          line(0, coords[1], width, coords[1]);
          stroke(127,0,0);
          circle(coords[0], coords[1], 2);
          break;
        case 3:
        case 6:
          beginShape();
          for (float theta = 0; theta < TWO_PI; theta += TWO_PI/6) {
               vertex(coords[0]+(RADIUS/2)*cos(theta), coords[1]+(RADIUS/2)*sin(theta));
          }
          endShape();
          stroke(127,0,0);
          circle(coords[0], coords[1], 2);
      }
    }
  }
  popMatrix();
}
 
 
//===============================    HELPERS ===============================

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

public SingleCurve curveFromJSON(JSONObject json) {
    if (json == null) return null;
    return new SingleCurve(json.getInt("row"), json.getInt("col"), json.getInt("quadrant"), json.getInt("orientation"), json.getInt("radius"), json.getFloat("curvature"));
}
  
//=========================== INTERACTION HANDLING ==================================
//===================================================

void mouseReleased() {
  println("mouse clicked============+");

  // Create a new current mark
  var coords = toGrid(mouseX, mouseY);
  int row = coords[0];
  int col = coords[1];
  int quad = coords[2];
  
  if (row < 0 || col < 0) return;
  if ((interfaceBuffer.mode() == interfaceBuffer.TILE_REGION) && 
       !interfaceBuffer.insideTiling(row, col)) return;
  
  var mark = marks.get(row, col, quad);

  if (mark == null) {
      print(coords[2]);
      mark = new SingleCurve(coords[0], coords[1], coords[2]);
      println("create" + mark);
      marks.put(mark);
  } else {
    var current = interfaceBuffer.click();
    if (current == interfaceBuffer.ROTATE) {
      //println("rotate\n" + marks);
      if (mark.orientation == 3) marks.delete(mark.row, mark.col, mark.quadrant);
      mark.orientation = (mark.orientation+1)%4;
      //println(marks);
    } else if (current == interfaceBuffer.CURVEIN) {
      println("reducing curve") ;
      mark.curvature -= 0.1;
      if (mark.curvature < -2) mark.curvature = 2;
   } else {
      println("increasing curve");
      mark.curvature += 0.1;
      if (mark.curvature > 2) mark.curvature = -2;
    }
  }
  if (interfaceBuffer.mode() == interfaceBuffer.TILE_REGION) marks.tile(interfaceBuffer.rowStart,interfaceBuffer.rowDist,interfaceBuffer.colStart,interfaceBuffer.colDist,true,true);
}



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
    onscreenBuffer.stroke(127,0,0);
    onscreenBuffer.strokeWeight(3);
    marks.addBuffer(onscreenBuffer);
    break;
  case 's':
  case 'S': // S to save
    interfaceBuffer.save();
    break;
  case 'c':
  case 'C':
    println("changing curvature");
    var current = interfaceBuffer.click();
    if (current == interfaceBuffer.ROTATE) interfaceBuffer.setClick(interfaceBuffer.CURVEIN);
    else if (current == interfaceBuffer.CURVEIN) interfaceBuffer.setClick(interfaceBuffer.CURVEOUT);
    else interfaceBuffer.setClick(interfaceBuffer.ROTATE);
    break;
  }

}

class SingleCurve {
  public float curvature;
  int radius, row, col;
  public int orientation;
  public int quadrant;
  ArrayList<SingleCurve> neighbors = new ArrayList<SingleCurve>(); 
  
  // quadrant 0 from 0 t PI/2. 1 is the next quarter, 
  // 2 is the next, and 3 is the final quarter of a circle
  SingleCurve(int row, int col) {
    this(row, col, 0, 0, RADIUS);
  }
  
  SingleCurve(int row, int col, int quadrant) {
    this(row, col, quadrant, 0, RADIUS, 1);
  }
  
  SingleCurve(int row, int col, int quadrant, int orientation) {
    this(row, col, quadrant, orientation, RADIUS, 1);
  }
  SingleCurve(int row, int col, int quadrant, int orientation, int radius) {
    this(row, col, quadrant, orientation, radius, 1);
  }
  SingleCurve(int row, int col, int quadrant, int orientation, int radius, float curvature) {
    this.curvature = curvature;
    this.orientation = orientation;
    this.radius = radius;
    this.quadrant = quadrant;
    this.row = row;
    this.col = col;
  }
 
  void clear() {
    neighbors = new ArrayList<SingleCurve>();
  }
  
  int[] localCoords() {
    // draw a square onscreen for reference
    //rect(x, y, radius, radius);
    var adjust = adjustXY(orientation, quadrant);
    var localx = this.col*RADIUS + adjust[0];
    var localy = this.row*RADIUS + adjust[1];
    int[] ret = {localx, localy};
    return ret;
  }
  
  float[] orientationToRadians() {
    float[] ret = new float[2];
    switch (orientation) {
      case 0: 
         ret[0] = radians(0);
         ret[1] = radians(90);
         return ret;
      case 1:
         ret[0] = radians(90);
         ret[1] = radians(180);
         return ret;
      case 2: 
         ret[0] = radians(180);
         ret[1] = radians(270);
         return ret;
      case 3: 
         ret[0] = radians(-90);
         ret[1] = radians(0);
         return ret;
    } 
    return ret;
  }
  
  void update(PGraphics buffer) {
    int[] coords = localCoords();
    float[] angles = orientationToRadians();
    bezierArc(buffer, coords[0], coords[1], radius, angles[0], angles[1], curvature); 
  }
  
  void update(PEmbroiderGraphics ebuffer) {
    int[] coords = localCoords();
    float[] angles = orientationToRadians();
    bezierArc(ebuffer, coords[0], coords[1], radius, angles[0], angles[1], curvature); 
  }
  
  SingleCurve copy() {
    return new SingleCurve(this.row, this.col, this.quadrant, this.orientation, this.radius, this.curvature);
  }
  
  public JSONObject toJSON() {
    var curve = new JSONObject();
    curve.setInt("row", row);
    curve.setInt("col", col);
    curve.setInt("quadrant", quadrant);
    curve.setInt("orientation", orientation);
    curve.setInt("radius", radius);
    curve.setFloat("curvature", curvature);
    return curve;
  }
  
  String toString() {
    return "Curve at " + row + "," + col + ":q" + quadrant + ":o"+orientation;
  }
}


class CurveTable {
  SingleCurve[][][] table;
  int rows; 
  int cols;  
  int quadrants = 4;
  ArrayList<PGraphics> buffers;
  ArrayList<PEmbroiderGraphics> ebuffers;
  ArrayList<SingleCurve> curves;
  
  CurveTable(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;
    this.table = new SingleCurve[rows][cols][quadrants];

    this.buffers = new ArrayList<PGraphics>();
    this.ebuffers = new ArrayList<PEmbroiderGraphics>();
    this.curves = new ArrayList<SingleCurve>();
  }
  
  // if row = 0, items at col 0->cols-1; 
  // if row = 0 items at cols cols->2*cols-1, etc
  SingleCurve get(int row, int col, int quadrant) {
    return this.table[row][col][quadrant];
  }
  
  
  void tile(int startRow, int rowDist, int startCol, int colDist, boolean x, boolean y) {
    println("tile " + startRow + "," + startCol + "," + rowDist + "," + colDist +"," + x + "," + y);
    //println("[" + table.length +"][" + table[0].length +"]");
    // startx/starty is the grid coordinates of the top left of the tile
    // width is the width of the tile
    // height is the height of the tile
    // x is whether to tile in x direction
    // y is whether to tile in y direction
    SingleCurve tile;
    println(marks);
    //println(this);
    
    // Loop through the tile region in each quadrant
    for (int q = 0; q<4;  q++) {
      for (int s=startRow; s<=startRow+rowDist; s++) {
        for (int t=startCol; t<=startCol+colDist; t++) {
          tile = table[s][t][q];
          if (tile != null) {
            println("copying tile: " + tile);
            // loop through the table, starting at a copy of the tile located at (0,0) and moving by tile size
            for (int gridrow=0+s-startRow; gridrow+rowDist < gridrows; gridrow+=rowDist) {
              for (int gridcol=0+t-startCol; gridcol+colDist < gridcols; gridcol+=colDist) {
                println("copying to " + gridcol + "," + gridrow);
                if (tile != null && !interfaceBuffer.insideTiling(gridrow, gridcol)) {
                   tile = tile.copy();
                   tile.col = gridcol;
                   tile.row = gridrow;
                   table[gridrow][gridcol][q] = tile;
                   curves.add(tile);
                }
              }
            }
          }
        }
      }
    }
  }
  
  ////// ////// ////// //////  HELPERS ////// ////// ////// ////// ////// 
  
  void put(SingleCurve curve) {
    this.table[curve.row][curve.col][curve.quadrant] = curve;
    this.curves.add(curve);
  }
  
  void delete(int row, int col, int quadrant) {
    var curve = this.table[row][col][quadrant];
    this.table[row][col][quadrant] = null;
    curves.remove(curve);
    curve.clear();
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
      //buffer.beginShape();
      updateAll(buffer);
      //buffer.endShape();
    }
    
    for (PEmbroiderGraphics ebuffer : ebuffers) {
      //ebuffer.beginShape();
      updateAll(ebuffer);
      //ebuffer.endShape();
    }
    
  }
  
  void updateAll(PEmbroiderGraphics ebuffer) {
    //println("======= Update All Onscreen " + this);
    ebuffer.beginShape();
    for (SingleCurve curve : curves) {
        //System.out.println("curve at:" + curve);
        curve.update(ebuffer);
    }
    ebuffer.endShape();
  }
  
  void updateAll(PGraphics buffer) {
   buffer.beginShape();
   for (SingleCurve curve : curves) {
        //System.out.println("curve at:" + curve);
        curve.update(buffer);
    }
    buffer.endShape();
  }
  
  void clear() {
    var symmetry = interfaceBuffer.symmetry();
    if (symmetry == interfaceBuffer.THREE_WAY) quadrants = 3;
    if (symmetry == interfaceBuffer.FOUR_WAY) quadrants = 4;
    if (symmetry == interfaceBuffer.SIX_WAY) quadrants = 6;
    if (symmetry == interfaceBuffer.EIGHT_WAY) quadrants = 8;
    for (SingleCurve curve : curves) {
        //System.out.println("curve at:" + curve);
        curve.clear();
    }
   
    this.table = new SingleCurve[rows][cols][quadrants];
  }
  
  String toString() {
    String ret = "";
    int i = 0;
    for (SingleCurve[][] cols : this.table) {
      ret += "q"+i + ":[";
      i += 1;
      for (SingleCurve[] quadrants : cols) {
        ret += "[";
        for (SingleCurve curve : quadrants) {
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
  
  public void save_tiling(int rowStart, int rowEnd, int colStart, int colEnd) {
    JSONObject json = new JSONObject();
    json.setInt("rowStart", rowStart);
    json.setInt("rowEnd", rowEnd);
    json.setInt("colStart", colStart);
    json.setInt("colEnd", colEnd);
    
    var cells = new JSONArray(); 
    int i = 0;
    for (int q = 0; q < quadrants; q++) {
      for (int row = rowStart; row <= rowEnd; row++) {
        for (int col = colStart; col <= colEnd; col++) {
          SingleCurve cell = table[row][col][q];
          if (cell != null) {
            JSONObject cell_json = cell.toJSON();
            cells.setJSONObject(i, cell_json);
            i += 1;
          }
        }
      }
    }
    json.setJSONArray("cells", cells);
    saveJSONObject(json, "tile.JSON");
  }
  
  public void load_tiling() {
    var values = loadJSONObject("tile.JSON");
    var cells = values.getJSONArray("cells");
    var rowStart = values.getInt("rowStart");
    var rowEnd = values.getInt("rowEnd");
    var colStart = values.getInt("colStart");
    var colEnd = values.getInt("colEnd");
    tileFromJSON(cells, rowStart, rowEnd, colStart, colEnd);
    
  }
  
  public void tileFromJSON(JSONArray cells, int rowStart, int rowEnd, int colStart, int colEnd) {
    interfaceBuffer.setTiling(rowStart, rowEnd, colStart, colEnd);
    interfaceBuffer.setMode(interfaceBuffer.TILE_REGION);
    for (int i = 0; i<=cells.size(); i++) {
      var cell = curveFromJSON(cells.getJSONObject(i));
      if (interfaceBuffer.insideTiling(cell.row, cell.col)) {
        table[cell.row][cell.col][cell.quadrant] = cell;
      } else println ("ERROR JSON had items outside tiling region specified in JSON object");
    }
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
  final String ROTATE = "Place and Rotate";
  final String CURVEIN = "Change Curve Inward";
  final String CURVEOUT = "Change Curve Outward";

  Group tiling;
  MyRange col_range;
  public int colStart=1;
  public int colEnd=1;
  public int colDist = 1;
  MyRange row_range;
  public int rowStart=1;
  public int rowEnd=1;
  public int rowDist = 1;
  Button save_tiling;
  Button load_tiling;
  final String TILE_REGION = "Tile Region";
  final String FREE_ENTRY = "Free Entry";
  final String TILE_REGION_TO_REGION = "Tile Region to Region";

  public Button save;

  int INSET = 10;
  int ITEM_HEIGHT = 20;
  int SPACING = 5;

  Interface(PApplet app, int width, int height) {
    super();
    this.setSize(width, height);
    cp5 = new ControlP5(app);
    textAlign(CENTER,CENTER);
  
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
    
    var label = cp5.addTextlabel(" ");
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

    // set up click mode as rotation or curve modification
    // set up the radio buttons for tiling mode
    click = cp5.addRadioButton("ClickMode");
    click.setGroup(settings);
    click.setPosition(0, 180);
    click.setItemHeight(ITEM_HEIGHT);
    click.addItem(ROTATE, 0);
    click.getItem(ROTATE).setValue(true);
    click.addItem(CURVEIN, 1);
    click.addItem(CURVEOUT, 2);
    click.setColorLabels(BLACK);
    
    tiling = cp5.addGroup("Tiling", INSET, 290);
    col_range = new MyRange(cp5, "Column Start and End ", true);
    col_range.setGroup(tiling);
    col_range.setSize(interfaceWidth-INSET*2, ITEM_HEIGHT);
    col_range.setRange(1,gridcols);
    col_range.setRangeValues(1,1);
    col_range.setNumberOfTickMarks(gridcols);
    col_range.snapToTickMarks(true);
    col_range.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    col_range.setPosition(0, SPACING);
    col_range.setColorCaptionLabel(BLACK);
    
    row_range = new MyRange(cp5, "Row Start and End", true);
    row_range.setGroup(tiling);
    row_range.setSize(interfaceWidth-INSET*2, ITEM_HEIGHT);
    row_range.setPosition(0, ITEM_HEIGHT*2+SPACING*2);
    row_range.setRange(1,gridrows);
    row_range.setRangeValues(1,1);
    row_range.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    row_range.setColorCaptionLabel(BLACK);
    
    save_tiling = new Button(cp5, "Save Tiling Info");
    save_tiling.setGroup(tiling);
    save_tiling.setPosition(0, ITEM_HEIGHT*4+SPACING*4);
    save_tiling.setHeight(ITEM_HEIGHT);
    load_tiling = new Button(cp5, "Load Tiling Info");
    load_tiling.setGroup(tiling);
    load_tiling.setPosition(100, ITEM_HEIGHT*4+SPACING*4);
    load_tiling.setHeight(ITEM_HEIGHT);

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


  public void setMode(String val) {
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


  public void setSymmetry(String val) {
    println("changing symmetry");
    for (Toggle item : this.symmetry.getItems()) {
      if (item.getName().equals(val)) item.setValue(true);
      else item.setValue(false);
    }
  }


  public String click() {
    for (Toggle item : this.click.getItems()) {
      if (item.getBooleanValue()) {
        return item.getName();
      }
    }
    return "";
  }
  
  
  public void setClick(String val) {
    println("changing click: " + val);
    for (Toggle item : this.click.getItems()) {
      println(item.getName() + item.getName().equals(val));
      println(item.getName() + item.getState());
      if (item.getName().equals(val))  item.setState(true);
      else item.setState(false);
      println(item.getName() + item.getState());
    }
    //cp5.update();
  }
  


  public void save() {
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

  public void setTiling(int rowStart, int rowEnd, int colStart, int colEnd) {
    row_range.setRangeValues(rowStart, rowEnd);
    col_range.setRangeValues(colStart, colEnd);
  }
  
 // are x/y inside the tiling rect?
  public  boolean insideTiling(int row, int col) {
    println("row, col" + row + "," + col);
    println(this);
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
    } else if (theEvent.isFrom(this.save_tiling)) {
      marks.save_tiling(rowStart, rowEnd, colStart, colEnd);
    } else if (theEvent.isFrom(this.load_tiling)) {
      marks.load_tiling();
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
     println("in update" + _myArrayValue[1]);
     _myArrayValue[ 0 ] = map( minHandle , handleSize , getWidth( ) - handleSize , _myMin , _myMax );
     _myArrayValue[ 1 ] = map( maxHandle , handleSize , getWidth( ) - handleSize , _myMin , _myMax );
     _myArrayValue[ 0 ] = round(_myArrayValue[0]);
     _myArrayValue[ 1 ] = round(_myArrayValue[1]);
     _myHighValueLabel.set( adjustValue( _myArrayValue[ 1 ] ) );
     _myValueLabel.set( adjustValue( _myArrayValue[ 0 ] ) );
      mr = maxHandle - minHandle;
      return setValue( _myValue );
   }
   
   public Range setValue(float theValue) {
     if (!this.snapToIntegers) return super.setValue(theValue);
     println("in setValue" + theValue);
     _myValue = round(theValue);
     broadcast(ARRAY);
     return this;
   }
  
}
