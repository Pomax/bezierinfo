/**
 * A segment is any kind of line section over a definite interval
 */
class Segment
{
	boolean showtext=false;
	void setShowText(boolean b) { showtext=b; }
	boolean showText() { return showtext; }

	boolean showpoints=true;
	void setShowPoints(boolean b) { showpoints=b; }
	boolean showPoints() { return showpoints; }

	boolean showcontrols=true;
	void setShowControlPoints(boolean b) { showcontrols=b; }
	boolean showControlPoints() { return showcontrols; }

	boolean drawcurve=true;
	void setDrawCurve(boolean b) { drawcurve=b; }
	boolean drawCurve() { return drawcurve; }

	boolean drawbbox=false;
	void setShowBoundingBox(boolean b) { drawbbox=b; }
	boolean showBoundingBox() { return drawbbox; }

	Point[] points = new Point[0];
	Point getFirstPoint() { return points[0]; }
	Point getLastPoint() { return points[points.length-1]; }
	
	double start_t = 0.0;
	double end_t = 1.0;
	void setTValues(double st, double et) { start_t=st; end_t=et;}
	double getStartT() { return start_t;}
	double getEndT() { return end_t;}

	double start_d = 0.0;
	double end_d = 0.0;
	void setDistanceValues(double sd, double ed) { start_d=sd; end_d=ed;}
	double getStartDistance() { return start_d;}
	double getEndDistance() { return end_d;}
	
	double[] bounds = new double[8];
	double[] getBoundingBox() { return bounds; }
	void computeBoundingBox() {}
	void computeTightBoundingBox() {}

  double getLength() { return 0; }

	int ox=0;
	int oy=0;
	
	Segment() {}
	Segment(Segment other) {
		setPoints(other.points);
		showtext=other.showtext;
		showpoints=other.showpoints;
		showcontrols=other.showcontrols;
		drawcurve=other.drawcurve;
		setTValues(other.start_t, other.end_t);
		setDistanceValues(other.start_d, other.end_d);
		if(other.bounds!=null) arrayCopy(other.bounds,0,bounds,0,8);
		ox=other.ox;
		oy=other.oy;
	}
	
	void setPoints(Point[] opoints)
	{
		int len = opoints.length;
		points = new Point[len];
		for(int i=0; i<len; i++) {
		  points[i] = new Point(opoints[i].x, opoints[i].y); }
	}
	
	void draw(int ox, int oy) {
		this.ox=ox;
		this.oy=oy;
		draw(); }

	// draw this segment
	void draw() {
		stroke(r,g,b);
		fill(r,g,b);
		if(drawcurve) drawSegment();
		stroke(0,0,255);
		int last = points.length-1;
		for(int p=0; p<points.length; p++){
			noFill();
			double x = points[p].getX();
			double y = points[p].getY();
			if(showpoints) {
				if(p==0 || p==last || (points.length>2 && p!=0 && p!=last && showcontrols)) {
					drawEllipse(ox+x, oy+y, 4, 4); 
				}
			}
			fill(0);
			if(showtext) drawText("x: "+x+"\ny: "+y, ox+x, oy+y+15); }
		if(drawbbox && bounds!=null) {
			noFill();
			stroke(255,0,0,150);
			strokeWeight(1);
			beginShape();
			drawVertex(bounds[0]+ox, bounds[1]+oy);
			drawVertex(bounds[2]+ox, bounds[3]+oy);
			drawVertex(bounds[4]+ox, bounds[5]+oy);
			drawVertex(bounds[6]+ox, bounds[7]+oy);
			endShape(CLOSE); }
	}

	void drawSegment() { }
	
	Line[] flattened = null;
	Line[] flatten(int steps) { if(flattened!=null) { return flattened; } return new Line[0]; }
	Line[] flattenWithDistanceThreshold(double threshold) { return flatten(0); }

	// offset default: don't offset
	Segment[] offset(double distance) { Segment[] ret = {this}; return ret; }

	// simple offset default: don't offset
	Segment simpleOffset(double distance) { return this; }
	
	int r, g, b;
	void setColor(int r, int g, int b) { this.r=r; this.g=g; this.b=b; }
	
	String toString() {
		String r = "";
		for(int p=0; p<points.length; p++) {
			r += points[p].getX()+","+points[p].getY()+" "; }
		return r; }

	Segment[] splitSegment(double t) { return null; }
	Segment splitSegment(double t1, double t2) { return null; }

	boolean equals(Object o)
	{
		if(this==o) return true;
		if(!(o instanceof Segment)) return false;
		Segment other = (Segment) o;
		if(other.points.length != points.length) return false;
		int len = points.length;
		// if the coordinates are the same, the segments are the same
		boolean same=true;
		for(int p=0; p<len; p++) {
			if(!points[p].equals(other.points[p])) {
				same = false;
				break; }}
		if(same) return true;
		// the segments are also the same if the coordinates match in reverse
		int last = len-1;
		same=true;
		for(int p=0; p<len; p++) {
			if(!points[p].equals(other.points[last-p])) {
				same = false;
				break; }}
		return same;

	}
}
