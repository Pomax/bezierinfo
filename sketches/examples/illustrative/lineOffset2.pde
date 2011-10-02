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
	points = new Point[2];
	points[0] = new Point(35,230);
	points[1] = new Point(270,135);
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
	Line linesegment = new Line(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY());
	linesegment.setShowPoints(false);
	linesegment.draw();
	drawOffsets(linesegment);
}

void drawOffsets(Segment segment) {
	Segment[] n_offset = segment.offset(-20);
	Segment[] f_offset = segment.offset(-(20+steps));
	
	for(int f=0; f<n_offset.length; f++) {
		if(f%2==0) { n_offset[f].setColor(200,200,255); } else { n_offset[f].setColor(255,200,200); }
		n_offset[f].setShowPoints(false);
		n_offset[f].draw(); 
		
		if(f%2==0) { f_offset[f].setColor(255,200,200); } else { f_offset[f].setColor(200,200,255); }
		f_offset[f].setShowPoints(false);
		f_offset[f].draw();
		
		Line interpolated = new Line(n_offset[f].points[0].getX(), n_offset[f].points[0].getY(), 
												f_offset[f].points[1].getX(), f_offset[f].points[1].getY());
		interpolated.setShowPoints(false);
		interpolated.setColor(0,150,0);
		interpolated.draw();
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
}
