var Activities = {
  init: function() {
    Activities._addOnFilterSubmit();
    $(".client_combo, .user_combo, .role_combo, .project_combo").change(function() { Activities.onSelectChanged($(this)); });
    $(".add_criterium").click(Activities.addCriterium);
    $(".remove_criterium").click(Activities.removeCriterium);
    Activities._updateIcons('client');
    Activities._updateIcons('project');
    Activities._updateIcons('role');
    Activities._updateIcons('user');
    if (!Activities._calendarContainer().blank()) {
      Activities._calendarContainer().click(Activities._dispatchClick);
      $(document).bind(EVENTS.activities_changed, Activities._reloadCalendar);
    }
    $(document).bind(EVENTS.activities_changed, Activities._reloadList);
    $(document).bind(EVENTS.activities_changed, function() { Rubytime.notice('Activity added successfully!'); });
  },
  
  _dispatchClick: function(e) {
    var target = $(e.target);
    if (target.hasClass('add_activity')) {
      var memo = { date: target.attr('id'), user_id: $.getDbId(Activities._calendarContainer().attr('id')) };
      $(document).trigger(EVENTS.add_activity_clicked, memo);
    } else if ((/previous_month|next_month/).test(target.attr('id'))) {
      $("div[id$=calendar][id^=users]").load(target.url());
    } else if (target.hasClass("delete_activity")) {
      Activities._deleteActivity(target);
    }
    return false;
  },
  
  _deleteActivity: function(link) {
    var activity = link.parent();
    if (confirm("Are you sure?"))
      $.ajax({
        url: link.url(), 
        type: "DELETE",
        beforeSend: function() { activity.disableLinks(); },
        success: function() { activity.remove(); },
        error: function(xhr) {
          activity.enableLinks();
          Rubytime.errorFromXhr(xhr);
        }
      });
      
    return false;
  },
  
  _reloadCalendar: function(e, memory) {
    var container = Activities._calendarContainer();
    container.load('/' + container.attr('id').replace(/_/g, '/'), memory ? memory : {});
  },
  
  _reloadList: function(e) {
    $('#activities_filter form:first').submit();
  },
  
  _calendarContainer: function() {
    return $("div[id$=calendar][id^=users]");
  },
  
  _addOnFilterSubmit: function() {
    var form = $("#activities_filter form:first");
    form.submit(function() {
      //form.find("input[type=submit]").attr("disabled", "true"); // it would prevent form to submit in IE probably
      // load with GET request
      $("#primary").load(form.url()+'?' + form.serialize(), null, function() {
        //form.find("input[type=submit]").removeAttr("disabled");
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
  }
};

$(Activities.init);