(function(d) {
  var nav = d.querySelector("#navbar ol");
  var items = d.querySelectorAll("section"), e, i, l;
  var sectionId = 1;
  for(i=1, l=items.length; i<l; i++) {
    e = items[i];
    if(e.id) {
      var titular = e.querySelector("h2");
      titular.setAttribute("data-num", sectionId++);
      var entry = d.createElement("li");
      var html = "<a href='#" + e.getAttribute("id") + "'>" + e.querySelector("h2").innerHTML + "</a>";
      entry.innerHTML = html;
      nav.appendChild(entry);
    }
  };
}(document));
