schedule(function() {
  var nav = find("#navbar ol"),
      items = find("section"),
      sectionId = 1,
      e, i, l,
      id, titular, entry;
  for(i=1, l=items.length; i<l; i++) {
    e = items[i];
    if(e.id) {
      id = e.id,
      titular = find("#"+id+" > h2:first-child"),
      titular.set("data-num", sectionId++);
      entry = create("li");
      entry.innerHTML = "<a href='#" + id + "'>" +titular.innerHTML + "</a>";
      nav.add(entry);
    }
  };
});
