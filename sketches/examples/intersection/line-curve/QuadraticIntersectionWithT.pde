// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

Point[] points;
int steps = 16;
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
 * Set up three points, to form a quadratic curve,
 * and an additional two points, to form a line
 */
void setupPoints()
{
	points = new Point[5];
	points[0] = new Point(25,150);
	points[1] = new Point(180,30);
	points[2] = new Point(230,250);

	points[3] = new Point(40,60);
	points[4] = new Point(260,200);
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
 * Draw the curves, the line, the flattened curve, and
 * the intersections between the line and flattened curve.
 */
void drawCurves()
{

	// first the quadratic curve
	stroke(0,0,255,150);
	double range = 200;
	stroke(0);
	for(float t = 0; t<1.0; t+=1.0/range) {
		float mt = (1-t);
		double x = computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX());
		double y = computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY());
		drawPoint(x,y); }

	// then the line
	stroke(0);
	drawLine(points[3].getX(), points[3].getY(), points[4].getX(), points[4].getY());
	
	// then the flattened curve - the Segment code found in common/Segment.pde
	Segment segment = new Bezier2(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY());
	Segment[] flattened = segment.flatten(steps);
	for(int l=0; l<flattened.length; l++) {
		flattened[l].setShowText(false);
		flattened[l].setShowPoints(false);
		flattened[l].draw(); }
	
	// and finally, the intersections
	double[] oline = {points[3].getX(), points[3].getY(), points[4].getX(), points[4].getY()};
	for(int l=0; l<flattened.length; l++) {
		Line target = (Line) flattened[l];
		double[] tline = {target.points[0].getX(), target.points[0].getY(), target.points[1].getX(), target.points[1].getY()};
		double[] intersection = intersectsLineLine(oline, tline);
		// NOTE: intersectsLineLine() is found in common/common.pde
		if(intersection!=null) { drawIntersection(intersection[0], intersection[1], oline, tline, target.getStartT(), target.getEndT()); }}
}

/**
 * Draw the intersection between the line( segment)s. If it's between
 * lines only, draw point red. If it's between our line segments, draw point
 * green. If the intersection falls outside the screen, nothing is drawn.
 */
void drawIntersection(double ix, double iy, double[] line1, double[] line2, double st, double et)
{
	if(0<=ix && ix<=boxsize && 0<=iy && iy<=boxsize)
	{
		double bounds_1_xmin = min(line1[0], line1[2]);
		double bounds_2_xmin = min(line2[0], line2[2]);
		double bounds_xmin = max(bounds_1_xmin, bounds_2_xmin);

		double bounds_1_xmax = max(line1[0], line1[2]);
		double bounds_2_xmax = max(line2[0], line2[2]);
		double bounds_xmax = min(bounds_1_xmax, bounds_2_xmax);
		
		double bounds_1_ymin = min(line1[1], line1[3]);
		double bounds_2_ymin = min(line2[1], line2[3]);
		double bounds_ymin = max(bounds_1_ymin, bounds_2_ymin);

		double bounds_1_ymax = max(line1[1], line1[3]);
		double bounds_2_ymax = max(line2[1], line2[3]);
		double bounds_ymax = min(bounds_1_ymax, bounds_2_ymax);

		if(bounds_xmin<=ix && ix<=bounds_xmax && bounds_ymin<=iy && iy<=bounds_ymax)
		{
			fill(255,0,255);
			stroke(255,0,0);
			drawEllipse(ix, iy, 5,5);

			// roughly where on the line segment was the intersection point?
			// source code for showEstimatedT is in common/common.pde
			showEstimatedT(ix,iy,line2,st,et);
		}
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
	drawLine(points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY());
	fill(0);
	double precision = 1000;
	double err = ((int)(precision/steps))/(2*precision);
	drawText("flattened quadratic curve, using "+steps+" segments (error: t ± "+err+")", 5,12);
}
