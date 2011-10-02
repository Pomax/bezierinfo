/**
 * Cubic Bezier curve segment from point P1 to P4 over control points P2 and P3
 */
class Bezier3 extends Bezier2
{
	double[] scale_origin = null;

	Bezier3() { super(); }
	
	Bezier3(double x1, double y1, double cx1, double cy1, double cx2, double cy2, double x2, double y2) {
		super(0,0,0,0,0,0);
		points = new Point[4];
		points[0] = new Point(x1,y1);
		points[1] = new Point(cx1,cy1);
		points[2] = new Point(cx2,cy2);
		points[3] = new Point(x2,y2); 
  }

	Bezier3(Bezier3 other) { super(other); }

	double getX(double t) { return computeCubicBaseValue(t, points[0].getX(), points[1].getX(), points[2].getX(), points[3].getX()); }
	double getY(double t) { return computeCubicBaseValue(t, points[0].getY(), points[1].getY(), points[2].getY(), points[3].getY()); }

	void computeBoundingBox() { bounds = computeCubicBoundingBox(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY()); }
	void computeTightBoundingBox() { bounds = computeCubicTightBoundingBox(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY()); }

	Segment[] splitSegment(double t) {
		Segment[] curves = splitCubicCurve(t, points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY()); 
		curves[0].setTValues( getStartT(), getStartT() + t*(getEndT()-getStartT()));
		curves[1].setTValues(getStartT() + t*(getEndT()-getStartT()), getEndT());
		return curves;
	}

	Segment splitSegment(double t1, double t2) {
    return getCubicSegment(t1, t2, points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY()); 
  }

	/**
	 * use fat line clippping to clip "other" on "this".
	 */
	Segment clip(Bezier3 other)
	{
		Point[] p1 = points;
		Point[] p2 = other.points;		
		double[] tvalues = fatlineCubicClip(this, other);
		// a minimum 20% clipping is required to constitute a successful clip
		if(tvalues[1]-tvalues[0]>0.8) { return null; }
		return other.splitSegment(tvalues[0], tvalues[1]);
	}

	/**
	 * Override from Bezier2, as cubic bezier curves need to be cut into
	 * more segments in order to consist of safe-for-scaling curves.
	 */
	Segment[] makeSafe()
	{
		Point[] uniform = rotateToUniform(points);
		// find split points
		double[] x_roots = computeCubicFirstDerivativeRoots(uniform[0].getX(), uniform[1].getX(), uniform[2].getX(), uniform[3].getX());
		double[] y_roots = computeCubicFirstDerivativeRoots(uniform[0].getY(), uniform[1].getY(), uniform[2].getY(), uniform[3].getY());
		double x_root = computeCubicSecondDerivativeRoot(uniform[0].getX(), uniform[1].getX(), uniform[2].getX(), uniform[3].getX());
		double y_root = computeCubicSecondDerivativeRoot(uniform[0].getY(), uniform[1].getY(), uniform[2].getY(), uniform[3].getY());
		double[] values = {0.0, x_roots[0], x_roots[1], x_root, y_roots[0], y_roots[1], y_root, 1.0};
		swapSort(values);
		// filter array
		int size=0;
		double last=-1;
		for(int v=0; v<values.length; v++) { if(values[v]>=0 && values[v]<=1 && values[v]!=last) {last=values[v]; size++; }}
		double[] roots = new double[size];
		int pos=0;
		last=-1;
		for(int v=0; v<values.length; v++) { if(values[v]>=0 && values[v]<=1 && values[v]!=last)  { last=values[v]; roots[pos++] = values[v]; }}
		// form segments
		ArrayList safe = new ArrayList();
		for(int v=0; v<size-1; v++) { 
			Segment subsegment = getCubicSegment(roots[v], roots[v+1], points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY());
		
			// TODO: this is not complete, and requires a recursive validation to make sure
			// the validation results themselves are valid, scalable segments.
			Segment[] validated = validate(subsegment);
			
			if(validated==null) { safe.add(subsegment); }
			else { for(Segment valid: validated) { safe.add(valid); }}}

		Segment[] sarray = new Segment[safe.size()];
		for(int s=0; s<safe.size(); s++) {
      sarray[s] = (Bezier3) safe.get(s); 
    }
		return sarray;
	}

