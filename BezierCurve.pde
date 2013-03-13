/**
 * Bezier curve class (of any degree)
 */
class BezierCurve {
  final int LUT_resolution = 200;
  int order;
  Point[] points,              // the control points for this curve
          abc = new Point[3],  // the "ABC" points. Only for 2nd and 3rd order curves
          span,                // de Casteljau's spanning lines for some t=...
          left_split,          // for any span, these are the control points for the subcurve [0,t]
          right_split,         // for any span, these are the control points for the subcurve [t,1]
          normals;             // the normal vectors for each control point.
  // LUT for the point x/y values and t-at-x/y values
  float[] x_values,
          y_values,
          LUT_x = new float[LUT_resolution],
          LUT_y = new float[LUT_resolution],
          ratios;              // the distance ratios for each control point.
  // for drawing the curve, we use integer lookups
  int[] draw_x = new int[LUT_resolution],
        draw_y = new int[LUT_resolution];
  float span_t = -1,     // indicates the 't' value for which span/left/right was last computed
        curveLength,     // the arc length of this curve, computed on construction
        bias = 0;        // are control points are on one side of the baseline? -1/1 means yes (sign indicates left/right), 0 means no.

  // lower order Bezier curve, if this curve is an elevation
  BezierCurve generator = null;


  /**
   * construct a typical curve
   */
  BezierCurve(Point[] points) {
    this.points = points;
    order = points.length-1;
    int L = points.length;
    x_values = new float[L];
    y_values = new float[L];
    update();
  }

  /**
   * Update all the cachable information
   * - x/y lookup tables
   * - coordinates in x and y dimensions
   * - curve length
   * - control normals
   */
  void update() {
    generator = null;
    // Split up "point" x- and y- components for quick lookup.
    for(int i=0, last=points.length; i<last; i++) {
      x_values[i] = points[i].x;
      y_values[i] = points[i].y;
    }
    // Create lookup tables for resolving coordinate -> 't' value
    // as well as the int-cast screen point for that 't' value.
    float t, r=(float)(LUT_resolution-1);
    for(int idx=0; idx<LUT_resolution; idx++) {
      t = idx/r;
      // lookup values
      LUT_x[idx] = getXValue(t);
      LUT_y[idx] = getYValue(t);
      // squashed values, for drawing
      draw_x[idx] = (int)round(LUT_x[idx]);
      draw_y[idx] = (int)round(LUT_y[idx]);
    }
    // Determine curve length
    curveLength = (order==1? dist(x_values[0],y_values[0],x_values[1],y_values[1]) : comp.getArcLength(x_values, y_values));
    // Figure out the normals along this curve
    // for each control point.
    normals = new Point[order+1];
    normals[0] = getNormal(0);
    normals[order] = getNormal(1);
    ratios = new float[order+1];
    ratios[0] = 0;
    for(int i=1; i<=order; i++) {
      t = 0.5;
      Point p = new Point(points[i]);
      // find an approximate t value that acts as the control's
      // projection onto the curve, towards the origin.
      float mindist=9999999, pdist;
      int mindist_idx=0;
      for(int idx=0; idx<LUT_resolution; idx+=1) {
        pdist = dist(p.x, p.y, LUT_x[idx], LUT_y[idx]);
        if(pdist<mindist) {
          mindist = pdist;
          mindist_idx = idx;
          t = (float)idx/(float)LUT_resolution; }}
      normals[i] = getNormal(t);
      float partialLength = (order==1? dist(x_values[0],y_values[0],LUT_x[mindist_idx],LUT_y[mindist_idx]) : comp.getArcLength(t, x_values, y_values));
      ratios[i] = partialLength/curveLength;
    }
    ratios[order] = 1;
    // Is this curve biased? i.e. are all the control
    // points on one side of the baseline?
    if(order>1) {
      bias = comp.getSide(points[0],points[order],points[1]);
      for(int i=2; i<order; i++) {
        if(comp.getSide(points[0],points[order],points[i])!=bias) {
          bias = 0;
          break; }}}
  }

  /**
   * Get values
   */
  float getXValue(float t) { return comp.getValue(t, x_values); }
  float getYValue(float t) { return comp.getValue(t, y_values); }
  Point getPoint(float t)  { return new Point(getXValue(t), getYValue(t)); }

