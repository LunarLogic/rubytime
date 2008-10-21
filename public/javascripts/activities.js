var Activities = {
  init: function() {
    $(".role_combo, .client_combo").change(Activities.reloadForm);
    $(".add_criterium").click(Activities.addCriterium);
    $(".remove_criterium").click(Activities.removeCriterium);
  },
  
  reloadForm: function() {
    var url = "/activities?"+$("#activities_filter form").serialize();
    $("#activities_filter").load(url, Activities.init);
  },
  
  addCriterium: function() {
    var currentCriteriumNumber = $(this).prevAll("select").attr("id").match("\\d+")[0];
    var newCriteriumNumber = currentCriteriumNumber * 1 + 1;
    var currentParagraph = $(this).parents("p");
    var newParagraph = currentParagraph.clone(true);
    var select = newParagraph.find("select")
    var label = newParagraph.find("label")
    select.attr("id", select.attr("id").replace(currentCriteriumNumber, newCriteriumNumber ));
    select.attr("name", select.attr("name").replace(currentCriteriumNumber, newCriteriumNumber));
    label.attr("for", label.attr("for").replace(currentCriteriumNumber, newCriteriumNumber));
    newParagraph.insertAfter(currentParagraph);
    $(this).hide();
    newParagraph.find(".remove_criterium").show();
  },
  
  removeCriterium: function() {
    var currentParagraph = $(this).parents("p");
    var parent = currentParagraph.parent();
    currentParagraph.remove();
    parent.find("p a.add_criterium:last").show();
  }
}  

$(Activities.init);