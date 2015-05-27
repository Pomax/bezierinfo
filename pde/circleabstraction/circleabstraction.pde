Point[] points = new Point[4];
Point p1, p2, p3, p4, pc;
double pad = 25;
double errorThreshold = 0.5;

void setup() {
  size(500,500);
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
/*
  points[0] = new Point(94.11341105819245,340.93873937170713);
  points[1] = new Point(636.5745376572827,594.1225391842106);
  points[2] = new Point(661.4440240192771,610.5579251929132);
  points[3] = new Point(306.84619192858946,247.0708672418129);
*/
  p1 = points[0];
  p2 = points[1];
  p3 = points[2];
  p4 = points[3];
/*
  println("---");
  println(p1);
  println(p2);
  println(p3);
  println(p4);
*/
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
