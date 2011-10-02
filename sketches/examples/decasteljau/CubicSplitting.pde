// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

ViewPort main, first, second;
Point[] points;
int boxsize = 200;

// REQUIRED METHOD
void setup()
{
	size(800,boxsize+100);
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
	points[0] = new Point(20, 20);
	points[1] = new Point(150, 20);
	points[2] = new Point(50,150);
	points[3] = new Point(170,170);
}

/**
 * Set up three 'view ports', because we'll be drawing three different things
 */
void setupViewPorts()
{
	main = new ViewPort(50+0,50+0,boxsize,boxsize);
	first = new ViewPort(50+250,50+0,boxsize,boxsize);
	second = new ViewPort(50+500,50+0,boxsize,boxsize);
}

// REQUIRED METHOD
void draw()
{
	if(playing) {
		noFill();
		stroke(0);
		background(255);
		drawViewPorts();
		PointSegment ps = drawCurves();
		drawExtras(ps); }
	// pause after first draw (playback controls are interactive)
	if(firstrun) { pause(); }
}

/**
 * Draw all the viewport graphics
 */
void drawViewPorts()
{
	main.drawLine(0,0,0,main.height,  0,0,0,255);
	main.drawLine(0,0,main.width,0,  0,0,0,255);
	String st = "" + ((int)(100*splitting_t))/100.0;
	while(st.length()<4) { st += "0"; } 
	main.drawText("Full curve, splitting at t="+st, 0,-15, 0,0,0,255);

	first.drawLine(0,0,0,first.height,  0,0,0,255);
	first.drawLine(0,0,first.width,0,  0,0,0,255);
	first.drawText("First subcurve", 0,-15, 0,0,0,255);

	second.drawLine(0,0,0,second.height,  0,0,0,255);
	second.drawLine(0,0,second.width,0,  0,0,0,255);
	second.drawText("Second subcurve", 0,-15, 0,0,0,255);
}

double splitting_step = 0.01;
double splitting_t = 0.0;
boolean flip = false;

/**
 * Run through the entire interval [0,1] for 't', and generate
 * the subcurves that result from splitting at a particular
 * (per-draw incremented) t value.
 */
PointSegment drawCurves()
{
	// NOTE: splitCubicCurve is found in common/BezierFunctions.pde
	Segment[] subcurves = splitCubicCurve(splitting_t, points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY());

	// draw main curve, with shadow copies in the extra two viewports
	double range = 200;
	for(float t = 0; t<1.0; t+=1.0/range) {
		// main curve		
		double x = computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
		double y = computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
		main.drawPoint(x,y, 0,0,0,255); 
		first.drawPoint(x,y, 0,0,0,100); 
		second.drawPoint(x,y, 0,0,0,100); }

	// highlight where we are splitting this curve
	double x = computeCubicBaseValue(splitting_t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
	double y = computeCubicBaseValue(splitting_t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
	main.drawEllipse(x,y,4,4,  255,0,0,255);

	// draw the subcurves
	stroke(0);
	int id1 = flip? 0 : 1;
	int id2 = flip? 1 : 0;
	subcurves[id1].draw(first.ox, first.oy);
	subcurves[id2].draw(second.ox, second.oy);

	// draw the subcurve control lines
	Point[] c1points = subcurves[id1].points;
	first.drawLine(c1points[0].getX(), c1points[0].getY(), c1points[1].getX(), c1points[1].getY(), 0,0,0,75);
	first.drawLine(c1points[2].getX(), c1points[2].getY(), c1points[3].getX(), c1points[3].getY(), 0,0,0,75);
	Point[] c2points = subcurves[id2].points;
	second.drawLine(c2points[0].getX(), c2points[0].getY(), c2points[1].getX(), c2points[1].getY(), 0,0,0,75);
	second.drawLine(c2points[2].getX(), c2points[2].getY(), c2points[3].getX(), c2points[3].getY(), 0,0,0,75);
	
	// set up the splitting value for 't' for the next position
	splitting_t = splitting_t + splitting_step;
	if(splitting_t>1.0-splitting_step) { splitting_t = 0; flip=!flip; }
	
	// return the intermediate values, for further drawing
	return (PointSegment)subcurves[2];
}

/**
 * For nice visuals, make the curve's fixed points stand out,
 * and draw the lines connecting the start/end and control point.
 * Also, we label each coordinate with its x/y value, for clarity.
 */
void drawExtras(PointSegment pointsegment)
{
	showPointsInViewPort(points,main);
	stroke(0,75);
	main.drawLine(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), 0,0,0,75);
	main.drawLine(points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY(), 0,0,0,75);
	
	// show splitting values
	pointsegment.setShowText(false);
	pointsegment.draw(main.ox, main.oy);
	Point[] spoints = pointsegment.points;
	main.drawLine(spoints[0].getX(), spoints[0].getY(), spoints[1].getX(), spoints[1].getY(), 0,200,0,255);
	main.drawLine(spoints[1].getX(), spoints[1].getY(), spoints[2].getX(), spoints[2].getY(), 0,200,0,255);
	main.drawLine(spoints[3].getX(), spoints[3].getY(), spoints[4].getX(), spoints[4].getY(), 200,200,0,255);
}