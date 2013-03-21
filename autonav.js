(function(d) {
  var nav = d.querySelector("#navbar");
  var items = d.querySelectorAll("section"), e, i, l;
  for(i=1, l=items.length; i<l; i++) {
    e = items[i];
    if(e.id) {
      var entry = d.createElement("li");
      var html = "<a href='#" + e.getAttribute("id") + "'>" + e.querySelector("h2").innerHTML + "</a>";
      entry.innerHTML = html;
      nav.appendChild(entry);
    }
  };
}(document));
