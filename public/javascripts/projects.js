$(function() {
  $("#projects a.delete").click(function (e) {
    if (confirm('Are you sure to remove this project?'))
      $.delete_($(this).attr('href'), {}, function() { $(e.target).parents('tr').remove(); });
    return false;
  });
});