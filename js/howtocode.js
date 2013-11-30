function foldCode(section) {
  section.find(".howtocode h3").forEach(function(h3) {
    h3.parent().find("h3 ~ *").toggle();
    h3.listen("click", function() {
      h3.parent().find("h3 ~ *").toggle();
    });
  });
}
