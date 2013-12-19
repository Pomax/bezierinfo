(function() {
  var scanning = false;

  var beforePrint = function() {
    //console.log('Functionality to run before printing.');
    if(scanning) { return; }
    var res = !!confirm("This page cannot be printed without first processing all\n"+
                         "the graphics and formulae. Would you like to do this now?\n"+
                         "Note: if you do, you will have to cancel your current print.");
    if(res) {
      scanning = true;
      (function scrollDown() {
        if(window.innerHeight + window.scrollY < window.document.body.offsetHeight) {
          window.scrollBy(0, window.innerHeight / 2);
          setTimeout(scrollDown, 100);
        } else {
          window.scrollTo(0,0);
          alert("This page can now be printed properly.");
        }
      }());
    }
  };

  var afterPrint = function() {
    //console.log('Functionality to run after printing');
  };

  if (window.matchMedia) {
    var mediaQueryList = window.matchMedia('print');
    mediaQueryList.addListener(function(mql) {
      if (mql.matches) {
        if(beforePrint()) {

        }
      }
      else { afterPrint(); }
    });
  }

  window.onbeforeprint = beforePrint;
  window.onafterprint = afterPrint;
}());