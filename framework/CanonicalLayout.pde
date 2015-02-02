static class CanonicalLayout {

  static CanonicalValues getCanonicalValues(Point B3, float s) {
    return new CanonicalValues(B3, s);
  }

  // we along translate the past point, because we know what the other three points will be, by convention.
  static Point forwardTransform(Point p1, Point p2, Point p3, Point p4, float s) {
    float xn = -p1.x + p4.x - (-p1.x+p2.x)*(-p1.y+p4.y)/(-p1.y+p2.y);
    float xd = -p1.x + p3.x - (-p1.x+p2.x)*(-p1.y+p3.y)/(-p1.y+p2.y);
    float np4x = s*xn/xd;

    float yt1 = s*(-p1.y+p4.y) / (-p1.y+p2.y);
    float yt2 = s - (s*(-p1.y+p3.y)/(-p1.y+p2.y));
    float yp = yt2 * xn / xd;
    float np4y = yt1 + yp;

    return new Point(np4x, np4y);
  }

  // the back-translation is equally easy, since we already know the first three coordinates. we just convert point 4.
  static Point backwardTransform(Point p1, Point p2, Point p3, Point p4, float dx, float dy, float s) {
    return new Point(
      (-dy * p1.x + (-dx+dy)*p2.x + dx*p3.x + s*p4.x) / s,
      (-dy * p1.y + (-dx+dy)*p2.y + dx*p3.y + s*p4.y) / s
    );
  }

  static PGraphics create(PApplet sketch, int width, int height, float s) {
    int w = width / 2;
    int h = height / 2;
    float f = s/100;

    PGraphics buffer = sketch.createGraphics(width, height);
    buffer.beginDraw();
    buffer.background(255);
    buffer.translate(w, h);
    buffer.stroke(150);
    for (int i=-w; i<=w; i+=s/2) {
      buffer.line(i, -h, i, h);
    }
    for (int i=-h; i<=h; i+=s/2) {
      buffer.line(-w, i, w, i);
    }
    buffer.stroke(0);
    buffer.line(0, -h, 0, h);
    buffer.line(-w, 0, w, 0);

    // single inflection area
    buffer.stroke(120, 120, 160);
    buffer.fill(0, 255, 0, 50);
    buffer.rect(-w-1, s, 2*w+2, h-s);

    // Loop region
    buffer.fill(255, 0, 0, 50);
    buffer.beginShape();

    // Do some canonical curve work, following Stone and DeRose,
    // "A Geometric Characterization of Parametric Cubic Curves"
    float px=-w*2, py=-h*2;
    for (float y, x=-10; x<=1; x+=0.01) {
      // Cusp parabola:
      y = (-x*x + 2*x + 3)/4;
      buffer.line(px, py, x*s, y*s);
      px = x*s;
      py = y*s;
      buffer.vertex(px, py);
    }

    // loop/arch transition boundary, elliptical section
    px=1*s;
    py=1*s;
    for (float x=1, y; x>=0; x-=0.005) {
      y = 0.5 * (sqrt(3) * sqrt(4*x - x*x) - x);
      buffer.line(px, py, x*s, y*s);
      px = x*s;
      py = y*s;
      buffer.vertex(px, py);
    }

    // loop/arch transition boundary, parabolic section
    px=0;
    py=0;
    for (float x=0, y; x>-w; x-=0.01) {
      y = (-x*x + 3*x)/3;
      buffer.line(px, py, x*s, y*s);
      px = x*s;
      py = y*s;
      buffer.vertex(px, py);
    }
    buffer.endShape();

    buffer.fill(0,0,100);

    buffer.textFont(sketch.createFont("Arial", 18*f));
    buffer.textAlign(CENTER, CENTER);
    buffer.text("simple arch\n(no inflections)", 1.5*s, -1.51*s);
    buffer.text("loop", -175, -175);
    buffer.text("double\ninflection", -2*s, -30*f);
    buffer.text("single inflection", 0, 2*s);
    buffer.text("loop", -1.1*s, -65*f);

    buffer.fill(100);


    buffer.text("cusp", -1.2*s, 20*f);
    buffer.line(-1.4*s, 30*f, -0.65*s, 30*f);

    buffer.text("loop on t=0", -0.8*s, -1.9*s);
    buffer.line(-1.25*s, -1.8*s, -0.3*s, -1.8*s);

    buffer.text("loop on t=1", 0.8*s, 30*f);
    buffer.line(0.08*s, 40*f, 1.2*s, 40*f);

    // our magic coordinates
    buffer.fill(0);
    buffer.ellipse(0,0,5,5);
    buffer.text("(0,0)", 0-20, 0+10);
    buffer.ellipse(0,s,5,5);
    buffer.text("(0,1)", 0-20, s+10);
    buffer.ellipse(s,s,5,5);
    buffer.text("(1,1)", s-20, s+10);

    buffer.endDraw();
    return buffer;
  }
}
