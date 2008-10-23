// TODO clean up application.js
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
      $("#add_activity").load($("#add_activity_form").url(), params, function(responseText, textStatus) {
          if (responseText == '') {
            $("#add_activity").hide();
            alert('Activity added successfully!');
          } else {
            addOnSubmitForActivityPopup();
          }
      });
      $("#add_activity_form input[type=submit]").attr("disabled", "true");
      return false;
  });
}

$(function() {
    $(".datepicker").datepicker({
      dateFormat: "yy-mm-dd", duration: "", showOn: "both", 
      buttonImage: "/images/icons/calendar_month.png", buttonImageOnly: true });
    
    $(".add-activity a").click(function() {
        var form = $("#add_activity_form");
        if (form.length > 0) {
          // hide the form
          $("#add_activity").fadeOut(function() { form.remove() });
        } else {
          // show the form
          $("#add_activity").load("/activities/new", {}, function() {
            $("#add_activity").fadeIn("normal", addOnSubmitForActivityPopup);
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
