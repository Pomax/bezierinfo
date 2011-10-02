// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

ViewPort main, fatline, params;
Point[] points;
Bezier3 flcurve;
Bezier3 curve;
int boxsize = 200;

// REQUIRED METHOD
void setup()
{
	size(50 + 3*(boxsize+50),50+boxsize+50);
	noLoop();
	setupPoints();
	setupViewPorts();
	text("",0,0);
}

/**
 * Set up four points, to form a cubic curve, and a static curve that is used for intersection checks
 */
void setupPoints()
{
	points = new Point[4];
	points[0] = new Point(85,30);
	points[1] = new Point(180,50);
	points[2] = new Point(30,155);
	points[3] = new Point(130,160);

	curve = new Bezier3(175,25,	55,40,	140,140,	85,210);
	curve.setShowControlPoints(false);
}


/**
 * Set up three 'view ports', because we'll be drawing three different things
 */
void setupViewPorts()
{
	main = new ViewPort(50+0,50,boxsize,boxsize);
	fatline = new ViewPort(50+250,50,boxsize,boxsize);
	params = new ViewPort(50+500,50,boxsize,boxsize);
}

// REQUIRED METHOD
void draw()
{
	noFill();
	stroke(0);
	background(255);
	drawViewPorts();
	drawCurves();
	drawFatLine();
	drawClipping();
	drawExtras();
}

/**
 * Draw all the viewport graphics
 * (axes, labels, numbering, etc)
 */
void drawViewPorts()
{
	main.drawText("C1 (interactive) and C2 (fixed)", -20,-25, 0,0,0,255);
	main.drawLine(0,0,0,main.height,	0,0,0,255);
	main.drawLine(0,0,main.width,0,	0,0,0,255);

	fatline.drawText("Fat Line for C1 (baseline in green)", -20,-25, 0,0,0,255);
	fatline.drawLine(0,0,0,main.height,	0,0,0,255);
	fatline.drawLine(0,0,main.width,0,	0,0,0,255);

	params.drawText("Distance function for C2 to C1's baseline", -20,-25, 0,0,0,255);
	params.drawLine(0,0,0,main.height,	0,0,0,255);
	params.drawLine(0,0,main.width,0,	0,0,0,255);
	params.drawText("D ↓", -20,40, 0,0,0,255);
	params.drawText("t →", 40,-5, 0,0,0,255);
	params.drawText("0", -3,-7, 0,0,0,255);
	params.drawLine(0,-4,0,0, 0,0,0,255);
	params.drawText("0.5", 93,-7, 0,0,0,255);
	params.drawLine(100,-4,100,0, 0,0,0,255);
	params.drawText("1", 195,-7, 0,0,0,255);
	params.drawLine(200,-4,200,0, 0,0,0,255);
}

/**
 * Run through the entire interval [0,1] for 't', and generate
 * the corresponding fx(t) and fy(t) values at each 't' value.
 * Then draw those as points in three places: once as mixed
 * parametric curve, and twice as component single curves
 */
void drawCurves()
{
	curve.setColor(200,200,200);
	curve.draw(main.ox, main.oy);	

	double range = 200;
	for(float t = 0; t<1.0; t+=1.0/range) {
		double x = computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
		double y = computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
		main.drawPoint(x,y, 0,0,0,255); 
		if(t==0) { main.drawText("C1",x+5,y-3, 0,0,0,150); }
		fatline.drawPoint(x,y, 0,0,0,255);
	}
	
	double x = computeCubicBaseValue(0, curve.points[0].getX(), curve.points[1].getX(), curve.points[2].getX(), curve.points[3].getX());
	double y = computeCubicBaseValue(0, curve.points[0].getY(), curve.points[1].getY(), curve.points[2].getY(), curve.points[3].getY());
	main.drawText("C2",x+5,y+3, 0,0,0,150);
}

/**
 * 
 */
