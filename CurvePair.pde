/**
 * CurvePairs are linked curves for finding intersections.
 * Without linking specific pairs, it's very easy to write
 * a bad algorithm.
 */
class CurvePair {
  boolean overlapping = false;
  BezierCurve c1, c2;
  float t1, t2;
  int s1, s2;

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
  
  /**
   * 
   */
  void setTValues() {
    float[] t1s = c1.getInterval(),
            t2s = c2.getInterval();
    t1 = (t1s[0] + t1s[1])/2;
    t2 = (t2s[0] + t2s[1])/2;
  }

  // Is this pair small enough to count as "done"?
  boolean smallEnough() {
    return c1.getCurveLength() < 0.5 && c2.getCurveLength() < 0.5;
  }

  // draw these curves with linked coloring
  void draw(color c) { c1.draw(c); c2.draw(c); }

  // ye olde toStringe
  String toString() { return c1  + " -- " + c2; }
}

