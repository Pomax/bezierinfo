function loadSectionMath(element, callback) {
  callback = callback || function(){};
  if(window.location.toString().indexOf("noMathJax") === -1) {
    var typeset = function() {
      MathJax.Hub.Queue(["Typeset", MathJax.Hub, element, callback]);
    };
    if(!window.MathJax) {
      var script = document.createElement("script");
      script.src = "http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML";
      script.onload = typeset;
      document.head.appendChild(script);
    } else { typeset(); }
  }
}

nunjucks.configure('views', { autoescape: false });

function visible(element) {
  var rect = element.getBoundingClientRect();
  return rect.top <= window.innerHeight && rect.bottom > 0;
}

function inject(sectionname) {
  var section = find("#" + sectionname);
  var reveal = function(callback) {
    nunjucks.render(sectionname + ".html", function(err, sectiondata) {
      section.remove(section.find("script"));
      section.add(sectiondata);
      section.find("h2").css("cursor","auto");
      colorpreprocess(section);
      foldCode(section);
      var sl = function() {
        if(visible(section)) {
          window.removeEventListener("scroll", sl);
          console.log("removing");
          loadSketches(section);
          loadSectionMath(section, callback);
        }
      };
      window.addEventListener("scroll", sl);
    });
  };
  //section.find("h2").listen("click", reveal);
  reveal();
}
