
var Projects = {
  init: function() {
    Projects.initRemoveProject();
  },
  
  initRemoveProject: function() {
    $("#projects a.delete").click(function () {
      if (confirm('Are you sure to remove this project?')) {
        $(this).parent().parent().addClass('to_delete');
        $.delete_($(this).attr('href'), {}, Projects._onRemoved);
      }
      return false;
    });
  },

  _onRemoved: function() {
    $("tr.to_delete").fadeOut();
  }
}

$(function() {
  Projects.init();
});
