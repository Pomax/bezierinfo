static class TestRunner {
  static int test = 1;
  
  static boolean equal(float a, float b, String desc) {
    int testNumber = test++;
    if(abs(a-b)>0.0001) {
      println("["+testNumber+"] test failed, "+desc); 
      println("  "+a+" does not equal "+b);
      return false;
    }
    println("["+testNumber+"] test passed"); 
    return true;
  }

  static boolean equal(float[] a, float[] b, String desc) {
    return equal(a,b,desc,0.00001);
  }

  static boolean equal(float[] a, float[] b, String desc, float precision) {
    int testNumber = test++;
    
    if(a.length!=b.length) {
      println("["+testNumber+"] test failed, unequal length arrays, "+desc); 
      println();
      println("found values:");
      println(a);
      println();
      println("supposed values:");
      println(b);
      println();
      return false;
    }
    
    for(int i=0, end=a.length; i<end; i++) {
      if(abs(a[i]-b[i])>precision) {
        println("["+testNumber+"] test failed, "+desc); 
        println("  "+a[i]+" does not equal "+b[i]);
        println();
        println("found values:");
        println(a);
        println();
        println("supposed values:");
        println(b);
        println();
        return false;
      } 
    }
    println("["+testNumber+"] test passed"); 
    return true;
  }
}