  /**
   * Get derivative values
   */
  float getDXValue(float t) { return comp.getDerivative(1, t, x_values);  }
  float getDYValue(float t) { return comp.getDerivative(1, t, y_values);  }
  Point getDerivativePoint(float t)  { return new Point(getDXValue(t), getDYValue(t)); }
  Point[] getSpanLines(float t)  { 
    Point[] span = generateSpan(t);
    int prev = span.length-3, b = span.length-1, next = span.length-2;
    Point p1 = new Point(span[prev].x-span[b].x, span[prev].y-span[b].y);
    Point p2 = new Point(span[next].x-span[b].x, span[next].y-span[b].y);
    return new Point[]{p1, p2};
  }

  /**
   * Get second derivative values
   */
  float getD2XValue(float t) { return comp.getDerivative(2, t, x_values);   }
  float getD2YValue(float t) { return comp.getDerivative(2, t, y_values);   }
  Point getSecondDerivativePoint(float t)  { return new Point(getD2XValue(t), getD2YValue(t)); }

  /**
   * get a point-normal
   */
  Point getNormal(float t) {
    float dx = getDXValue(t),
          dy = getDYValue(t),
          a = -PI/2,
          ca = cos(a),
          sa = sin(a),
          nx = dx*ca - dy*sa,
          ny = dx*sa + dy*ca,
          dst = sqrt(nx*nx+ny*ny);
    return new Point(nx/dst, ny/dst);
  }

  /**
   * Get the spanning lines for this curve at t = ...
   * While we do this, we also calculate the A/B/C points,
   * as well as the split curves for [t], since this requires
   * the same information.
   */
  Point[] generateSpan(float t) {
    span_t = t;
    left_split = new Point[order+1];
    right_split = new Point[order+1];
    int l = 0, r = order;
    Point[] span = new Point[comp.markers(order+1)];
    arrayCopy(points,0,span,0,points.length);
    Point p1, p2, p3;
    int next = points.length;
    for(int c = order; c>0; c--) {
      left_split[l++] = span[next-c-1];
      for(int i = 0; i<c; i++) {
        p1 = span[next-c-1];
        p2 = span[next-c];
        p3 = new Point(lerp(p1.x, p2.x, t), lerp(p1.y, p2.y, t));
        if(c==3 && i==1) { abc[0] = p3; }
        span[next++] = p3;
      }
      right_split[r--] = span[next-c-1];
    };
    left_split[l] = span[next-1];
    right_split[0] = span[next-1];
//    right_split = (Point[]) reverse(right_split);
    // fill in the ABC array
    int last = span.length - 1;
    abc[0] = (order%2==0 ? span[order/2] : span[order + order - 1]);
    abc[1] = span[last];
    abc[2] = comp.getProjection(abc[0], abc[1], span[0], span[order]);
    // and finally, return the span lines
    return span;
  }

  /**
   * compute the bounding box for a curve
   */
  Point[] generateBoundingBox() {
    float[] inflections = getInflections();
    float mx=999999, MX=-999999, my=mx, MY=MX, x, y, t;
    for(int i=0; i<inflections.length; i++) {
      t = inflections[i];
      x = getXValue(t);
      y = getYValue(t);
      if(x < mx) { mx = x; }
      if(x > MX) { MX = x; }
      if(y < my) { my = y; }
      if(y > MY) { MY = y; }
    }
    Point[] bbox = {new Point(mx,my), new Point(MX,my), new Point(MX,MY), new Point(mx,MY)};
    return bbox;
  }

  Point[] generateTightBoundingBox() {
    float ox = points[0].x,
          oy = points[0].y,
          angle = atan2(points[order].y - points[0].y, points[order].x - points[0].x) + PI,
          ca = cos(angle),
          sa = sin(angle),
          nx, ny;
    Point[] bbox = align().generateBoundingBox();
    for(Point p: bbox) {
      nx = (p.x * ca - p.y * sa) + ox;
      ny = (p.x * sa + p.y * ca) + oy;
      p.x = nx;
      p.y = ny;
    }
    return bbox;
  }

  /**
   * Just the X curvature
   */
  BezierCurve justX(float h) {
    int L = points.length, l = L - 1;
    Point[] newPoints = new Point[L];
    for(int i=0; i<L; i++) {
      newPoints[i] = new Point(i*h/l, points[i].x);
    }
    return new BezierCurve(newPoints);
  }

  /**
   * Just the Y curvature
   */
  BezierCurve justY(float h) {
    int L = points.length, l = L - 1;
    Point[] newPoints = new Point[L];
    for(int i=0; i<L; i++) {
      newPoints[i] = new Point(i*h/l, points[i].y);
    }
    return new BezierCurve(newPoints);
  }

