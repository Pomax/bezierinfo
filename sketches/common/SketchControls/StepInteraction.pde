// intertaction handling for sketches with a "steps" regulator

void keyPressed()
{
	if(key=='+' || key == 107) { steps++; redraw(); }
	else if(key=='-' || key == 109) { if(steps>1) steps--; redraw(); }
}
