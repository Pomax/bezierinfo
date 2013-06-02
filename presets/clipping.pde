/***************************************************
 *                                                 *
 *  Preset functions for curve/curve intersecting  *
 *                                                 *
 ***************************************************/

int iterationCount = 1;
float PRECISION = 0.01;
boolean iterated = false;
BezierCurve c1, c2;
ArrayList<CurvePair> pairs, newPairs, finals;

/**
 * set up the screen
 */
void setupScreen() {
  size(dim,dim);
  labels();
  controls();
  additionals();
  noConnect();

  iterationCount = 1;
  iterated = false;
  pairs = new ArrayList<CurvePair>();
  newPairs = new ArrayList<CurvePair>();
  finals = new ArrayList<CurvePair>();
}

/**
 *
 */
void setupCurve() {
  Point[] curve1 = new Point[]{
    new Point(10,100),
    new Point(90,30),
    new Point(40,140),
    new Point(220,240)
  };
  Point[] curve2 = new Point[]{
    new Point(5,150),
    new Point(180,20),
    new Point(80,280),
    new Point(210,190)
  };
  c1 = new BezierCurve(curve1);
  c2 = new BezierCurve(curve2);
  pairs.add(new CurvePair(c1,c2));
  curves.add(c1);
  curves.add(c2);

  if(javascript!=null) {
    javascript.setupClippingButton(this);
  }

}

/**
 * Actual draw code
 */
void drawFunction() {
  if(iterated) { noAdditionals(); }
  for(CurvePair cp: pairs) {
    cp.c1.draw(color(255,0,0));
    drawBoundingBox(cp.c1.generateBoundingBox());
    cp.c2.draw(color(0,0,255));
    drawBoundingBox(cp.c2.generateBoundingBox());
  }
  if(iterated) { iterate(); }
}

/**
 *
 */
void drawResult() {
  additionals();
  curves.get(0).draw(color(255,0,0));
  curves.get(1).draw(color(0,0,255));

  noAdditionals();
  float t;
  float[] tvalues;
  for(CurvePair cp: finals) {
    noFill();
    stroke(255,0,0);
    ellipse(cp.c1.points[0].x, cp.c1.points[0].y, 10,10);
    fill(255,0,0);
    tvalues = cp.c1.getInterval();
    t = (tvalues[0]+tvalues[1])/2;
    text("t ≈ "+int(1000*t)/1000, cp.c1.points[0].x + 10, cp.c1.points[0].y-2);

    noFill();
    stroke(0,0,255);
    ellipse(cp.c2.points[0].x, cp.c2.points[0].y, 10,10);
    fill(0,0,255);
    tvalues = cp.c2.getInterval();
    t = (tvalues[0]+tvalues[1])/2;
    text("t ≈ "+int(1000*t)/1000, cp.c2.points[0].x + 10, cp.c2.points[0].y+12);
  }

  iterationCount = 1;
  mayReset();
}