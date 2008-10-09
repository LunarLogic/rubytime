
var Projects = {
  init: function() {
    $("#projects a.delete").click(function () {
      Projects.removeProject();
    });
  },
  
  removeProject: function() {
    $.delete_($(this).attr('href'), {}, Projects._onProjectRemoved);
    return false;
  }, 
  
  _onProjectRemoved: function(data, textStatus) {
    alert('removed');
  }
}


$(function() {
  Projects.init();
});