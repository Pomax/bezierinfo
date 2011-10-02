/**
 * Straight line segment from point P1 to P2
 */
class Line extends Segment
{
	double length=0;
	double getLength() { return length; }

	void computeBoundingBox() {
		double minx = min(points[0].x, points[1].x);
		double miny = min(points[0].y, points[1].y);
		double maxx = max(points[0].x, points[1].x);
		double maxy = max(points[0].y, points[1].y);
		// direction: {+x, +y, -x, -y}
		double[] bbox = {minx,miny, maxx,miny, maxx,maxy, minx,maxy};
		bounds = bbox;
	}

	void computeTightBoundingBox() {
		double[] bbox = {points[0].x, points[0].y, points[1].x, points[1].y, points[1].x, points[1].y, points[0].x, points[0].y};
		bounds = bbox;
	}

	Line() { super(); }

	Line(double x1, double y1, double x2, double y2) {
		points = new Point[2];
		points[0] = new Point(x1,y1);
		points[1] = new Point(x2,y2); 
		length = (double) sqrt((float)((x2-x1)*(x2-x1)) + (float)((y2-y1)*(y2-y1))); }

	Line(Line other) { super(other); }

	void drawSegment() {
		drawLine(ox+points[0].getX(), oy+points[0].getY(), ox+points[1].getX(), oy+points[1].getY()); }
		
	// can't flatten a line, return self
	Line[] flatten(int steps) { Line[] ret = {this}; return ret; }
	
	/**
	 * check how many pixels of the curve are not covered by this line
	 */
	int getOffPixels(double[] xcoords, double[] ycoords, int end)
	{
		int off = 0;
		for(int c=0; c<end; c++) {
			double x = xcoords[c];
			double y = ycoords[c];
			double supposed_y = getYforX(x);
			if(abs((float)(supposed_y-y))>=2) { off++; }}
		return off;
	}
	
	/**
	 * If we plug an 'x' value into this line's f(x), which 'y' value comes rolling out?
	 */
	double getYforX(double x)
	{
		double dy = points[1].getY() - points[0].getY();
		double dx = points[1].getX() - points[0].getX();
		return (dy/dx) * (x - points[0].getX()) + points[0].getY();
	}

	/**
	 * Offset this line by {distance} pixels. Note that these do not need to be full pixels
	 */
	Segment[] offset(double distance) {
		double angle = getDirection(points[1].getX()-points[0].getX(), points[1].getY() - points[0].getY());
		double dx = distance * Math.cos(angle + PI/2.0);
		double dy = distance * Math.sin(angle + PI/2.0);
		Segment[] ret = { new Line(points[0].getX() + dx, points[0].getY() + dy, points[1].getX() + dx, points[1].getY() + dy) };
		return ret;
	}
	
	/**
	 * simply wraps offset
	 */
	Segment simpleOffset(double distance) {
		Segment[] soffset = offset(distance);
		return soffset[0]; }
}
