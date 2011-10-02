/**
 * Quadratic functions
 */

/**
 * compute the value for the quadratic bezier function at time=t
 */
double computeQuadraticBaseValue(double t, double a, double b, double c) {
	double mt = 1-t;
	return mt*mt*a + 2*mt*t*b + t*t*c; }
	
/**
 * compute the value for the first derivative of the quadratic bezier function at time=t
 */
double computeQuadraticFirstDerivativeRoot(double a, double b, double c) {
	double t=-1;
	double denominator = a -2*b + c;
	if(denominator!=0) { t = (a-b) / denominator; }
	return t; }



/**
 * Compute the bounding box based on the straightened curve, for best fit
 */
double[] computeQuadraticBoundingBox(double xa, double ya, double xb, double yb, double xc, double yc)
{
	double minx = 9999;
	double maxx = -9999;
	if(xa<minx) { minx=xa; }
	if(xa>maxx) { maxx=xa; }
	if(xc<minx) { minx=xc; }
	if(xc>maxx) { maxx=xc; }
	double t = computeQuadraticFirstDerivativeRoot(xa, xb, xc);
	if(t>=0 && t<=1) {
		double x = computeQuadraticBaseValue(t, xa, xb, xc);
		double y = computeQuadraticBaseValue(t, ya, yb, yc);
		if(x<minx) { minx=x; }
		if(x>maxx) { maxx=x; }}

	double miny = 9999;
	double maxy = -9999;
	if(ya<miny) { miny=ya; }
	if(ya>maxy) { maxy=ya; }
	if(yc<miny) { miny=yc; }
	if(yc>maxy) { maxy=yc; }
	t = computeQuadraticFirstDerivativeRoot(ya, yb, yc);
	if(t>=0 && t<=1) {
		double x = computeQuadraticBaseValue(t, xa, xb, xc);
		double y = computeQuadraticBaseValue(t, ya, yb, yc);
		if(y<miny) { miny=y; }
		if(y>maxy) { maxy=y; }}

	// bounding box corner coordinates
	double[] bbox = {minx,miny, minx,maxy, maxx,maxy, maxx,miny};
	return bbox;
}


/**
 * Compute the bounding box based on the straightened curve, for best fit
 */
double[] computeQuadraticTightBoundingBox(double xa, double ya, double xb, double yb, double xc, double yc)

