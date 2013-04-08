/***************************************************
 *                                                 *
 *   Preset functions for simple Poly sketching    *
 *                                                 *
 ***************************************************/

int pvt;
boolean mouseDown = false;
PolyBezierCurve p = new PolyBezierCurve();

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
  BezierCurve curve = curves.get(0);
  p.draw();
  int pt = p.overPoint(mouseX, mouseY);
  cursor(pt==-1 ? ARROW : HAND);
  if(mouseDown != mousePressed) {
    mouseDown = mousePressed;
    pvt = mouseDown ? pt : -1;
  }
  if(pvt!=-1 && mousePressed) {
    movePoint(pvt,mouseX,mouseY);
  }
  if(typeof handleMouseMoved !== "undefined") {
    if(pt==-1) { cursor(CROSS); } else { cursor(HAND); }
    handleMouseMoved(mouseX,mouseY);
  }
}
