// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

Point[] points;
int boxsize = 300;
int steps = 30;

// REQUIRED METHOD
void setup()
{
	size(boxsize,boxsize);
	noLoop();
	setupSegments();
	text("",0,0);
}

/**
 * Set up three points, to form a quadratic curve
 */
void setupSegments()
{
	points = new Point[3];
	points[0] = new Point(30,110);
	points[1] = new Point(145,55);
	points[2] = new Point(260,160);
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
	Bezier2 linesegment = new Bezier2(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY());
	linesegment.draw();
	drawOffsets(linesegment);
}

void drawOffsets(Segment segment) {
	Segment[] segments = segment.offset(0);
	Segment[] n_offset = segment.offset(-20);
	Segment[] f_offset = segment.offset(-(20+steps));
	
	for(int f=0; f<n_offset.length; f++) {
		if(f%2==0) { n_offset[f].setColor(200,200,255); } else { n_offset[f].setColor(255,200,200); }
		n_offset[f].setShowPoints(false);
		n_offset[f].draw(); 
		
		if(f%2==0) { f_offset[f].setColor(255,200,200); } else { f_offset[f].setColor(200,200,255); }
		f_offset[f].setShowPoints(false);
		f_offset[f].draw();

		// interpolation, t-value based
		Bezier2 interpolated = interpolateQuadraticForT(segments[f], n_offset[f], f_offset[f], n_offset[f].getStartT(), n_offset[f].getEndT());
		if(interpolated!=null) {
			interpolated.setShowPoints(false);
			interpolated.setColor(0,150,0);
			interpolated.draw(); }
	}
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
	drawLine(points[2].getX(), points[2].getY(), points[1].getX(), points[1].getY());
}
