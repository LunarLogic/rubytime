var EVENTS = {
  //activities_changed: 'activitites:changed',
  activity_added: 'activitites:added',
  activity_deleted: 'activitites:deleted',
  add_activity_clicked: 'activitites:add_clicked'
};

function hoursFormat(value, element, params) {
  return this.optional(element) || (/^\d+([\.,]\d*|:([0-5]\d?)?)?$/).test(value);
};

var Application = {
  init: function() {
    Application.setupAjax();
    Application.setupValidator();
    Application.initDatepickers();
    Application.initAddActivityButton();
    Application.initTables();
    Application.initFlash();
    Application.initDeleteLinks();
  },
  
  setupAjax: function() {
    $.ajaxSetup({
        error: function(xhr) {
          Application.errorFromXhr(xhr);
        }
    });
  },
  
  setupValidator: function() {
    $.validator.addMethod('hours', hoursFormat, "Please enter hours in format like 3:45 or 2,5.");
  },

  initDatepickers: function() {
    $(".datepicker").datepicker({
      dateFormat: "yy-mm-dd", duration: "", showOn: "both", 
      buttonImage: "/images/icons/calendar_month.png", buttonImageOnly: true });
  },
  
  initAddActivityButton: function() {
    $(".add-activity a").click(function() { $(document).trigger(EVENTS.add_activity_clicked); return false; });
    $(document).bind(EVENTS.add_activity_clicked, function(e, memory) {
        // don't hide form if memory which means click on calendar form
        if ($("#add_activity_form").length > 0 && !memory) {
          Application._closeActivityPopup();
        } else {
          var user_id = memory && memory.user_id; 
          // TODO should be done via GET
          $("#add_activity").load("/activities/new?user_id=" + user_id, function() {
            $("#add_activity").slideDown("fast", Application._initActivityPopup);
            if (memory && memory.date)
              $('#activity_date').attr('value', memory.date);
            $.scrollTo('.header');
          });
        }
        return false;
    });
  },
  
  initTables: function() {
    $("table").zebra();
  },

  initFlash: function() {
    $("#flash").click(Application._closeFlash);
    setTimeout(Application._closeFlash, 5000);
  },
  
  initDeleteLinks: function() {
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
            Application.errorFromXhr(xhr);
          }
        });
      };
      return false;
    });
  },
  
  _closeActivityPopup: function() {
    // slide up and remove the form
    $("#add_activity").slideUp("fast", function() { $("#add_activity_form").remove(); });
    return false;
  },

  _initActivityPopup: function() {
    // hide popup on clicking Cancel link
    $("#cancel_add_activity").click(Application._closeActivityPopup);
    
    // set validation rules
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
    
    // focus first blan field (hours)
    $("#add_activity_form").focusFirstBlank();
    
    // handle form submission
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
            Application._closeActivityPopup();
            $(document).trigger(EVENTS.activity_added, {date: $('#activity_date').attr('value')});
          },
          error: function(xhr) {
            $('#add_activity').html(xhr.responseText);
            Application._initActivityPopup();
          }
        });
        $("#add_activity_form input[type=submit]").attr("disabled", "true");
        return false;
    });
  },
  
  _showFlash: function(klass, message) {
    $("#flash").removeClass("error").removeClass("notice").addClass(klass).text(message).slideDown();
    Application.initFlash();
  },
  
  _closeFlash: function() {
    $("#flash").slideUp(function() {
      $(this).removeClass("notice").removeClass("error").hide();
    });
  },

  notice: function(message) {
    Application._showFlash("notice", message);
  },
  
  error: function(message) {
    Application._showFlash("error", message);
  },
  
  errorFromXhr: function(xhr) {
    if (xhr.status >= 400 && xhr.status < 500)
      Application.error(xhr.responseText);
    if(xhr.status >= 500)
      Application.error("Ooops! Something went wrong.");
  }  
};
$(Application.init);
