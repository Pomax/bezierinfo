(function() {
  var labelImages = function() {
    document.removeEventListener("DOMContentLoaded", labelImages, false);
    var count = 1;
    document.querySelectorAll(".labeled-image").forEach(function(e){
      var p = e.querySelector("p");
      p.setAttribute("data-img-label",count++);
    });
  }
  document.addEventListener("DOMContentLoaded", labelImages, false);
}());
