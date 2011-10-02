/**
 * Cubic functions
 */

/**
 * compute the value for the cubic bezier function at time=t
 */
double computeCubicBaseValue(double t, double a, double b, double c, double d) {
	double mt = 1-t;
	return mt*mt*mt*a + 3*mt*mt*t*b + 3*mt*t*t*c + t*t*t*d; }

/**
 * compute the value for the first derivative of the cubic bezier function at time=t
 */
double[] computeCubicFirstDerivativeRoots(double a, double b, double c, double d) {
	double[] ret = {-1,-1};
	double tl = -a+2*b-c;
	double tr = -sqrt((float)(-a*(c-d) + b*b - b*(c+d) +c*c));
	double dn = -a+3*b-3*c+d;
	if(dn!=0) { ret[0] = (tl+tr)/dn; ret[1] = (tl-tr)/dn; }
	return ret; }

/**
 * compute the value for the second derivative of the cubic bezier function at time=t
 */
double computeCubicSecondDerivativeRoot(double a, double b, double c, double d) {
	double ret = -1;
	double tt = a-2*b+c;
	double dn = a-3*b+3*c-d;
	if(dn!=0) { ret = tt/dn; }
	return ret; }

/**
 * Compute the bounding box based on the straightened curve, for best fit
 */
double[] computeCubicBoundingBox(double xa, double ya, double xb, double yb, double xc, double yc, double xd, double yd)
{
	// find the zero point for x and y in the derivatives
	double minx = 9999;
	double maxx = -9999;
	if(xa<minx) { minx=xa; }
	if(xa>maxx) { maxx=xa; }
	if(xd<minx) { minx=xd; }
	if(xd>maxx) { maxx=xd; }
	double[] ts = computeCubicFirstDerivativeRoots(xa, xb, xc, xd);
	for(int i=0; i<ts.length;i++) {
		double t = ts[i];
		if(t>=0 && t<=1) {
			double x = computeCubicBaseValue(t, xa, xb, xc, xd);
			double y = computeCubicBaseValue(t, ya, yb, yc, yd);
			if(x<minx) { minx=x; }
			if(x>maxx) { maxx=x; }}}

	double miny = 9999;
	double maxy = -9999;
	if(ya<miny) { miny=ya; }
	if(ya>maxy) { maxy=ya; }
	if(yd<miny) { miny=yd; }
	if(yd>maxy) { maxy=yd; }
	ts = computeCubicFirstDerivativeRoots(ya, yb, yc, yd);
	for(int i=0; i<ts.length;i++) {
		double t = ts[i];
		if(t>=0 && t<=1) {
			double x = computeCubicBaseValue(t, xa, xb, xc, xd);
			double y = computeCubicBaseValue(t, ya, yb, yc, yd);
			if(y<miny) { miny=y; }
			if(y>maxy) { maxy=y; }}}

	// bounding box corner coordinates
	double[] bbox = {minx,miny, minx,maxy, maxx,maxy, maxx,miny};
	return bbox;
}


/**
 * Compute the bounding box based on the straightened curve, for best fit
 */
