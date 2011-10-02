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
	points[0] = new Point(100,150);
	points[1] = new Point(150,100);
	points[2] = new Point(200,150);
}

// REQUIRED METHOD
void draw()
{
	noFill();
	stroke(0);
	background(255);
	drawCurve();
	drawScalingParameters();
	drawExtras();
}

/**
 * Run through the entire interval [0,1] for 't'.
 */
void drawCurve()
{
	double range = 200;
	for(float t = 0; t<1.0; t+=1.0/range) {
		int x = (int) computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX());
		int y = (int) computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY());
		stroke(0);
		drawPoint(x,y); }
}

/**
 * Draw the derivative roots for the component curves, if they have any
 */
void drawScalingParameters()
{
	// get angles for start and end
	double start_angle = getDirection(points[1].getX()-points[0].getX(), points[1].getY()-points[0].getY());
	double end_angle = getDirection(points[2].getX()-points[1].getX(), points[2].getY()-points[1].getY());
	
	// build perpendicular line for starting point
	stroke(0,0,255,100);
	double offset = 500;
	double line1_angle = start_angle - PI/2.0;
	double dx = offset*cos(line1_angle);
	double dy = offset*sin(line1_angle);
	double[] line1 = {points[0].getX()-dx, points[0].getY()-dy, points[0].getX()+dx, points[0].getY()+dy};
	drawLine(line1[0], line1[1], line1[2], line1[3]);

	// build perpendicular line for end point
	double line2_angle = end_angle - PI/2.0;
	dx = offset*cos(line2_angle);
	dy = offset*sin(line2_angle);
	double[] line2 = {points[2].getX()-dx, points[2].getY()-dy, points[2].getX()+dx, points[2].getY()+dy};
	drawLine(line2[0], line2[1], line2[2], line2[3]);
	
	// determine intersection of these two lines
	double[] intersection = intersectsLineLine(line1, line2);
	if(intersection!=null) {
		int x = (int)round(intersection[0]);
		int y = (int)round(intersection[1]);
		stroke(255,0,0);
		drawEllipse(x,y,5,5); }

	// show offset points
	stroke(0,0,255,200);
	offset = 25;
	dx = offset*cos(line1_angle);
	dy = offset*sin(line1_angle);
	Point offset1 = new Point(points[0].getX()+dx, points[0].getY()+dy);
	drawEllipse(offset1.getX(), offset1.getY(), 3,3);

	dx = offset*cos(line2_angle);
	dy = offset*sin(line2_angle);
	Point offset2 = new Point(points[2].getX()+dx, points[2].getY()+dy);
	drawEllipse(offset2.getX(), offset2.getY(), 3,3);
	
	// build lines from offset points parallel to contol lines
	stroke(255,0,255,100);
	offset = 500;
	dx = offset*cos(start_angle);
	dy = offset*sin(start_angle);
	double[] line3 = {offset1.getX(), offset1.getY(), offset1.getX()+dx, offset1.getY()+dy};
	drawLine(line3[0], line3[1], line3[2], line3[3]);
	dx = offset*cos(end_angle+PI);
	dy = offset*sin(end_angle+PI);
	double[] line4 = {offset2.getX(), offset2.getY(), offset2.getX()+dx, offset2.getY()+dy};
	drawLine(line4[0], line4[1], line4[2], line4[3]);
	
	intersection = intersectsLineLine(line3, line4);
	if(intersection!=null) {
		int ix = (int)round(intersection[0]);
		int iy = (int)round(intersection[1]);
		// since we now can, let's just draw the offset curve in grey
		for(double t=0; t<=1.0; t+=1.0/60.0) {
			int x = (int) computeQuadraticBaseValue(t, offset1.getX(), ix, offset2.getX());
			int y = (int) computeQuadraticBaseValue(t, offset1.getY(), iy, offset2.getY());
			stroke(127);
			drawPoint(x,y); }}
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
		int x = (int) computeQuadraticBaseValue(t, 0, x2, x3); 
		int y = (int) computeQuadraticBaseValue(t, 0, y2, 0);
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