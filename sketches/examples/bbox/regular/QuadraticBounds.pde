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
 * Set up three points, to form a quadratic curve
 */
void setupPoints()
{
	points = new Point[3];
	points[0] = new Point(70,250);
	points[1] = new Point(20,110);
	points[2] = new Point(250,60);
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
		int x = (int) computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX());
		int y = (int) computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY());
		point(x,y); }
}

/**
 * Compute the bounding box, and draw the derivative roots for the
 * component curves, if they have any.
 */
void drawBoundingBox()
{
	double minx = 9999;
	double maxx = -9999;
	if(points[0].getX()<minx) { minx=points[0].getX(); }
	if(points[0].getX()>maxx) { maxx=points[0].getX(); }
	if(points[2].getX()<minx) { minx=points[2].getX(); }
	if(points[2].getX()>maxx) { maxx=points[2].getX(); }
	double t = computeQuadraticFirstDerivativeRoot(points[0].getX(), points[1].getX(), points[2].getX());
	if(t>=0 && t<=1) {
		stroke(255,0,0);
		double x = computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX());
		double y = computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY());
		drawEllipse(x,y,5,5);
		if(x<minx) { minx=x; }
		if(x>maxx) { maxx=x; }}

	double miny = 9999;
	double maxy = -9999;
	if(points[0].getY()<miny) { miny=points[0].getY(); }
	if(points[0].getY()>maxy) { maxy=points[0].getY(); }
	if(points[2].getY()<miny) { miny=points[2].getY(); }
	if(points[2].getY()>maxy) { maxy=points[2].getY(); }
	t = computeQuadraticFirstDerivativeRoot(points[0].getY(), points[1].getY(), points[2].getY());
	if(t>=0 && t<=1) {
		stroke(255,0,255);
		double x = computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX());
		double y = computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY());
		drawEllipse(x,y,5,5);
		if(y<miny) { miny=y; }
		if(y>maxy) { maxy=y; }}

	// draw bounding box
	noFill();
	stroke(0,255,0);
	drawRect(minx, miny, maxx-minx, maxy-miny);
}

/**
 * For nice visuals, make the curve's fixed points stand out,
 * and draw the lines connecting the start/end and control point.
 * Also, we label each coordinate with its x/y value, for clarity.
 */
void drawExtras()
{
	showPoints(points);
	stroke(0,75);
	drawLine(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY());
	drawLine(points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY());
}
