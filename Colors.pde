/**
 * Fixed color list
 */
int[] colorListing = new int[100];

void setupColors() {
  for(int i=0; i<colorListing.length; i++) {
    randomSeed(i);
    colorListing[i] = color(random(255),random(255),random(255));
  }
}

int getColor(float idx) { return colorListing[int(idx) % 100]; }
