Point getCCenter(Point p1, Point p2, Point p3) {
  // deltas
  double dx1 = (p2.x - p1.x),
         dy1 = (p2.y - p1.y),
         dx2 = (p3.x - p2.x),
         dy2 = (p3.y - p2.y);

  // perpendiculars (quarter circle turned)
  double dx1p = dx1 * cos(PI/2) - dy1 * sin(PI/2),
         dy1p = dx1 * sin(PI/2) + dy1 * cos(PI/2),
         dx2p = dx2 * cos(PI/2) - dy2 * sin(PI/2),
         dy2p = dx2 * sin(PI/2) + dy2 * cos(PI/2);
  
  // chord midpoints
  double mx1 = (p1.x + p2.x)/2,
         my1 = (p1.y + p2.y)/2,
         mx2 = (p2.x + p3.x)/2,
         my2 = (p2.y + p3.y)/2;
  
  // midpoint offsets
  double mx1n = mx1 + dx1p,
         my1n = my1 + dy1p,
         mx2n = mx2 + dx2p,
         my2n = my2 + dy2p;
  
  // intersection of these lines:
  Point i = lli(mx1,my1,mx1n,my1n, mx2,my2,mx2n,my2n);
  double r = dist(i,p1);
  
  // arc start/end values, over mid point
  double s = atan2(p1.y - i.y, p1.x - i.x),
         m = atan2(p2.y - i.y, p2.x - i.x),
         e = atan2(p3.y - i.y, p3.x - i.x);

  // determine arc direction (cw/ccw correction)
  double _;
  if (s<e) {
    // if s<m<e, arc(s,e)
    // if m<s<e, arc(e,s+tau)
    // if s<e<m, arc(e,s+tau)
    if (s>m || m>e) { s += TAU; }
    if (s>e) { _=e; e=s; s=_; }
  } else {
    // if e<m<s, arc(e,s)
    // if m<e<s, arc(s,e+tau)
    // if e<s<m, arc(s,e+tau)
    if (e<m && m<s) { _=e; e=s; s=_; } else { e += TAU; }
  }
  
  // assign and done.
  i.s = s;
  i.e = e;
  i.r = r;
  return i;
}

double signedAngle(double v1x, double v1y, double v2x, double v2y) {
  double dot = v1x * v2x + v1y * v2y;
  double perpDot = v1x * v2y - v1y * v2x;
  return atan2(perpDot, dot);
}

Point lli(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) {
  double nx=(x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4),
         ny=(x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4),
         d=(x1-x2)*(y3-y4)-(y1-y2)*(x3-x4);
  if(d==0) { return null; }
  return new Point(nx/d, ny/d);
}