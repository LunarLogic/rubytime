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
  
  $('#project_form .activity_types a.toggler').click(function() { 
    $(this).parents('.activity_types').children('ul').toggle('fast') 
  });
  
  $('#project_form .activity_types input[type=checkbox]').click(function() { 
    $(this).filter(':checked').siblings('ul').show().find('li input[type=checkbox]').attr("checked", "checked");
    $(this).filter(':not(:checked)').siblings('ul').hide().find('li input[type=checkbox]').removeAttr("checked");
  });
});

