void drawCurve() {
  noFill();
  strokeWeight(10);
  stroke(0,90);
  bezier(
    p1.x, p1.y,
    p2.x, p2.y,
    p3.x, p3.y,
    p4.x, p4.y
  );
  strokeWeight(1);
}

void drawCircle(Point c) {
  stroke(0,255,0);
  noFill();
  ellipse(c.x, c.y, 5, 5);
  // ellipse(c.x, c.y, 2*c.r, 2*c.r);
  stroke(255,0,0);
  fill(0,0,0,20);
  arc(c.x, c.y, 2*c.r, 2*c.r, c.s, c.e);
}