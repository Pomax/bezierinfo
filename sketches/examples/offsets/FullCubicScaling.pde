// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

Point[] points;
int boxsize = 400;
int steps = 25;

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
	points[0] = new Point(335,315);
	points[1] = new Point(250,25);
	points[2] = new Point(20,160);
	points[3] = new Point(110,195);
}

// REQUIRED METHOD
void draw()
{
	noFill();
	stroke(0);
	background(255);
	drawCurves();
	drawExtras();
}

/**
 * Run through the entire interval [0,1] for 't'.
 */
void drawCurves()
{
	Bezier3 cubicsegment = new Bezier3(points[0].getX(), points[0].getY(),
														points[1].getX(), points[1].getY(),
														points[2].getX(), points[2].getY(),
														points[3].getX(), points[3].getY());
	cubicsegment.draw();
	Segment[] offset = cubicsegment.offset(steps);
	for(int f=0; f<offset.length; f++) {
		if(f%2==0) { offset[f].setColor(200,200,255); }
		else { offset[f].setColor(255,200,200); }
		offset[f].setShowPoints(false);
		offset[f].draw(); }
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
	drawLine(points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY());
	fill(0);
	drawText("Offset curve based on "+steps+" pixel extrusion", 5,12);
}