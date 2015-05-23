/**
 * Area between bezier and circle.
 * |B(t) - C(t)|_x = http://www.wolframalpha.com/input/?i=integrate%5Ba*%281-t%29%5E3+%2B+3*b*%281-t%29%5E2*t+%2B+3*c*%281-t%29*t%5E2+%2B+d*t%5E3+-+cos%28t%29%5D+for+t+from+s+to+e 
 * |B(t) - C(t)|_y = http://www.wolframalpha.com/input/?i=integrate%5Ba*%281-t%29%5E3+%2B+3*b*%281-t%29%5E2*t+%2B+3*c*%281-t%29*t%5E2+%2B+d*t%5E3+-+sin%28t%29%5D+for+t+from+s+to+e
 */
Tuple getAreaDifference(double s, double e, Point p1, Point p2, Point p3, Point p4) {
  double end_x = -sin(e) + sin(s),
         end_y =  cos(e) - cos(s),
         area_x = getArea(s, e, p1.x, p2.x, p3.x, p4.x) + end_x,
         area_y = getArea(s, e, p1.y, p2.y, p3.y, p4.y) + end_y;
  return new Tuple(area_x, area_y);
}

double getArea(double s, double e, double a, double b, double c, double d) {
  double e2 =  e * e,
         e3 = e2 * e,
         e4 = e3 * e,
         s2 =  s * s,
         s3 = s2 * s,
         s4 = s3 * s,
         c1 = -a + 3 * b - 3 * c + d,
         c2 = a - 2 * b + c,
         c3 = b - a,
         part1 = e4 *  c1 + 4 * e3 * c2 + 6 * e2 *  c3 + 4 * e * a,
         part2 = s4 * -c1 - 4 * s3 * c2 + 6 * s2 * -c3 + 4 * s * a;
  return (part1 + part2)/4;
}