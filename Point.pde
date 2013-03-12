// Point class. Utter boilerplate and not interesting.
class Point {
  float x,y,d;
  Point normal = null;
  Point(float x, float y) { moveTo(x,y); }
  Point(Point o) {
    x = o.x;
    y = o.y;
    normal = o.normal;
  }
  Point times(float f) { return new Point(f*x,f*y); }
  Point normalize() { return new Point(x/d,y/d); }
  void moveTo(float _x, float _y) { x=_x; y=_y; d=sqrt(x*x+y*y); }
  void moveBy(float _x, float _y) { moveTo(x+_x, y+_y); }
  void rotateOver(Point o, float angle) {
    float nx = x-o.x, ny = y-o.y,
          mx = nx*cos(angle) - ny*sin(angle),
          my = nx*sin(angle) + ny*cos(angle);
    moveTo(mx+o.x,my+o.y);    
  }
  boolean over(float mx, float my) { return abs(mx-x)<5&&abs(my-y)<5; }
  String toString() { return x+"/"+y+(normal!=null ? " (normal: "+normal.toString()+")" : ""); }
  void draw() { ellipse(x,y,3,3); }
  void draw(String label) {
    draw();
    if(showLabels) {
      fill(0);
      text(label+(int)x+"/"+(int)y,x+10,y);
      noFill();
    } 
  }  
}
