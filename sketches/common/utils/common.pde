/**
 * Setting the main font is essential for cross-sketch consistency
 */
textFont(createFont("Arial", 10));

/**
 * Used all over the place - draws all points as open circles,
 * and lists their coordinates underneath.
 */
void showPoints(Point[] points) {
	stroke(0,0,200);
	for(int p=0; p<points.length; p++) {
		noFill();
		drawEllipse(points[p].getX(), points[p].getY(), 5, 5);
		fill(0,0,255,100);
		int x = round(points[p].getX());
		int y = round(points[p].getY());
		drawText("x"+(p+1)+": "+x+"\ny"+(p+1)+": "+y, x-10, y+15); }}


/**
 * draws an estimated 't' value on the sketch area
 */
void showEstimatedT(double ix, double iy, double[] line, double st, double et)
{
	double perc;
	if(line[0]>line[2]) { perc = (ix - line[2]) / (line[0] - line[2]); }
	else if(line[2]>line[0]) { perc = (ix - line[0]) / (line[2] - line[0]); }
	else {
		if(line[1]>line[3]) { perc = (iy - line[3]) / (line[1] - line[3]); }
		else { perc = (iy - line[1]) / (line[3] - line[1]); }}
	double precision = 1000;
	double estimated_t = (int)(precision*((1-perc)*st + perc*et));
	estimated_t = estimated_t/precision;
	fill(255,0,255);
	text("t = "+estimated_t, (float)ix, (float)(iy+15));
}

/**
 * Get the angular direction indicated by the provided dx/dy ratio,
 * with the value expressed in radians (not degrees!)
 */
double getDirection(double dx, double dy)
{
  return Math.atan2(-dy,-dx) - PI;
}

/**
 * get the angular directions for a curve's end points, giving the angels (start->start control) and (end control->end)
 */
double[] getCurveDirections(double xa, double ya, double xb, double yb, double xc, double yc, double xd, double yd)
{
	double[] directions = new double[2];
	if(notEqual(xa,ya,xb,yb)) { directions[0] = getDirection(xb-xa, yb-ya); }
	else if(notEqual(xa,ya,xc,yc)) { directions[0] = getDirection(xc-xa, yc-ya); }
	else if(notEqual(xa,ya,xd,yd)) { directions[0] = getDirection(xd-xa, yd-ya); }
	else { directions[0] = -1; }

	if(notEqual(xd,yd,xc,yc)) { directions[1] = getDirection(xd-xc, yd-yc); }
	else if(notEqual(xd,yd,xb,yb)) { directions[1] = getDirection(xd-xb, yd-yb); }
	else if(notEqual(xd,yd,xa,ya)) { directions[1] = getDirection(xd-xa, yd-ya); }
	else { directions[1] = -1; }
	
	return directions;
}


boolean notEqual(double x1, double y1, double x2, double y2) { return x1!=x2 || y1 != y2; }

/**
 * Rotate a set of points so that point 0 is on (0,0) and point [last] is on (...,0)
 */
Point[] rotateToUniform(Point[] points)
{
	int len = points.length;
	Point[] uniform = new Point[len];
	// translate point set to start at 0,0
	double xoffset = points[0].getX();
	double yoffset = points[0].getY();
	uniform[0] = new Point(0,0);
	for(int i=1; i<len; i++) {
		uniform[i] = new Point(points[i].getX() - xoffset, points[i].getY() - yoffset); }
	// rotate all points so that the last point of the curve is on the x-axis
	double angle = -getDirection(uniform[len-1].getX(), uniform[len-1].getY());
	for(int i=1; i<len; i++) {
		Point uorg = uniform[i];
		double x = uorg.getX();
		double y = uorg.getY();
		uniform[i] = new Point(x * Math.cos(angle) - y * Math.sin(angle), x * Math.sin(angle) + y * Math.cos(angle)); }
	// done	
	return uniform;
}

/**
 * line intersection detection algorithm
 * see http://www.topcoder.com/tc?module=Static&d1=tutorials&d2=geometry2#line_line_intersection
 */
double[] intersectsLineLine(double[] line1, double[] line2)
{
	// value extraction to named variables is purely for convenience
	double x1 = line1[0];    double y1 = line1[1];
	double x2 = line1[2];    double y2 = line1[3];
	double x3 = line2[0];    double y3 = line2[1];
	double x4 = line2[2];    double y4 = line2[3];

	// the important values
	double nx = (x1*y2 - y1*x2)*(x3-x4) - (x1-x2)*(x3*y4 - y3*x4);
	double ny = (x1*y2 - y1*x2)*(y3-y4) - (y1-y2)*(x3*y4 - y3*x4);
	double denominator = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);

	// If the lines are parallel, there is no real 'intersection',
	// and if they are colinear, the intersection is an entire line,
	// rather than a point. return "null" in both cases.
	if(denominator==0) { return null; }
	// if denominator isn't zero, there is an intersection, and it's a single point.
	double px = nx/denominator;
	double py = ny/denominator;
	double[] ret = {px, py};
	return ret;
}

