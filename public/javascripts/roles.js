$(function() {
  $('#role_form').validate({
  rules: {
    "role[name]": {
    required: true
    }
  }
  });
});