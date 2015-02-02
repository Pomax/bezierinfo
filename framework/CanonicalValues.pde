static class CanonicalValues {
  float B3x, B3y, A, B, C, discriminant;

  CanonicalValues(Point B3, float s) {
    B3x = B3.x / s;
    B3y = B3.y / s;
    A = 9 * (B3.x + B3.y - 3);
    B = -9 * (B3.x - 3);
    C = -9;
    discriminant = B3x * B3x - 2 * B3x + 4 * B3y - 3;  
  }

  boolean hasLoop() {
    return discriminant < 0; 
  }

  boolean hasCusp() {
    // epislon based "equal to 0"
    return abs(discriminant) < 0.000001; 
  }
}

