/***************************************************
 *                                                 *
 *              Sketch framework code              *
 *                                                 *
 ***************************************************/

/**
  Generic main sketch code. All the important bits happen in whatever supplies drawFunction()
**/
BezierComputer comp = new BezierComputer();
BezierComputer getComputer() { return comp; }

ArrayList<BezierCurve> curves = new ArrayList<BezierCurve>();
ArrayList<BezierCurve> getCurves() { return curves; }

ArrayList<PolyBezierCurve> polycurves = new ArrayList<PolyBezierCurve>();
ArrayList<PolyBezierCurve> getPolyCurves() { return polycurves; }

// JS reference
JavaScript javascript = null;

// some default 't' numbers
float t = 0, step = 0.002;
PApplet sketch;

/**
 * set up a curve, and show everything we know about it.
 */
void setup() {
  sketch = this;
  ellipseMode(CENTER);
  // force text engine load (only needed for Processing)
  text("",0,0);
  setupColors();
  noLoop();
  reset();
}

// reset all the things
void reset() {
  // reset values
  curves.clear();
  t = 0;
  step = 0.002;
  // reset methods
  setupScreen();
  noAnimate();
  setupCurve();
  noReset();
}

/**
 * Pass-through that takes care of [t] incrementing
 */
void draw() {
  if(ghosting && frameCount>1) {
    strokeWeight(0);
    fill(255,10);
    rect(-1,-1,width+1,height+1);
    strokeWeight(1);
  } else { background(255); }
  if(playing) { preDraw(); }
  drawFunction();
  if(playing) { postDraw(); }

  // PJS patching
  resetMatrix();

  if(animated && !playing) {
    pushStyle();
    fill(255,0,0,25);
    textAlign(CENTER,CENTER);
    textSize(dim/9);
    text("Animated sketch\nCick to play/pause", width/2, height/2);
    popStyle();
  }
}