double[] computeCubicTightBoundingBox(double xa, double ya, double xb, double yb, double xc, double yc, double xd, double yd)
{
	// translate to 0,0
	Point np2 = new Point(xb - xa, yb - ya);
	Point np3 = new Point(xc - xa, yc - ya);
	Point np4 = new Point(xd - xa, yd - ya);

	// get angle for rotation
	float angle = (float) getDirection(np4.getX(), np4.getY());
	
	// rotate everything counter-angle so that it's aligned with the x-axis
	Point rnp2 = new Point(np2.getX() * cos(-angle) - np2.getY() * sin(-angle), np2.getX() * sin(-angle) + np2.getY() * cos(-angle));
	Point rnp3 = new Point(np3.getX() * cos(-angle) - np3.getY() * sin(-angle), np3.getX() * sin(-angle) + np3.getY() * cos(-angle));
	Point rnp4 = new Point(np4.getX() * cos(-angle) - np4.getY() * sin(-angle), np4.getX() * sin(-angle) + np4.getY() * cos(-angle));

	// find the zero point for x and y in the derivatives
	double minx = 9999;
	double maxx = -9999;
	if(0<minx) { minx=0; }
	if(0>maxx) { maxx=0; }
	if(rnp4.getX()<minx) { minx=rnp4.getX(); }
	if(rnp4.getX()>maxx) { maxx=rnp4.getX(); }
	double[] ts = computeCubicFirstDerivativeRoots(0, rnp2.getX(), rnp3.getX(), rnp4.getX());
	stroke(255,0,0);
	for(int i=0; i<ts.length;i++) {
		double t = ts[i];
		if(t>=0 && t<=1) {
			int x = (int)computeCubicBaseValue(t, 0, rnp2.getX(), rnp3.getX(), rnp4.getX());
			if(x<minx) { minx=x; }
			if(x>maxx) { maxx=x; }}}

	float miny = 9999;
	float maxy = -9999;
	if(0<miny) { miny=0; }
	if(0>maxy) { maxy=0; }
	ts = computeCubicFirstDerivativeRoots(0, rnp2.getY(), rnp3.getY(), 0);
	stroke(255,0,255);
	for(int i=0; i<ts.length;i++) {
		double t = ts[i];
		if(t>=0 && t<=1) {
			int y = (int)computeCubicBaseValue(t, 0, rnp2.getY(), rnp3.getY(), 0);
			if(y<miny) { miny=y; }
			if(y>maxy) { maxy=y; }}}

	// bounding box corner coordinates
	Point bb1 = new Point(minx,miny);
	Point bb2 = new Point(minx,maxy);
	Point bb3 = new Point(maxx,maxy);
	Point bb4 = new Point(maxx,miny);
	
	// rotate back!
	Point nbb1 = new Point(bb1.x * cos(angle) - bb1.y * sin(angle), bb1.x * sin(angle) + bb1.y * cos(angle));
	Point nbb2 = new Point(bb2.x * cos(angle) - bb2.y * sin(angle), bb2.x * sin(angle) + bb2.y * cos(angle));
	Point nbb3 = new Point(bb3.x * cos(angle) - bb3.y * sin(angle), bb3.x * sin(angle) + bb3.y * cos(angle));
	Point nbb4 = new Point(bb4.x * cos(angle) - bb4.y * sin(angle), bb4.x * sin(angle) + bb4.y * cos(angle));
	
	// move back!
	nbb1.x += xa;	nbb1.y += ya;
	nbb2.x += xa;	nbb2.y += ya;
	nbb3.x += xa;	nbb3.y += ya;
	nbb4.x += xa;	nbb4.y += ya;
	
	double[] bbox = {nbb1.x, nbb1.y, nbb2.x, nbb2.y, nbb3.x, nbb3.y, nbb4.x, nbb4.y};
	return bbox;
}


/**
 * split a cubic curve into two curves at time=t
 */
Segment[] splitCubicCurve(double t, double xa, double ya, double xb, double yb, double xc, double yc, double xd, double yd) {
	Segment[] curves = new Segment[3];
	// interpolate from 4 to 3 points
	Point p5 = new Point((1-t)*xa + t*xb, (1-t)*ya + t*yb);
	Point p6 = new Point((1-t)*xb + t*xc, (1-t)*yb + t*yc);
	Point p7 = new Point((1-t)*xc + t*xd, (1-t)*yc + t*yd);
	// interpolate from 3 to 2 points
	Point p8 = new Point((1-t)*p5.getX() + t*p6.getX(), (1-t)*p5.getY() + t*p6.getY());
	Point p9 = new Point((1-t)*p6.getX() + t*p7.getX(), (1-t)*p6.getY() + t*p7.getY());
	// interpolate from 2 points to 1 point
	Point p10 = new Point((1-t)*p8.getX() + t*p9.getX(), (1-t)*p8.getY() + t*p9.getY());
	// we now have all the values we need to build the subcurves
	curves[0] = new Bezier3(xa,ya, p5.getX(), p5.getY(), p8.getX(), p8.getY(), p10.getX(), p10.getY());
	curves[1] = new Bezier3(p10.getX(), p10.getY(), p9.getX(), p9.getY(), p7.getX(), p7.getY(), xd, yd);
	// return full intermediate value set, in case they are needed for something else
	Point[] points = {p5, p6, p7, p8, p9, p10};
	curves[2] = new PointSegment(points);
	return curves; }

