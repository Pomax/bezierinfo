/**
 * Convenience class, used for interactive points
 */
class Point
{
	double x, y;
	double xo=0;
	double yo=0;
	boolean moving=false;
	Point(double x, double y) {
		this.x = x;
		this.y = y; }
	double getX() { return x+xo; }
	double getY() { return y+yo; }
	boolean over(int x, int y) { return abs(this.x-x)<=3 && abs(this.y-y)<=3; }
	String toString() { return x+","+y; }
	boolean equals(Object o) {
		if(this==o) return true;
		if(!(o instanceof Point)) return false;
		Point other = (Point) o;
		return abs(x-other.x)<=0.1 && abs(y-other.y)<=0.1; }
}
