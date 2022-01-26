import processing.embroider.*;
import processing.svg.PGraphicsSVG;

// Hex Embroidery drawer for the PEmbroider library for Processing!
// Press 's' to save the embroidery file. Press space to clear.
// Press 'i' to insert hex (this is the default mode)
// Press 'd' to add a line dividing a hex.
PEmbroiderGraphics E;
int fileNumber = 1;

int ROWS = 1;
int COLS = 3;

int WHITE = 255;
int BLACK = 0;

int SCALE=8;
float b = 4*SCALE;
float B = 6*SCALE;
float h = 5*SCALE;
float C = 8*SCALE;
float t = 3*SCALE;
float H = 16*SCALE;
float OFFSETX = C;
float OFFSETY = C;

//===================================================
void setup() { 
  size(1100,500,SVG, "fishCell.svg");
  
  println(""+width+","+height);
  E = new PEmbroiderGraphics(this, width, height);
  
  noLoop();
}

//===================================================
void draw() {
  //background(200);
  strokeWeight(t/3);
  strokeJoin(ROUND);
  smooth();
  hint(DISABLE_DEPTH_TEST); // avoids z-fighting
  hint(ENABLE_STROKE_PURE); // strokes are drawn correctly
  basicEmbroiderySettings();
  E.beginDraw();
  drawGrid();
  E.endDraw();
  //E.optimize(); 
  E.visualize(true, true, true);
}
  
void basicEmbroiderySettings() {
    E.stroke(BLACK);  //
    E.strokeWeight(t/2);  //
    //E.fill(BLACK);
    //E.fill(0, 0, 255);
    E.strokeSpacing(2.0);  
    //E.noStroke(); 
    E.setRenderOrder(PEmbroiderGraphics.STROKE_OVER_FILL); // or E.FILL_OVER_STROKE
    E.strokeMode(PEmbroiderGraphics.PERPENDICULAR); //
    E.strokeLocation(PEmbroiderGraphics.INSIDE); // or E.OUTSIDE, E.INSIDE
    //E.hatchMode(PEmbroiderGraphics.VECFIELD); //
    //E.HATCH_VECFIELD=new CrossField();
    E.hatchMode(PEmbroiderGraphics.CROSS); //
    //E.HATCH_ANGLE = radians(45);
    //E.HATCH_ANGLE2 = radians(-45);
    //E.STROKE_CAP = PConstants.SQUARE;
    //E.STROKE_JOIN = PConstants.MITER;
    //E.NO_CONNECT = true;
    E.HATCH_SPACING = 20;
    //E.satinMode(PEmbroiderGraphics.ZIGZAG);
    E.setStitch(20, 26, 0);  //
    //E.RESAMPLE_MAXTURN = 0.8f; //
    randomSeed(5);
}

void drawGrid() {
  ArrayList<PVector> vertices;
  PVector vertex;
  
  for(var row = 0; row <= ROWS; row++) {
      for(var col = 0; col <= COLS; col++) {
        vertices = new ArrayList<PVector>();

        float x1 = OFFSETX +b + (B*2+C)*col; // top left vertex 
        float y1 = OFFSETY + H*row; 
        if (col%2 ==0) {
          vertices.add(new PVector(x1, y1));
          vertices.add(new PVector(x1-b, y1+h));
          vertices.add(new PVector(x1+b,y1+H-h));
          vertices.add(new PVector(x1, y1+H)); // bottom left vertex
          vertices.add(new PVector(x1+2*B, y1+H)); // bottom right vertex
          vertices.add(new PVector(x1+2*B-b, y1+H-h));
          vertices.add(new PVector(x1+2*B+b, y1+h));
          vertices.add(new PVector(x1+2*B, y1)); // top right vertex
          //drawLaceShape(vertices, (row ==0), false);
          drawLaceShape(vertices, true, false);
          if (col < COLS) {
            vertex = vertices.get(5);
            //E.line(vertex.x, vertex.y, vertex.x+C, vertex.y);
            line(vertex.x, vertex.y, vertex.x+C, vertex.y);
            
            vertex = vertices.get(6);
            //E.line(vertex.x, vertex.y, vertex.x+C, vertex.y);
            line(vertex.x, vertex.y, vertex.x+C, vertex.y);
          }
        } else {
          vertices.add(new PVector(x1, y1));
          vertices.add(new PVector(x1+b,y1+h));
          vertices.add(new PVector(x1-b, y1+H-h));
          vertices.add(new PVector(x1, y1+H));
          vertices.add(new PVector(x1+2*B, y1+H));
          vertices.add(new PVector(x1+2*B+b, y1+H-h));
          vertices.add(new PVector(x1+2*B-b, y1+h));
          vertices.add(new PVector(x1+2*B, y1));
          //drawLaceShape(vertices, (row ==0), false);
          drawLaceShape(vertices, true, false);
          
          if (col < COLS) {
            vertex = vertices.get(5);
            //E.line(vertex.x, vertex.y, vertex.x-C, vertex.y);
            line(vertex.x, vertex.y, vertex.x+C, vertex.y);

            vertex = vertices.get(6);
            //E.line(vertex.x, vertex.y, vertex.x-C, vertex.y);
            line(vertex.x, vertex.y, vertex.x+C, vertex.y);

          }
        }
        
     }
  }
}
  
void drawLaceShape(ArrayList<PVector> vertices, boolean closed, boolean fill) {
  
    PVector prev = vertices.get(0); // holds the previous vertex
    PVector v = new PVector();
    beginShape();
    for (int i=1; i<vertices.size(); i++) {
      v = vertices.get(i);
      //E.line(prev.x, prev.y, v.x, v.y);
      vertex(prev.x, prev.y);
      //E.vertex(v.x, v.y);
      prev = v;
    }
    vertex(prev.x, prev.y);
    if (closed) {
      prev = vertices.get(0);
      //E.line(v.x, v.y, prev.x, prev.y);
      vertex(v.x, v.y);
      vertex(prev.x, prev.y);
    }
    endShape();
}

//--------------------------------------------
void generateEmbroideryFromRasterGraphics() {
  E.beginDraw(); 
  E.clear();

  basicEmbroiderySettings();
  
  E.stroke(127,0,0);  //

  E.visualize();
  E.endDraw();
  
}
 
 
//===================================================

//===================================================
void mousePressed() {
  println("mouse pressed============+");
}


//===================================================
void mouseReleased() {
  E.printStats();
}


//===================================================
void keyPressed() {
  if (key == ' ') {
    
  }  else if (key == 's' || key == 'S') { // S to save
    //E.optimize(); // slow, but very good and important
    E.printStats(); 
    String outputFilePath = sketchPath("fishCell" + fileNumber + ".dst");
    E.setPath(outputFilePath); 
    save(outputFilePath);
    
    E.endDraw(); // write out the file
    fileNumber += 1;
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
