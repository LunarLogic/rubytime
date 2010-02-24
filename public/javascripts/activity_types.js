$(function() { 
  
  $('table#activity_types').sortable({ 
    items: 'tr.activity-type',
    axis: 'y',
    cursor: 'move',
    change: function(event, ui) { $('table#activity_types').zebra() },
    stop: function(event, ui) { $('table#activity_types').zebra() },
    update: function(event, ui) {
      $.ajax({
        url: '/activity_types/' + $(ui.item).recordId(),
        type: "PUT",
        data: { 'activity_type[position]': ui.item.positionInParent('.activity-type') }
      });
    }
  });

  
});
