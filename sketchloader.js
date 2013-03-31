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
  }

  document.addEventListener("DOMContentLoaded", loadSketches, false);
}());