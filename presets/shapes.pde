/***************************************************
 *                                                 *
 *    Preset functions for simple 1x1 sketching    *
 *                                                 *
 ***************************************************/

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
