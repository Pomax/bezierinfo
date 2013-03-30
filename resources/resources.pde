HashMap<Float, Float> values;
float minx = 9999999, maxx = -999999;
ArrayList<Float> keys;

int hpad = 30, vpad=20;

void setup() {
  size(300, 187);
  String[] data = loadStrings("./plot-data.txt");
  keys = new ArrayList<Float>();
  values = new HashMap<Float, Float>();
  float x, y;
  for (String s: data) {
    String[] terms = s.split("\t");
    x = Float.parseFloat(terms[0]);
    y = Float.parseFloat(terms[1]);
    values.put(x, y);
    if (x<minx) minx = x;
    if (x>maxx) maxx = x;
    keys.add(x);
  }
  noLoop();
  textFont(createFont("Times", 11));
}

void draw() {
  float xrange = 0.2*PI, yrange = 0.0005;

  background(255);
  println(minx+"/"+maxx);
  stroke(0, 0, 200, 150);
  float px=hpad, py=height-vpad, y;
  for (float x: keys) {
    y = values.get(x);
    x = map(x, 0, xrange, hpad, width);
    y = map(y, 0, yrange, height-vpad, 0);
    line(px, py, x, y);
    px=x;
    py=y;
  }
  stroke(0);
  fill(0);
  line(hpad, 0, hpad, height-(vpad-5));
  line((hpad-5), height-vpad, width, height-vpad);

  float x, f;
  int last = 0;
  textAlign(CENTER, CENTER);  
  for (x=0; x<xrange; x+=0.001) {
    f = map(x, 0, xrange, hpad, width);
    if (int(f)%10==0) {
      line(f, height-(vpad+2), f, height-vpad);
    }
    if (round(f)%50==30 && round(f)!=last) {
      line(f+1, height-(vpad+4), f+1, height-(vpad+2));
      last = round(f);
      text((int(x*10)/10.0)+"", f, height-10);
    }
  } 

  textAlign(RIGHT, CENTER);
  for (y=0; y<yrange; y+=0.00001) {
    f = map(y, 0, yrange, height-vpad, 0);
    if (int(f)%10==0) {
      line(hpad, f, hpad+2, f);
    }
    if (round(f)%40==10 && round(f)!=last) {
      last = round(f);
      line(hpad+2, f, hpad+4, f);
      text((int(y*10000)/10000.0)+"", hpad-2, f-1);
    }
  }
}

