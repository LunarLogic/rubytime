$.fn.extend({
  fill: function(source) {
    var source = $(source);
    if (source.blank())
      throw "@source doesn't match any element";
    else {
      var target = this;
      function sourceChanged(e) {
        target.attr('value', source.attr('value'));
      };
      source.keyup(sourceChanged);
      target.change(function() {
        source.unbind('keyup', sourceChanged);
      });
    }
  }
});