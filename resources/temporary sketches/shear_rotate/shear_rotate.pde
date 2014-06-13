final int w = 300;
float a = 0;
int d, d2;

void setup() {
  size(4*w,300);
  d2 = w >> 2;
  d = d2 >> 1;
  noStroke();
  background(255);
}

void draw() { 
  a += random(0,0.04);
  if(a>2*PI) { a = 0; }

  fill(255,10);
  rect(-1,-1,width+2,height+2);

  float x1 = -d,
        x2 = -d,
        x3 = d,
        x4 = d,
        y1 = -d,
        y2 = d,
        y3 = d,
        y4 = -d;

  resetMatrix();

  translate(d2,height/2);
  stroke(0,30);
  noFill();
  if(a==0) {
    stroke(0,180,230);
    strokeWeight(5);
  }
  rect(-d,-d,2*d,2*d);
  translate(w,0);
  rect(-d,-d,2*d,2*d);
  translate(w,0);
  rect(-d,-d,2*d,2*d);
  translate(w,0);
  rect(-d,-d,2*d,2*d);
  strokeWeight(1);
  noStroke();

  resetMatrix();

  translate(d2,height/2);
  fill(255,0,0);
  ellipse(x1,y1,9,9);
  fill(0,255,0);
  ellipse(x2,y2,9,9);
  fill(0,0,255);
  ellipse(x3,y3,9,9);
  fill(255,255,0);
  ellipse(x4,y4,9,9);

  float ny1 = y1 + tan(a/2) * x1,
        ny2 = y2 + tan(a/2) * x2,
        ny3 = y3 + tan(a/2) * x3,
        ny4 = y4 + tan(a/2) * x4;
 
  translate(w,0);
  stroke(0);
  line(-w/2,-150,-w/2,150);
  noStroke();

  fill(255,0,0);
  ellipse(x1,ny1,9,9);
  fill(0,255,0);
  ellipse(x2,ny2,9,9);
  fill(0,0,255);
  ellipse(x3,ny3,9,9);
  fill(255,255,0);
  ellipse(x4,ny4,9,9);

  float nx1 = x1 - sin(a) * ny1,
        nx2 = x2 - sin(a) * ny2,
        nx3 = x3 - sin(a) * ny3,
        nx4 = x4 - sin(a) * ny4;

  translate(w,0);
  stroke(0);
  line(-w/2,-150,-w/2,150);
  noStroke();

  fill(255,0,0);
  ellipse(nx1,ny1,9,9);
  fill(0,255,0);
  ellipse(nx2,ny2,9,9);
  fill(0,0,255);
  ellipse(nx3,ny3,9,9);
  fill(255,255,0);
  ellipse(nx4,ny4,9,9);

  float n2y1 = ny1 + tan(a/2) * nx1,
        n2y2 = ny2 + tan(a/2) * nx2,
        n2y3 = ny3 + tan(a/2) * nx3,
        n2y4 = ny4 + tan(a/2) * nx4;
 
  translate(w,0);
  stroke(0);
  line(-w/2,-150,-w/2,150);
  noStroke();

  fill(255,0,0);
  ellipse(nx1,n2y1,9,9);
  fill(0,255,0);
  ellipse(nx2,n2y2,9,9);
  fill(0,0,255);
  ellipse(nx3,n2y3,9,9);
  fill(255,255,0);
  ellipse(nx4,n2y4,9,9);
}
