class Point extends PVector {
  Point(float x, float y) { super(x,y); }
  void draw() { ellipse(x,y,5,5); }
}
 
Point p1, p2, p3, p4;
Point[] bezier = {null,null,null,null};
 
float c = 1.1, d;
float hp = PI * 0.5;
float a1 = 0.70 * TAU;
float a2 = 0.85 * TAU;
float z = 0, zn = z+0.01, tx = 0, ty = 0;
float zoom = 2.0; 

/**
 * Boilerplate
 */
void setup() {
  size(500,500);
  noLoop();
  d = width/1.2;
  ellipseMode(CENTER);
  initialise();
}
 
/**
 * In its own function so we can call it without illegally calling setup()
 */
void initialise() {
  for(int i=0; i<4; i++) {
    bezier[i] = new Point( random(-width,width), random(-height,height) );
  }
}
 

/**
 * Boilerplate - draw curve, then call the interesting functions
 */
void draw() {
  translate(width/2 - tx, height/2 - ty);
  scale(1.0/zoom);
  background(255);
 
  findSegment(z, zn);

  stroke(200);
  line(bezier[0].x, bezier[0].y, bezier[1].x, bezier[1].y);
  line(bezier[2].x, bezier[2].y, bezier[3].x, bezier[3].y);
 
  stroke(0);
  for(float i=0; i<=1; i+=0.001) {
    point(
      getValue(i, bezier[0].x, bezier[1].x, bezier[2].x, bezier[3].x),
      getValue(i, bezier[0].y, bezier[1].y, bezier[2].y, bezier[3].y)
    );
  }
 
  for(int i=0; i<4; i++) { bezier[i].draw(); }
  println("-");
}

/**
 * Try to approximate a segment with a circular arc
 */
void findSegment(float z, float zn) { 
  background(255);
 
  float[][] split = split(z, zn, getListX(bezier), getListY(bezier));
  float[] left = split[0];
  
  stroke(0,127,200);
  for(float i=0; i<=1; i+=0.005) {
    point(
      getValue(i, left[0], left[2], left[4], left[6]),
      getValue(i, left[1], left[3], left[5], left[7])
    );
  }
  
  float x, y, dx, dy, nx, ny, nx2, ny2;
  dx = getDerivativeValue(0, left[0], left[2], left[4], left[6]);
  dy = getDerivativeValue(0, left[1], left[3], left[5], left[7]);
  
  float a = atan2(left[3] - left[1], left[2] - left[0]);
  float t = sqrt(dx*dx + dy*dy);
  println(a + ", " + t);
  
  float cx = left[0] + t * cos(a - PI/2);
  float cy = left[1] + t * sin(a - PI/2);
  Point center = new Point(cx, cy);
  center.draw();
  
  line(left[0],left[1],cx,cy);
  
  if(true) return;
  
  line(bezier[0].x, bezier[0].y, bezier[0].x + dx, bezier[0].y + dy); 
  nx = -dy;
  ny = dx;
  line(left[0], left[1], left[0] + nx, left[1] + ny);
 
  x = getValue(1, left[0], left[2], left[4], left[6]);
  y = getValue(1, left[1], left[3], left[5], left[7]);
  dx = getDerivativeValue(1, left[0], left[2], left[4], left[6]);
  dy = getDerivativeValue(1, left[1], left[3], left[5], left[7]);
  line(x, y, x - dx, y - dy); 
  nx2 = -dy;
  ny2 = dx;
  line(left[6], left[7], left[6] + nx2, left[7] + ny2); 

  Point c = lli(left[0], left[1], left[0] + nx, left[1] + ny, left[6], left[7], left[6] + nx2, left[7] + ny2);
  if(c==null) {
    throw new RuntimeException("DAAAAAA " + left.toString());
  }
  
  findCircleSection(c, left);
}

void findCircleSection(Point c, float[] left) {
  c.draw();
  float cr = dist(c.x, c.y, left[0], left[1]),
        cd = 2 * cr;
  noFill();
  stroke(255,0,0,150);
  ellipse(c.x, c.y, cd, cd);
  
  float a1 = (TAU + atan2(left[1] - c.y, left[0] - c.x)) % TAU,
        a2 = (TAU + atan2(left[7] - c.y, left[6] - c.x)) % TAU;

  fill(0,200,0,150);
  arc(c.x, c.y, cd, cd, a1 > a2 ? a2 : a1, a1 > a2 ? a1 : a2);

  // let's find our
  float cx = cr * cos(a2),
        cy = cr * sin(a2),
        cxh = cr * cos(a1 + (a2-a1)/2),
        cyh = cr * sin(a1 + (a2-a1)/2);

  Point mark = new Point(c.x + cx, c.y + cy);
  Point mid = new Point(c.x + cxh, c.y + cyh);
  Point target = new Point( getValue(1, left[0],left[2],left[4],left[6]), getValue(1, left[1],left[3],left[5],left[7]) );
  Point curveMid = new Point(
    getValue(0.5,left[0],left[2],left[4],left[6]),
    getValue(0.5,left[1],left[3],left[5],left[7])
  );
 
  stroke(200,0,200);
  
  println("angles: " + a1 + "/" + a2);

  line(curveMid.x,curveMid.y,mid.x,mid.y); 
  mid.draw();
  curveMid.draw();
  println("midpoint distance: " + dist(curveMid.x,curveMid.y,mid.x,mid.y)); 

  line(mark.x,mark.y,target.x,target.y); 
  mark.draw(); 
  target.draw();
  println("endpoint distance: " + dist(mark.x,mark.y,target.x,target.y)); 
}
 
