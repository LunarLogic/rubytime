var Rubytime ={
  error: function(message) {
    alert(message);
  },
  
  errorFromXhr: function(xhr) {
    if (xhr.status >= 400 && xhr.status < 500)
      Rubytime.error(xhr.responseText);
    if(xhr.status >= 500)
      Rubytime.error("Ooops! Something went wrong.");
  }
};