$.fn.extend({
  fill: function(source, slugify) {
  var source = $(source);
  if (source.blank())
    throw "@source doesn't match any element";
  else {
    var target = this;
    function sourceChanged(e) {
    target.attr('value', slugify ? source.attr('value').replace(/\W+/g, "-") : source.attr('value'));
    };
    source.keyup(sourceChanged);
    target.change(function() {
    source.unbind('keyup', sourceChanged);
    });
  }
  }
});