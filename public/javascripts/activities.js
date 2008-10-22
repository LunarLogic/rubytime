var Activities = {
  init: function() {
    Activities._addOnFilterSubmit();
    $(".client_combo, .user_combo, .role_combo, .project_combo").change(function() { Activities.onSelectChanged($(this)) });
    $(".add_criterium").click(Activities.addCriterium);
    $(".remove_criterium").click(Activities.removeCriterium);
  },
  
  _addOnFilterSubmit: function() {
    var form = $("#activities_filter form:first");
    form.submit(function() {
      //form.find("input[type=submit]").attr("disabled", "true");
      var params = form.serializeArray();
      $("#primary").load(form.url(), params, function() {
        //form.find("input[type=submit]").attr("disabled", "false");
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

  _updateIcons: function(group, select) {
    var criteria = $("p." + group);
    if (criteria.length == 1) { 
      // single criteria of this kind
      
      var first_select = $("p." + group + " select:first");
      if (first_select.val() == '') { 
        // 'All' selected - hiding '+' button
        first_select.siblings('a.add_criterium').hide()
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
      if (select && (Activities._getUnselectedOptions(group, select).length == 0)) {
        $("p." + group + " a.add_criterium:last").hide();
      } else {
        $("p." + group + " a.add_criterium:last").show();
      }
    }
  },
  
  _getUnselectedOptions: function(group, select) {
    var siblingSelects = select.parent().parent().find("p." + group + " select");
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
    Activities._updateIcons(currentParagraph.attr("class"));
    Activities._reloadOtherCriteria(group);
  },
  
  addCriterium: function() {
    var currentParagraph = $(this).parents("p");
    var group = currentParagraph.attr("class");
    var currentCriteriumNumber = $(this).prevAll("select").attr("id").match("\\d+")[0];
    var newCriteriumNumber = currentCriteriumNumber * 1 + 1;
    
    // clone current paragraph to new (with events)
    var newParagraph = currentParagraph.clone(true);
    
    // remove blank 'All' option
    newParagraph.find("option[value='']").remove();
    
    var select = newParagraph.find("select")
    var label = newParagraph.find("label")
    
    // increment id of new paragraph
    select.attr("id", select.attr("id").replace(currentCriteriumNumber, newCriteriumNumber ));
    select.attr("name", select.attr("name").replace(currentCriteriumNumber, newCriteriumNumber));
    label.attr("for", label.attr("for").replace(currentCriteriumNumber, newCriteriumNumber));

    // hide, insert into dom, select first unselected item and finally show
    newParagraph.hide().insertAfter(currentParagraph);
    Activities._getUnselectedOptions(group, select).filter(":first").attr("selected", "selected"); // TODO: remove option from option:first
    newParagraph.show();
    
    Activities._reloadOtherCriteria(group);
    Activities._updateIcons(group, select);

    return false;
  },
  
  removeCriterium: function() {
    var currentParagraph = $(this).parents("p");
    var group = currentParagraph.attr("class");
    currentParagraph.remove();
    Activities._updateIcons(group);
    Activities._reloadOtherCriteria(group);

    return false;
  }
}  

$(Activities.init);