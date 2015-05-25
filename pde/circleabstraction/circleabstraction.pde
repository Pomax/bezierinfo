Point[] points = new Point[4];
Point p1, p2, p3, p4, pc;
double pad = 50;
double errorThreshold = 0.5;

void setup() {
  size(800,800);
  newPoints();
  noLoop();
}

void keyPressed() {
  if (keyCode==38) {
    errorThreshold += (errorThreshold>100 ? 3 : errorThreshold>10 ? 1 : 0.1);
  }
  else if (keyCode==40) {
    errorThreshold -=  (errorThreshold>100 ? 3 : errorThreshold>10 ? 1 : 0.1);  
    if (errorThreshold < 0.1) {
      errorThreshold = 0.1;
    }
  }
  else { newPoints(); }
  redraw();
}

void newPoints() {
  for(int i=0; i<points.length; i++) {
    points[i] = new Point(pad + random(width - 2 * pad), pad + random(height - 2 * pad));
  }
  p1 = points[0];
  p2 = points[1];
  p3 = points[2];
  p4 = points[3];
}

void draw() {
  background(255);
  drawCurve();
  ArrayList<Point> circles = iterate(errorThreshold);
  if(circles != null) {
    for(Point c: circles) {
      drawCircle(c);
    }
  }
  fill(0);
  text(circles.size() + " arcs, using error threshold: "+errorThreshold, 15, 15);
}