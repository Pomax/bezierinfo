void drawCurve() {
  bezier(
    p1.x, p1.y,
    p2.x, p2.y,
    p3.x, p3.y,
    p4.x, p4.y
  );
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

void drawCircle(Point i, Point p1, Point p2, Point p3) {
  stroke(0);
  ellipse(p1.x, p1.y, 5, 5);
  ellipse(p2.x, p2.y, 5, 5);
  ellipse(p3.x, p3.y, 5, 5);
  stroke(0,255,0);
  ellipse(i.x, i.y, 5, 5);
  double rx = p1.x - i.x,
         ry = p1.y - i.y,
         r = sqrt(rx*rx+ry*ry);
  ellipse(i.x, i.y, 2*r, 2*r);
  stroke(255,0,0);
  if(badarc) { fill(255,0,0,20); } else { fill(0,0,200,20); }
  arc(i.x, i.y, 2*r, 2*r, i.s, i.e);
}