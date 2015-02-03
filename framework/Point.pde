/***************************************************
 *                                                 *
 *      A "Point" class, a bit like PVector but    *
 *      with a completely different API.           *
 *                                                 *
 ***************************************************/

// Point class. Utter boilerplate and not interesting.
class Point {
  float x,y,d;
  Point normal = null;

  Point(float x, float y) {
    moveTo(x,y);
  }

  Point(Point o) {
    moveTo(o.x, o.y);
    normal = normalize();
  }

  // scale
  Point scale(float f) {
    return new Point(f*x,f*y);
  }

  // normalize
  Point normalize() {
    return new Point(x/d,y/d);
  }

  // repositioning
  void moveTo(float _x, float _y) { x=_x; y=_y; d=sqrt(x*x+y*y); }
  void moveTo(float _x, float _y, float ratio) { x+=(_x-x)*ratio; y+=(_y-y)*ratio; d=sqrt(x*x+y*y); }
  void moveBy(float _x, float _y) { moveTo(x+_x, y+_y); }

  // rotate this point w.r.t. another point
  Point rotateOver(Point o, float angle) {
    float nx = x-o.x, ny = y-o.y,
          mx = nx*cos(angle) - ny*sin(angle),
          my = nx*sin(angle) + ny*cos(angle);
    moveTo(mx+o.x,my+o.y);
    return this;
  }

  // reflect a point through this point
  Point reflect(Point original) {
    return new Point(2*x - original.x, 2*y - original.y);
  }

  // does this point coincide with coordinate mx/my?
  boolean over(float mx, float my) {
    return abs(mx-x)<5&&abs(my-y)<5;
  }

  // ye olde tostringe
  String toString() { return x+"/"+y+(normal!=null ? " (normal: "+normal.toString()+")" : ""); }

  // point draw functions
  void draw() { ellipse(x,y,3,3); }
  void draw(String label) {
    draw();
    if(showLabels) {
      fill(0);
      text(label+"("+(int)x+","+(int)y+")",x+10,y);
      noFill();
    }
  }
}

