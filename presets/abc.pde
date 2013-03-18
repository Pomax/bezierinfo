/***************************************************
 *                                                 *
 *    Preset functions for showing mould ratios    *
 *                                                 *
 ***************************************************/

float Bt = -1;

/**
 * set up the screen
 */
void setupScreen() {
  size(dim,dim);
  labels();
  controls();
  additionals();
  noConnect();
  mould();
  span();
}

/**
 * Actual draw code
 */
void drawFunction() {
  BezierCurve curve = curves.get(0);
  if(Bt!=-1) { drawSpan(curve, Bt); }
  drawCurve(curve);
}

void startCurveMoulding(BezierCurve curve, float t) { Bt = t; }
void mouldCurve(BezierCurve curve, int mx, int my) {}
void endCurveMoulding(BezierCurve curve) {}
boolean testCurveMoulding(BezierCurve curve, int mx, int my) {
  if(curve.over(mx,my)!=-1) { cursor(HAND); return true; }
  return false; }

void drawABC(BezierCurve curve, Point[] abc) {
  pushStyle();

  noStroke();
  fill(240);
  rect(0, dim-15, dim, 15);

  noFill();
  stroke(0);
  ellipse(abc[1].x, abc[1].y, 5, 5);
  ellipse(abc[2].x, abc[2].y, 5, 5);

  fill(0);
  text("A", abc[0].x+10, abc[0].y-10);
  text("B", abc[1].x+10, abc[1].y-10);
  text("C", abc[2].x+10, abc[2].y-10);

  stroke(255,0,0);
  line(abc[0].x, abc[0].y, abc[1].x, abc[1].y);
  stroke(0,255,0);
  line(abc[2].x, abc[2].y, abc[1].x, abc[1].y);
  stroke(0,0,150,150);
  line(curve.points[0].x, curve.points[0].y, curve.points[curve.order].x, curve.points[curve.order].y);

  float d1 = dist(abc[0].x, abc[0].y, abc[1].x, abc[1].y),
         d2 = dist(abc[2].x, abc[2].y, abc[1].x, abc[1].y);
  textAlign(LEFT);
  text("A-B: " + int(1000*d1)/1000.0, 10, dim-2);
  textAlign(CENTER);
  text("B-C: " + int(1000*d2)/1000.0, dim/2, dim-2);
  textAlign(RIGHT);
  text("ratio: " + int(1000*(d1/d2))/1000.0, dim-10, dim-2);

  popStyle();
}