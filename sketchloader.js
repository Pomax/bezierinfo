(function(){

  var dependencies = [],
      sourceCode = [];

  var viewSource = function(idx) {
    var source = sourceCode[idx] + "\n", xhr;
    dependencies[idx].split(/\s+/).forEach(function(dep) {
      // this *SHOULD* come in straight from cache.
      xhr = new XMLHttpRequest();
      xhr.open("GET",dep,false);
      xhr.send(null);
      source += xhr.responseText;
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

      var script = document.createElement("script");
      script.type = "text/processing";
      script.innerHTML = sketch.value;

      var canvas = document.createElement("canvas");
      canvas.setAttribute("class", sketch.getAttribute("class"));
      var preset = sketch.getAttribute("data-sketch-preset");
      var dps = "presets/" + preset+".pde";
      dps += " RuntimeException.pjs API.pde Point.pde BezierCurve.pde BezierComputer.pde Interaction.pde JavaScript.pde framework.pde";
      canvas.setAttribute("data-processing-sources", dps);
      canvas.setAttribute("data-preset",preset);

      dependencies[figCount] = dps.replace(" RuntimeException.pjs",'') + (preset == "abc" || preset == "moulding" ? "" : " moulding.pde");
      sourceCode[figCount] = sketch.value.replace(/(^|\n)      /g,"\n") + "\n";

      var viewSource = "<span onclick=\"viewSource(" + figCount + ")\">view source</span>";
      var label = document.createElement("span");
      label.innerHTML = sketch.getAttribute("data-sketch-title") + " (" + viewSource + ")";
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