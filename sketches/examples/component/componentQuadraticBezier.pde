// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

ViewPort main, cx, cy;
Point[] points;
int boxsize = 200;

// REQUIRED METHOD
void setup()
{
	size(800,boxsize+100);
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
	cx = new ViewPort(50+250,50+0,boxsize,boxsize);
	cy = new ViewPort(50+500,50+0,boxsize,boxsize);
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
 * (axes, labels, numbering, etc)
 */
void drawViewPorts()
{
	main.drawLine(0,0,0,main.height,  0,0,0,255);
	main.drawLine(0,0,main.width,0,  0,0,0,255);
	main.drawText("Full curve", 0,-15, 0,0,0,255);

	cx.drawText("Only f(t) for X coordinates", -20,-25, 0,0,0,255);
	cx.drawText("t →", 100,-5, 0,0,0,255);
	cx.drawText("0", -2,-10, 0,0,0,255);
	cx.drawLine(0,0,0,main.height,  0,0,0,255);
	cx.drawText("1", main.width-4,-8, 0,0,0,255);
	cx.drawLine(0,0,main.width,0,  0,0,0,255);
	cx.drawLine(0,0,0,-5,  0,0,0,255);
	cx.drawLine(main.width,0,main.width,-5,  0,0,0,255);
	cx.drawText("X ↓", -20,130, 0,0,0,255);

	cy.drawText("Only f(t) for Y coordinates", -20,-25, 0,0,0,255);
	cy.drawText("t →", 100,-5, 0,0,0,255);
	cy.drawText("0", -2,-10, 0,0,0,255);
	cy.drawLine(0,0,0,main.height,  0,0,0,255);
	cy.drawText("1", main.width-4,-8, 0,0,0,255);
	cy.drawLine(0,0,main.width,0,  0,0,0,255);
	cy.drawLine(0,0,0,-5,  0,0,0,255);
	cy.drawLine(main.width,0,main.width,-5,  0,0,0,255);
	cy.drawText("Y ↓", -20,130, 0,0,0,255);
}

/**
 * Run through the entire interval [0,1] for 't', and generate
 * the corresponding fx(t) and fy(t) values at each 't' value.
 * Then draw those as points in three places: once as mixed
 * parametric curve, and twice as component single curves
 */
void drawCurves()
{
	double range = 200;
	for(float t = 0; t<1.0; t+=1.0/range) {
		double x = computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX());
		double y = computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY());
		main.drawPoint(x,y, 0,0,0,255); 
		cx.drawPoint(t*range, x, 0,0,0,255);
		cy.drawPoint(t*range, y, 0,0,0,255);
	}
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
