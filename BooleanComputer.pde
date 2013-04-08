/***************************************************
 *                                                 *
 *  A special computer class for shape operations  *
 *                                                 *
 ***************************************************/

/**
 *  computation class for Boolean shape operations
 */
class BooleanComputer {
  // each instance operates on two shapes.
  PolyBezierCurve p1, p2;

  ArrayList<CurvePair> intersections;
  ArrayList<PolyBezierCurve> segments1, segments2;

  IntersectionTracker intersectionTracker;

  final int UNION = 0,
            INTERSECTION = 1,
            EXCLUSION = 2;

  /**
   * bind poly-beziers and compute segmentation
   */
  BooleanComputer(PolyBezierCurve _p1, PolyBezierCurve _p2) {
    p1 = _p1;
    p2 = _p2;
    segment();
  }

  /**
   * Split up p1 and p2 into lists of continuous sections
   * based on the intersection points.
   */
  void segment() {
    intersections = p1.getIntersections(p2);
    intersectionTracker = new IntersectionTracker(intersections.size());

    if(intersections.size()>0) {
      // make sure the curvepairs are sorted w.r.t. t values on p1
      if(p1.segments.size()>0) {
        int MODE = 1;
        sortCurvePairs(intersections, MODE);
        segments1 = buildSegments(p1, intersections, MODE, intersectionTracker);
      }
      // then, make sure the curvepairs are sorted w.r.t. t values on p2
      if(p2.segments.size()>0) {
        int MODE = 2;
        sortCurvePairs(intersections, MODE);
        segments2 = buildSegments(p2, intersections, MODE, intersectionTracker);
      }
    }

    // no intersections means we don't segment.
    else {
      segments1 = new ArrayList<PolyBezierCurve>();
      segments1.add(p1);
      segments2 = new ArrayList<PolyBezierCurve>();
      segments2.add(p2);
    }
  }

  /**
   * Split up a polybezier based on a list of intersection 't' values,
   * encoded as part of intersection curve pairs.
   */
  private ArrayList<PolyBezierCurve> buildSegments(PolyBezierCurve p, ArrayList<CurvePair> intersections, int MODE, IntersectionTracker tracker) {
    ArrayList<PolyBezierCurve> segments = new ArrayList<PolyBezierCurve>();
    float t1=0, t2=1.0;
    boolean open = false;
    PolyBezierCurve pbc;
    CurvePair cp;
    for(int c=0, last=intersections.size(); c<last; c++) {
      cp = intersections.get(c);
      t2 = (MODE == 1? cp.t1 : cp.t2);
      pbc = p.split(t1,t2);
      //open = (pbc.getCurveLength()<2);
      if(!open) {
        t1 = t2;
        segments.add(pbc);
        tracker.trackOut(c,pbc,MODE);
        tracker.trackIn((c+1)%last,pbc,MODE);
      }
    }
    // merge last segment with first segment
    pbc = p.split(open?t1:t2)[1];
    segments.get(0).prepend(pbc);
    return segments;
  }

  /**
   * custom quicksort for sorting curvepairs based either on t1 or t2 properties.
   */
  void sortCurvePairs(ArrayList<CurvePair> cp, int MODE) {
    if(cp.size()==0) return;
    if(cp.size()==1) return;
    int pos = int((int)(cp.size()-1)/2);
    CurvePair pivot = cp.get(pos);
    ArrayList<CurvePair> left = new ArrayList<CurvePair>();
    ArrayList<CurvePair> right = new ArrayList<CurvePair>();
    for(int i=cp.size()-1; i>=0; i--) {
      if(i==pos) { cp.remove(i); continue; }
      if(MODE == 1) {
        if(cp.get(i).t1 < pivot.t1) { left.add(cp.get(i)); }
        else { right.add(cp.get(i)); }}
      else if(MODE == 2) {
        if(cp.get(i).t2 < pivot.t2) { left.add(cp.get(i)); }
        else { right.add(cp.get(i)); }}
      cp.remove(i);
    }
    sortCurvePairs(left,MODE);
    for(CurvePair c: left) { cp.add(c); }
    cp.add(pivot);
    sortCurvePairs(right,MODE);
    for(CurvePair c: right) { cp.add(c); }
  }

  /**
   * Get a reference point for ray-crossings
   */
  Point getReference(PolyBezierCurve pbc) {
    Point s = pbc.getFirst().getStart(),
          e = pbc.getLast().getEnd();
    float dx = e.x - s.x,
          dy = e.y - s.y,
          d = dist(s.x,s.y,e.x,e.y);
    dx/=d; dy/=dy;
    return (new Point(dx, dy)).rotateOver(ORIGIN,PI/2).scale(10*dim);
  }

  /**
   * Construct the union outline (i.e. all covered area)
   */
  PolyBezierCurve getUnion() {
    IntersectionTracker generator = intersectionTracker.copy();
    PolyBezierCurve shape = getOperation(UNION, generator);
    return generator.formShape();
  }

  /**
   * Construct the intersection outline (i.e. the overlap only)
   */
  PolyBezierCurve getIntersection() {
    IntersectionTracker generator = intersectionTracker.copy();
    PolyBezierCurve shape = getOperation(INTERSECTION, generator);
    return generator.formShape();
  }

  /**
   * Construct the exclusion outline (i.e. all areas the shapes do not overlap)
   */
  // FIXME: implement?
  PolyBezierCurve getExclusion() { return null; }

  /**
   * generic operator
   */
  PolyBezierCurve getOperation(int op, IntersectionTracker intersectionTracker) {
    PolyBezierCurve shape = new PolyBezierCurve(false);
    int f = 0, cross;
    Point s, e, reference;
    for(PolyBezierCurve pbc: segments1) {
      cross = p2.contains(pbc, getReference(pbc));
      if(cross % 2 == op) {
        for(BezierCurve c: pbc.segments) {
          shape.addCurve(c, false);
        }
        shape.subShape();
      } else { intersectionTracker.remove(pbc); }
    }
    f = 0;
    for(PolyBezierCurve pbc: segments2) {
      cross = p1.contains(pbc, getReference(pbc));
      if(cross % 2 == op) {
        for(BezierCurve c: pbc.segments) {
          shape.addCurve(c, false);
        }
        shape.subShape();
      } else { intersectionTracker.remove(pbc); }
    }
    return shape;
  }
}