/**
 *
 */
void mouseClicked() {
  initialise();
  redraw();
}
 
/**
 *
 */
void keyPressed() {
  if(keyCode == 38) {
    ty -= 10;
  }
  if(keyCode == 40) {
    ty += 10;
  }
  if(keyCode == 37) {
    tx -= 10;
  }
  if(keyCode == 39) {
    tx += 10;
  }
  if(key=='-') {
    z -= 0.01;
    if(z<0) { z = 0; }
  }
  if(key=='+' || key=='=') {
    z += 0.01;
    if(z>1) { z = 1; }
  }
  if(key=='w') {
    zoom /= 2;
  }
  if(key=='s') {
    zoom *= 2;
  }
 
  if(key=='a') {
    zn -= 0.01;
    if(zn < 0.01) { zn = 0.01; }
  }
  if(key=='d') {
    zn += 0.01;
    if(zn > 1) { zn = 1; }
  }
  if(key==' ') {
    initialise();
  }
 
  redraw();
}
 
/**
 *
 */
float[] getListX(Point[] p) {
  float[] l = new float[p.length];
  for(int i=0; i<l.length; i++) {
    l[i] = p[i].x;
  };
  return l;
}
 
/**
 *
 */
float[] getListY(Point[] p) {
  float[] l = new float[p.length];
  for(int i=0; i<l.length; i++) {
    l[i] = p[i].y;
  };
  return l;
}
 
/**
 *
 */
float getValue(float t, float a, float b, float c, float d) {
  float mt = 1-t,
        t2 = t*t,
        mt2 = mt*mt,
        t3 = t2*t,
        mt3 = mt2*mt;
  return a * mt3 + b * 3 * mt2 * t + c * 3 * mt * t2 + d * t3;
}
 
/**
 *
 */
float getDerivativeValue(float t, float a, float b, float c, float d) {
  float mt = 1-t,
        t2 = t*t,
        mt2 = mt*mt;
  return -3 * (a * (t-1) * (t-1)  + b * (-3 * t*t + 4*t - 1) + t * (3 * c * t - 2 * c - d * t));
}

/**
 *
 */
float[][] split(float z, float[] x, float[] y) {
  float cz = z-1,
        z2 = z*z,
        cz2 = cz*cz,
        z3 = z2*z,
        cz3 = cz2*cz;
 
  float[] left = {
    x[0],
    y[0],
    z*x[1] - cz*x[0], 
    z*y[1] - cz*y[0], 
    z2*x[2] - 2*z*cz*x[1] + cz2*x[0],
    z2*y[2] - 2*z*cz*y[1] + cz2*y[0],
    z3*x[3] - 3*z2*cz*x[2] + 3*z*cz2*x[1] - cz3*x[0],
    z3*y[3] - 3*z2*cz*y[2] + 3*z*cz2*y[1] - cz3*y[0]
  };
 
  float[] right = {
    z3*x[3] - 3*z2*cz*x[2] + 3*z*cz2*x[1] - cz3*x[0],
    z3*y[3] - 3*z2*cz*y[2] + 3*z*cz2*y[1] - cz3*y[0],
                    z2*x[3] - 2*z*cz*x[2] + cz2*x[1],
                    z2*y[3] - 2*z*cz*y[2] + cz2*y[1],
                                    z*x[3] - cz*x[2], 
                                    z*y[3] - cz*y[2], 
                                                x[3],
                                                y[3]
  };
 
  return new float[][]{left, right};
}

/**
 *
 */
float[][] split(float z, float z2, float[] x, float[] y) {
  float[][] lr = split(z, x, y);
  float[]    r = lr[1];
  return split(z2, new float[]{r[0],r[2],r[4],r[6]}, new float[]{r[1],r[3],r[5],r[7]});
}
 
/**
 * line/line intersection function. Mostly boilerplate.
 */
public Point lli(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  float nx=(x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4),
        ny=(x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4),
        d=(x1-x2)*(y3-y4)-(y1-y2)*(x3-x4);
  if(d==0) { return null; }
  return new Point(nx/d, ny/d);
}