/**
 * split a cubic curve into three segments [0,t1,t2,1], returning the segment between t1 and t2
 */
Segment getCubicSegment(double t1, double t2, double xa, double ya, double xb, double yb, double xc, double yc, double xd, double yd)
{
	if(t1==0) {
		Segment[] shortcut = splitCubicCurve(t2, xa, ya, xb, yb, xc, yc, xd, yd);
		shortcut[0].setTValues(t1,t2);
		return shortcut[0]; }
	else if(t2==1) {
		Segment[] shortcut = splitCubicCurve(t1, xa, ya, xb, yb, xc, yc, xd, yd);
		shortcut[1].setTValues(t1,t2);
		return shortcut[1]; }
	else
	{
		Segment[] first_segmentation = splitCubicCurve(t1, xa, ya, xb, yb, xc, yc, xd, yd);
		double t3 = (t2-t1) * 1/(1-t1);
		Point[] fs = ((Bezier3) first_segmentation[1]).points;
		Segment[] second_segmentation = splitCubicCurve(t3, fs[0].getX(), fs[0].getY(), fs[1].getX(), fs[1].getY(), fs[2].getX(), fs[2].getY(), fs[3].getX(), fs[3].getY());
		second_segmentation[0].setTValues(t1,t2);
		return second_segmentation[0];
	}
}



/**
 * Perform fat line clipping of curve 2 on curve 1
 */
double[] fatlineCubicClip(Bezier3 flcurve, Bezier3 curve)
{
	double[] tvalues = {0.1,0.0};
	flcurve.computeTightBoundingBox();
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
	double a, b, c;
	if(dx!=0)
	{
		a = dy / dx;
		b = -1;
		c = -(a * flcurve.points[0].x - flcurve.points[0].y);
		// normalize so that a� + b� = 1
		double scale = sqrt(a*a+b*b);
		a /= scale; b /= scale; c /= scale;		

		// set up the coefficients for the Bernstein polynomial that
		// describes the distance from curve 2 to curve 1's baseline
		double[] coeff = new double[4];
		for(int i=0; i<4; i++) { coeff[i] = a*curve.points[i].x + b*curve.points[i].y + c; }
		double[] vals = new double[4];
		for(int i=0; i<4; i++) { vals[i] = computeCubicBaseValue(i*(1/3), coeff[0], coeff[1], coeff[2], coeff[3]); }

		// form the convex hull
		ConvexHull ch = new ConvexHull();
		ArrayList hps = new ArrayList();
		hps.add(new Point(0, coeff[0]));
		hps.add(new Point(1/3, coeff[1]));
		hps.add(new Point(2/3, coeff[2]));
		hps.add(new Point(1, coeff[3]));
		Point[] hull = ch.jarvisMarch(hps,-10,-200);
		
		double[][] tests = getEdges(hull);
		
		{double[] line = {0,d1,1,d1};
		for(int test=0; test<tests.length; test++) {
			double[] tl = tests[test];
			double[] intersection = intersectsLineLine(line, tl);
			if(intersection==null) continue;
			double ix = intersection[0];
			double iy = intersection[1];
			if(min(tl[0],tl[2])<=ix && ix<=max(tl[0],tl[2]) && min(tl[1],tl[3])<=iy && iy<=max(tl[1],tl[3])) {
				double val = ix;
				if(tvalues[0]>val) {
					tvalues[0] = val; }}}
		if(tvalues[0]<0) { tvalues[0]=0; } if(tvalues[0]>1) { tvalues[0]=1; }}

		
		{double[] line = {0,d2,1,d2};
		for(int test=0; test<tests.length; test++) {
			double[] tl = tests[test];
			double[] intersection = intersectsLineLine(line, tl);
			if(intersection==null) continue;
			double ix = intersection[0];
			double iy = intersection[1];
			if(min(tl[0],tl[2])<=ix && ix<=max(tl[0],tl[2]) && min(tl[1],tl[3])<=iy && iy<=max(tl[1],tl[3])) {
				double val = ix;
				if(tvalues[1]<val) { tvalues[1] = val; }}}
		if(tvalues[1]<0) { tvalues[1]=0; } if(tvalues[1]>1) { tvalues[1]=1; }}
	}
		
	// done.
	return tvalues;
}