  /**
   * Determine whether all control points are on
   * one side of the baseline. If so, this curve
   * is biased, making certain computations easier.
   */
  boolean isBiased() { return bias != 0; }

  /**
   * return the arc length for this curve.
   */
  float getCurveLength() { return curveLength; }

  /**
   * Get the A/B/C points for this curve. These are only
   * meaningful for quadratic and cubic curves.
   */
  Point[] getABC(float t) {
    generateSpan(t);
    return abc;
  }

  /**
   * Get the distance of the curve's midpoint to the
   * baseline (start-end). The smaller this value is,
   * the more linear a simple curve will be. For
   * non-simple curves, this value is relatively useless.
   */
  float getScaleAngle() {
    Point p1 = getNormal(0), p2 = getNormal(1);
    return abs(atan2(p1.x*p2.y - p2.x*p1.y, p1.x*p2.x + p1.y*p2.y) % 2*PI);
  }

  /**
   * Split into two curves at t
   */
  BezierCurve[] split(float t) {
    if (t != span_t) { generateSpan(t); }
    BezierCurve[] subcurves = {new BezierCurve(left_split), new BezierCurve(right_split)};
    return subcurves;
  }

  /**
   * Get the segment from t1 to t2 as new curve
   */
  BezierCurve split(float t1, float t2) {
    BezierCurve segment;
    if(t1==0) { segment = split(t2)[0]; }
    else if(t2==1) { segment = split(t1)[1]; }
    else {
      BezierCurve[] subcurves = split(t1);
      t2 = (t2-t1)/(1-t1);
      subcurves = subcurves[1].split(t2);
      segment = subcurves[0];
    }
    return segment;
  }

  /**
   * Scale this curve. Note that this is NOT
   * the same as offsetting the curve. We're
   * literally just scaling the coordinates.
   */
  BezierCurve scale(float f) {
    int L = points.length;
    Point[] scaled = new Point[L];
    Point p;
    for (int i=0; i<L; i++) {
      p = points[i];
      scaled[i] = new Point(f * p.x, f * p.y);
    }
    return new BezierCurve(scaled);
  }

  /**
   * Align this curve: rotate it so that the first and last coordinates line up,
   * and shift it so that the first coordinate is (0,0), which simplifies the formulae.
   */
  BezierCurve align() {
    return align(points[0], points[order]);
  }

  /**
   * Align this curve to a line defined by two points: rotate it so that the line
   * start is on (0,0), and rotate it so the angle is 0.
   */
  BezierCurve align(Point start, Point end) {
    float angle = atan2(end.y - start.y, end.x - start.x) + PI,
          ca = cos(-angle),
          sa = sin(-angle),
          ox = start.x,
          oy = start.y;
    int L = points.length;
    Point[] aligned = new Point[L];
    Point p = points[0];
    for (int i=0; i<L; i++) {
      p = points[i];
      p = new Point(ca * (p.x-ox) - sa * (p.y-oy), sa * (p.x-ox) + ca * (p.y-oy));
      aligned[i] = p;
    }
    return new BezierCurve(aligned);
  }

  /**
   * Normalise this curve: scale all coordinate to within a unit rectangle.
   */
  BezierCurve normalize() {
    int L = points.length;
    Point[] normalised = new Point[L];
    Point p = points[0];
    float mx = 999999, my = mx,
          MX = -999999, MY = MX;
    for (int i=0; i<L; i++) {
      p = points[i];
      if(p.x<mx) { mx = p.x; }
      if(p.y<my) { my = p.y; }
      if(p.x>MX) { MX = p.x; }
      if(p.y>MY) { MY = p.y; }
      normalised[i] = p;
    }
    for (int i=0; i<L; i++) {
      normalised[i].x = map(normalised[i].x,  mx,MX,  0,1);
      normalised[i].y = map(normalised[i].y,  my,MY,  0,1);
    }
    return new BezierCurve(normalised);
  }

  /**
   * Elevate this curve by one order
   */
  BezierCurve elevate() {
    int L = points.length;
    Point[] elevatedPoints = new Point[L+1];
    elevatedPoints[0] = new Point(LUT_x[0], LUT_y[0]);
    float np1 = order+1, nx, ny;
    for(int i=1; i<L; i++) {
      nx = (i/np1) * x_values[i-1] + (np1-i)/np1 * x_values[i];
      ny = (i/np1) * y_values[i-1] + (np1-i)/np1 * y_values[i];
      elevatedPoints[i] = new Point(nx,ny);
    }
    elevatedPoints[L] = new Point(x_values[L-1], y_values[L-1]);
    BezierCurve b = new BezierCurve(elevatedPoints);
    b.setLower(this);
    return b;
  }

