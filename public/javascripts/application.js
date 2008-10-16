function _ajax_request(url, data, callback, type, method) {
    if (jQuery.isFunction(data)) {
        callback = data;
        data = {};
    }
    return jQuery.ajax({
        type: method,
        url: url,
        data: data,
        success: callback,
        dataType: type
        });
}

jQuery.extend({
    put: function(url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'PUT');
    },
    delete_: function(url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'DELETE');
    }
});

$.ajaxSetup({
    error: function(responseText, textStatus) {
      //alert('kurde blade');
    }
});


function addOnSubmit() {
  $("#add_activity_form").submit(function() {
      $("#add_activity_form input[type=submit]").attr("disabled", "false");
      var params = $("#add_activity_form").serializeArray();
      $("#add_activity").load($("#add_activity_form").url(), params, function(responseText, textStatus) {
          if (responseText == '') {
            $("#add_activity").hide();
            alert('Activity added successfully!');
          } else {
            addOnSubmit();
          }
      });
      return false;
  });
}

$(function() {
    /*$(".datepicker").datepicker({
      dateFormat: "yy-mm-dd", showOn: "both", buttonImage: "/images/calendar.gif", buttonImageOnly: true });
    */
    
    $(".add-activity a").click(function() {
        $("#add_activity").load("/activities/new", {}, function() {
          addOnSubmit();
          $("#add_activity").fadeIn();
        });
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
        error: function() { 
          target.click(handler); row.enableLinks(); 
        }
      });
    };
    return false;
  });
});
