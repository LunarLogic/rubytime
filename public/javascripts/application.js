// TODO clean up application.js
var EVENTS = {
  activities_changed: 'activitites:changed',
  activity_added: 'activitites:added',
  activity_deleted: 'activitites:deleted',
  add_activity_clicked: 'activitites:add_clicked'
};

$(function() {
  $.ajaxSetup({
      error: function(xhr) {
        Rubytime.errorFromXhr(xhr);
      }
  });
  
  function hoursFormat(value, element, params) {
    return this.optional(element) || (/^\d+([\.,]\d+|:[0-5]\d)?$/).test(value);
  };
  $.validator.addMethod('hours', hoursFormat, "Please enter hours in format like 3:45 or 2,5.");
});

function addOnSubmitForActivityPopup() {
  $("#add_activity_form").validate({
    rules: {
      "activity[hours]": {
        hours: true
      },
      "activity[comments]": {
        required: true
      }
    }
  });
  $("#add_activity_form").focusFirstBlank();
  $("#add_activity_form").submit(function() {
      var form = $("#add_activity_form");
      $.ajax({
        url: form.url(), 
        type: "POST",
        data: form.serialize(),
        success: function(responseText) {
          var responseText = $(responseText).hide();
          $('#' + $('#activity_date').attr('value')).before(responseText).parents('td.day').find('a.show_day').show();
          responseText.fadeIn();
          hideActivityPopup();
          
          $(document).trigger(EVENTS.activity_added, {date: $('#activity_date').attr('value')});
        },
        error: function(xhr) {
          $('#add_activity').html(xhr.responseText);
          addOnSubmitForActivityPopup();
        }
      });
      $("#add_activity_form input[type=submit]").attr("disabled", "true");
      return false;
  });
}

function hideActivityPopup() {
  $("#add_activity").fadeOut(function() { $("#add_activity_form").remove(); });
  return false;
}

$(function() {
    $(".datepicker").datepicker({
      dateFormat: "yy-mm-dd", duration: "", showOn: "both", 
      buttonImage: "/images/icons/calendar_month.png", buttonImageOnly: true });
    
    $(".add-activity a").click(function() { $(document).trigger(EVENTS.add_activity_clicked); return false; });
    $(document).bind(EVENTS.add_activity_clicked, function(e, memory) {
        // don't hide form if memory.date which means click on calendar form
        if ($("#add_activity_form").length > 0 && !memory) {
          hideActivityPopup();
        } else {
          var user_id = memory && memory.user_id; 
          // TODO should be done via GET
          $("#add_activity").load("/activities/new", { user_id: user_id }, function() {
            $("#add_activity").fadeIn("normal", addOnSubmitForActivityPopup);
            if (memory && memory.date)
              $('#activity_date').attr('value', memory.date);
            $("#cancel_add_activity").click(hideActivityPopup);
          });
        }
        return false;
    });
});

$(function() {
  $(".delete_row").click(function (e) {
    if (confirm('Are you sure?')) {
      var target = $(this);
      var row = target.parents('tr');
      var handler = arguments.callee;
      
      $.ajax({
        type: "DELETE",
        url: $(this).url(),
        beforeSend: function() { 
          target.unbind('click', handler); row.disableLinks(); 
        },
        success: function() { 
          row.remove(); 
        },
        error: function(xhr) { 
          target.click(handler); 
          row.enableLinks(); 
          Rubytime.errorFromXhr(xhr);
        }
      });
    };
    return false;
  });
});

$(function() {
  $("table").zebra();
});