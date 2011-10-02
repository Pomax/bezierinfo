/**
 * Find the convex hull for an arbitrary collection of points
 */
class ConvexHull
{
  /**
   * First algorithm: Jarvis' March - this is a simple but slow algorithm
   * that forms edges, and then checks that every point left is 
   * on the same side. If a point is found on the wronng side, the
   * edge is broken and a new edge to that point is formed instead.
   */
  Point[] jarvisMarch(ArrayList pointset, double minx, double miny)
  {
    int pslen = pointset.size();
    if(pslen<2) return new Point[0];

    ArrayList path = new ArrayList();
    // we need a virtual "first" point to
    // act as initial reference
    Point virtual = new Point(minx, miny);
    boolean vused = true;
    path.add(virtual);
    Point first = (Point)pointset.get(0);
    path.add(first);

    // finding the first hull point is simpler
    // than finding subsequent hull points
    for(int s=1; s<pslen; s++) {
      Point p = (Point)pointset.get(s);
      if(p.equals(first)) continue;
      if(aboveEdge(virtual, first, p)) {
        path.set(1, p);
        first=p; }}

    // finding hull points is based on the convex property:
    // the bigger the angle to the next point, the better.
    for(int point = 0; point<pslen; point++) {
      if(vused && path.size()>2) { path.remove(0); vused=false; }
      Point ref = vused ? virtual : (Point)path.get(path.size()-2);
      Point last = (Point)path.get(path.size()-1);
      Point provisional = (Point)pointset.get(point);
      if(path.contains(provisional)) { continue; }

      // add the provisional point
      int setpos = path.size();
      path.add(provisional);
      double angle_to_provisional = angleTo(ref, last, provisional);

      // is there a better point?
      for(int s=0; s<pslen; s++) {
        Point test = (Point)pointset.get(s);
        // this point may not already be in the path, unless it's the first point (for closing)
        if(!test.equals(first) && path.contains(test)) { continue; }
        // if the angle to this point is bigger than the angle
        // to the provisional point, this point is better
        double angle_to_test = angleTo(ref, last, test);
        if(angle_to_test > angle_to_provisional) {
          path.set(setpos, test);
          provisional = test;
          angle_to_provisional = angle_to_test;
          point=0; }}

      // if the best candidate was the first point,
      // we found our convex hull
      if(provisional.equals(first)) {
        path.remove(path.size()-1);
        break; }
    }

    // the result is a convex polygon that encloses all pointset in the set.
    Point[] hull = new Point[path.size()];
    for(int p=0; p<hull.length; p++) {
      hull[p] = (Point)path.get(p); }
    return hull;
  }
  
  /**
   * test whether the point 'test' is above the edge {start,end},
   * when we apply T/R so that start is 0/0 and end is x/0
   * we can take a lot of shortcuts in this method, because
   * the only important bit is whether test.y is positive or 
   * negative after translation/rotation.
   */
  boolean aboveEdge(Point s, Point e, Point t)
  {
    double tx = t.x - s.x;
    double ty = t.y - s.y;
    double angle = -getDirection(e.x-s.x, e.y-s.y);
    double height = tx * sin(angle) + ty * cos(angle);
    return (height > 0);
  }
  
  /**
   * get the angle between {start,end} and {end,point}
   */
  double angleTo(Point s, Point e, Point t)
  {
    // vector end->start
    double dx1 = s.x - e.x;
    double dy1 = s.y - e.y;
    // normalise
    double sf = sqrt(dx1*dx1+dy1*dy1);
    dx1 /= sf;
    dy1 /= sf;
    // vector end->test
    double dx2 = t.x - e.x;
    double dy2 = t.y - e.y;
    // normalise
    sf = sqrt(dx2*dx2+dy2*dy2);
    dx2 /= sf;
    dy2 /= sf;
    // angle between the two vectors, in radians
    return Math.acos(dx1*dx2 + dy1*dy2);
  }
}
