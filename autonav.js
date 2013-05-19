schedule(function() {
  var nav = find("#navbar ol"),
      items = find("section"),
      sectionId = 1,
      e, i, l;
  for(i=1, l=items.length; i<l; i++) {
    e = items[i];
    if(e.id) {
      var titular = e.find("h2");
      titular.set("data-num", sectionId++);
      var entry = create("li");
      var html = "<a href='#" + e.get("id") + "'>" + e.find("h2").innerHTML + "</a>";
      entry.innerHTML = html;
      nav.add(entry);
    }
  };
});
