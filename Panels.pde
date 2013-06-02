int panelDim = dim;

/**
 * pad the sketch translation
 */
void usePanelPadding() {
  translate(pad, pad);
  panelDim = dim - 2*pad;
}

/**
 * switch drawing over to the next dim*dim area
 */
void nextPanel() {
  translate(dim,0);
}

// draws a set of labeled axes
void drawAxes(String horizontalLabel, float hs, float he, String verticalLabel, float vs, float ve) {
  pushStyle();
  stroke(0);
  line(0,0,panelDim,0);
  line(0,0,0,panelDim);
  fill(0);
  // horizontal
  textAlign(CENTER);
  text(horizontalLabel + " →",panelDim/2,-8);
  textAlign(LEFT);
  hs = int(1000*hs)/1000;
  text(""+hs,0,-2);
  textAlign(RIGHT);
  he = int(1000*he)/1000;
  text(""+he,panelDim,-2);
  // vertical
  textAlign(RIGHT);
  text(verticalLabel + "\n↓",-8,panelDim/2);
  textAlign(RIGHT,TOP);
  vs = int(1000*vs)/1000;
  text(""+vs,-2,0);
  textAlign(RIGHT,BOTTOM);
  ve = int(1000*ve)/1000;
  text(""+ve,-2,panelDim);
  // clear
  popStyle();
}