{	// translate to 0,0
	Point np2 = new Point(xb - xa, yb - ya);
	Point np3 = new Point(xc - xa, yc - ya);

	// get angle for rotation
	float angle = (float) getDirection(np3.getX(), np3.getY());
	
	// rotate everything counter-angle so that it's aligned with the x-axis
	Point rnp2 = new Point(np2.getX() * cos(-angle) - np2.getY() * sin(-angle), np2.getX() * sin(-angle) + np2.getY() * cos(-angle));
	Point rnp3 = new Point(np3.getX() * cos(-angle) - np3.getY() * sin(-angle), np3.getX() * sin(-angle) + np3.getY() * cos(-angle));

	// same bounding box approach as before:
	double minx = 9999;
	double maxx = -9999;
	if(0<minx) { minx=0; }
	if(0>maxx) { maxx=0; }
	if(rnp3.getX()<minx) { minx=rnp3.getX(); }
	if(rnp3.getX()>maxx) { maxx=rnp3.getX(); }
	double t = computeQuadraticFirstDerivativeRoot(0, rnp2.getX(), rnp3.getX());
	if(t>=0 && t<=1) {
		int x = (int) computeQuadraticBaseValue(t, 0, rnp2.getX(), rnp3.getX());
		if(x<minx) { minx=x; }
		if(x>maxx) { maxx=x; }}

	float miny = 9999;
	float maxy = -9999;
	if(0<miny) { miny=0; }
	if(0>maxy) { maxy=0; }
	if(0<miny) { miny=0; }
	if(0>maxy) { maxy=0; }
	t = computeQuadraticFirstDerivativeRoot(0, rnp2.getY(), 0);
	if(t>=0 && t<=1) {
		int y = (int) computeQuadraticBaseValue(t, 0, rnp2.getY(), 0);
		if(y<miny) { miny=y; }
		if(y>maxy) { maxy=y; }}

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
 * split a quadratic curve into two curves at time=t
 */
Segment[] splitQuadraticCurve(double t, double xa, double ya, double xb, double yb, double xc, double yc) {
	Segment[] curves = new Segment[3];
	// interpolate from 3 to 2 points
	Point p4 = new Point((1-t)*xa + t*xb, (1-t)*ya + t*yb);
	Point p5 = new Point((1-t)*xb + t*xc, (1-t)*yb + t*yc);
	// interpolate from 2 points to 1 point
	Point p6 = new Point((1-t)*p4.getX() + t*p5.getX(), (1-t)*p4.getY() + t*p5.getY());
	// we now have all the values we need to build the subcurves
	curves[0] = new Bezier2(xa,ya, p4.getX(), p4.getY(), p6.getX(), p6.getY());
	curves[0].setTValues(0,t);
	curves[1] = new Bezier2(p6.getX(), p6.getY(), p5.getX(), p5.getY(), xc, yc);
	curves[1].setTValues(t,1);
	// return full intermediate value set, in case they are needed for something else
	Point[] points = {p4, p5, p6};
	curves[2] = new PointSegment(points);
	return curves; }

/**
 * split a quadratic curve into three segments [0,t1,t2,1], returning the segment between t1 and t2
 */
Segment getQuadraticSegment(double t1, double t2, double xa, double ya, double xb, double yb, double xc, double yc)
{
	if(t1==0.0) {
		Segment[] shortcut = splitQuadraticCurve(t2, xa, ya, xb, yb, xc, yc);
		shortcut[0].setTValues(t1,t2);
		return shortcut[0]; }
	else if(t2==1.0) {
		Segment[] shortcut = splitQuadraticCurve(t1, xa, ya, xb, yb, xc, yc);
		shortcut[1].setTValues(t1,t2);
		return shortcut[1]; }
	else {
		Segment[] first_segmentation = splitQuadraticCurve(t1, xa, ya, xb, yb, xc, yc);
		double t3 = (t2-t1) * 1/(1-t1);
		Point[] fs = first_segmentation[1].points;
		Segment[] second_segmentation = splitQuadraticCurve(t3, fs[0].getX(), fs[0].getY(), fs[1].getX(), fs[1].getY(), fs[2].getX(), fs[2].getY());
		second_segmentation[0].setTValues(t1,t2);
		return second_segmentation[0]; }
}

/**
 * create an interpolated segment based on the segments "min" and "max.
 * interpolication ratios are based on the time values at the start and end of the segment.
 */
Bezier2 interpolateQuadraticForT(Segment original, Segment min, Segment max, double segment_start_t, double segment_end_t)
{
	// start point
	double tA = segment_start_t;
	// control point
	double dx = min.points[1].getX() - max.points[1].getX();
	double dy = min.points[1].getY() - max.points[1].getY();

	double[] line1 = {min.points[1].getX() - dx, min.points[1].getY() - dy, 
					min.points[1].getX() + dx, min.points[1].getY() + dy, };
	double[] intersection = intersectsLineCurve(line1, (Bezier2) original);
	// FIXME: The following is a hack, to get around double precision not being precise enough.
	//	We already know that there is an intersection when we enter this function, but machine
	//	preceision might cause the algorithm to miss the coordinate for it. So, we simply try
	//	with arbitrarily different line values until that intersection is found. Is this clean?
	//	no. Does it work? practically, yes. Can it potentially lead to an infinite block? ... yes
	//	A better solution is to encode the scaling point directly into a curve segment, if it
	//	gets computed, so that intersection checks can be omitted if it's set, removing the need
	//	for this particular hack.
	for(int f = 1; intersection==null; f++) {
		double salt = random(10000);
		double[] testline = {min.points[1].getX() - salt*dx, min.points[1].getY() - salt*dy, 
						min.points[1].getX() + salt*dx, min.points[1].getY() + salt*dy, };
		intersection = intersectsLineCurve(testline, (Bezier2) original); 
		// safeguard
		if(f>100) return null; }
	double tB = segment_start_t + (segment_end_t - segment_start_t) * intersection[2];
	// end point
	double tC = segment_end_t;

	// form interpolation
	double nxa = (1-tA) * min.points[0].getX() + tA * max.points[0].getX();
	double nxb = (1-tB) * min.points[1].getX() + tB * max.points[1].getX();
	double nxc = (1-tC) * min.points[2].getX() + tC * max.points[2].getX();
	double nya = (1-tA) * min.points[0].getY() + tA * max.points[0].getY();
	double nyb = (1-tB) * min.points[1].getY() + tB * max.points[1].getY();
	double nyc = (1-tC) * min.points[2].getY() + tC * max.points[2].getY();
	Bezier2 interpolated = new Bezier2(nxa, nya, nxb, nyb, nxc, nyc);
	return interpolated;
}

/**
 * create an interpolated segment based on the segments "min" and "max.
 * interpolication ratios are based on dinstance-on-curve at the start and end of the segment.
 */
Bezier2 interpolateQuadraticForDistance(Segment original, Segment min, Segment max, double segment_start_d, double segment_end_d)
{
	// start point
	double tA = segment_start_d;
	// control point
	double dx = min.points[1].getX() - max.points[1].getX();
	double dy = min.points[1].getY() - max.points[1].getY();
	double[] line1 = {min.points[1].getX() - 100*dx, min.points[1].getY() - 100*dy, 
					min.points[1].getX() + 100*dx, min.points[1].getY() + 100*dy, };
	double[] intersection = intersectsLineCurveWithDistance(line1, (Bezier2) original, segment_start_d, segment_end_d);
	// problem?
	if(intersection==null) { return null; }
	double tB = segment_start_d + (segment_end_d - segment_start_d) * intersection[3];
	// end point
	double tC = segment_end_d;

	// form interpolation
	double nxa = (1-tA) * min.points[0].getX() + tA * max.points[0].getX();
	double nxb = (1-tB) * min.points[1].getX() + tB * max.points[1].getX();
	double nxc = (1-tC) * min.points[2].getX() + tC * max.points[2].getX();
	double nya = (1-tA) * min.points[0].getY() + tA * max.points[0].getY();
	double nyb = (1-tB) * min.points[1].getY() + tB * max.points[1].getY();
	double nyc = (1-tC) * min.points[2].getY() + tC * max.points[2].getY();
	Bezier2 interpolated = new Bezier2(nxa, nya, nxb, nyb, nxc, nyc);
	return interpolated;
}
