/**
 * Processing does not support doubles. A bit silly, but easy enough to get around
 */

double abs(double x) { if(x<0) { return -x; } return x; }
double min(double a, double b) { if(a<b) { return a; } return b; }
double max(double a, double b) { if(a<b) { return b; } return a; }
double sqrt(double v) { return Math.sqrt(v); }

double sin(double v) { return Math.sin(v); }
double cos(double v) { return Math.cos(v); }
double tan(double v) { return Math.tan(v); }
double asin(double v) { return Math.asin(v); }
double acos(double v) { return Math.acos(v); }
double atan(double v) { return Math.atan(v); }

int round(double x) { return (int) Math.round(x); }
int floor(double x) { return (int) Math.floor(x); }
int ceil(double x) { return (int) Math.ceil(x); }

// -- draw methods --

void drawPoint(double x, double y) { point(round(x),round(y)); }
void drawLine(double x1, double y1, double x2, double y2) {
	line(round(x1),round(y1),round(x2),round(y2)); }
void drawRect(double x, double y, double w, double h) {
	rect(round(x),round(y),round(w),round(h)); }
void drawBezier(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) {
	bezier(round(x1),round(y1),round(x2),round(y2),round(x3),round(y3),round(x4),round(y4)); }
void drawEllipse(double x, double y, double w, double h) {
	ellipse(round(x),round(y),round(w),round(h)); }
void drawText(String t, double x, double y) {text(t,round(x),round(y)); }
void drawVertex(double x, double y) { vertex((float)x,(float)y); }
