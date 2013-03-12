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
 * force-update code
 */
void update() {}

/**
 * Actual draw code
 */
void drawFunction() {
  BezierCurve curve = curves.get(0);
  drawCurve(curve);
}
