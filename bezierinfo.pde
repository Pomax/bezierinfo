void setupScreen() {
  size(dim,dim);
}

void setupCurve() {
  setupDefaultCubic();
}

void drawFunction() {
  test();

  BezierCurve c = curves.get(0);
  c.draw();
  float[] inflections = c.getInflections();
  Point p;
  for(float t: inflections) {
    p = c.getPoint(t);
    ellipse(p.x,p.y,5,5);
  }
  drawBoundingBox(c.generateBoundingBox());
  drawOffset(c, 10);
}
