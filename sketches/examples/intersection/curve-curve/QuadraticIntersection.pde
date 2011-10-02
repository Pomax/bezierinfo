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
 * Set up six points, to form two quadratic curves
 */
void setupPoints()
{
	points = new Point[6];
	points[0] = new Point(240,40);
	points[1] = new Point(30,140);
	points[2] = new Point(250,200);

	points[3] = new Point(50,240);
	points[4] = new Point(150,30);
	points[5] = new Point(240,250);
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
 * Draw both curves, their flattened versions, and
 * the intersections between the flattened curves.
 */
void drawCurves()
{
	// first quadratic curve
	stroke(0,0,255,150);
	double range = 200;
	stroke(0,100);
	for(float t = 0; t<1.0; t+=1.0/range) {
		float mt = (1-t);
		double x = computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX());
		double y = computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY());
		drawPoint(x,y); }

	// second quadratic curve
	for(float t = 0; t<1.0; t+=1.0/range) {
		float mt = (1-t);
		double x = computeQuadraticBaseValue(t, points[3].getX(), points[4].getX(), points[5].getX());
		double y = computeQuadraticBaseValue(t, points[3].getY(), points[4].getY(), points[5].getY());
		drawPoint(x,y); }

	// then the flattened curves - the Segment code found in common/Segment.pde
	Segment segment = new Bezier2(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY());
	Segment[] flattened1 = segment.flatten(steps);
	for(int l=0; l<flattened1.length; l++) {
		flattened1[l].setShowText(false);
		flattened1[l].setShowPoints(false);
		flattened1[l].draw(); }

	segment = new Bezier2(points[3].getX(), points[3].getY(), points[4].getX(), points[4].getY(), points[5].getX(), points[5].getY());
	Segment[] flattened2 = segment.flatten(steps);
	for(int l=0; l<flattened1.length; l++) {
		flattened2[l].setShowText(false);
		flattened2[l].setShowPoints(false);
		flattened2[l].draw(); }

	// and finally, the intersections
	for(int l1=0; l1<flattened1.length; l1++) {
		Line reference = (Line) flattened1[l1];
		double[] line1 = {reference.points[0].getX(), reference.points[0].getY(), reference.points[1].getX(), reference.points[1].getY()};
		for(int l2=0; l2<flattened2.length; l2++) {
			Line target = (Line) flattened2[l2];
			double[] line2 = {target.points[0].getX(), target.points[0].getY(), target.points[1].getX(), target.points[1].getY()};
			double[] intersection = intersectsLineLine(line1, line2);
			// NOTE: intersectsLineLine() is found in common/common.pde
			if(intersection!=null) { drawIntersection(intersection[0], intersection[1], line1, line2); }}}
}

/**
 * Draw the intersection between the line( segment)s. If it's between
 * lines only, draw point red. If it's between our line segments, draw point
 * green. If the intersection falls outside the screen, nothing is drawn.
 */
void drawIntersection(double ix, double iy, double[] line1, double[] line2)
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
	drawLine(points[3].getX(), points[3].getY(), points[4].getX(), points[4].getY());
	drawLine(points[4].getX(), points[4].getY(), points[5].getX(), points[5].getY());
	fill(0);
	drawText("flattened quadratic curve, using "+steps+" segments", 5,12);
}