/**
 * create an interpolated segment based on the segments "min" and "max.
 * interpolication ratios are based on the time values at the start and end of the segment.
 */
Bezier3 interpolateCubicForT(Segment original, Segment min, Segment max, double segment_start_t, double segment_end_t)
{
	// start point
	double tA = segment_start_t;
	// control point 1
	double dx = min.points[1].getX() - max.points[1].getX();
	double dy = min.points[1].getY() - max.points[1].getY();
	double[] line1 = {min.points[1].getX() - 100*dx, min.points[1].getY() - 100*dy, 
					min.points[1].getX() + 100*dx, min.points[1].getY() + 100*dy, };
	double[] intersection1 = intersectsLineCurve(line1, (Bezier3) original);
	if(intersection1==null) {
		println("could not determine projection of point B on curve!");
		print("line: "); println(line1);
		print("curve: "); println(original.toString());
		return null; }

	double tB = segment_start_t + (segment_end_t - segment_start_t) * intersection1[2];
	// control point 2 
	dx = min.points[2].getX() - max.points[2].getX();
	dy = min.points[2].getY() - max.points[2].getY();
	double[] line2 = {min.points[2].getX() - 100*dx, min.points[2].getY() - 100*dy, 
					min.points[2].getX() + 100*dx, min.points[2].getY() + 100*dy, };
	double[] intersection2 = intersectsLineCurve(line2, (Bezier3) original);

	if(intersection2==null) {
		println("could not determine projection of point C on curve!");
		print("line: "); println(line2);
		print("curve: "); println(original.toString());
		return null; }

	double tC = segment_start_t + (segment_end_t - segment_start_t) * intersection2[2];
	// end point
	double tD = segment_end_t;

	// form interpolation
	double nxa = (1-tA) * min.points[0].getX() + tA * max.points[0].getX();
	double nxb = (1-tB) * min.points[1].getX() + tB * max.points[1].getX();
	double nxc = (1-tC) * min.points[2].getX() + tC * max.points[2].getX();
	double nxd = (1-tD) * min.points[3].getX() + tD * max.points[3].getX();
	double nya = (1-tA) * min.points[0].getY() + tA * max.points[0].getY();
	double nyb = (1-tB) * min.points[1].getY() + tB * max.points[1].getY();
	double nyc = (1-tC) * min.points[2].getY() + tC * max.points[2].getY();
	double nyd = (1-tD) * min.points[3].getY() + tD * max.points[3].getY();
	Bezier3 interpolated = new Bezier3(nxa, nya, nxb, nyb, nxc, nyc, nxd, nyd);
	return interpolated;
}

/**
 * create an interpolated segment based on the segments "min" and "max.
 * interpolication ratios are based on the time values at the start and end of the segment.
 */
