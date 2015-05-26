ArrayList<Point> iterate(double errorThreshold) {
  ArrayList<Point> circles = new ArrayList<Point>();
  return __iterate(errorThreshold, circles);
}

ArrayList<Point> __iterate(double errorThreshold, ArrayList<Point> circles) {
  double s = 0, e = 1;

  // we do a binary search to find the "good `t` closest to no-longer-good"
  do {
    // step 1: start with the maximum possible arc
    e = 1;
    Point np1 = getCurve(s), np2, np3, pc=null, prev_pc;
    boolean curr_good = false, prev_good = false, done;
    double m = e, prev_e = 1;
    int step = 0;
  
    // step 2: find the best possible arc
    do {
      prev_good = curr_good;
      prev_pc = pc;
      m = (s + e)/2;
      step++;

      np2 = getCurve(m);
      np3 = getCurve(e);
      pc = getCCenter(np1, np2, np3);
      double error = getError(pc, np1, s, e);
      curr_good = error <= errorThreshold;

      //println("params:",s,m,e,prev_e,error);

      done = prev_good && !curr_good;
      if(!done) prev_e = e;

      // this arc is fine: we can move 'e' up to see if we can find a wider arc
      if(curr_good) {
        // if e is already at max, then we're done for this arc.
        if (e >= 1) { prev_e = 1; break; }
        e = e + (e - s)/2;
      }
      // this is a bad arc: we need to move 'e' down to find a good arc
      else { e = m; }
    }
    while(!done);

    //println("arc found:",s,",",prev_e,":",prev_pc.s+","+prev_pc.e);

    prev_pc = prev_pc == null ? pc : prev_pc;
    circles.add(prev_pc);
    s = prev_e;
  }
  while(e < 1);

  return circles;
}
