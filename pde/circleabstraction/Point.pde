class Point {
  double x, y, s, e, r;
  public Point(double _x, double _y) { x = _x; y = _y; }
}

class Vector extends Point {
  public Vector(double x, double y) { super(x,y); }
}

class Tuple extends Point {
  public Tuple(double x, double y) { super(x,y); }
}