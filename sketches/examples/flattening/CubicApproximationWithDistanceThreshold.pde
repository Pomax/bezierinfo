// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

ViewPort main, flat;
Point[] points;
int steps = 2;
int fsegments;
double flength;
long ms;
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
 * Set up four points, to form a cubic curve
 */
void setupPoints()
{
	points = new Point[4];
	points[0] = new Point(30, 170);
	points[1] = new Point(185, 200);
	points[2] = new Point(20,15);
	points[3] = new Point(185,35);
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
}


/**
 * Run through the entire interval [0,1] for 't', and generate
 * the corresponding flattened curve.
 */
void drawCurves()
{
	// first the cubic curve
	double range = 200;
	for(float t = 0; t<1.0; t+=1.0/range) {
		float mt = (1-t);
		double x = computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
		double y = computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
		main.drawPoint(x,y, 0,0,0,255); }

	// then the flattened curve - the Segment code found in common/Segment.pde
	long start = millis();
	Segment segment = new Bezier3(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY());
	Segment[] flattened = segment.flattenWithDistanceThreshold(steps);
	int r = 0;
	int b = 255;
	double length = 0;
	for(int l=0; l<flattened.length; l++) {
		flattened[l].setShowText(false);
		flattened[l].setShowPoints(false);
		r = (r==0? 255 : 0);
		b = (b==255? 0 : 255);
		flattened[l].setColor(r,0,b);
		flattened[l].draw(flat.ox, flat.oy); 
		length += flattened[l].getLength(); }
	fsegments = flattened.length;
	flength = ((double)((int)(100*length)))/100;
	ms = millis()-start;
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
	main.drawLine(points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY(), 0,0,0,75);

	flat.drawText("Flattened curve (threshold: "+steps+"px) "+fsegments+" segments", 0,-25, 0,0,0,255);	
	flat.drawText("Estimated arc length of this curve ("+ms+"ms): "+flength, 0,-10, 0,0,0,255);	
}