// TODO clean up application.js
var EVENTS = {
  activities_changed: 'activitites:changed',
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
      var params = $("#add_activity_form").serializeArray();
      var date = $('#activity_date').attr('value').split(/\D/g);
      $("#add_activity").load($("#add_activity_form").url(), params, function(responseText, textStatus) {
          if (responseText == '') {
            // TODO: parse date rather than split - user ui.datapicker method for parsing?
            $("#add_activity").hide();
            $(document).trigger(EVENTS.activities_changed, { month: date[1], year: date[2]});
          } else {
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