  /**
   * Fix the "lower" degree curve for this Bezier curve.
   * The moment any of the curve points are modified, this
   * lower degree curve is discarded.
   */
  void setLower(BezierCurve parent) { generator = parent; }

  /**
   * Lower the curve's complexity, if we can. Which basically
   * means "if this curve was raised without the coordinates
   * having been touched, since". Otherwise we fake it, by
   *
   */
  BezierCurve lower() {
    if(generator!=null) return generator;
    if(order==1) return this;
    Point[] newPoints = new Point[order];
    float x, y;
    newPoints[0] = points[0];
    // FIXME: this is not very good lowering =)
    for(int i=1; i<order; i++) {
      x = lerp(points[i-1].x,points[i].x,0.5);
      y = lerp(points[i-1].y,points[i].y,0.5);
      newPoints[i] = new Point(x,y);
    }
    newPoints[order-1] = points[order];
    return new BezierCurve(newPoints);
  }

  /**
   * Get all 't' values for which this curve inflects.
   * NOTE: this is an expensive operation!
   */
  float[] getInflections() {
    float[] ret = {};
    ArrayList<Float> t_values = new ArrayList<Float>();
    t_values.add(0.0);
    t_values.add(1.0);
    float[] roots;
    // get first derivative roots
    roots = comp.findAllRoots(1, x_values);
    for(float t: roots) { if(0 < t && t < 1) { t_values.add(t); }}
    roots = comp.findAllRoots(1, y_values);
    for(float t: roots) { if(0 < t && t < 1) { t_values.add(t); }}
    // get second derivative roots
    if(order>2) {
      roots = comp.findAllRoots(2, x_values);
      for(float t: roots) { if(0 < t && t < 1) { t_values.add(t); }}
      roots = comp.findAllRoots(2, y_values);
      for(float t: roots) { if(0 < t && t < 1) { t_values.add(t); }}
    }
    // sort roots
    ret = new float[t_values.size()];
    for(int i=0; i<ret.length; i++) { ret[i] = t_values.get(i); }
    ret = sort(ret);
    // remove duplicates
    t_values = new ArrayList<Float>();
    for(float f: ret) { if(!t_values.contains(f)) { t_values.add(f); }}
    ret = new float[t_values.size()];
    for(int i=0; i<ret.length; i++) { ret[i] = t_values.get(i); }

    if(ret.length > order+2) {
      String errMsg = "ERROR: getInflections is returning way too many roots";
      if(javascript != null) { javascript.console.log(errMsg); } else { println(errMsg); }
      return new float[0];
    }

    return ret;
  }

  /**
   * Graduate this curve along its normals
   */
  void graduate(float offset, float start, float end) {
    float moveStart = map(start,0,1,offset,0),
          moveEnd =  map(end,0,1,offset,0),
          dx, dy;
    for(int i=0; i<=order; i++) {
      dx = map(ratios[i],0,1,moveStart,moveEnd);
      dy = map(ratios[i],0,1,moveStart,moveEnd);
      dx *= normals[i].x;
      dy *= normals[i].y;
      points[i].x -= dx;
      points[i].y -= dy;
    }
    update();
  }

  /**
   * Offset this curve as a segment, i.e. without chopping it up.
   */
  BezierCurve simpleOffset(float distance) {
    Point[] newPoints = new Point[order+1];
    float x, y;
    for(int i=0; i<=order; i++) {
      x = points[i].x + distance * normals[i].x;
      y = points[i].y + distance * normals[i].y;
      newPoints[i] = new Point(x, y);
    }
    BezierCurve offset = new BezierCurve(newPoints);
    return offset;
  }