void drawFatLine()
{
	curve.setColor(200,200,200);
	curve.draw(fatline.ox, fatline.oy);	

	flcurve = new Bezier3(points[0].getX(), points[0].getY(),
											points[1].getX(), points[1].getY(),
											points[2].getX(), points[2].getY(),
											points[3].getX(), points[3].getY());

	flcurve.computeTightBoundingBox();
	double[] bounds = flcurve.getBoundingBox();
	fatline.drawLine(bounds[2],bounds[3], bounds[4],bounds[5], 0,0,200,255);
	fatline.drawLine(bounds[6],bounds[7], bounds[0],bounds[1], 200,0,0,255);
	fatline.drawLine(flcurve.points[0].x, flcurve.points[0].y, flcurve.points[3].x, flcurve.points[3].y, 0,200,0,255);
}

/**
 * FIXME: coordinate ordering (if a-b, ensure a>b in a few places)
 */
void drawClipping()
{
	double[] bounds = flcurve.getBoundingBox();

	// get the distances from C1's baseline to the two other lines
	Point p0 = flcurve.points[0];
	// offset distances from baseline
	double dx = p0.x - bounds[0];
	double dy = p0.y - bounds[1];
	double d1 = sqrt(dx*dx+dy*dy);
	dx = p0.x - bounds[2];
	dy = p0.y - bounds[3];
	double d2 = sqrt(dx*dx+dy*dy);

	// get the distances from C2's point 0 to the three lines
	Point c2p0 = curve.points[0];
	double dxtblue = c2p0.x - bounds[0];
	double dytblue = c2p0.y - bounds[1];
	double dtblue = sqrt(dxtblue*dxtblue + dytblue*dytblue);
	double dxtred = c2p0.x - bounds[2];
	double dytred = c2p0.y - bounds[3];
	double dtred = sqrt(dxtred*dxtred + dytred*dytred);

	// which of d1/d2 is negative, and which is positive?
	if(dtblue <= dtred) { d1 = abs(d1); d2 = -abs(d2); }
	else { d1 = -abs(d1); d2 = abs(d2); }
	
	// find the expression L: ax + by + c = 0 for the baseline
	Point p3 = flcurve.points[3];
	dx = (p3.x - p0.x);
	dy = (p3.y - p0.y);

	// if vertical, salt dx ever so slightly. However, this is only for
	// demonstration purposes, and may result in incorrect clipping. Instead,
	// both curves should be uniformly rotated.
	if(dx==0) { dx=0.1; }

	double a, b, c;
	a = dy / dx;
	b = -1;
	c = -(a * flcurve.points[0].x - flcurve.points[0].y);
	// normalize so that a² + b² = 1
	double scale = sqrt(a*a+b*b);
	a /= scale; b /= scale; c /= scale;		

	// set up the coefficients for the Bernstein polynomial that
	// describes the distance from curve 2 to curve 1's baseline
	double[] coeff = new double[4];
	for(int i=0; i<4; i++) { coeff[i] = a*curve.points[i].x + b*curve.points[i].y + c; }
	double[] vals = new double[4];
	for(int i=0; i<4; i++) { vals[i] = computeCubicBaseValue(i*(1/3), coeff[0], coeff[1], coeff[2], coeff[3]); }

	translate(0,100);

	// draw the fat line + baseline
	params.drawLine(0,d1,200,d1, 100,0,0,255); 
	params.drawText(""+round(d1),-20,d1+5);
	params.drawLine(0,0,200,0, 0,100,0,255); 
	params.drawText("0",-10,5);
	params.drawLine(0,d2,200,d2, 0,0,100,255); 
	params.drawText(""+round(d2),-20,d2+5);

	// draw the distance Bezier function
	double range = 200;
	for(float t = 0; t<1.0; t+=1.0/range) {
		double y = computeCubicBaseValue(t, coeff[0], coeff[1], coeff[2], coeff[3]);
		params.drawPoint(t*range, y, 0,0,0,255); }

	// form the convex hull
	ConvexHull ch = new ConvexHull();
	ArrayList hps = new ArrayList();
	hps.add(new Point(0, coeff[0]));
	hps.add(new Point(range/3, coeff[1]));
	hps.add(new Point(2*range/3, coeff[2]));
	hps.add(new Point(range, coeff[3]));
	Point[] hull = ch.jarvisMarch(hps,-10,-200);

	// draw the convex hull
	noStroke();
	fill(100,100,255,50);
	beginShape();
	for(Point p: hull) { drawVertex(params.ox+p.x,params.oy+p.y); }
	endShape(CLOSE);
	fill(0);

	// draw the control lines
	params.drawLine(0*range, coeff[0], (1.0/3.0)*range, coeff[1], 0,0,255,255);
	params.drawLine((2.0/3.0)*range, coeff[2], 1*range, coeff[3], 0,0,255,255);

	// draw the control points
	for(int i=0; i<4; i++) {
		double x = i * (range/3);
		double y = coeff[i];
		params.drawEllipse(x,y,4,4,	0,0,0,255); 
		params.drawText(""+round(y),x+10,y); }

	// to ensure we are performing intersection validation the correct
	// fat line boundary, we make sure that the lines are such that
	// the convex hull point (0.0, ...) is always above d1.
	if(d1<d2) { double t=d1; d1=d2; d2=t; };

	// are the start and endpoints for the distance function outside of the fat line?
	boolean ssafe = coeff[0]<min(d1,d2) || coeff[0] > max(d1,d2);
	boolean sabove = (coeff[0]>max(d1,d2) ? true : false);
	boolean esafe = coeff[3]<min(d1,d2) || coeff[3] > max(d1,d2);
	boolean eabove = (coeff[3]>max(d1,d2) ? true : false);

	// we start with the safest interval: t1 is 0.0
	double t1 = 0.0;
	// now, are we outside the fat line? if so, we can try to find a better t-value
	if(ssafe)
	{
		// start with the least safe value
		t1 = 1.0;

		// pick the right line for which to perform intersection checking (this is very important)
		double ypos = (sabove? d1 : d2);
		double[] line = {0,ypos,range,ypos};

		// find the two hull edges that join up at the safe point (t=0.0)
		double[][] edges = getEdgesOn(hull, 0.0);

		// now, we have two edges to test for intersection values
		for(int test=0; test<edges.length; test++) {
			double[] intersection = intersectsLineLine(line, edges[test]);
			if(intersection==null) continue;	// unlikely, but safe
			double ix = intersection[0];
			double iy = intersection[1];
			if(ix>=0 && ix<=range) params.drawEllipse(ix, iy, 3, 3, 0,0,255,255);
			double val = ix/range;
			// is this t-value lower (==safer) than what we already have?
			if(val>=0 && val<=1.0 && t1>val) { t1 = val; }}
		// make sure that t values don't drop below 0.0
		if(t1<0) { t1=0; }
		params.drawLine(range*t1,0,range*t1,100, 0,0,0,150);
		params.drawText("t1: "+round(1000*t1)/1000,10+range*t1,100, 0,0,0,150);		
	}

	// we do the same thing for t2, but then in the opposite direction
	double t2 = 1.0;
	if(esafe)
	{
		t2 = 0.0; // least safe value
		double ypos = (eabove? d1 : d2);
		double[] line = {0,ypos,range,ypos};
		double[][] edges = getEdgesOn(hull, range);
		for(int test=0; test<edges.length; test++) {
			double[] intersection = intersectsLineLine(line, edges[test]);
			if(intersection==null) continue;	// unlikely, but safe
			double ix = intersection[0];
			double iy = intersection[1];
			if(ix>=0 && ix<=range) params.drawEllipse(ix, iy, 3, 3, 255,0,0,255);
			double val = ix/range;
			if(val>=0 && val<=1.0 && t2<val) { t2 = val; }}
		// make sure that t values don't go over 1.0
		if(t2>1) { t2=1; }
		params.drawLine(range*t2,0,range*t2,-100, 0,0,0,150);
		params.drawText("t2: "+round(1000*t2)/1000,10+range*t2,-85, 0,0,0,150);
	}

	translate(0,-100);
	
	// we now have our clipping interval t-values: let's clip!
	Segment clipped = curve.splitSegment(t1,t2);
	clipped.setShowPoints(true);
	clipped.setShowControlPoints(false);
	clipped.draw(fatline.ox, fatline.oy);
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
}
