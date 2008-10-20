$(function() {
  $('#project_form').validate({
    rules: {
      "project[name]": {
        required: true
      },
      "project[client_id]": {
        required: true
      }
    }
  });
});