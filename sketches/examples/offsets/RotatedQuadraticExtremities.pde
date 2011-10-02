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
	points[0] = new Point(45,115);
	points[1] = new Point(130,30);
	points[2] = new Point(240,220);
}

// REQUIRED METHOD
void draw()
{
	noFill();
	stroke(0);
	background(255);
	drawCurve();
	drawDerivativeRoots();
	drawExtras();
}

/**
 * Run through the entire interval [0,1] for 't'.
 */
void drawCurve()
{
	double range = 200;
	for(float t = 0; t<1.0; t+=1.0/range) {
		double x = computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX());
		double y = computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY());
		stroke(0);
		drawPoint(x,y); }
}

/**
 * Draw the derivative roots for the component curves, if they have any
 */
void drawDerivativeRoots()
{
	// translate to 0,0
	Point np2 = new Point(points[1].getX() - points[0].getX(), points[1].getY() - points[0].getY());
	Point np3 = new Point(points[2].getX() - points[0].getX(), points[2].getY() - points[0].getY());

	// get angle for rotation
	float angle = (float) getDirection(np3.getX(), np3.getY());
	
	// rotate everything counter-angle so that it's aligned with the x-axis
	Point rnp2 = new Point(np2.getX() * cos(-angle) - np2.getY() * sin(-angle), np2.getX() * sin(-angle) + np2.getY() * cos(-angle));
	Point rnp3 = new Point(np3.getX() * cos(-angle) - np3.getY() * sin(-angle), np3.getX() * sin(-angle) + np3.getY() * cos(-angle));

	stroke(255,0,255);

	// Find root for the (rotated) x-direction
	findRotatedRoot(rnp2.getX(), rnp3.getX(),  rnp2.getX(), rnp2.getY(), rnp3.getX(), angle);
	// Find root for the (rotated) y-direction
	findRotatedRoot(rnp2.getY(), 0,  rnp2.getX(), rnp2.getY(), rnp3.getX(), angle);
}

/**
 * Find and draw the root, giving the provided parameters
 * See bbox/minimal/QuadraticBounds.pde for the full code,
 * because this is shuffled a little for cleaner function calling
 */
void findRotatedRoot(double v1, double v2, double x2, double y2, double x3, double angle)
{
	// compute root for the given parameters
	double t = computeQuadraticFirstDerivativeRoot(0, v1, v2);
	Point root =null;
	if(t>=0 && t<=1) {
		double x = computeQuadraticBaseValue(t, 0, x2, x3); 
		double y = computeQuadraticBaseValue(t, 0, y2, 0);
		root = new Point(x,y); }

	// rotate/move back and draw
	if(root!=null) {
		root = new Point(points[0].getX() + root.x * cos(angle) - root.y * sin(angle),
								points[0].getY() + root.x * sin(angle) + root.y * cos(angle));
		drawEllipse(root.x, root.y, 5, 5); }
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