/**
 * Determine whether an intersection point between two lines is virtual, or actually
 * on both line segments it was computed for
 */
boolean intersectsLineSegmentLineSegment(double ix, double iy, double[] line1, double[] line2)
{
	if(0<=ix && ix<=boxsize && 0<=iy && iy<=boxsize)
	{
		double bounds_1_xmin = min(line1[0], line1[2]);
		double bounds_2_xmin = min(line2[0], line2[2]);
		double bounds_xmin = max(bounds_1_xmin, bounds_2_xmin);

		double bounds_1_xmax = max(line1[0], line1[2]);
		double bounds_2_xmax = max(line2[0], line2[2]);
		double bounds_xmax = min(bounds_1_xmax, bounds_2_xmax);
		
		double bounds_1_ymin = min(line1[1], line1[3]);
		double bounds_2_ymin = min(line2[1], line2[3]);
		double bounds_ymin = max(bounds_1_ymin, bounds_2_ymin);

		double bounds_1_ymax = max(line1[1], line1[3]);
		double bounds_2_ymax = max(line2[1], line2[3]);
		double bounds_ymax = min(bounds_1_ymax, bounds_2_ymax);

		return (bounds_xmin<=ix && ix<=bounds_xmax && bounds_ymin<=iy && iy<=bounds_ymax);
	}
	return false;
}

/**
 * interpolates a time value for a coordinate on a line, based on the start and end times of the line
 */
double estimateT(double ix, double iy, double[] line, double st, double et)
{
	double perc;
	if(line[0]>line[2]) { perc = (ix - line[2]) / (line[0] - line[2]); }
	else if(line[2]>line[0]) { perc = (ix - line[0]) / (line[2] - line[0]); }
	else {
		if(line[1]>line[3]) { perc = (iy - line[3]) / (line[1] - line[3]); }
		else { perc = (iy - line[1]) / (line[3] - line[1]); }}
	double estimated_t = (1-perc)*st + perc*et;
	return estimated_t;
}

/**
 * interpolates a distance value (expressed over interval [0,1]) for a coordinate on a line, based on the start and end distances of the line
 */
double estimateDistancePercentage(double ix, double iy, double[] line, double sd, double ed)
{
	double perc;
	if(line[0]>line[2]) { perc = (ix - line[2]) / (line[0] - line[2]); }
	else if(line[2]>line[0]) { perc = (ix - line[0]) / (line[2] - line[0]); }
	else {
		if(line[1]>line[3]) { perc = (iy - line[3]) / (line[1] - line[3]); }
		else { perc = (iy - line[1]) / (line[3] - line[1]); }}
	return perc;
}

/**
 * generate a 2D array; each row models an edge {x1,y1,x2,y2}
 */
double[][] getEdges(Point[] hull)
{
	double[][] edges = new double[hull.length][4];
	int len = hull.length;
	for(int p=0; p<len; p++) {
		double[] edge = {hull[p].x, hull[p].y, hull[(p+1)%len].x, hull[(p+1)%len].y};
		edges[p] = edge; }
	return edges;
}

/**
 * generate a 2D array; each row models an edge {x1,y1,x2,y2}
 * but only edges with coordinates at the specified _x value
 * are returned.
 */
double[][] getEdgesOn(Point[] hull, double _x)
{
	double r = 0.1;
	double[][] edges = new double[2][4];
	int len = hull.length;
	int pos = 0;
	for(int p=0; p<len; p++) {
		if(!near(hull[p].x,_x,r) && !near(hull[(p+1)%len].x,_x,r)) continue;
		double[] edge = {hull[p].x, hull[p].y, hull[(p+1)%len].x, hull[(p+1)%len].y};
		edges[pos++] = edge; }
	return edges;
}

/**
 * "is v1 a near enough to v2" check
 */
boolean near(double v1, double v2, double r) {
	return (abs(v1-v2)<=r);
}

/**
 * Arguably the least efficient sorting algorithm available... but very easy to write!
 */
void swapSort(double[] array)
{
	boolean sorted;
	int len = array.length;
	do {	sorted=true;
			for(int i=0; i<len-1; i++) {
				if(array[i+1]<array[i]) {
					// out of order: swap
					double swap = array[i];
					array[i] = array[i+1];
					array[i+1] = swap;
					// this list was not sorted
					sorted=false; }}} while(!sorted);
}
