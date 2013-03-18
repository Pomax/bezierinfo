/***************************************************
 *                                                 *
 *   Preset functions for showing curve weights    *
 *                                                 *
 ***************************************************/

void setupScreen() {
  size(dim,dim);
  labels();
  controls();
  additionals();
  noConnect();
}

void setupCurve() {
  float d = dim-2*pad;
  for(int i = 0; i < order; i++) {
    Point[] points = new Point[order];
    for(int j = 0; j < order; j++) {
      points[j] = new Point(d*j/(order-1),(i==j ? d : 0));
    }
    curves.add(new BezierCurve(points));
  }
  textAlign(CENTER,CENTER);
}

void drawFunction() {
  usePanelPadding();
  translate(5,0);
  noAdditionals();
  connect();

  float t = map(mouseX-pad, 0,panelDim, 0,1);

  if(0<=t && t<=1) {
    noStroke();
    fill(255,0,0,30);
    rect(mouseX-5-pad,0,10,panelDim);
    fill(255,0,0,80);
    text("t ≈ "+int(100*t)/100, mouseX-pad, panelDim+10); }

  for(int i=0; i<curves.size(); i++) {
    BezierCurve c = curves.get(i);
    color col = getColor(i);
    c.draw(col);
    fill(col);
    Point p = c.getPoint(i/(order-1)),
          n = c.getNormal(i/(order-1));
    text("P"+(i+1),p.x+n.x*-15,p.y+n.y*15);

    if(0<=t && t<=1) {
      Point p = c.getPoint(t);
      ellipse(p.x,p.y,5,5);
      text(int(map(p.y,0,panelDim,0,100))+"%",p.x+pad,p.y); }
  }

  drawAxes("t",0,1, "S",0,1);
}