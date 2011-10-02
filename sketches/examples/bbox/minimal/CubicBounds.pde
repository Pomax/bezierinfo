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
		double x = computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
		double y = computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
		drawPoint(x,y); }
}

/**
 * Compute the bounding box based on the straightened curve, for best fit
 */
void drawBoundingBox()
{
	// translate to 0,0
	Point np2 = new Point(points[1].getX() - points[0].getX(), points[1].getY() - points[0].getY());
	Point np3 = new Point(points[2].getX() - points[0].getX(), points[2].getY() - points[0].getY());
	Point np4 = new Point(points[3].getX() - points[0].getX(), points[3].getY() - points[0].getY());

	// get angle for rotation
	float angle = (float) getDirection(np4.getX(), np4.getY());
	
	// rotate everything counter-angle so that it's aligned with the x-axis
	Point rnp2 = new Point(np2.getX() * cos(-angle) - np2.getY() * sin(-angle), np2.getX() * sin(-angle) + np2.getY() * cos(-angle));
	Point rnp3 = new Point(np3.getX() * cos(-angle) - np3.getY() * sin(-angle), np3.getX() * sin(-angle) + np3.getY() * cos(-angle));
	Point rnp4 = new Point(np4.getX() * cos(-angle) - np4.getY() * sin(-angle), np4.getX() * sin(-angle) + np4.getY() * cos(-angle));

	// find the zero point for x and y in the derivatives
	double minx = 9999;
	double maxx = -9999;
	if(0<minx) { minx=0; }
	if(0>maxx) { maxx=0; }
	if(rnp4.getX()<minx) { minx=rnp4.getX(); }
	if(rnp4.getX()>maxx) { maxx=rnp4.getX(); }
	double[] ts = computeCubicFirstDerivativeRoots(0, rnp2.getX(), rnp3.getX(), rnp4.getX());
	stroke(255,0,0);
	for(int i=0; i<ts.length;i++) {
		double t = ts[i];
		if(t>=0 && t<=1) {
			int x = (int)computeCubicBaseValue(t, 0, rnp2.getX(), rnp3.getX(), rnp4.getX());
			if(x<minx) { minx=x; }
			if(x>maxx) { maxx=x; }}}

	float miny = 9999;
	float maxy = -9999;
	if(0<miny) { miny=0; }
	if(0>maxy) { maxy=0; }
	ts = computeCubicFirstDerivativeRoots(0, rnp2.getY(), rnp3.getY(), 0);
	stroke(255,0,255);
	for(int i=0; i<ts.length;i++) {
		double t = ts[i];
		if(t>=0 && t<=1) {
			int y = (int)computeCubicBaseValue(t, 0, rnp2.getY(), rnp3.getY(), 0);
			if(y<miny) { miny=y; }
			if(y>maxy) { maxy=y; }}}

	// bounding box corner coordinates
	Point bb1 = new Point(minx,miny);
	Point bb2 = new Point(minx,maxy);
	Point bb3 = new Point(maxx,maxy);
	Point bb4 = new Point(maxx,miny);
	
	// rotate back!
	Point nbb1 = new Point(bb1.x * cos(angle) - bb1.y * sin(angle), bb1.x * sin(angle) + bb1.y * cos(angle));
	Point nbb2 = new Point(bb2.x * cos(angle) - bb2.y * sin(angle), bb2.x * sin(angle) + bb2.y * cos(angle));
	Point nbb3 = new Point(bb3.x * cos(angle) - bb3.y * sin(angle), bb3.x * sin(angle) + bb3.y * cos(angle));
	Point nbb4 = new Point(bb4.x * cos(angle) - bb4.y * sin(angle), bb4.x * sin(angle) + bb4.y * cos(angle));
	
	// move back!
	nbb1.x += points[0].getX();	nbb1.y += points[0].getY();
	nbb2.x += points[0].getX();	nbb2.y += points[0].getY();
	nbb3.x += points[0].getX();	nbb3.y += points[0].getY();
	nbb4.x += points[0].getX();	nbb4.y += points[0].getY();
	
	double[] bounds = {nbb1.x, nbb1.y, nbb2.x, nbb2.y, nbb3.x, nbb3.y, nbb4.x, nbb4.y};
	
	// draw bounding box
	noFill();
	stroke(0,255,0);
	drawLine(bounds[0], bounds[1], bounds[2], bounds[3]);
	drawLine(bounds[2], bounds[3], bounds[4], bounds[5]);
	drawLine(bounds[4], bounds[5], bounds[6], bounds[7]);
	drawLine(bounds[6], bounds[7], bounds[0], bounds[1]);
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
