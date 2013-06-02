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
  BezierCurve curve = null;
  if(curves.size()>0) { curve = curves.get(0); }
  drawCurve(curve);
  if(p1==null) {
    pushStyle();
    fill(255,0,0,25);
    textAlign(CENTER,CENTER);
    textSize(dim/9);
    text("click to place points", width/2, height/2);
    popStyle();
  }
}

boolean mouseDown = false;
Point p1=null, p2=null, p3=null;

/**
 * record a mouseclick
 */
void recordPoint(int mx, int my) {
  if(!mouseDown && mousePressed) {
    mouseDown = true;
    // reset?
    if(p3!=null) { p1=null; p2=null; p3=null; }
    // record point
    if(p1==null) { p1 = new Point(mouseX,mouseY); }
    else if(p2==null) { p2 = new Point(mouseX,mouseY); }
    else if(p3==null) { p3 = new Point(mouseX,mouseY); }
  }
  if(mouseDown && !mousePressed) { mouseDown = false; }
}