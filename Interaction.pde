/***************************************************
 *                                                 *
 *      Mouse and keyboard interaction code        *
 *                                                 *
 ***************************************************/

// Runs before drawFunction is called,
// if this is an animate sketch.
void preDraw() {
  if(t>1) {
    t = 0;
  }
}

// Runs after drawFunction is called,
// if this is an animate sketch.
void postDraw() {
  t += step;
}

BezierCurve active = null;
int current = -1,
    offset = 0;


// curve interaction based on mouse movement alone
void mouseMoved() {
  for(BezierCurve curve: curves) {
    int p = curve.overPoint(mouseX, mouseY);
    current = p;
    if(p != -1) {
      active = curve;
      cursor(HAND);
      return;
    }
    if(moulding) {
      if(testCurveMoulding(curve, mouseX, mouseY)) {
        return;
      }
    }
  }
  cursor(ARROW);
  current = -1;
}

// point/curve dragging
void mouseDragged() {
  if(current != -1) {
    active.movePoint(current, mouseX, mouseY);
  }
  if(moulding) {
    for(BezierCurve curve: curves) {
      mouldCurve(curve, mouseX, mouseY);
    }
  }
  if(!animated || !playing) redraw();
}

// playback control
void mouseClicked() {
  if(resetAllowed) { reset(); }
  if(animated) {
    if(playing) { pause(); }
    else { play(); }
  }
}

// selection using the mouse
void mousePressed() {
  if(moulding && current==-1) {
    for(BezierCurve curve: curves) {
      float t = curve.over(mouseX, mouseY);
      if(t != -1) {
        startCurveMoulding(curve, t);
      }
    }
    if(!animated || !playing) redraw();
  }
}

// end-of-interaction trigger
void mouseReleased() {
  current = -1;
  active = null;
  if(moulding) {
    for(BezierCurve curve: curves) {
      endCurveMoulding(curve);
    }
  }
  if(!animated || !playing) redraw();
}

// modifier monitoring
boolean shift = false,
         control = false,
         alt = false;

// key input handling
void keyPressed() {

  if(keyCode==SHIFT)   { shift   = true; }
  if(keyCode==CONTROL) { control = true; }
  if(keyCode==ALT)     { alt     = true; }

  for(BezierCurve curve: curves) {
    if(allowReordering && keyCode==38) {
      curves.set(curves.indexOf(curve), curve.elevate());
      if(!animated || !playing) { redraw(); }
    }
    else if(allowReordering && keyCode==40 && curve.lower()!=null) {
      curves.set(curves.indexOf(curve), curve.lower());
      if(!animated || !playing) { redraw(); }
    }
    else if(animated && str(key).equals(" ")) {
      togglePlaying();
    }
    else if(str(key).equals("g")) {
      toggleGhosting();
    }
    else if(str(key).equals("s")) {
      toggleSimplify();
    }
    else if(str(key).equals("p")) {
      toggleSpan();
    }
    else if(allowOffsetting && str(key).equals("+")) {
      offset++;
      if(!animated || !playing) redraw();
    }
    else if(allowOffsetting && str(key).equals("-")) {
      offset--;
      if(offset<0) offset=0;
      if(!animated || !playing) redraw();
    }
  }
}

// modifier monitoring
void keyReleased() {
  if(keyCode==SHIFT)   { shift   = false; }
  if(keyCode==CONTROL) { control = false; }
  if(keyCode==ALT)     { alt     = false; }
}
