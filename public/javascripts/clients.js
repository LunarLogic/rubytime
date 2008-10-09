$(function() {
  $('#client_user_login').fill('#client_name');
  $('#client_user_email').fill('#client_email');
  $('#client_user_password, #client_user_password_confirmation').one('change', function() {
    $('#generated_password').empty();
  });
});