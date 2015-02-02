var scHeader = "/***************************************************\n"+
" *                                                 *\n"+
" *   Example source - this is public domain code   *\n"+
" *                                                 *\n"+
" ***************************************************/\n\n";

function viewSketchSource(id) {
  var source = scHeader + viewSketchSource[id].code + "\n", xhr;
  viewSketchSource[id].dependencies.forEach(function(dep) {
    xhr = new XMLHttpRequest();
    xhr.open("GET",dep,false);
    xhr.send(null);
    source += "\n" + xhr.responseText;
  });

  var tab = window.open("");
  tab.document.body.style.whiteSpace = "pre";
  tab.document.body.style.fontFamily = "monospace";
  tab.document.body.innerHTML = source.replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

function loadSketches(section) {
  var figCount = 0,
      sketches = section.find("textarea[class='sketch-code']"),
      secCount = section.find("h2").get("data-num");

  // convert to sketch blocks
  sketches.forEach(function(sketch) {
    figCount++;

    var id = secCount+"."+figCount;
    var sketchLabel = "Figure "+id+": "+sketch.get("data-sketch-title");
    var sketchCode = sketch.value + "\n\nString getSketchLabel() {\n  return \""+ sketchLabel +"\";\n}\n\n";
    var canvas = create("canvas", { id: "figure"+secCount + "." + figCount, "class": sketch.get("class") });
    var preset = sketch.get("data-sketch-preset");
    var dps = ["presets/" + preset+".pde",
                "framework/Point.pde",
                "framework/BezierCurve.pde",
                "framework/PolyBezierCurve.pde",
                "framework/CurvePair.pde",
                "framework/BezierComputer.pde",
                "framework/BooleanComputer.pde",
                "framework/IntersectionTracker.pde",
                "framework/CanonicalLayout.pde",
                "framework/CanonicalValues.pde",
                "framework/BezierCurve.pde",
                "framework/Colors.pde",
                "framework/Constants.pde",
                "framework/Defaults.pde",
                "framework/framework.pde",
                "framework/Panels.pde",
                "framework/Interaction.pde",
                "framework/API.pde",
                "framework/JavaScript.pde"];

    if (preset.indexOf("abc")===-1 && preset.indexOf("mould")===-1) {
      dps.push("framework/moulding.pde");
    }

    canvas.set({
      "data-print-image": "images/print/" + (figCount<10? "0":'') + figCount + ".gif"
    });

    var label = create("span", {
      "class": "sketch-title",
      "data-number": ""+figCount
    }, sketchLabel + "<button class='viewsource' onclick='viewSketchSource("+id+")'>view source</button>");
    viewSketchSource[id] = {
      dependencies: dps,
      code: sketchCode
    };
    sketch.replace(create("div",{"class": "sketch"}).css("textAlign", "center").add(canvas, create("br"), label));
    Processing.loadSketchFromSources(canvas, dps.concat("RuntimeException.pjs"), [sketchCode]);
  });
}