Bezier3 interpolateCubicForDistance(Segment original, Segment min, Segment max, double segment_start_d, double segment_end_d)
{
	// start point
	double tA = segment_start_d;
	// control point 1
	double dx = min.points[1].getX() - max.points[1].getX();
	double dy = min.points[1].getY() - max.points[1].getY();
	double[] line1 = {min.points[1].getX() - 100*dx, min.points[1].getY() - 100*dy, 
					min.points[1].getX() + 100*dx, min.points[1].getY() + 100*dy, };
	double[] intersection1 = intersectsLineCurveWithDistance(line1, (Bezier3) original, segment_start_d, segment_end_d);

	if(intersection1==null) {
		println("could not determine projection of point B on curve!");
		print("line: "); println(line1);
		print("curve: "); println(original.toString());
		return null; }

	double tB = segment_start_d + (segment_end_d - segment_start_d) * intersection1[3];
	// control point 2 
	dx = min.points[2].getX() - max.points[2].getX();
	dy = min.points[2].getY() - max.points[2].getY();
	double[] line2 = {min.points[2].getX() - 100*dx, min.points[2].getY() - 100*dy, 
					min.points[2].getX() + 100*dx, min.points[2].getY() + 100*dy, };
	double[] intersection2 = intersectsLineCurveWithDistance(line2, (Bezier3) original, segment_start_d, segment_end_d);

	if(intersection2==null) {
		println("could not determine projection of point C on curve!");
		print("line: "); println(line2);
		print("curve: "); println(original.toString());
		return null; }

	double tC = segment_start_d + (segment_end_d - segment_start_d) * intersection2[3];
	// end point
	double tD = segment_end_d;

	// form interpolation
	double nxa = (1-tA) * min.points[0].getX() + tA * max.points[0].getX();
	double nxb = (1-tB) * min.points[1].getX() + tB * max.points[1].getX();
	double nxc = (1-tC) * min.points[2].getX() + tC * max.points[2].getX();
	double nxd = (1-tD) * min.points[3].getX() + tD * max.points[3].getX();
	double nya = (1-tA) * min.points[0].getY() + tA * max.points[0].getY();
	double nyb = (1-tB) * min.points[1].getY() + tB * max.points[1].getY();
	double nyc = (1-tC) * min.points[2].getY() + tC * max.points[2].getY();
	double nyd = (1-tD) * min.points[3].getY() + tD * max.points[3].getY();
	Bezier3 interpolated = new Bezier3(nxa, nya, nxb, nyb, nxc, nyc, nxd, nyd);
	return interpolated;
}




/**
 * scale a cubic bezier curve by some distance (in coordinate units)
 */
Segment scaleCubic(double distance, double xa, double ya, double xb, double yb, double xc, double yc, double xd, double yd)
{
	// 1: find the point from which the curve must be scaled, based on
	// the intersection of the lines that run perpendicular to the curve
	// at the start and end point.
	double[] scale_origin = getScaleOrigin(xa,ya,xb,yb,xc,yc,xd,yd);
	if(scale_origin==null || isLinear(xa,ya,xb,yb,xc,yc,xd,yd))
	{
		// it is of course always possible that the curve segment is a line
		double angle_AB = getDirection(xb-xa, yb-ya) + PI/2.0;
		double angle_CD = getDirection(xd-xc, yd-yc) + PI/2.0;
		double nxa = xa - distance * cos((float)angle_AB);
		double nya = ya - distance * sin((float)angle_AB);
		double nxd = xd - distance * cos((float)angle_CD);
		double nyd = yd - distance * sin((float)angle_CD);
		return new Line(nxa, nya, nxd, nyd);
	}
	else
	{
		double sx = scale_origin[0];
		double sy = scale_origin[1];

		// 2: offset each coordinate on the curve by adding add 'distance'
		// to their coordinate,  in the direction opposite the scaling origin
		double nxa,nya,nxb,nyb,nxc,nyc,nxd,nyd;

		double angle_to_A = getDirection(xa-sx, ya-sy);
		double angle_to_D = getDirection(xd-sx, yd-sy);

		// correct the "distance" value: positive scale distance should be on the
		// "left" of the curve (90 degrees counterclockwise from the direction of
		// the curve's start to first control). 
		double angle_AB = getDirection(xb-xa, yb-ya) + PI/2.0;
		double angle_CD = getDirection(xd-xc, yd-yc) + PI/2.0;

		// the new start and end point are easily computed
		nxa = xa - distance * cos((float)angle_AB);
		nya = ya - distance * sin((float)angle_AB);
		nxd = xd - distance * cos((float)angle_CD);
		nyd = yd - distance * sin((float)angle_CD);

		// the new control points are not at a fixed distance, because the
		// angle between on-curve and off-curve coordinate needs to
		// be preserved. So: same angle, and on the line that runs through
		// the control point to the scale origin
		double[] nAnB = {nxa,nya,nxa+(xb-xa),nya+(yb-ya)};
		double[] onB = {sx,sy,xb,yb};
		double[] nB = intersectsLineLine(nAnB,onB);
		if(nB==null) {
//			println("error extruding control 1 of {"+xa+","+ya+","+xb+","+yb+","+xc+","+yc+","+xd+","+yd+"}, scale origin {"+sx+","+sy+"}");
			//FIXME: seems to happen when coordinates (on, off or origin) lie on top of each other
			nxb=nxa; nyb=nya; }
		else { nxb = nB[0]; nyb = nB[1]; }
			
		double[] nCnD = {nxd,nyd,nxd+(xc-xd),nyd+(yc-yd)};
		double[] onC = {sx,sy,xc,yc};
		double[] nC = intersectsLineLine(nCnD,onC);
		if(nC==null) {
//			println("error extruding control 2 of {"+xa+","+ya+","+xb+","+yb+","+xc+","+yc+","+xd+","+yd+"}, scale origin {"+sx+","+sy+"}");
			//FIXME: seems to happen when coordinates (on, off or origin) lie on top of each other
			nxc=nxd; nyc=nyd; }
		else{ nxc = nC[0]; nyc = nC[1]; }

		// 3: create a new curve with these new parameters
		Bezier3 ret = new Bezier3(nxa,nya,nxb,nyb,nxc,nyc,nxd,nyd);
		return ret;
	}
}

