double dist(Point p1, Point p2) {
  double dx = p1.x - p2.x,
         dy = p1.y - p2.y;
  return sqrt(dx*dx + dy*dy);
}