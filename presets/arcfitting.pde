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
  ellipseMode(CENTER);
  redrawOnMove();
}

float order, f=1.5,f2=2*f,mx,my,d,mxn,myn,ax,ay,da,s,e,dx,dy;

/**
 * Actual draw code
 */
void drawFunction() {
  noFill();
  stroke(255,0,0);
  ellipse(dim/2,dim/2,dim/f,dim/f);

  mx = mouseX - dim/2;
  my = mouseY - dim/2;
  d = dist(0,0,mx,my);
  mxn = mx/d;
  myn = my/d;
  ax = acos(mxn);
  ay = asin(myn);
  da = ax-ay;
  if(order==3) {
    s = 0;
    e = (ay > 0 ? ax : 2*PI - ax);
  } else {
    s = (ay > 0 ? 0 : -ax);
    e = (ay > 0 ? ax : 0);
  }
  dx = sin(ax);
  dy = s==0 ? -cos(ax) : cos(ax);

  checkConnect();

  fill(0,255,0,100);
  arc(dim/2,dim/2,dim/f,dim/f, s, e);

  stroke(200);
  line(0,dim/2,dim,dim/2);
  line(dim/2,0,dim/2,dim);

  findArcFitting();
}

/**
 * Draw a guessed curve as a faint-lined shape
 */
void drawGuess(BezierCurve guess) {
  noAdditionals();
  guess.draw(color(150,150,255));
  stroke(150,150,255,100);
  line(guess.points[0].x, guess.points[0].y, guess.points[1].x, guess.points[1].y);
  line(guess.points[1].x, guess.points[1].y, guess.points[2].x, guess.points[2].y);
  line(guess.points[2].x, guess.points[2].y, guess.points[3].x, guess.points[3].y);
  noFill();
  ellipse(guess.points[1].x, guess.points[1].y, 5,5);
  ellipse(guess.points[2].x, guess.points[2].y, 5,5);
  additionals();
}