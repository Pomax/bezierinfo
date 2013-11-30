/**
 * Intersection tracker for PolyBezierCurve shape pairs
 */


class IntersectionTracker {
  Intersection[] intersections;
  Intersection current;

  // construct a new list, with empty elements.
  IntersectionTracker(int size) {
    intersections = new Intersection[size];
    while(size-->0) { intersections[size] = new Intersection(); }
  }

  IntersectionTracker copy() {
    int L = intersections.length;
    IntersectionTracker copied = new IntersectionTracker(L);
    for(int i=0; i<L; i++) {
      copied.intersections[i] = new Intersection(intersections[i]);
    }
    return copied;
  }

  void trackIn(int idx, PolyBezierCurve c, int MODE) {
    intersections[idx].setIn(c,MODE);
  }

  void trackOut(int idx, PolyBezierCurve c, int MODE) {
    intersections[idx].setOut(c,MODE);
  }

  void remove(PolyBezierCurve c) {
    for(Intersection i: intersections) {
      i.blank(c);
    }
  }

  void draw() { for(Intersection i: intersections) { i.draw(); }}

  /**
   * Form a single shape outline using this tracker's interesection data
   */
  PolyBezierCurve formShape() {
    PolyBezierCurve shape = new PolyBezierCurve(false);
    // initial shape
    Intersection current = intersections[0];
    PolyBezierCurve p=current.getIn(), pout;

    // algorithm walk to add the remaining shapes
    boolean done = false;
    while(!done) {
      shape.append(p);
      current.blank(p);
      pout = current.getOut();
      current.blank();
      current = getAdjoint(pout);
      if(current == null) { done = true; }
      else { p=current.getIn(); }
    }
    // and we're done.
    return shape;
  }

  // get the section that follows this one.
  Intersection getAdjoint(PolyBezierCurve c) {
    Intersection it;
    for(int i=0, pos; i<intersections.length; i++) {
      it = intersections[i];
      pos = it.indexOf(c);
      if(pos>-1) { return it; }
    }
    // there is no adjoint.
    return null;
  }

  // get the next not-empty intersection's
  Intersection getNextShape() {
    for(Intersection i: intersections) {
      if(!i.isEmpty()) { return i; }
    }
    return null;
  }

  String toString() {
    String[] s = new String[intersections.length];
    for(int i=0; i<s.length; i++) {
      s[i] = intersections[i].toString();
    }
    return join(s,"\n");
  }


  /**
   * Inner class. Your code should never get access to instances of this class.
   */
  private class Intersection {
    // has this intersection tracker been passed in an algorithmic run?
    boolean marked = false;
    int other = -1;

    // our in- and out-curves
    PolyBezierCurve c1_in = null,
                    c1_out = null,
                    c2_in = null,
                    c2_out = null;

    // empty contructor
    Intersection() {}

    // copy constructor
    Intersection(Intersection other) {
      c1_in = other.c1_in;
      c1_out = other.c1_out;
      c2_in = other.c2_in;
      c2_out = other.c2_out;
    }

    // setters
    void setIn(PolyBezierCurve c, int MODE)  {
      if(MODE==1) { if(c1_in==null)  c1_in = c;  }
      if(MODE==2) { if(c2_in==null)  c2_in = c;  }
    }

    void setOut(PolyBezierCurve c, int MODE)  {
      if(MODE==1) { if(c1_out==null)  c1_out = c;  }
      if(MODE==2) { if(c2_out==null)  c2_out = c;  }
    }

    // linkers
    void linkIn(Intersection previous) {
      c1_in = previous.c1_out;
      c2_in = previous.c2_out;
    }

    void linkOut(Intersection next) {
      c1_out = next.c1_in;
      c2_out = next.c2_in;
    }

    // blankers
    void blank() { c1_in = null; c1_out = null; c2_in = null; c2_out = null; }
    void blank(PolyBezierCurve c) {
      if(c1_in==c)  c1_in = null;
      if(c1_out==c) c1_out = null;
      if(c2_in==c)  c2_in = null;
      if(c2_out==c) c2_out = null;
    }

    // traversal getters
    PolyBezierCurve getIn() {
      if(c1_in==null && c2_in==null) return null;
      if(c1_in!=null) return c1_in;
      if(c2_in!=null) return c2_in;
      /* it would be interesting if we could get here */
      return null;
    }

    PolyBezierCurve getOut() {
      if(c1_out==null && c2_out==null) return null;
      if(c2_out!=null) return c2_out;
      if(c1_out!=null) return c1_out;
      /* it would be interesting if we could get here */
      return null;
    }

    PolyBezierCurve getOut(int other) {
      if(other==1) { return c2_out; }
      return c1_out;
    }

    PolyBezierCurve getNext(PolyBezierCurve c) {
      if(c1_in==c)       if (c1_out==null) { other = 1; return c2_out; } else { other = 2; return c1_out; }
      else if(c1_out==c) if (c1_in==null)  { other = 1; return c2_in;  } else { other = 2; return c1_in;  }
      else if(c2_in==c)  if (c2_out==null) { other = 2; return c1_out; } else { other = 1; return c2_out; }
      /*if(c2_out==c)*/  if (c2_in==null)  { other = 2; return c1_in;  } else { other = 1; return c2_in;  }
    }

    int indexOf(PolyBezierCurve c) {
      if(c1_in==c || c1_out==c) return 1;
      if(c2_in==c || c2_out==c) return 2;
      return -1;
    }

    boolean isEmpty() {
      return c1_in==null && c1_out==null;
    }

    // this this thing around. out becomes in and vice versa, and the curves need to be flipped, too.
    void flip() {
      // in<->out
      PolyBezierCurve _temp = c1_in;
      c1_in = c1_out;
      c1_out = _temp;
      _temp = c2_in;
      c2_in = c2_out;
      c2_out = _temp;
      // flip curves
      if(c1_in!=null)  c1_in.flip();
      if(c1_out!=null) c1_out.flip();
      if(c2_in!=null)  c2_in.flip();
      if(c2_out!=null) c2_out.flip();
    }

    // algorithmic run marking
    void mark() { marked = true; other = -1; }
    void reset() { marked = false; other = -1; }

    // draw
    void draw() {
      int col = colorListing[int(random(100))];
      if(c1_in!=null)  { c1_in.draw(col);  }
      if(c1_out!=null) { c1_out.draw(col); }
      if(c2_in!=null)  { c2_in.draw(col);  }
      if(c2_out!=null) { c2_out.draw(col); }
    }

    // tostring
    String toString() { return "in: "+c1_in+"/"+c1_out+", out:"+c2_in+"/"+c2_out; }
  }
}
