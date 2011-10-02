/**
 * Quadratic Bezier curve segment from point P1 (x1/y1) to P3 (x3/y3) over control point P2 (x2/y2)
 */
class Bezier2 extends Segment
{
	Bezier2() { super(); }
	
	Bezier2(double x1, double y1, double cx, double cy, double x2, double y2) {
		points = new Point[3];
		points[0] = new Point(x1,y1);
		points[1] = new Point(cx,cy); 
		points[2] = new Point(x2,y2); }

	Bezier2(Bezier2 other) { super(other); }

	void drawSegment() {
		for(float t = 0; t<1.0; t+=1.0/200.0) {
			double x = getX(t);
			double y = getY(t);
			drawPoint(ox+x,oy+y); }}

	double getX(double t) { return computeQuadraticBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX()); }
	double getY(double t) { return computeQuadraticBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY()); }

	void computeBoundingBox() { bounds = computeQuadraticBoundingBox(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY()); }
	void computeTightBoundingBox() { bounds = computeQuadraticTightBoundingBox(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY()); }

	Segment[] splitSegment(double t) { return splitQuadraticCurve(t, points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY()); }

	/**
	 * use fat line clippping to clip "other" on "this".
	 */
	Segment clip(Bezier2 other) { return this; }

	/**
	 * Flatten this curve as a series of connected lines, each line
	 * connecting two coordinates on the curve for 't' values that
	 * are separated by fixed intervals.
	 */
	Line[] flatten(int steps)
	{
		// shortcut
		if(flattened!=null) { return flattened; }
		// not previously flattened - compute
		double step = 1.0 / (double)steps;
		Line[] lines = new Line[steps];
		int l = 0;
		double sx = getX(0);
		double sy = getY(0);
		for(double t = step; t<1.0; t+=step) {
			double nx = getX(t);
			double ny = getY(t);
			Line segment = new Line(sx,sy,nx,ny);
			segment.setTValues(t-step, t);
			lines[l++] = segment;
			sx=nx;
			sy=ny; }
		// don't forget to add the last segment
		Line segment = new Line(sx,sy,getX(1),getY(1));
		segment.setTValues(1.0-step, 1.0);
		lines[l++] = segment;
		return lines;
	}

	/**
	 * Flatten this curve as a series of connected lines, each line
	 * made to fit the curve as best as possible based on how big
	 * the tolerance in error is between the line segment, and the
	 * section of curve that segment approximates.
	 *
	 * For this function, the "threshold" value indicates the number
	 * of pixels that are permissibly non-overlapping between the two.
	 */
	Line[] flattenWithDistanceThreshold(double threshold)
	{
		// shortcut
		if(flattened!=null) { return flattened; }
		// not previously flattened - compute
		ArrayList/*<Line>*/ lines = new ArrayList();
		double x1 = getX(0);
		double y1 = getY(0);
		double x2 = x1;
		double y2 = y1;
		Line last_segment = new Line(x1,y1,x2,y2);
		// we use an array of at most 'steps' positions to record which coordinates have been seen
		// during a walk, so that we can determine the error between the curve and the line approximation
		int fsteps = 200;
		double[] xcoords = new double[fsteps];
		double[] ycoords = new double[fsteps];
		int coord_pos = 0;
		xcoords[coord_pos] = x1;
		ycoords[coord_pos] = y1;
		coord_pos++;
		// start running through the curve
		double step = 1.0/(double)fsteps;
		double old_t = 0.0;
		double old_d = 0.0;
		// start building line segments
		for(double t=step; t<1.0; t+=step)
		{
			x2 = getX(t);
			y2 = getY(t);
			xcoords[coord_pos] = x2;
			ycoords[coord_pos] = y2;
			coord_pos++;
			
			Line test = new Line(x1,y1,x2,y2);
			int off_pixels = test.getOffPixels(xcoords, ycoords, coord_pos);
			// too big an error? commit last line as segment
			if(off_pixels>threshold) {
				double d = old_d + last_segment.getLength();
				// record segment
				last_segment.setTValues(old_t, t);
				last_segment.setDistanceValues(old_d, d);
				lines.add(last_segment);
				// cycle all administrative values
				old_t = t;
				old_d = d;
				x1 = last_segment.points[1].getX();
				y1 = last_segment.points[1].getY();
				last_segment = new Line(x1,y1,x2,y2);
				xcoords = new double[fsteps];
				ycoords = new double[fsteps];
				coord_pos = 0;
				xcoords[coord_pos] = x1;
				ycoords[coord_pos] = y1;
				coord_pos++;
			 }
			// error's small enough, try to extend the line
			else { last_segment = test; }
		}
		// make sure we also get the last segment!
		last_segment = new Line(x1,y1,getX(1), getY(1));
		last_segment.setTValues(old_t, 1.0);
		lines.add(last_segment);
		
		Line[] larray = new Line[lines.size()];
		for(int l=0; l<lines.size(); l++) { larray[l] = (Line) lines.get(l); }
		return larray;
	}

	/**
	 * Segment this curve into a series of safe-for-scaling curves
	 */
	Segment[] makeSafe()
	{
		Segment[] safe;
		ArrayList segments = new ArrayList();
		Point[] uniform = rotateToUniform(points);
		double x_root = computeQuadraticFirstDerivativeRoot(uniform[0].getX(), uniform[1].getX(), uniform[2].getX());
		double y_root = computeQuadraticFirstDerivativeRoot(uniform[0].getY(), uniform[1].getY(), uniform[2].getY());
		if(x_root>0 && x_root<1 && y_root>0 && y_root<1) {
			if(x_root>y_root) { double swp = y_root; y_root = x_root; x_root = swp; }

			segments.add(getQuadraticSegment(0.0, x_root, points[0].getX(), points[0].getY(),
																			points[1].getX(), points[1].getY(),
																			points[2].getX(), points[2].getY()));

			if(x_root!=y_root) {
				segments.add(getQuadraticSegment(x_root, y_root, points[0].getX(), points[0].getY(),
																					points[1].getX(), points[1].getY(),
																					points[2].getX(), points[2].getY())); }

			segments.add(getQuadraticSegment(y_root, 1.0,	 points[0].getX(), points[0].getY(),
																			points[1].getX(), points[1].getY(),
																			points[2].getX(), points[2].getY()));

			Segment[] ret = new Segment[segments.size()];
			for(int s=0; s<ret.length; s++) { ret[s] = (Segment) segments.get(s); }
			safe = ret; }
		else if(x_root>0 && x_root<1 ) {
			Segment[] split = splitQuadraticCurve(x_root, points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY());
			Segment[] ret = {split[0], split[1]};
			safe = ret; }
		else if(y_root>0 && y_root<1 ) {
			Segment[] split = splitQuadraticCurve(y_root, points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY());
			Segment[] ret = {split[0], split[1]};
			safe = ret; }
		else { Segment[] ret = {this}; safe = ret; }
		return safe;
	}

	/**
	 * Offset this quadratic bezier curve by {distance} pixels. Note that these do not need to be full pixels
	 */
	Segment[] offset(double distance)
	{
		Segment[] safe = makeSafe();
		Segment[] ret = new Segment[safe.length];
		for(int s=0; s<ret.length; s++) {
			ret[s] = safe[s].simpleOffset(distance);
			ret[s].setTValues(safe[s].getStartT(), safe[s].getEndT()); }
		// before we return, make sure to line up the segment coordinates
		for(int s=1; s<ret.length; s++) {
			ret[s].getFirstPoint().x = ret[s-1].getLastPoint().x;
			ret[s].getFirstPoint().y = ret[s-1].getLastPoint().y; }
		return ret;
	}
	
	/**
	 * Offset this quadratic bezier curve, which is presumed to be safe for scaling,
	 * by {distance} pixels. Note that these do not need to be full pixels
	 */
	Segment simpleOffset(double distance)
	{
		double xa = points[0].getX();
		double ya = points[0].getY();
		double xb = points[1].getX();
		double yb = points[1].getY();
		double xc = points[2].getX();
		double yc = points[2].getY();

		// offsetting the end points is always simple
		double[] angles = getCurveDirections(xa, ya, xb, yb, xb, yb, xc, yc);
		double nxa = xa + distance*Math.cos(angles[0] + PI/2.0);
		double nya = ya + distance*Math.sin(angles[0] + PI/2.0);
		double nxc = xc + distance*Math.cos(angles[1] + PI/2.0);
		double nyc = yc + distance*Math.sin(angles[1] + PI/2.0);

		// offsetting the control point requires a few line intersection checks.
		// For quadratic bezier curves, we don't need to figure out where the
		// curve scaling origin is to get the correct offset point
		double[] line1 = {nxa, nya, nxa + (xb-xa), nya + (yb-ya)};
		double[] line2 = {nxc, nyc, nxc + (xc-xb), nyc + (yc-yb)};
		double[] intersection = intersectsLineLine(line1, line2);
		if(intersection==null) {
//			println("ERROR: NO INTERSECTION ON "+nxa+","+nya+","+(nxa + (xb-xa))+","+(nya + (yb-ya))+" WITH "+nxc+","+nyc+","+(nxc + (xc-xb))+","+(nyc + (yc-yb)));
			return this; }
		double nxb = intersection[0];
		double nyb = intersection[1];

		// and return offset curve
		return new Bezier2(nxa, nya, nxb, nyb, nxc, nyc);
	}
}



