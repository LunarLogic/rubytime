$(function() {
  $('#client_user_login').fill('#client_name', true);
  $('#client_user_email').fill('#client_email');
  $('#client_user_password, #client_user_password_confirmation').one('change', function() {
  $('#generated_password').empty();
  });
  
  $('#client_form').validate({
  rules: {
    "client[name]": {
    required: true,
    minlength: 3
    },
    "client[email]": {
    email: true
    },
    "client_user[name]": {
    required: true,
    minlength: 3
    },
    "client_user[login]": {
    required: true,
    minlength: 3, 
    maxlength: 20
    },
    "client_user[email]": {
    required: true,
    email: true
    },
    
    "client_user[password]": {
    required: true
    },
    "client_user[password_confirmation]": {
    equalTo: "#client_user_password"
    }
  }
  });
});