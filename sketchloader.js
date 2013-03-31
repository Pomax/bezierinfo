(function(){

  var dependencies = [],
      sourceCode = [];

  var scHeader = "/***************************************************\n"+
" *                                                 *\n"+
" *   Example source - this is public domain code   *\n"+
" *                                                 *\n"+
" ***************************************************/\n\n";

  var viewSource = function(idx) {
    var source = sourceCode[idx] + "\n", xhr;
    dependencies[idx].split(/\s+/).forEach(function(dep) {
      // this *SHOULD* come in straight from cache.
      xhr = new XMLHttpRequest();
      xhr.open("GET",dep,false);
      xhr.send(null);
      source += "\n" + xhr.responseText;
    });
    var tab = window.open("");
    tab.document.body.style.whiteSpace = "pre";
    tab.document.body.style.fontFamily = "monospace";
    tab.document.body.innerHTML = source.replace(/</g,'&lt;').replace(/>/g,'&gt;');
  };
  window.viewSource = viewSource;

  function loadSketches() {
    document.removeEventListener("DOMContentLoaded", loadSketches, false);

    // grab sketch divs
    var nodelist = document.querySelectorAll("textarea[class='sketch-code']");
    var sketches = [];
    for(var i=0, e=nodelist.length; i<e; i++) { sketches.push(nodelist[i]); }

    var figCount = 0;

    // convert to sketch blocks
    sketches.forEach(function(sketch) {
      figCount++;

      var sketchLabel = sketch.getAttribute("data-sketch-title");

      var script = document.createElement("script");
      script.type = "text/processing";
      script.innerHTML = sketch.value + "\n" +
                         "String getSketchLabel() { return \""+ sketchLabel +"\"; }\n\n";

      var canvas = document.createElement("canvas");
      canvas.id = "figure"+figCount;
      canvas.setAttribute("class", sketch.getAttribute("class") + " loading-sketch");
      var preset = sketch.getAttribute("data-sketch-preset");
      var dps = "presets/" + preset+".pde";
      dps += " Point.pde BezierCurve.pde CurvePair.pde BezierComputer.pde framework.pde Interaction.pde API.pde JavaScript.pde RuntimeException.pjs";
      canvas.setAttribute("data-processing-sources", dps);
      canvas.setAttribute("data-preset",preset);
      canvas.setAttribute("data-print-image","images/print/"+(figCount<10? "0":'')+figCount+".gif");

      dependencies[figCount] = dps.replace(" RuntimeException.pjs",'') + (preset == "abc" || preset == "moulding" ? "" : " moulding.pde");
      sourceCode[figCount] = scHeader + sketch.value.replace(/(^|\n)      /g,"\n") + "\n";

      var viewSource = "<span onclick=\"viewSource(" + figCount + ")\">view source</span>";
      var label = document.createElement("span");
      label.innerHTML = sketchLabel + "<span class='viewsource'> (" + viewSource + ")</span>";
      label.setAttribute("class", "sketch-title");
      label.setAttribute("data-number", ""+figCount);

      div = document.createElement("div");
      div.setAttribute("class","sketch");
      div.style.textAlign = "center";
      div.appendChild(script);
      div.appendChild(canvas);
      div.appendChild(document.createElement("br"));
      div.appendChild(label);
      sketch.parentNode.replaceChild(div,sketch);
    });
  
    /**
     * When MathJax completes, start to trickle-load sketches. We
     * do this last, because we need to make sure all these canvas
     * elements actually exist, which is completely unrelated to
     * MathJax throwing an 'End Process'.
     */
    (function(){
      MathJax.Hub.Register.MessageHook("End Process", function (msg, target) {
        var listing = document.querySelectorAll("canvas").toArray();

        /**
         * try a sketch load on a canvas element
         */
        var loadSketch = (function(list){
          return function loadSketch() {
            var canvas = list.splice(0,1)[0];
            var label = canvas.parentNode.querySelector("canvas ~ span");
            if(canvas.loadSketch) {
              canvas.loadSketch();
              return true; }
            return false; }
        }(listing));

        // interval between trickle loads, in milliseconds:
        var loadInterval = 350;

        /**
         * trickle-load until we run out of canvas elements.
         */
        var trickle = function trickle() {
          if(listing.length===0) return;
          var timeout = (loadSketch() ? loadInterval : 10);
          if(console.info) {
            console.info("trickle loading, timeout: "+timeout);
          }
          setTimeout(trickle, timeout);
        };

        // let's try this
        trickle();
      });
    }());
  }

  document.addEventListener("DOMContentLoaded", loadSketches, false);
}());
