(function(){
  function loadSketches() {
    document.removeEventListener("DOMContentLoaded", loadSketches, false);

    // grab sketch divs
    var nodelist = document.querySelectorAll("div[class='sketch-code']");
    var sketches = [];
    for(var i=0, e=nodelist.length; i<e; i++) { sketches.push(nodelist[i]); }

    var figCount = 1;

    // convert to sketch blocks
    sketches.forEach(function(div) {
      var script = document.createElement("script");
      script.type = "text/processing";
      script.innerHTML = div.textContent;

      var canvas = document.createElement("canvas");
      canvas.setAttribute("class", div.getAttribute("class"));
      var dps = "presets/" + div.getAttribute("data-sketch-preset")+".pde";
      dps += " RuntimeException.pjs API.pde Point.pde BezierCurve.pde BezierComputer.pde Interaction.pde framework.pde";
      canvas.setAttribute("data-processing-sources", dps);

      var label = document.createElement("span");
      label.innerHTML = div.getAttribute("data-sketch-title");
      label.setAttribute("class", "sketch-title");
      label.setAttribute("data-number", ""+(figCount++));

      div.innerHTML="";
      div.setAttribute("class","sketch");
      div.appendChild(script);
      div.appendChild(canvas);
      div.appendChild(document.createElement("br"));
      div.appendChild(label);
    });
  }

  document.addEventListener("DOMContentLoaded", loadSketches, false);
}());