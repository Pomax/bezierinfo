class BooleanComputer {
  PolyBezierCurve p1, p2;
  ArrayList<CurvePair> intersections;
  ArrayList<PolyBezierCurve> segments1, segments2;
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
    intersections = p.getIntersections(p2);

    // make sure the curvepairs are sorted w.r.t. t values on p1
    int MODE = 1;
    sortCurvePairs(intersections, MODE);
    println("\nbuilding p1");
    segments1 = buildSegments(p1, intersections, MODE);

    // make sure the curvepairs are sorted w.r.t. t values on p2
    MODE = 2;
    println("\nbuilding p2");
    sortCurvePairs(intersections, MODE);
    segments2 = buildSegments(p2, intersections, MODE);
  }
  
  /**
   * Split up a polybezier based on a list of intersection 't' values,
   * encoded as part of intersection curve pairs. 
   */
  private ArrayList<PolyBezierCurve> buildSegments(PolyBezierCurve p, ArrayList<CurvePair> intersections, int MODE) {
    ArrayList<PolyBezierCurve> segments = new ArrayList<PolyBezierCurve>();
    float t1=0, t2=1.0;
    for(CurvePair cp: intersections) {
      println(cp.t1 + " (" + cp.s1 + "), " + cp.t2 + " (" + cp.s2 + ")");
      t2 = (MODE == 1? cp.t1 : cp.t2);
      segments.add(p.split(t1,t2));
      t1 = t2;
    }
    segments.add(p.split(t2)[1]);
    return segments;
  }

  /**
   * custom quicksort
   */
  void sortCurvePairs(ArrayList<CurvePair> cp, int MODE) {
    if(cp.size()==0) return;
    if(cp.size()==1) return;
    int pos = (int)(cp.size()-1)/2;
    CurvePair pivot = cp.get(pos);
    ArrayList<CurvePair> left = new ArrayList<CurvePair>();
    ArrayList<CurvePair> right = new ArrayList<CurvePair>();
    for(int i=cp.size()-1; i>=0; i--) {
      if(i==pos) { cp.remove(i); continue; }
      if(MODE == 1) { if(cp.get(i).t1 < pivot.t1) { left.add(cp.get(i)); } else { right.add(cp.get(i)); }}
      else if(MODE == 2) { if(cp.get(i).t2 < pivot.t2) { left.add(cp.get(i)); } else { right.add(cp.get(i)); }}
      cp.remove(i);
    }
    sortCurvePairs(left,MODE);
    for(CurvePair c: left) { cp.add(c); }
    sortCurvePairs(right,MODE);
    for(CurvePair c: right) { cp.add(c); }
  }
  
  
  /**
   * 
   */
  PolyBezierCurve getUnion() {
    return null;
  }
  
  /**
   * 
   */
  PolyBezierCurve getIntersection() {
    return null;
  }
  
  /**
   * 
   */
  PolyBezierCurve getExclusion() {
    return null;
  }
  
  
}
