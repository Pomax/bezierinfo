/**
 * set up the screen
 */
void setupScreen() {
  size(dim,dim);
  labels();
  controls();
  additionals();
  noConnect();
}

/**
 * Actual draw code
 */
void drawFunction() {
  BezierCurve curve = curves.get(0);
  curve.draw();
  if(Bt!=-1) {
    Point p = curve.getPoint(Bt);
    ellipse(p.x,p.y,5,5);
    stroke(0,0,200);
    line(curve.points[0].x,curve.points[0].y,curve.points[curve.order].x,curve.points[curve.order].y);
    drawSpan(curve, Bt);
    Point[] abc = curve.getABC(Bt);
    stroke(255,0,0);
    line(abc[0].x,abc[0].y,abc[1].x,abc[1].y);
    stroke(0,255,255);
    line(abc[2].x,abc[2].y,abc[1].x,abc[1].y);
  }
}

Point B = null;
Point[] tangents = null;
float Bt = -1;

/**
 * indicate we can move the curve
 */
boolean testCurveMoulding(BezierCurve curve, int mx, int my) {
  if(curve.over(mx,my) != -1) {
    cursor(HAND);
    return true;
  }
  clear();
  return false;
}

/**
 * mark moulding start
 */
void startCurveMoulding(BezierCurve curve, float t) {
  B = curve.getPoint(t);
  tangents = curve.getSpanLines(t);
  Bt = t;
}

/**
 * mark moulding end
 */
void endCurveMoulding(BezierCurve curve) {
  clear();
}

void clear() {
  B = null;
  tanget = null;
  Bt = -1;
}