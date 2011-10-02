// Dependencies are in the "common" directory
// © 2011 Mike "Pomax" Kamermans of nihongoresources.com

ViewPort main, bbox;
Point[] points;
Bezier3 curve1, curve2;
int boxsize = 200;

// REQUIRED METHOD
void setup()
{
	size(2*boxsize+150,200+100);
	noLoop();
	setupPoints();
	setupViewPorts();
	text("",0,0);
}

/**
 * Set up 2 x four points, to form two cubic curves
 */
void setupPoints()
{
	points = new Point[8];
	points[0] = new Point(25,65);
	points[1] = new Point(155,20);
	points[2] = new Point(50,210);
	points[3] = new Point(180,130);

	points[4] = new Point(130,205);
	points[5] = new Point(190,60);
	points[6] = new Point(20,160);
	points[7] = new Point(60,15);
}

void updateCurves()
{
	curve1 = new Bezier3(points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y, points[3].x, points[3].y);
	curve1.computeBoundingBox();
	curve1.setShowPoints(false);
	curve2 = new Bezier3(points[4].x, points[4].y, points[5].x, points[5].y, points[6].x, points[6].y, points[7].x, points[7].y);
	curve2.computeBoundingBox();
	curve2.setShowPoints(false);
}

/**
 * Set up two 'view ports'
 */
void setupViewPorts()
{
	main = new ViewPort(50+0,50+0,boxsize,boxsize);
	bbox = new ViewPort(50+250,50+0,boxsize,boxsize);
}

int drawmode = 0;

// REQUIRED METHOD
void draw()
{
	// normal sketch
	if(drawmode==0)
	{
		updateCurves();
		noFill();
		stroke(0);
		background(255);
		drawViewPorts();
		drawCurves();
		drawExtras();
	}
	
	// animated subdivision algorithm
	else if(drawmode==1)
	{
		noStroke();
		fill(255);
		rect(250,0,300,300);
		if(iterate())
		{
			drawSubDiv();
			ArrayList intersections = new ArrayList();
			for(CurvePair cp: finals)
			{
				double[] intersection = cp.getIntersection();
				Point p = new Point(intersection[0], intersection[1]);
				if(!intersections.contains(p)) {
					intersections.add(p);
					double t1 = round(1000*intersection[2])/1000;
					double t2 = round(1000*intersection[3])/1000;
					String tinfo = "t1: "+t1+"\nt2: "+t2;
					bbox.drawText(tinfo, p.x+10, p.y, 0,0,0,100);
					bbox.drawEllipse(p.x, p.y, 4, 4,  200,0,0,255);
					
					main.drawLine(curve1.getX(t1), 0, curve1.getX(t1), curve1.getY(t1),  255,0,0,100);
					main.drawLine(0,curve1.getY(t1), curve1.getX(t1), curve1.getY(t1), 255,0,0,100);
					main.drawLine(curve2.getX(t2), 0, curve2.getX(t2), curve2.getY(t2),  0,0,255,100);
					main.drawLine(0,curve2.getY(t2), curve2.getX(t2), curve2.getY(t2), 0,0,255,100);
				}
			}
			drawmode=0;
			noLoop(); 
		}
		else
		{
			drawSubDiv();
			//println("["+cstep+"] evaluating "+curvepairs.size()+" pair"+(curvepairs.size()==1? "s":""));
			for(CurvePair cp: curvepairs) { cp.draw(bbox.ox, bbox.oy); }
		}
	}
}

/**
 * Draw all the viewport graphics
 * (axes, labels, numbering, etc)
 */
void drawViewPorts()
{
	main.drawText("curves", -20,-25, 0,0,0,255);
	main.drawLine(0,0,0,main.height,  0,0,0,255);
	main.drawLine(0,0,main.width,0,  0,0,0,255);

	drawSubDiv();
}

void drawSubDiv()
{
	bbox.drawText("subdivision - "+cstep, -20,-25, 0,0,0,255);
	bbox.drawLine(0,0,0,main.height,  0,0,0,255);
	bbox.drawLine(0,0,main.width,0,  0,0,0,255);
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
		double x = computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX());
		double y = computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY());
		main.drawPoint(x,y, 0,0,0,255); 
		bbox.drawPoint(x,y, 0,0,0,255);
		x = computeCubicBaseValue(t, points[4].getX(), points[5].getX(), points[6].getX(), points[7].getX());
		y = computeCubicBaseValue(t, points[4].getY(), points[5].getY(), points[6].getY(), points[7].getY());
		main.drawPoint(x,y, 0,0,0,255); 
		bbox.drawPoint(x,y, 0,0,0,255);
	}

	translate(bbox.ox, bbox.oy);	
	double[] bounds = curve1.getBoundingBox();
	beginShape();
	drawVertex(bounds[0], bounds[1]);
	drawVertex(bounds[2], bounds[3]);
	drawVertex(bounds[4], bounds[5]);
	drawVertex(bounds[6], bounds[7]);
	stroke(255,0,0,150);
	noFill();
	endShape(CLOSE);

	bounds = curve2.getBoundingBox();
	beginShape();
	drawVertex(bounds[0], bounds[1]);
	drawVertex(bounds[2], bounds[3]);
	drawVertex(bounds[4], bounds[5]);
	drawVertex(bounds[6], bounds[7]);
	stroke(0,0,255,150);
	noFill();
	endShape(CLOSE);
	translate(-bbox.ox, -bbox.oy);	
}

// PLAY TRIGGER
void keyTyped() { if(int(key)==10) { startAlgorithm(); } }

ArrayList<CurvePair> curvepairs;
ArrayList<CurvePair> finals;

/** 
 *
 */
void startAlgorithm()
{
	cstep=0;
	frameRate(1);
	loop();
	drawmode = 1;
	curvepairs = new ArrayList();
	updateCurves();
	curvepairs.add(new CurvePair(curve1,curve2));
	finals = new ArrayList();
	redraw();
}

int cstep = 0;

/**
 * Perform an iteration step
 */
boolean iterate()
{
	cstep++;
	
	// crisis measure
	if(curvepairs.size()>100) {
		println("ERROR: math failz! the list of potential intersections has gotten way too big:");
		for(int cps=curvepairs.size()-1; cps>=0; cps--) {
			CurvePair curvepair = (CurvePair)curvepairs.remove(cps);
			println(curvepair.toString()); }
		return true;
	}

	else
	{
		boolean finished = true;

		// subdivide all curves with overlapping bounding boxes.
		// if we're left with more than 0 pairs in the to-do list,
		// we're not finished yet
		for(int cps=curvepairs.size()-1; cps>=0; cps--) {
			CurvePair curvepair = (CurvePair)curvepairs.remove(cps);
			ArrayList<CurvePair> subpairs = curvepair.generateSubPairs();
			if(subpairs==null) {
				if(!finals.contains(curvepair)) {
					finals.add(curvepair); }}
			else {
				finished = false;
				for(int ncp=subpairs.size()-1; ncp>=0; ncp--) {
					curvepairs.add(subpairs.get(ncp)); }}}
	
		return finished;
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
	main.drawLine(points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY(), 0,0,0,75);
	main.drawLine(points[4].getX(), points[4].getY(), points[5].getX(), points[5].getY(), 0,0,0,75);
	main.drawLine(points[6].getX(), points[6].getY(), points[7].getX(), points[7].getY(), 0,0,0,75);
}