void setupScreen() {}

void setupCurve() {}

void drawFunction() { test(); exit(); }

void test() {
  testBezierComputer();
}

void testBezierComputer() {
  testQuadratic();
  testCubic();
}

void testQuadratic() {
  BezierComputer comp = new BezierComputer();
  float[] values = { 1., 3., 2. };
  TestRunner.equal(comp.getValue(0,     values), 1,     "quadratic at 0");
  TestRunner.equal(comp.getValue(1./3., values), 2,     "quadratic at 1/3");
  TestRunner.equal(comp.getValue(2./3., values), 7./3., "quadratic at 2/3");
  TestRunner.equal(comp.getValue(1,     values), 2.,    "quadratic at 1");

  TestRunner.equal(comp.getDerivative(1, 0,     values),  4, "quadratic' at 0");
  TestRunner.equal(comp.getDerivative(1, 1./3., values),  2, "quadratic' at 1/3");
  TestRunner.equal(comp.getDerivative(1, 2./3., values),  0, "quadratic' at 2/3");
  TestRunner.equal(comp.getDerivative(1, 1,     values), -2, "quadratic' at 1");
}

void testCubic() {
  BezierComputer comp = new BezierComputer();
  float[] values = { 1., -3., 7., 2 };
  TestRunner.equal(comp.getValue(0,     values), 1,       "cubic at 0");
  TestRunner.equal(comp.getValue(1./3., values), 16./27., "cubic at 1/3");
  TestRunner.equal(comp.getValue(2./3., values), 83./27., "cubic at 2/3");
  TestRunner.equal(comp.getValue(1,     values), 2.,      "cubic at 1");

  TestRunner.equal(comp.getDerivative(1, 0,     values), -12,    "cubic' at 0");
  TestRunner.equal(comp.getDerivative(1, 1./3., values), 19./3., "cubic' at 1/3");
  TestRunner.equal(comp.getDerivative(1, 2./3., values), 16./3., "cubic' at 2/3");
  TestRunner.equal(comp.getDerivative(1, 1,     values), -15.,   "cubic' at 1");

  TestRunner.equal(comp.getDerivative(2, 0,     values),  84, "cubic'' at 0");
  TestRunner.equal(comp.getDerivative(2, 1./3., values),  26, "cubic'' at 1/3");
  TestRunner.equal(comp.getDerivative(2, 2./3., values), -32, "cubic'' at 2/3");
  TestRunner.equal(comp.getDerivative(2, 1,     values), -90, "cubic'' at 1");
  
  // real root is 1.1008, but this value is outside [0,1]
  TestRunner.equal(comp.findAllRoots(0, values), new float[]{},           "cubic root");
  TestRunner.equal(comp.findAllRoots(1, values), new float[]{0.17434, 0.79118}, "cubic' roots");
  TestRunner.equal(comp.findAllRoots(2, values), new float[]{0.48276},          "cubic'' root");

  // Joe Hewitt curve
  values = new float[]{ 0, -25, 7, -25 };
  TestRunner.equal(comp.findAllRoots(0, values), new float[]{0},                "cubic root (2)");
  TestRunner.equal(comp.findAllRoots(1, values), new float[]{0.34738, 0.59477}, "cubic' roots (2)");
  TestRunner.equal(comp.findAllRoots(2, values), new float[]{0.47107},          "cubic'' root (2)");

  values = new float[]{ 0, 0, 15, 25 };
  // real roots are {0, 9/4}, but second value is outside [0,1]
  TestRunner.equal(comp.findAllRoots(0, values), new float[]{0}, "cubic roots (3)");
  // real roots are {0, 3/2}, but second value is outside [0,1]
  TestRunner.equal(comp.findAllRoots(1, values), new float[]{0}, "cubic' roots (3)");
  TestRunner.equal(comp.findAllRoots(2, values), new float[]{0.75},    "cubic'' root (3)");
  
  hewittTest();
}

void hewittTest() {
  Point[] points = {
    new Point(0,0),
    new Point(-25,0),
    new Point(7,15),
    new Point(-25,25)
  };
  BezierCurve c = new BezierCurve(points);
  float[] inflectionPoints = c.getInflections();
  TestRunner.equal(inflectionPoints, new float[]{0,0.34738,0.47107,0.59477,0.75,1}, "Joe's curve");
}
