/***************************************************
 *                                                 *
 *    Preset functions for simple 2x1 sketching    *
 *                                                 *
 ***************************************************/

/**
 * set up the screen
 */
void setupScreen() {
  size(2*dim,dim);
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
