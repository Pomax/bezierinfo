Point[] points = new Point[4];
Point p1, p2, p3, p4, pc;
float startratio = 0.003;
boolean badarc = false;
ArrayList<Point> circles = new ArrayList<Point>();
double pad = 100;
Mark current;

void setup() {
  size(800,800);
  newPoints();
  noLoop();
}

void keyPressed() {
  loop();
}

void newPoints() {
  for(int i=0; i<points.length; i++) {
    points[i] = new Point(pad + random(width - 2 * pad), pad + random(height - 2 * pad));
  }
  p1 = points[0];
  p2 = points[1];
  p3 = points[2];
  p4 = points[3];
  /*
    p1 = new Point(300,100);
    p2 = new Point(500,500);
    p3 = new Point(0,500);
    p4 = new Point(100,0);
  */
  current = new Mark(p1, startratio, 0);
}

void draw() {
  background(255);
 
  if(current.t+current.ratio >1) {
    noLoop();
    circles.add(pc);
  } else {
    stroke(0);
    noFill();
    drawCurve();

    current.ratio += startratio;
  
    Point np1 = current.p;
    Point np2 = get(current.t + current.ratio/2);
    Point np3 = get(current.t + current.ratio);
    pc  = getCCenter(np1, np2, np3);
    double error = getError(pc, np1);
    boolean badarc = (error > 0.5);
    drawCircle(pc, np1, np2, np3);
  
    if(badarc) {
      circles.add(pc);
      current = new Mark(np3, startratio, current.t + current.ratio);
    }
  }

  for(Point c: circles) { drawCircle(c); }
}