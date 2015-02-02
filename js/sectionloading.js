function loadSectionMath(element) {
  if(window.location.toString().toLowerCase().indexOf("nomathjax") === -1) {
    var typeset = function() {
      MathJax.Hub.Queue(["Typeset", MathJax.Hub, element, false]);
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
  var reveal = function() {
    nunjucks.render(sectionname + ".html", function(err, sectiondata) {
      section.remove(section.find("script"));
      section.add(sectiondata);
      section.find("h2").css("cursor","auto");
      colorpreprocess(section);
      foldCode(section);
      setTimeout(function(){
        var sl = function() {
          if(visible(section)) {
            window.removeEventListener("scroll", sl);
            loadSketches(section);
            loadSectionMath(section);
          }
        };
        window.addEventListener("scroll", sl);
        sl();
      },200);
    });
  };
  reveal();
}
