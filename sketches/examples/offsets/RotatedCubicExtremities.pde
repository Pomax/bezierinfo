// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

ViewPort main, second;
Point[] points;
int boxsize = 200;

// REQUIRED METHOD
void setup()
{
	size(2*boxsize + 100,boxsize+100);
	noLoop();
	setupPoints();
	setupViewPorts();
	text("",0,0);
}

/**
 * Set up four points, to form a cubic curve
 */
void setupPoints()
{
	points = new Point[4];
	points[0] = new Point(15,0);
	points[1] = new Point(130,0);
	points[2] = new Point(50,100);
	points[3] = new Point(150,190);
}

/**
 * Set up two 'view ports', because we'll be drawing two different things
 */
void setupViewPorts()
{
	main = new ViewPort(25+0,50+0,boxsize,boxsize);
	second = new ViewPort(25+boxsize+50,50+0,boxsize,boxsize);
}

// REQUIRED METHOD
void draw()
{
	noFill();
	stroke(0);
	background(255);
	drawViewPorts();
	drawCurves();
	drawDerivativeRoots();
	drawExtras();
}

/**
 * Draw all the viewport graphics
 */
void drawViewPorts()
{
	main.drawText("Splits based on first derivative", 0,-35, 0,0,0,255);
	stroke(0,100);
	line(width/2, 20, width/2,height-20);
	second.drawText("Splits based on first and second derivative", 0,-35, 0,0,0,255);
}

/**
 * Run through the entire interval [0,1] for 't'.
 */
void drawCurves()
{
	double range = 200;
	for(float t = 0; t<1.0; t+=1.0/range) {
		double x = computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
		double y = computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
		main.drawPoint(x,y, 0,0,0,255);
		second.drawPoint(x,y, 0,0,0,75);
	}
}

/**
 * Draw the derivative roots for the component curves, if they have any
 */
void drawDerivativeRoots()
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

	// Find first derivative roots for the (rotated) x-direction
	findRotatedFirstRoots(rnp2.getX(), rnp3.getX(), rnp4.getX(),  rnp2.getX(), rnp2.getY(), rnp3.getX(), rnp3.getY(), rnp4.getX(), angle);
	// Find first derivative roots for the (rotated) y-direction
	findRotatedFirstRoots(rnp2.getY(), rnp3.getY(), rnp4.getY(),  rnp2.getX(), rnp2.getY(), rnp3.getX(), rnp3.getY(), rnp4.getX(), angle);
	// Find second derivative root for the (rotated) x-direction
	findRotatedSecondRoot(rnp2.getX(), rnp3.getX(), rnp4.getX(),  rnp2.getX(), rnp2.getY(), rnp3.getX(), rnp3.getY(), rnp4.getX(), angle);
	// Find second derivativeroot for the (rotated) y-direction
	findRotatedSecondRoot(rnp2.getY(), rnp3.getY(), rnp4.getY(),  rnp2.getX(), rnp2.getY(), rnp3.getX(), rnp3.getY(), rnp4.getX(), angle);
}

/**
 * Find and draw the first derivative roots, giving the provided parameters
 * See bbox/minimal/QuadraticBounds.pde for the full code,
 * because this is shuffled a little for cleaner function calling
 */
void findRotatedFirstRoots(double v1, double v2, double v3,  double x2, double y2, double x3, double y3, double x4, double angle)
{
	// compute root for the given parameters
	double[] ts = computeCubicFirstDerivativeRoots(0,v1, v2, v3);
	for(int i=0; i<ts.length;i++) {
		double t = ts[i];
		Point root =null;
		if(t>=0 && t<=1) {
			double x = computeCubicBaseValue(t, 0, x2, x3, x4); 
			double y = computeCubicBaseValue(t, 0, y2, y3, 0);
			root = new Point(x,y); }

		// rotate/move back and draw
		if(root!=null) {
			root = new Point(points[0].getX() + root.x * cos(angle) - root.y * sin(angle),
									points[0].getY() + root.x * sin(angle) + root.y * cos(angle));
			main.drawEllipse(root.x, root.y, 5, 5, 255,0,255,255);
			second.drawEllipse(root.x, root.y, 5, 5, 255,0,255,255); }}
}

/**
 * Find and draw the second derivative roots, giving the provided parameters
 * See bbox/minimal/QuadraticBounds.pde for the full code,
 * because this is shuffled a little for cleaner function calling
 */
void findRotatedSecondRoot(double v1, double v2, double v3,  double x2, double y2, double x3, double y3, double x4, double angle)
{
	// compute root for the given parameters
	double t = computeCubicSecondDerivativeRoot(0,v1, v2, v3);
	Point root =null;
	if(t>=0 && t<=1) {
		double x = computeCubicBaseValue(t, 0, x2, x3, x4); 
		double y = computeCubicBaseValue(t, 0, y2, y3, 0);
		root = new Point(x,y); }

	// rotate/move back and draw
	if(root!=null) {
		root = new Point(points[0].getX() + root.x * cos(angle) - root.y * sin(angle),
								points[0].getY() + root.x * sin(angle) + root.y * cos(angle));
		second.drawEllipse(root.x, root.y, 5, 5, 255,0,255,255); }
}

/**
 * For nice visuals, make the curve's fixed points stand out,
 * and draw the lines connecting the end points and control points.
 * Also, we label each coordinate with its x/y value, for clarity.
 */
void drawExtras()
{
	showPointsInViewPort(points,main);
	showPointsInViewPort(points,second);
	stroke(0,75);
	main.drawLine(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), 0,0,0,75);
	main.drawLine(points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY(), 0,0,0,75);
	second.drawLine(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), 0,0,0,75);
	second.drawLine(points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY(), 0,0,0,75);
}