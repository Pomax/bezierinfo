class Mark {
  Point p;
  double ratio;
  double t, s, e;
  public Mark(Point _p, double _ratio, double _t) {
    p = _p;
    ratio = _ratio;
    t = _t;
  }
  public Mark(Point _p, double _s, double _e, boolean test) {
    p = _p;
    s = _s;
    e = _e;
  }
}