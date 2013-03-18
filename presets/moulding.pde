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

    pushStyle();
    {
      noStroke();
      fill(240);
      rect(0, dim-15, dim, 15);

      noFill();
      stroke(0);
      ellipse(abc[0].x, abc[0].y, 5, 5);
      ellipse(abc[1].x, abc[1].y, 5, 5);
      ellipse(abc[2].x, abc[2].y, 5, 5);

      fill(0);
      text("A", abc[0].x+10, abc[0].y-10);
      text("B", abc[1].x+10, abc[1].y-10);
      text("C", abc[2].x+10, abc[2].y-10);

      float d1 = dist(abc[0].x, abc[0].y, abc[1].x, abc[1].y),
             d2 = dist(abc[2].x, abc[2].y, abc[1].x, abc[1].y);
      textAlign(LEFT);
      text("A-B: " + int(1000*d1)/1000.0, 10, dim-2);
      textAlign(CENTER);
      text("B-C: " + int(1000*d2)/1000.0, dim/2, dim-2);
      textAlign(RIGHT);
      text("ratio: " + int(1000*(d1/d2))/1000.0, dim-10, dim-2);
    }
    popStyle();
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
  tangents = null;
  Bt = -1;
}