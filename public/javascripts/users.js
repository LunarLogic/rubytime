$(function() {
  function loginFormat(value, element, params) {
    return this.optional(element) || (/^[\w_-]{3,20}$/).test(value);
  };
  $.validator.addMethod('login', loginFormat, 
    "Login should have between 3 and 20 characters including letters, digits, hyphen or underscore.");
  
  $('#user_form').validate({
    rules: {
      "user[name]": {
        required: true
      },
      "user[login]": {
        login: true
      },
      "user[email]": {
        required: true,
        email: true
      },
      "user[password]": {
        required: true
      },
      "user[password_confirmation]": {
        equalTo: "#user_password"
      }
    }
  });
});