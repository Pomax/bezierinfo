boolean firstrun = true;
boolean playing = true;

/**
 * Start playback
 */
void play() {
	frameRate(24);
	playing = true;
	loop();
}
 
/**
 * Pause playback
 */
void pause() {
	noLoop(); 
	playing = false;
	fill(127,0,0,50);
	String pausetext = "Animated sketch, click to play/pause";
	textSize(40);
	float twidth = textWidth(pausetext);
	text(pausetext, (width-twidth)/2,height/2);
	textSize(10);
	firstrun=false;
}

/**
 * Does not fire on click-drag-release,
 * which means it won't interfere with
 * other mouse interaction
 */
void mouseClicked() {
	if(!playing) { play(); }
	else { pause(); }}
