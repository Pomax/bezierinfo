// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

Point[] points;
int boxsize = 300;

// REQUIRED METHOD
void setup()
{
	size(boxsize,boxsize);
	noLoop();
	setupPoints();
	text("",0,0);
}

/**
 * Set up four points, to form a cubic curve
 */
void setupPoints()
{
	points = new Point[4];
	points[0] = new Point(120,160);
	points[1] = new Point(35,200);
	points[2] = new Point(220,260);
	points[3] = new Point(220,40);
}

// REQUIRED METHOD
void draw()
{
	noFill();
	stroke(0);
	background(255);
	drawCurve();
	drawBoundingBox();
	drawExtras();
}

/**
 * Run through the entire interval [0,1] for 't'.
 */
void drawCurve()
{
	for(float t = 0; t<1.0; t+=1.0/200.0) {
		float mt = (1-t);
		double x = computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
		double y = computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
		drawPoint(x,y); }
}

/**
 * Compute the bounding box, and draw the derivative roots for the
 * component curves, if they have any.
 */
void drawBoundingBox()
{
	// find the zero point for x and y in the derivatives
	double minx = 9999;
	double maxx = -9999;
	if(points[0].getX()<minx) { minx=points[0].getX(); }
	if(points[0].getX()>maxx) { maxx=points[0].getX(); }
	if(points[3].getX()<minx) { minx=points[3].getX(); }
	if(points[3].getX()>maxx) { maxx=points[3].getX(); }
	double[] ts = computeCubicFirstDerivativeRoots(points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
	stroke(255,0,0);
	for(int i=0; i<ts.length;i++) {
		double t = ts[i];
		if(t>=0 && t<=1) {
			double x = computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
			double y = computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
			drawEllipse(x,y,5,5);
			if(x<minx) { minx=x; }
			if(x>maxx) { maxx=x; }}}

	double miny = 9999;
	double maxy = -9999;
	if(points[0].getY()<miny) { miny=points[0].getY(); }
	if(points[0].getY()>maxy) { maxy=points[0].getY(); }
	if(points[3].getY()<miny) { miny=points[3].getY(); }
	if(points[3].getY()>maxy) { maxy=points[3].getY(); }
	ts = computeCubicFirstDerivativeRoots(points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
	stroke(255,0,255);
	for(int i=0; i<ts.length;i++) {
		double t = ts[i];
		if(t>=0 && t<=1) {
			double x = computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
			double y = computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
			drawEllipse(x,y,5,5);
			if(y<miny) { miny=y; }
			if(y>maxy) { maxy=y; }}}

	// bounding box
	noFill();
	stroke(0,255,0);
	drawRect(minx, miny, maxx-minx, maxy-miny);
}

/**
 * For nice visuals, make the curve's fixed points stand out,
 * and draw the lines connecting the end points and control points.
 * Also, we label each coordinate with its x/y value, for clarity.
 */
void drawExtras()
{
	showPoints(points);
	stroke(0,75);
	drawLine(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY());
	drawLine(points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY());
}
