final int w = 400, h = 400, p=40, p2=2*p;
float[] c;

void setup() {
  size(2*w,h*2);
  setupCurve();
  noLoop();
}

void setupCurve() {
  c = new float[]{
    p+random(w-p2), p+random(h-p2)
   ,p+random(w-p2), p+random(h-p2)
   ,p+random(w-p2), p+random(h-p2)
   ,p+random(w-p2), p+random(h-p2)
  };
}

void draw() {
  background(255);
  noFill();
  stroke(0);

  drawCatmullAsBezier();
  drawBezierAsCatmull();
}

void drawCatmullAsBezier() {
  beginShape();
  curveVertex(c[0],c[1]);
  curveVertex(c[2],c[3]);
  curveVertex(c[4],c[5]);
  curveVertex(c[6],c[7]);
  endShape();
 
  ellipse(c[0],c[1],3,3);
  ellipse(c[2],c[3],5,5);
  ellipse(c[4],c[5],5,5);
  ellipse(c[6],c[7],3,3);

  fill(0);
  text("1", c[0]+10,c[1]);
  text("2", c[2]+10,c[3]);
  text("3", c[4]+10,c[5]);
  text("4", c[6]+10,c[7]);
  noFill();
  
  stroke(0,50);
  translate(c[2]-c[4], c[3]-c[5]);
  line(c[0],c[1],c[4],c[5]);
  ellipse(c[0],c[1],9,9);
  resetMatrix();
  translate(c[4]-c[2], c[5]-c[3]);
  line(c[2],c[3],c[6],c[7]);
  ellipse(c[6],c[7],9,9);

  resetMatrix();
  translate(w,0);
  stroke(0);
  line(0,0,0,h);
  
  float[] b = {
    c[2],
    c[3],
    c[2] + (c[4] - c[0])/6.0,
    c[3] + (c[5] - c[1])/6.0, 
    c[4] - (c[6] - c[2])/6.0,
    c[5] - (c[7] - c[3])/6.0,
    c[4],
    c[5] 
  };
  stroke(0,0,100);
  bezier(b[0],b[1],b[2],b[3],b[4],b[5],b[6],b[7]);

  stroke(127);
  line(b[0],b[1],b[2],b[3]);
  line(b[4],b[5],b[6],b[7]);
  
  ellipse(b[0],b[1],5,5);
  ellipse(b[2],b[3],3,3);
  ellipse(b[4],b[5],3,3);
  ellipse(b[6],b[7],5,5);  
  
  fill(0,0,100);
  text("1", b[0]+10,b[1]);
  text("2", b[2]+10,b[3]);
  text("3", b[4]+10,b[5]);
  text("4", b[6]+10,b[7]);
  noFill();
}

void drawBezierAsCatmull() {
  resetMatrix();
  translate(0,h);
  stroke(0);  
  bezier(c[0],c[1],c[2],c[3],c[4],c[5],c[6],c[7]);

  stroke(127);
  line(c[0],c[1],c[2],c[3]);
  line(c[4],c[5],c[6],c[7]);
  
  ellipse(c[0],c[1],5,5);
  ellipse(c[2],c[3],3,3);
  ellipse(c[4],c[5],3,3);
  ellipse(c[6],c[7],5,5);  
  
  fill(0,0,100);
  text("1", c[0]+10,c[1]);
  text("2", c[2]+10,c[3]);
  text("3", c[4]+10,c[5]);
  text("4", c[6]+10,c[7]);
  noFill();
 
  resetMatrix();
  translate(w,h);
  stroke(0);
  line(-w,0,2*w,0);
  line(-w,3,2*w,3);
  line(0,0,0,h);

  float[] b = {
    c[6] + (c[0] - c[2])*6,
    c[7] + (c[1] - c[3])*6,
    c[0],
    c[1],
    c[6],
    c[7],
    c[0] + (c[6] - c[4])*6,
    c[1] + (c[7] - c[5])*6
  };
  stroke(0,0,100);

  beginShape();
  curveVertex(b[0],b[1]);
  curveVertex(b[2],b[3]);
  curveVertex(b[4],b[5]);
  curveVertex(b[6],b[7]);
  endShape();
 
  ellipse(b[0],b[1],3,3);
  ellipse(b[2],b[3],5,5);
  ellipse(b[4],b[5],5,5);
  ellipse(b[6],b[7],3,3);

  fill(0);
  text("1", b[0]+10,b[1]);
  text("2", b[2]+10,b[3]);
  text("3", b[4]+10,b[5]);
  text("4", b[6]+10,b[7]);
  noFill();
  
  stroke(0,50);
  translate(b[2]-b[4], b[3]-b[5]);
  line(b[0],b[1],b[4],b[5]);
  ellipse(b[0],b[1],9,9);
  resetMatrix();
  translate(w,h);  
  translate(b[4]-b[2], b[5]-b[3]);
  line(b[2],b[3],b[6],b[7]);
  ellipse(b[6],b[7],9,9);  
}

void mousePressed() {
  setupCurve();
  redraw();
}
