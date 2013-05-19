schedule(function labelImages() {
  var count = 1;
  find(".labeled-image").forEach(function(e){
    e.find("p").set("data-img-label", count++);
  });
});
