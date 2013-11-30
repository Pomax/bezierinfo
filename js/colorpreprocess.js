function colorpreprocess(section) {
  var regexp = new RegExp("([A-Z]+)\\[([^\\]]+)\\]",'g');

  var rewriteColors = function(input) {
    var output = input.replace(regexp, function(_,color,content) {
      if(content.indexOf(" ")!==-1) { content = " "+content; }
      return "{\\color{"+color.toLowerCase()+"}"+content.replace(/ /g,"\\ ")+"}";
    });
    return output;
  };

  section.find("p").forEach(function(p) {
    if(p.html().substring(0,2)=="\\[") {
      var csubbed = rewriteColors(p.html());
      p.html(csubbed);
    }
  });
}
