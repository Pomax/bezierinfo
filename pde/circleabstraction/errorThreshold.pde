double getError(Point pc, Point np1, double s, double e) {
  double q = (e - s) / 4;
  
  // get an error estimate baesd on the quarter points
  Point c1 = get(s + q),
        c2 = get(e - q);
  
  // distance from pc to c1/c2
  double ref = dist(pc, np1),
         d1  = dist(pc, c1),
         d2  = dist(pc, c2);
  
  return abs(d1-ref) + abs(d2-ref);
}