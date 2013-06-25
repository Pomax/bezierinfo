/***************************************************
 *                                                 *
 *   Preset functions for simple Poly sketching    *
 *                                                 *
 ***************************************************/

int pvt;
boolean mouseDown = false;

/**
 * set up the screen
 */
void setupScreen() {
  size(dim,dim);
  labels();
  controls();
  additionals();
  noConnect();
  redrawOnMove();
  noLabels();
}

/**
 * Actual draw code
 */
void drawFunction() {
  PolyBezierCurve p = polycurves.get(0);
  p.draw();
  int pt = p.overPoint(mouseX, mouseY);
  cursor(pt==-1 ? ARROW : HAND);
  if(mouseDown != mousePressed) {
    mouseDown = mousePressed;
    pvt = mouseDown ? pt : -1;
  }
  if(pvt!=-1 && mousePressed) {
    movePoint(p, pvt, mouseX, mouseY);
  }
  if(javascript != null) {
    javascript.handleMouseMoved(sketch, p, mouseX, mouseY);
  }
}