/**
 * line/curve intersection detection algorithm, returns coordinate and estimated time value on the curve
 */
double[] intersectsLineCurve(double[] oline, Bezier2 curve)
{
	Segment[] flattened = curve.flatten(32);
	for(int l=0; l<flattened.length; l++) {
		Line target = (Line) flattened[l];
		double[] tline = {target.points[0].getX(), target.points[0].getY(), target.points[1].getX(), target.points[1].getY()};
		double[] intersection = intersectsLineLine(oline, tline);
		if(intersection!=null) {
			double ix = intersection[0];
			double iy = intersection[1];
			if(intersectsLineSegmentLineSegment(ix, iy, oline, tline)) {
				double[] values = {	ix, iy,
											estimateT(ix, iy, tline, target.getStartT(), target.getEndT())};
				return values; }}}
	return null;
}


/**
 * line/curve intersection detection algorithm, returns coordinate, estimated time value on the curve, and estimated distance on the curve
 */
double[] intersectsLineCurveWithDistance(double[] oline, Bezier2 curve, double sd, double ed)
{
	Segment[] flattened = curve.flattenWithDistanceThreshold(1);
	for(int l=0; l<flattened.length; l++) {
		Line target = (Line) flattened[l];
		double[] tline = {target.points[0].getX(), target.points[0].getY(), target.points[1].getX(), target.points[1].getY()};
		double[] intersection = intersectsLineLine(oline, tline);
		if(intersection!=null) {
			double ix = intersection[0];
			double iy = intersection[1];
			if(intersectsLineSegmentLineSegment(ix, iy, oline, tline)) {
				double[] values = {	ix, iy,
											estimateT(ix, iy, tline, target.getStartT(), target.getEndT()),
											estimateDistancePercentage(ix, iy, tline, target.getStartDistance(), target.getEndDistance())};
				return values; }}}
	return null;
}
