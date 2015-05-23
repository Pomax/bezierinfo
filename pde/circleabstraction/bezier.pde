Point get(double t) {
  return new Point( getX(t), getY(t) );
}

double getX(double t) {
  return get(t, p1.x, p2.x, p3.x, p4.x);
}

double getY(double t) {
  return get(t, p1.y, p2.y, p3.y, p4.y);
}

double get(double t, double a, double b, double c, double d) {
  double mt = 1-t,
         mt2 = mt * mt,
         mt3 = mt2 * mt,
         t2 = t * t,
         t3 = t2 * t,
         v1 = mt3 * a,
         v2 = mt2 * t * 3 * b,
         v3 = mt * t2 * 3 * c,
         v4 = t3 * d;
  return v1 + v2 + v3 + v4;
}