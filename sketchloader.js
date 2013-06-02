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
    // grab sketch divs
    var figCount = 0,
        sketches = find("textarea[class='sketch-code']");

    // convert to sketch blocks
    sketches.forEach(function(sketch) {
      figCount++;

      var sketchLabel = sketch.get("data-sketch-title");

      var script = create("script",
        { type: "text/processing" },
        sketch.value + "\n" + "String getSketchLabel() { return \""+ sketchLabel +"\"; }\n\n"
      );

      var canvas = create("canvas", {
        id: "figure"+figCount,
        "class": sketch.get("class") + " loading-sketch"
      });

      var preset = sketch.get("data-sketch-preset");
      var dps = "presets/" + preset+".pde" + " ";
      dps += ["Point.pde",
              "BezierCurve.pde",
              "PolyBezierCurve.pde",
              "CurvePair.pde",
              "BezierComputer.pde",
              "BooleanComputer.pde",
              "IntersectionTracker.pde",
              "Colors.pde",
              "Constants.pde",
              "Defaults.pde",
              "framework.pde",
              "Panels.pde",
              "Interaction.pde",
              "API.pde",
              "JavaScript.pde",
              "RuntimeException.pjs"].join(" ");

      canvas.set({
        "data-processing-sources": dps,
        "data-preset": preset,
        "data-print-image": "images/print/" + (figCount<10? "0":'') + figCount + ".gif"
      });

      dependencies[figCount] = dps.replace(" RuntimeException.pjs",'') + (preset == "abc" || preset == "moulding" ? "" : " moulding.pde");
      sourceCode[figCount] = scHeader + sketch.value.replace(/(^|\n)      /g,"\n") + "\n";

      var viewSource = "<span onclick=\"viewSource(" + figCount + ")\">view source</span>";
      var label = create("span", {
        "class": "sketch-title",
        "data-number": ""+figCount
      }, sketchLabel + "<span class='viewsource'> (" + viewSource + ")</span>");

      sketch.replace(create("div",{"class": "sketch"}).css("textAlign", "center").add(script,canvas,create("br"),label));
    });

    /**
     * When MathJax completes, start to trickle-load sketches. We
     * do this last, because we need to make sure all these canvas
     * elements actually exist, which is completely unrelated to
     * MathJax throwing an 'End Process'.
     */
    (function(){
      var trickle = function (msg, target) {
        var listing = find("canvas");

        /**
         * try a sketch load on a canvas element
         */
        var loadSketch = (function(list){
          return function loadSketch() {
            var canvas = list.splice(0,1)[0];
            var label = canvas.parent().find("canvas ~ span").textContent;
            if(canvas.loadSketch) {
              canvas.loadSketch();
              return true; }
            return false; }
        }(listing));

        // interval between trickle loads, in milliseconds:
        var loadInterval = 4000;

        /**
         * trickle-load until we run out of canvas elements.
         */
        var trickle = function trickle() {
          if(listing.length===0) return;
          var timeout = (loadSketch() ? loadInterval : 10);
          setTimeout(trickle, timeout);
        };

        // let's try this
        trickle();
      };

      if (window.MathJax) {
        MathJax.Hub.Register.MessageHook("End Process",trickle);
      } else { trickle("End Process", document.body); }
    }());
  }

  schedule(loadSketches);
}());
