// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

ViewPort main, flat;
Point[] points;
int steps = 2;
int boxsize = 200;

// REQUIRED METHOD
void setup()
{
	size(2*boxsize + 150,boxsize+100);
	noLoop();
	setupPoints();
	setupViewPorts();
	text("",0,0);
}

/**
 * Set up three points, to form a quadratic curve
 */
void setupPoints()
{
	points = new Point[3];
	points[0] = new Point(70,175);
	points[1] = new Point(25,80);
	points[2] = new Point(190,40);
}

/**
 * Set up three 'view ports', because we'll be drawing three different things
 */
void setupViewPorts()
{
	main = new ViewPort(50+0,50+0,boxsize,boxsize);
	flat = new ViewPort(50+250,50+0,boxsize,boxsize);
}

// REQUIRED METHOD
void draw()
{
	noFill();
	stroke(0);
	background(255);
	drawViewPorts();
	drawCurves();
	drawExtras();
}

/**
 * Draw all the viewport graphics
 */
void drawViewPorts()
{
	main.drawLine(0,0,0,main.height,  0,0,0,255);
	main.drawLine(0,0,main.width,0,  0,0,0,255);
	main.drawText("Original curve", 0,-15, 0,0,0,255);

	flat.drawLine(0,0,0,main.height,  0,0,0,255);
	flat.drawLine(0,0,main.width,0,  0,0,0,255);
	flat.drawText("Flattened curve, "+steps+" segments", 0,-15, 0,0,0,255);
}

// if we flatten a curve, we also know how long it is (approximately!)
double arc_length=0;

/**
 * Run through the entire interval [0,1] for 't', and generate
 * the corresponding flattened curve.
 */
void drawCurves()
{
	// first the quadratic curve
	double range = 200;
	for(float t = 0; t<1.0; t+=1.0/range) {
		float mt = (1-t);
		double x = computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX());
		double y = computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY());
		main.drawPoint(x,y, 0,0,0,255); }
	
	// then the flattened curve - the Segment code found in common/Segment.pde
	Segment segment = new Bezier2(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY());
	Segment[] flattened = segment.flatten(steps);
	for(int l=0; l<flattened.length; l++) {
		flattened[l].setShowText(false);
		flattened[l].draw(flat.ox, flat.oy); }
}

/**
 * For nice visuals, make the curve's fixed points stand out,
 * and draw the lines connecting the start/end and control point.
 * Also, we label each coordinate with its x/y value, for clarity.
 */
void drawExtras()
{
	showPointsInViewPort(points,main);
	stroke(0,75);
	main.drawLine(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), 0,0,0,75);
	main.drawLine(points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY(), 0,0,0,75);
}
