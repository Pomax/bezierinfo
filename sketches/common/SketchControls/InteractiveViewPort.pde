// interaction handling when viewports are used

Point moving = new Point(0,0);
int mx, my;

void mouseMoved() {
	for(int p=0; p<points.length; p++) {
		if(points[p].over(mouseX-main.ox,mouseY-main.oy)) {
			cursor(HAND);
			return; }}
	cursor(ARROW); }

void mousePressed() {
	for(int p=0; p<points.length; p++) {
		if(points[p].over(mouseX-main.ox,mouseY-main.oy)) {
			moving=points[p];
			mx=mouseX;
			my=mouseY;
			break; }}}

void mouseDragged() {
	if(moving!=null) {
		moving.xo = mouseX-mx;
		moving.yo = mouseY-my; }
	redraw(); }

void mouseReleased() {
	if(moving!=null) {
		moving.x = moving.x+moving.xo;
		moving.y = moving.y+moving.yo;
		moving.xo = 0;
		moving.yo = 0;
		moving=null; }
	cursor(ARROW);
	redraw(); }

/**
 * Used all over the place - draws all points as open circles,
 * in a viewport, and lists their coordinates underneath.
 */
void showPointsInViewPort(Point[] points, ViewPort port) {
	stroke(0,0,200);
	for(int p=0; p<points.length; p++) {
		noFill();
		port.drawEllipse(points[p].getX(), points[p].getY(), 5, 5);
		fill(0,0,255,100);
		int x = round(points[p].getX());
		int y = round(points[p].getY());
		port.drawText("x"+(p+1)+": "+x+"\ny"+(p+1)+": "+y, x-10, y+15); }}
