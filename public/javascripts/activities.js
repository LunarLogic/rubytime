var Activities = {
  init: function() {
    $("#search_criteria_role_id, #search_criteria_client_id").change(Activities.reloadForm);
  },
  
  reloadForm: function() {
    var url = "/activities?"+$("#activities_filter form").serialize();
    $("#activities_filter").load(url, Activities.init);
  }
}

$(Activities.init);