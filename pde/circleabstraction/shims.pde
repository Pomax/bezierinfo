void bezier(double... v) {
  super.bezier(
    (float)v[0], (float)v[1],
    (float)v[2], (float)v[3],
    (float)v[4], (float)v[5],
    (float)v[6], (float)v[7]
  );
}

void arc(double... v) {
  super.arc(
    (float)v[0], (float)v[1],
    (float)v[2], (float)v[3],
    (float)v[4], (float)v[5]
  );
}

void ellipse(double... v) {
  super.ellipse(
    (float)v[0], (float)v[1],
    (float)v[2], (float)v[3]
  );
}

void line(double... v) {
  super.line(
    (float)v[0], (float)v[1],
    (float)v[2], (float)v[3]
  );
}

double sin(double v) {
  return Math.sin(v);
}

double cos(double v) {
  return Math.cos(v);
}

double atan2(double dy, double dx) {
  return Math.atan2(dy,dx);
}

double sqrt(double v) {
  return Math.sqrt(v);
}

double abs(double v) {
  return Math.abs(v);
}

double random(double v) {
  return Math.random()*v;
}