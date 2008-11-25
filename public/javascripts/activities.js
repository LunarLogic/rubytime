var Activities = {
  init: function() {
    // table listing
    if (!$("#activities_filter").blank()) {
      Activities._addOnFilterSubmit();
      $(".client_combo, .user_combo, .role_combo, .project_combo").change(function() { Activities.onSelectChanged($(this)); });
      $(".add_criterium").click(Activities.addCriterium);
      $(".remove_criterium").click(Activities.removeCriterium);
      Activities._updateIcons('client');
      Activities._updateIcons('project');
      Activities._updateIcons('role');
      Activities._updateIcons('user');
      Activities._initActivitiesList();
      $(document).bind(EVENTS.activity_added, Activities._reloadList);
      $(document).bind(EVENTS.activity_updated, Activities._reloadList);
      $(document).bind(EVENTS.activity_deleted, Activities._reloadList);
    }
    
    // calendar
    if (!Activities._calendarContainer().blank()) {
      Activities._calendarContainer().click(Activities._dispatchClick);
      $(document).bind(EVENTS.activity_added, Activities._reloadCalendar);
      $(document).bind(EVENTS.activity_updated, Activities._reloadCalendar);
      $(document).bind(EVENTS.activity_updated, function() { $("#activitites_for_day").html("") });
      $('#activitites_for_day').click(Activities._dispatchClick);
      $(document).bind(EVENTS.activity_added, function(e, memo){
        var date = memo.date; 
        if (!$('#activitites_for_day h3:contains(' + date + ')').blank())
          Activities.showDay($('#' + date).parents('td').find('a.show_day'));
      });
      $(document).bind(EVENTS.activity_deleted, Activities._removeActivityFromCalendar);
      Activities._initUserAndProjectCombo();
      Activities._initCalendarCells();
      tb_init($(".show_day"));
      $(document).bind('tb:ajax_loaded', Activities._initActivitiesList);
    }
  },
  
  _dispatchClick: function(e) {
    var target = $(e.target).is('a') ? $(e.target) : $(e.target).parents('a');
    if (target.hasClass('add_activity')) {
      var memo = { date: target.attr('id'), user_id: $.getDbId(Activities._calendarContainer().attr('id')) };
      $(document).trigger(EVENTS.add_activity_clicked, memo);
    } else if ((/previous_month|next_month/).test(target.attr('id'))) {
      $("div[id$=calendar][id^=users]").load(target.url());
//    } else if (target.hasClass("delete_activity")) {
//      Activities._deleteActivity(target);
//    } else if (target.hasClass("show_day")) {
//      Activities.showDay(target);
    }// else if (target.hasClass('edit_activity'))
      //Application.notice("No editing yet, sorry.");
    return false;
  },
  
  showDay: function(link) {
    $("#activitites_for_day").load(link.url(), function(responseText) {
      tb_init($("#activitites_for_day .edit_activity_link"));
    });
    $.scrollTo('div#activitites_for_day');
  },
  
  _deleteActivity: function(link) {
    var id = link.url().match(/\d+$/g)[0];
    var activities = $('#list_activity_' + id + ",#calendar_activity_" + id);
    if (confirm("Are you sure?"))
      $.ajax({
        url: link.url(), 
        type: "DELETE",
        beforeSend: function() { activities.disableLinks(); },
        success: function() { 
          $(document).trigger(EVENTS.activity_deleted, {id: id});
        },
        error: function(xhr) {
          activities.enableLinks();
          Application.errorFromXhr(xhr);
        }
      });
      
    return false;
  },
  
  _removeActivityFromCalendar: function(e, memory) {
    var id = memory.id;
    var activities = $('#list_activity_' + id + ",#calendar_activity_" + id);
    Activities._adjustDetailsCounter();
    activities.fadeOut(800, function() { 
      var activitiesContainer = $(this).parents('ul.activities');
      $(this).remove(); 
      if (!activitiesContainer.blank() && activitiesContainer.find('li.activity').blank())
        activitiesContainer.prev('.day_of_the_month').find('a.show_day').hide();
    });
  },
  
  _adjustDetailsCounter: function() {
    // TODO change regexp to not match digits in date and call it for each activity element
    $('#activitites_for_day h3').text($('#activitites_for_day h3').text().replace(/\d+/, 
      $('#activitites_for_day .activity_details').size()-1 || 'no'));
  },
  
  _reloadCalendar: function(e, memory) {
    var container = Activities._calendarContainer();
    container.load('/' + container.attr('id').replace(/_/g, '/'), memory ? memory : {});
  },
  
  _reloadList: function(e) {
    $('#activities_filter form:first').submit();
  },
  
  _calendarContainer: function() {
    return $("div[id$=calendar][id^=users], div[id$=calendar][id^=projects]");
  },
  
  _addOnFilterSubmit: function() {
    var form = $("#activities_filter form:first");
    form.submit(function() {
      $("#primary").load(form.url()+'?' + form.serialize(), null, function() {
        Activities._initActivitiesList();
      });
      return false;
    });
  },
  
  _initActivitiesList: function() {
    // style the table
    $(".activities").zebra();
    
    // init details icon/link
    Application.initCommentsIcons();
    
    // init edit icon/link
    tb_init(".edit_activity_link");

    // init delete icon/link
    $(".activities .remove_activity_link").click(function() {
        var t = $(this);
        Activities._deleteActivity(t);
        return false;
    });
    
    // handle selection of all activities
    $(".activity_select_all").click(function() {
        var checked = this.checked;
        $(this).parents("table").find("td input.checkbox").each(function() {
            this.checked = checked;
        });
    });
    
    // handle unselection of all_activities when one of activities has been unselected
    $(".activities td input.checkbox").click(function() {
        if (!this.checked) {
          $(this).parents("table").find(".activity_select_all")[0].checked = false;
        }
    });

    // handle new invoice form submission
    $("#create_invoice_form").submit(function() {
      if ($(".activities td input.checkbox:checked").length == 0) {
        Application.error('You need to select activities for this invoice.');
        return false;
      }
        
      $.post($(this).url(), $("#create_invoice_form, .activities td input.checkbox:checked").serialize(), function () {
        $("#activities_filter form:first").submit();
        Application.notice('Invoice has been created successfully');
      });
      return false;
    });

    // handle "add activities to existing invoice" form submission 
    $("#update_invoice_button").click(function() {
      if ($(".activities td input.checkbox:checked").length == 0) {
        Application.error('You need to select activities for this invoice.');
        return false;
      }
        
      var invoiceId = $("#invoice_id").val();
      if (invoiceId == "") {
        Application.error('You need to select an invoice.');
        return false;
      }
      
      $.ajax({
          type: "PUT",
          url: "/invoices/" + invoiceId,
          data: $(".activities td input.checkbox:checked").serialize(), 
          success: function () {
            $("#activities_filter form:first").submit();
            Application.notice('Activities have been added to invoice successfully');
          }
      });
      return false;
    });
  },
  
  _reloadSelects: function(url, group) {
    var url = url + "?"+$("#activities_filter form").serialize();
    $.getJSON(url, function(json) {
      var options = '<option value="">All</option>';
      for (var i = 0; i < json.length; i++) {
        options += '<option value="' + json[i].id + '">' + json[i].name + '</option>';
      }
      $("p." + group + ":not(:first)").remove();
      $("p." + group + " select").html(options);
      Activities._updateIcons(group);
    });
  },

  _reloadProjects: function() {
    Activities._reloadSelects('/projects/for_clients', 'project');
  },
  
  _reloadUsers: function() {
    Activities._reloadSelects('/users/with_roles', 'user');
  },
  
  _reloadOtherCriteria: function(group) {
    if (group == "client") {
      Activities._reloadProjects();
    } else if (group == "role") {
      Activities._reloadUsers();
    }
  },

  _updateIcons: function(group) {
    var criteria = $("p." + group);
    if (criteria.length == 1) { 
      // single criteria of this kind
      
      var first_select = $("p." + group + " select:first");
      if (first_select.val() == '') { 
        // 'All' selected - hiding '+' button
        first_select.siblings('a.add_criterium').hide();
      } else { 
        // particular item selected - showing '+' button
        first_select.siblings('a.add_criterium').show();
      }
    } else { 
      // multiple criterias of this kind
      
      // hide '+' button at all selects except last
      $("p." + group + " a.add_criterium:not(:last)").hide();
      // show '-' button at all selects except first
      $("p." + group + " a.remove_criterium:not(:first)").show();

      // show '+' button
      $("p." + group + " a.add_criterium:last").show();
    }
  },

  _getUnselectedOptions: function(group, select) {
    var siblingSelects = select.parent().siblings("p." + group).find("select");
    var unselected = select.find("option").filter(function() {
      return siblingSelects.find("option:selected[value="+$(this).val()+"]").length == 0;
    });
    return unselected;
  },
  
  onSelectChanged: function(select) {
    var currentParagraph = select.parents("p");
    var group = currentParagraph.attr("class");
    if (select.val() == '') { // "All" selected
      // remove additional criteria of the same kind
      currentParagraph.siblings("p." + group).remove();
    }
    Activities._reloadOtherCriteria(group);
    Activities._updateIcons(currentParagraph.attr("class"));
  },
  
  addCriterium: function() {
    var currentParagraph = $(this).parents("p");
    var group = currentParagraph.attr("class");
    
    // clone current paragraph to new (with events)
    var newParagraph = currentParagraph.clone(true);
    
    // remove blank 'All' option
    newParagraph.find("option[value='']").remove();
    
    var select = newParagraph.find("select");
    var label = newParagraph.find("label");
    
    // hide, insert into dom, select first unselected item and finally show
    newParagraph.hide().insertAfter(currentParagraph);
    var unselected = Activities._getUnselectedOptions(group, select);
    unselected.filter(":first").attr("selected", "selected");
    newParagraph.show();
    
    Activities._reloadOtherCriteria(group);
    Activities._updateIcons(group);

    return false;
  },
  
  removeCriterium: function() {
    var currentParagraph = $(this).parents("p");
    var group = currentParagraph.attr("class");
    currentParagraph.remove();
    Activities._reloadOtherCriteria(group);
    Activities._updateIcons(group);
    
    return false;
  },

  _initCalendarCells: function() {
    $("td.day").mouseover(function() { $(this).find(".activity_icons").show() }).mouseout(function() { $(this).find(".activity_icons").hide() })
  },
  
  _initUserAndProjectCombo: function() {
    $("select#user_id, select#project_id").change(function() {
      var location = ('' + window.location);
      var currentId = location.match(/(\d+)\/calendar/)[1];
      window.location = location.replace("/" + currentId + "/", "/" + $(this).val() + "/");
    });
  }
};

$(Activities.init);