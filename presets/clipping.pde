ArrayList<BezierCurve> curves1 = new ArrayList<BezierCurve>(),
                       curves2 = new ArrayList<BezierCurve>(),
                       subcurves1 = new ArrayList<BezierCurve>(),
                       subcurves2 = new ArrayList<BezierCurve>();

void clearSubcurves() {
  subcurves1 = new ArrayList<BezierCurve>();
  subcurves2 = new ArrayList<BezierCurve>();
}

/**
 * set up the screen
 */
void setupScreen() {
  size(dim,dim);
  labels();
  controls();
  additionals();
  noConnect();
}

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
  curves1.add(new BezierCurve(curve1));
  curves2.add(new BezierCurve(curve2));
  curves.add(curves1.get(0));
  curves.add(curves2.get(0));
}

boolean iterated = false;

/**
 * Actual draw code
 */
void drawFunction() {
  BezierCurve curve = curves.get(0);

  if(iterated) noAdditionals();
  for(BezierCurve c: curves1) {
    c.draw(color(255,0,0));
    drawBoundingBox(c.generateBoundingBox());
  }
  for(BezierCurve c: curves2) {
    c.draw(color(0,0,255));
    drawBoundingBox(c.generateBoundingBox());
  }

  iterate();
  iterated = true;
}
