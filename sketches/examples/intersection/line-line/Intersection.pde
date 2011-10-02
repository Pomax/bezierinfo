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
 * Set up four points, to form two lines
 */
void setupPoints()
{
	points = new Point[4];
	points[0] = new Point(50,50);
	points[1] = new Point(150,110);
	points[2] = new Point(50,250);
	points[3] = new Point(170,170);
}

// REQUIRED METHOD
void draw()
{
	noFill();
	stroke(0);
	background(255);
	drawExtras();
	drawLines();
	showPoints(points);
}

/**
 * Draw the two line segment <1,2> and <3,4>
 */
void drawLines()
{
	stroke(0);
	drawLine(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY());
	drawLine(points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY());
}

/**
 * Draw the lines that our line segments are intervals on,
 * plus the intersection (if there is one)
 */
void drawExtras()
{
	stroke(0,50);
	// possible?
	double den = (points[1].getX()-points[0].getX());
	if(den!=0) {
		double a = (points[1].getY()-points[0].getY()) / den;
		double b = points[0].getY() - (a * points[0].getX());
		drawLine(0,b, boxsize, a*boxsize +b); }
	else { drawLine(points[0].getX(),0,points[0].getX(),boxsize); }

	den = (points[3].getX()-points[2].getX());
	if(den!=0) {
		double c = (points[3].getY()-points[2].getY()) / den;
		double d = points[2].getY() - (c * points[2].getX());
		drawLine(0,d, boxsize, c*boxsize +d); }
	else { drawLine(points[2].getX(),0,points[2].getX(),boxsize); }

	double[] line1 = {points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY()};
	double[] line2 = {points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY()};
	// NOTE: intersectsLineLine() is found in common/common.pde
	double[] intersection = intersectsLineLine(line1, line2);
	
	if(intersection!=null) {
		drawIntersection(intersection[0], intersection[1], line1, line2); }
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

		if(bounds_xmin<=ix && ix<=bounds_xmax && bounds_ymin<=iy && iy<=bounds_ymax) {
			fill(0,255,0); stroke(0,255,0); }
		else { fill(255,0,0); stroke(255,0,0); }
		drawEllipse(ix,iy,6,6);
	}
}