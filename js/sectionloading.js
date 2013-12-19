function loadSectionMath(element, forced) {
  if(window.location.toString().indexOf("noMathJax") === -1) {
    var typeset = function() {
      if (forced) { MathJax.Hub.Typeset(element); }
      else { MathJax.Hub.Queue(["Typeset", MathJax.Hub, element]); }
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

var sectionLoaders = [];

function inject(sectionname) {
  var section = find("#" + sectionname);
  var reveal = function() {
    nunjucks.render(sectionname + ".html", function(err, sectiondata) {
      section.remove(section.find("script"));
      section.add(sectiondata);
      section.find("h2").css("cursor","auto");
      colorpreprocess(section);
      foldCode(section);
      var sl = function(forced) {
        var pos = sectionLoaders.indexOf(sl);
        if(pos>-1) { sectionLoaders.splice(pos,1); }
        if(forced===true || visible(section)) {
          window.removeEventListener("scroll", sl);
          loadSketches(section);
          loadSectionMath(section, forced);
        }
      };
      window.addEventListener("scroll", sl);
      sectionLoaders.push(sl);
    });
  };
  reveal();
}
