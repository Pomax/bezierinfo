/***************************************************
 *                                                 *
 *  Preset functions for curve/curve intersecting  *
 *                                                 *
 ***************************************************/

/**
 * CurvePairs are linked curves for finding intersections.
 * Without linking specific pairs, it's very easy to write
 * a bad algorithm.
 */
class CurvePair {
  boolean overlapping = false;
  BezierCurve c1, c2;
  CurvePair(BezierCurve _c1, BezierCurve _c2) {
    c1 = _c1;
    c2 = _c2;
    overlapping = c1.hasBoundOverlapWith(c2);
  }
  // Is this pair an overlapping pair?
  boolean hasOverlap() {
    return overlapping;
  }
  // Split up this pair into two subcurves for
  // each pair, and permute-combine.
  CurvePair[] splitAndCombine() {
    CurvePair[] sc = new CurvePair[4];
    BezierCurve[] c1s = c1.split();
    BezierCurve[] c2s = c2.split();
    sc[0] = new CurvePair(c1s[0], c2s[0]);
    sc[1] = new CurvePair(c1s[1], c2s[0]);
    sc[2] = new CurvePair(c1s[0], c2s[1]);
    sc[3] = new CurvePair(c1s[1], c2s[1]);
    return sc;
  }
  // Is this pair small enough to count as "done"?
  boolean smallEnough() {
    return c1.getCurveLength() < 0.5 && c2.getCurveLength() < 0.5
  }
  // draw these curves with linked coloring
  void draw(color c) {
    c1.draw(c);
    c2.draw(c);
  }
  // ye olde toStringe
  String toString() { return c1  + " -- " + c2; }
}

float PRECISION = 0.01;
boolean iterated = false;
BezierCurve c1, c2;
ArrayList<CurvePair> pairs = new ArrayList<CurvePair>(),
                     newPairs = new ArrayList<CurvePair>(),
                     finals = new ArrayList<CurvePair>();

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

  /***************************** JAVASCRIPT **/
    var b = document.getElementById("clippingButton");
    if(b) {
      b.onclick = function() {
        iterated = true;
        animate();
        play();
        loop();
        frameRate(2);
        redraw();
      };
    }
  /***************************** JAVASCRIPT **/

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
}