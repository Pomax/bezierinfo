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
  drawCurve(curve);
}

Point B = null;
Point[] tangents = null;
float Bt = -1;


/**
 * draw curve and if there is a mould point, that too
 */
void drawCurve(BezierCurve curve) {
  curve.draw();
  if(Bt!=-1) {
    Point p = curve.getPoint(Bt);
    ellipse(p.x,p.y,5,5);
  }
}

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