/**
* Finds the point from which the curve must be scaled, based on
* the intersection of the lines that run perpendicular to the curve
* at the start and end point. If there is no origin (when the lines
* perpendicular to the start and end directions are linear, which is
* the case for S curves, for instance) then this function returns
* null.
*/
double[] getScaleOrigin(double xa, double ya, double xb, double yb, double xc, double yc, double xd, double yd)
{
	double perpendicular_angle = getDirection(xb-xa, yb-ya) + PI/2.0;
	double pdxs = cos((float)perpendicular_angle);
	double pdys = sin((float)perpendicular_angle);
	double[] startline = {xa, ya, xa+pdxs, ya+pdys};

	perpendicular_angle = getDirection(xd-xc, yd-yc) + PI/2.0;
	double pdxe = cos((float)perpendicular_angle);
	double pdye = sin((float)perpendicular_angle);
	double[] endline = {xd+pdxe, yd+pdye, xd, yd};

	double[] origin = new double[2];
	
	// parallel lines: there is no intersection
	if(pdxs==pdxe && pdys==pdye) { return null; }

	// colinear lines: the intersection lies in between start and end
	// note that this should never be the case, because colinear endpoints
	// means the curve was not properly segmented.
	else if(pdxs==pdxe || pdys==pdye) {
		origin[0] = (xa+xd)/2.0;
		origin[1] = (ya+yd)/2.0; }

	// normal intersection: the intersection requires math!
	else {
		double[] intersection = intersectsLineLine(startline,endline);
		// if both control points are on top of on-curve points, there is no scaling origin.
		if(intersection==null) { return null; }		
		origin[0]=intersection[0];
		origin[1]=intersection[1]; }
		
	return origin;
}

/**
 * Checks whether a particular cubic curve is linear
 */
boolean isLinear(double xa, double ya, double xb, double yb, double xc, double yc, double xd, double yd)
{
	float dx1 = (float)(xb-xa);
	float dy1 = (float)(yb-ya); 
	float dx2 = (float)(xc-xb);
	float dy2 = (float)(yc-yb); 
	float dx3 = (float)(xd-xc);
	float dy3 = (float)(yd-yc); 
	return (abs(dx1-dx2)<1 && abs(dx3-dx2)<1 && abs(dy1-dy2)<1 && abs(dy3-dy2)<1);
}
