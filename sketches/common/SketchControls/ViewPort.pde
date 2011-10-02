/**
 * Convenience class for drawing things relative to a fixed coordinate,
 * without constantly having to add the offsets to Processing draw commands
 */
class ViewPort
{
	int ox,oy,width,height;
	ViewPort(int x, int y, int w, int h) { ox=x; oy=y; this.width=w; this.height=h;}
	void offset(int x, int y) { ox+=x; oy+=y; }
	void drawPoint(double x, double y) { point(ox+(int)round(x), oy+(int)round(y)); }
	void drawPoint(double x, double y, int r, int g, int b, int a) { stroke(r,g,b,a); drawPoint(x,y); }
	void drawLine(double sx, double sy, double ex, double ey) { line(ox+(int)round(sx),oy+(int)round(sy),ox+(int)round(ex),oy+(int)round(ey)); }
	void drawLine(double sx, double sy, double ex, double ey, int r, int g, int b, int a) { stroke(r,g,b,a); drawLine(sx,sy,ex,ey); }
	void drawText(String t, double x, double y) { text(t,ox+(int)round(x),oy+(int)round(y)); }
	void drawText(String t, double x, double y, int r, int g, int b, int a) { fill(r,g,b,a); drawText(t,x,y); }
	void drawEllipse(double x, double y, double r1, double r2) { ellipse(ox+(int)round(x),oy+(int)round(y),(int)round(r1),(int)round(r2)); }
	void drawEllipse(double x, double y, double r1, double r2, int r, int g, int b, int a) { stroke(r,g,b,a); noFill(); drawEllipse(x,y,r1,r2); }
}
