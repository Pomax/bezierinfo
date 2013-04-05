/**
 * set up the screen
 */
void setupScreen() {
  size(dim,dim);
}


/**
 * set up our curve
 */
void setupCurve() {
  int d = dim - 2*pad;
  int order = 2;
  ArrayList<Point> pts = new ArrayList<Point>();

  float dst = d/3, nx, ny, a=0, step = 2*PI/(order+1), r;
  for(a=0; a<2*PI; a+=step) {
    r = 0;//random(dst/1);
    pts.add(new Point(d/2 + cos(a) * (r+dst), d/2 + sin(a) * (r+dst)));
    dst -= 1.2;
  }
/*
  pts.add(new Point(120,160));
  pts.add(new Point(35,200));
  pts.add(new Point(215,215));
  pts.add(new Point(110,96));

  Point[] points = new Point[pts.size()];
  for(int p=0,last=points.length; p<last; p++) { points[p] = pts.get(p); }
  curves.add(new BezierCurve(points));
*/
  redrawOnMove();
  
  p.addCurve(new BezierCurve(new Point[]{ new Point(50,50), new Point(50,50), new Point(100,0), new Point (100,0) }));
  p.addCurve(new BezierCurve(new Point[]{ ORIGIN, ORIGIN, new Point(150,50),new Point(150,150) }));
  p.addCurve(new BezierCurve(new Point[]{ ORIGIN, ORIGIN, new Point(100,100),new Point(100,100) }));
  p.addCurve(new BezierCurve(new Point[]{ ORIGIN, ORIGIN, new Point(50,50),new Point(50,50) }));  

  p2.addCurve(new BezierCurve(new Point[]{ new Point(80,50), new Point(80,50), new Point(130,0), new Point (130,0) }));
  p2.addCurve(new BezierCurve(new Point[]{ ORIGIN, ORIGIN, new Point(180,50),new Point(180,150) }));
  p2.addCurve(new BezierCurve(new Point[]{ ORIGIN, ORIGIN, new Point(130,100),new Point(130,100) }));
  p2.addCurve(new BezierCurve(new Point[]{ ORIGIN, ORIGIN, new Point(0,80),new Point(80,50) }));
}

PolyBezierCurve p = new PolyBezierCurve(), p2 = new PolyBezierCurve();

BezierCurve[] offset1, offset2;
int oldOffset = 0;

/**
 * Actual draw code
 */
void drawFunction() {
  translate(30,30);
  
  int m = millis();
  
  BooleanComputer bcomp = new BooleanComputer(p, p2);

//  p.draw();
//  Point p0 = p.segments.get(0).points[0];
//  stroke(0);
//  ellipse(p0.x,p0.y,7,7);

//  p2.draw(color(255,0,0));
//  p0 = p2.segments.get(0).points[0];
//  stroke(255,0,0);
//  ellipse(p0.x,p0.y,7,7);


  for(PolyBezierCurve pbc: bcomp.segments1) { pbc.draw(); }
  for(PolyBezierCurve pbc: bcomp.segments2) { pbc.draw(color(255,0,0)); }

  PolyBezierCurve union = bcomp.getUnion(),
                  intersection = bcomp.getIntersection(),
                  exclusion = bcomp.getExclusion();


  println(millis()-m);

  /*
  int pt = p.overPoint(mouseX, mouseY);
  if(pt!=-1) {
    cursor(HAND);
    if(mousePressed) {
      p.movePoint(pt,mouseX,mouseY);
    } 
  }
  else { cursor(ARROW); }
  */

/*
  BezierCurve curve = curves.get(0);
  curve.draw();

  // the curve
  stroke(0);
  labels();
  controls();
  additionals();
  curve.draw();

  noLabels();
  noControls();
  noAdditionals();

  // the de Casteljau interpolations for [t]
  Point[] span = curve.generateSpan(t);
  if(showSpan) {
    drawSpan(curve, t);
  }
*/

/*
  drawBoundingBox(curve.generateBoundingBox());
  // point on the curve at [t]
  Point p = curve.getPoint(t);
  if(playing) {
    stroke(255,0,0);
    ellipse(p.x, p.y, 5, 5);

    // the curve tangent at point [t]
    Point der = curve.getDerivativePoint(t);
    line(p.x-der.x/2, p.y-der.y/2,
         p.x+der.x/2, p.y+der.y/2);

    // get our A/B/C points (this only works for quadratic/cubic curves)
    Point[] abc = {};
    try {
      float r = comp.calculateProjectionRatio(t, curve.order);
      abc = curve.getABC(t);
      stroke(0,255,255);
      line(abc[1].x,abc[1].y, abc[2].x,abc[2].y);
      float d1 = dist(abc[0].x,abc[0].y, abc[1].x,abc[1].y),
            d2 = dist(abc[1].x,abc[1].y, abc[2].x,abc[2].y),
            dx = abc[2].x - abc[1].x,
            dy = abc[2].y - abc[1].y;
      stroke(255,127,127);
      line(abc[1].x,abc[1].y, abc[1].x - r*dx, abc[1].y - r*dy);
    } catch (NoRatioExistsException e) {}
  }
*/  

/*
  // split the curve into two subcurves at [t]
  BezierCurve[] spl = test.split(t);
  stroke(0);
  line(dim,0,dim,height);
  translate(dim,0);
  stroke(0,0,200);
  spl[0].draw();
  stroke(200,0,200);
  spl[1].draw();
  translate(-dim,0);
*/

/*
  if(offset>0) {
    // offset the curve over some distance
    int offsetDistance = offset,
        normalDistance = offset/2;
    if(offset != oldOffset) {
      offset1 = curve.offset(offsetDistance, 0, 1);
    }
    for(BezierCurve b: offset1) { b.draw(); }
    if(offset != oldOffset) {
      offset2 = curve.offset(-offsetDistance, 0, 1);
      oldOffset = offset;
    }
    for(BezierCurve b: offset2) { b.draw(); }
  }

  if(playing) {
    Point N = curve.getNormal(t);
    stroke(0,0,100);
    line(p.x,p.y,p.x-N.x*offset,p.y-N.y*offset);
  }

  //noLoop();
  println("---"); println(curve.split()[0].getInterval());
  println("---"); println(curve.split()[0].split()[1].getInterval());
  println("---"); println(curve.split()[0].split()[1].split()[0].getInterval());
*/
}

// draw a bounding box
void drawBBox(Point[] p) {
  if(p==null) return;
  line(p[0].x,p[0].y,p[1].x,p[1].y);
  line(p[1].x,p[1].y,p[2].x,p[2].y);
  line(p[2].x,p[2].y,p[3].x,p[3].y);
  line(p[3].x,p[3].y,p[0].x,p[0].y);
}
