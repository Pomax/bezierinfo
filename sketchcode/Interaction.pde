void preDraw() {
  if(t>1) {
    t = 0;
  }
}

void postDraw() {
/*
  for(BezierCurve curve: curves) {
    float m = curve.over(mouseX,mouseY);
    int p = curve.overPoint(mouseX, mouseY);
    if(m!=-1 && p<0) {
      fill(0);
      text("t ≈ "+m,mouseX+10,mouseY+10);
      noFill();
    }
  }
*/
  t += step;
}

BezierCurve active = null;
int current = -1,
    offset = 0;

void mouseMoved() {
  for(BezierCurve curve: curves) {
    int p = curve.overPoint(mouseX, mouseY);
    if(p != -1) {
      active = curve;
      current = p;
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

void mouseDragged() {
  if(current != -1) {
    active.movePoint(current, mouseX, mouseY);
  }
  if(!playing) redraw();
  if(moulding) {
    for(BezierCurve curve: curves) {
      mouldCurve(curve, mouseX, mouseY);
    }
  }
}

void mouseClicked() {
  if(playing) { noLoop(); pause(); }
  else { loop(); play(); }
}

void mousePressed() {
  if(moulding && current==-1) {
    for(BezierCurve curve: curves) {
      float t = curve.over(mouseX, mouseY);
      if(t != -1) {
        startCurveMoulding(curve, t);
      }
    }
  }
}

void mouseReleased() {
  if(moulding) {
    for(BezierCurve curve: curves) {
      endCurveMoulding(curve);
    }
  }
}

void keyPressed() {
  for(BezierCurve curve: curves) {
    if(keyCode==UP) {
      curves.set(curves.indexOf(curve), curve.elevate());
    }
    else if(keyCode==DOWN && curve.lower()!=null) {
      curves.set(curves.indexOf(curve), curve.lower());
    }
    else if(str(key).equals(" ")) {
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
    else if(str(key).equals("+")) {
      offset++;
    }
    else if(str(key).equals("-")) {
      offset--;
      if(offset<0) offset=0;
    }
  }
}