  /**
   * Offset the entire curve by some distance, by
   * segmenting it based on inflection points, and
   * then simpleOffsetting those segments along
   * the segment normals.
   */
  BezierCurve[] offset(float distance) {
    // Step 1: split up the curve along inflections (this can be cached)
    float[] inflections = align().getInflections();
    ArrayList<BezierCurve> slices = new ArrayList<BezierCurve>();
    for(int i=0, L=inflections.length-1; i<L; i++) {
      slices.add(split(inflections[i], inflections[i+1]));
    }

    // Step 2: offset the generated segments
    ArrayList<BezierCurve> segments = new ArrayList<BezierCurve>();
    BezierCurve slice, segment;
    for(int b=0; b<slices.size(); b++) {
      slice = slices.get(b);
      segment = slice.simpleOffset(distance);
      // Is this segment not adequately curved to act as
      // an offset segment, or did we generate a segment
      // that is actually unbiased? Then generate better
      // segments.
      if(segment.getScaleAngle() > PI/2 || !segment.isBiased()) {
        BezierCurve[] retried = slice.split(0.5);
        segment = retried[0].simpleOffset(distance);
        segments.add(segment);
        segment = retried[1].simpleOffset(distance);
        segments.add(segment);
      } else { segments.add(segment);}
    }

    // Step 3: convert the arraylist to an array, and return
    BezierCurve[] offsetCurve = new BezierCurve[segments.size()];
    for(int b=0; b<segments.size(); b++) {
      offsetCurve[b] = segments.get(b);
      if(b>0 && !simplifiedFunctions) {
        // We used estimations for the control-projections,
        // so the start and end normals may in fact be wrong.
        correctIfNeeded(offsetCurve[b-1], offsetCurve[b]); }}

    // and we're done!
    return offsetCurve;
  }

  /**
   * When offsetting curves, it's possible that on strong
   * curvatures the normals for start and end points of
   * adjacent segments do not line up. In those cases, we
   * need to rotate the normals, which means moving the
   * control points, to ensure a continuously differentiable
   * polybezier.
   */
  void correctIfNeeded(BezierCurve prev, BezierCurve next) {
    float p2 = PI/2;
    Point n1 = prev.getNormal(1),
          n2 = next.getNormal(0),
          n2p = new Point(n2.x*cos(p2)-n2.y*sin(p2), n2.x*sin(p2)+n2.y*cos(p2));
    float diff = acos(n1.x*n2.x + n1.y*n2.y),
          sign = (acos(n1.x*n2p.x + n1.y*n2p.y) < p2 ? 1 : -1);
    // If the angle between the two normals can be resolved,
    // do so. Otherwise --if it's too big-- leave it be. It'll
    // be in an inside-curve, and thus occluded.
    if(diff>PI/20 && diff<PI/2) {
      prev.points[order-1].rotateOver(prev.points[order], -sign * diff/2);
      prev.update();
      next.points[1].rotateOver(next.points[0], sign * diff/2);
      next.update();
    }
  }

  /**
   * return the approximate 't' that the mouse
   * is near. If no approximate value can be found,
   * return -1, which is an impossible value.
   */
  float over(float mx, float my) {
    float r = (float)(LUT_resolution-1);
    for(int idx=0; idx<LUT_resolution; idx++) {
      if(abs(LUT_x[idx] - mx) < 5 && abs(LUT_y[idx] - my) < 5) {
        return idx/r;
      }
    }
    return -1;
  }

  /**
   * return the point we are over, if we're over a point
   */
  int overPoint(float mx, float my) {
    Point p;
    for(int i=0, last=order+1; i<last; i++) {
      p = points[i];
      if(abs(p.x-mx) < 5 && abs(p.y-my) < 5) {
        return i;
      }
    }
    return -1;
  }

  /**
   * Move a curve point
   */
  void movePoint(int idx, float nx, float ny) {
    Point p = points[idx];
    p.x = nx;
    p.y = ny;
    update();
  }

  /**
   * draw this curve
   */
  void draw() {
    if(showAdditionals && showPointPoly) {
      stroke(0,100);
      for(int i=1; i<=order; i++) {
        Point p1 = points[i-1];
        Point p2 = points[i];
        line(p1.x,p1.y,p2.x,p2.y);
      }
    }
    stroke(30);
    float t=0;
    int nx, ny, ox = draw_x[0], oy = draw_y[0];
    for(int idx=0; idx<LUT_resolution; idx++) {
      nx = draw_x[idx];
      ny = draw_y[idx];
      if(nx==ox && ny==oy) continue;
      if(drawConnected) { line(ox,oy,nx,ny); }
      else { point(nx, ny); }
      ox=nx;
      oy=ny;
    }
    if(showAdditionals) {
      for(int i=0; i<=order; i++) {
        stroke(0,0,200);
        Point p = points[i];
        if(i==0 || i==order) {
          fill(0,0,255);
          p.draw("p"+(i+1)+": ");
        } else {
          noFill();
          if(showControlPoints) { p.draw("p"+(i+1)+": "); }
        }
      }
    }
  }

  String toString() {
    String ret = "B"+order+": ";
    for(int i=0; i<points.length; i++) {
      ret += points[i].toString();
      if(i<order) ret += ", ";
    }
    return ret;
  }
}

