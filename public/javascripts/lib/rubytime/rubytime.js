var Rubytime ={
  notice: function(message) {
    Rubytime._showFlash("notice", message);
  },
  
  error: function(message) {
    Rubytime._showFlash("error", message);
  },
  
  errorFromXhr: function(xhr) {
    if (xhr.status >= 400 && xhr.status < 500)
      Rubytime.error(xhr.responseText);
    if(xhr.status >= 500)
      Rubytime.error("Ooops! Something went wrong.");
  },
  
  _showFlash: function(klass, message) {
    $("#flash").addClass(klass).text(message).click(Rubytime._closeFlash).slideDown();
  },
  
  _closeFlash: function() {
    $("#flash").slideUp(function() {
      $(this).removeClass("notice").removeClass("error").hide();
    });
  }
};