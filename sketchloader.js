(function(){
  function loadSketches() {
    document.removeEventListener("DOMContentLoaded", loadSketches, false);

    // grab sketch divs
    var nodelist = document.querySelectorAll("textarea[class='sketch-code']");
    var sketches = [];
    for(var i=0, e=nodelist.length; i<e; i++) { sketches.push(nodelist[i]); }

    var figCount = 1;

    // convert to sketch blocks
    sketches.forEach(function(sketch) {
      var script = document.createElement("script");
      script.type = "text/processing";
      script.innerHTML = sketch.value;

      var canvas = document.createElement("canvas");
      canvas.setAttribute("class", sketch.getAttribute("class"));
      var dps = "presets/" + sketch.getAttribute("data-sketch-preset")+".pde";
      dps += " RuntimeException.pjs API.pde Point.pde BezierCurve.pde BezierComputer.pde Interaction.pde framework.pde";
      canvas.setAttribute("data-processing-sources", dps);

      var label = document.createElement("span");
      label.innerHTML = sketch.getAttribute("data-sketch-title");
      label.setAttribute("class", "sketch-title");
      label.setAttribute("data-number", ""+(figCount++));

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