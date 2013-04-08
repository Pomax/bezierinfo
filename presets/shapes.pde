/***************************************************
 *                                                 *
 *    Preset functions for simple 1x1 sketching    *
 *                                                 *
 ***************************************************/

PolyBezierCurve p1, p2;
BooleanComputer bcomp;

/**
 * set up the screen
 */
void setupScreen() {
  size(3*dim,dim);
  labels();
  controls();
  additionals();
  noConnect();
}

/**
 *
 */
void setupDefaultShapes() {
  p1 = setupWedge(0,0);
  p2 = setupWedge(0,105);
}

/**
 *
 */
PolyBezierCurve setupWedge(float x, float y) {
  PolyBezierCurve p = new PolyBezierCurve(false);
  p.addCurve(new BezierCurve(new Point[]{  new Point(x+2*pad,y+pad),       new Point(x+3*pad,y+2*pad),         new Point(x+dim-3*pad, y+2*pad), new Point(x+dim-2*pad,y+pad)  }));
  p.addCurve(new BezierCurve(new Point[]{  new Point(x+dim-2*pad,y+pad),   new Point(x+dim, y+2*pad),          new Point(x+dim, y+dim/2-pad),   new Point(x+dim-2*pad,y+dim/2)  }));
  p.addCurve(new BezierCurve(new Point[]{  new Point(x+dim-2*pad,y+dim/2), new Point(x+dim-3*pad,y+dim/2-pad), new Point(x+3*pad,y+dim/2-pad),  new Point(x+2*pad,y+dim/2)  }));
  p.addCurve(new BezierCurve(new Point[]{  new Point(x+pad,y+dim/2),       new Point(x+0, y+dim/2-pad),        new Point(x+0,y+2*pad),          new Point(x+pad,y+pad)  }));
  p.close();
  return p;
}

/**
 * Actual draw code
 */
void drawFunction() {
  BezierCurve curve = curves.get(0);
  bcomp = new BooleanComputer(p1, p2);
  noAdditionals();
  drawShapes();
}