	Segment[] validate(Segment curve)
	{
		if(curve instanceof Line) {
			Segment[] validated = {curve};
			return validated; }
		Point[] points = curve.points;
		double[] origin = getScaleOrigin(points[0].getX(), points[0].getY(), points[1].getX(), points[1].getY(), points[2].getX(), points[2].getY(), points[3].getX(), points[3].getY());
		// if there is no scaling origin, signal 
		if(origin==null) { 
  		return null; }
		double a1 = getDirection(points[0].getX()-origin[0], points[0].getY()-origin[1]);
		double a2 = getDirection(points[3].getX()-origin[0], points[3].getY()-origin[1]);
		double diff;
		if(a1<a2) { diff = a2-a1; } else { diff = a1-a2; }
		if(diff>=PI/2) {
			Segment[] validated = {curve};
			return validated; }
		// if we get here, the angle {start,origin,end} is too wide.
		// splitting the curve in the middle should fix things.
		double t = 0.5;
		Segment[] split = curve.splitSegment(t);
		double mt = curve.getStartT() + t * (curve.getEndT() - curve.getStartT());
		split[0].setTValues(curve.getStartT(), mt);
		split[1].setTValues(mt, curve.getEndT());
		Segment[] ret = {split[0], split[1]};
		return ret;
	}

	/**
	 * Offset this cubic bezier curve, which is presumed to be safe for scaling,
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
		double xd = points[3].getX();
		double yd = points[3].getY();

		// offsetting the end points is just as simple as for quadratic curves
		double[] angles = getCurveDirections(xa, ya, xb, yb, xc, yc, xd, yd);
		double nxa = xa + distance*Math.cos(angles[0] + PI/2.0);
		double nya = ya + distance*Math.sin(angles[0] + PI/2.0);
		double nxd = xd + distance*Math.cos(angles[1] + PI/2.0);
		double nyd = yd + distance*Math.sin(angles[1] + PI/2.0);

		
		// get the scale origin, if it's not known yet
		if(scale_origin==null) { scale_origin = getScaleOrigin(xa,ya,xb,yb,xc,yc,xd,yd); }

		// if it's still null, then we couldn't figure out what the scale origin is supposed to be. That's bad.
		if(scale_origin==null) {
//			println("ERROR: NO ORIGIN FOR "+xa+","+ya+","+xb+","+yb+","+xc+","+yc+","+xd+","+yd);
			return this; }
		double xo = scale_origin[0];
		double yo = scale_origin[1];

		// offsetting the control points, however, requires much more work now
		double[] c1line1 = {nxa, nya, nxa + (xb-xa), nya + (yb-ya)};
		double[] c1line2 = {xo,yo, xb,yb};
		double[] intersection = intersectsLineLine(c1line1, c1line2);
		if(intersection==null) {
//			println("ERROR: NO INTERSECTION ON "+nxa+","+nya+","+(nxa + (xb-xa))+","+(nya + (yb-ya))+" WITH "+xo+","+yo+","+xb+","+yb);
			return this; }
		double nxb = intersection[0];
		double nyb = intersection[1];

		double[] c2line1 = {nxd, nyd, nxd + (xc-xd), nyd + (yc-yd)};
		double[] c2line2 = {xo,yo, xc,yc};
		intersection = intersectsLineLine(c2line1, c2line2);
		if(intersection==null) {
//			println("ERROR: NO INTERSECTION ON "+nxd+","+nyd+","+(nxd + (xc-xd))+","+(nyd + (yc-yd))+" WITH "+xo+","+yo+","+xc+","+yc);
			return this; }
		double nxc = intersection[0];
		double nyc = intersection[1];

		// finally, return offset curve
		Bezier3 newcurve = new Bezier3(nxa, nya, nxb, nyb, nxc, nyc, nxd, nyd);
		newcurve.scale_origin = scale_origin;
		
		return newcurve;
	}
}
