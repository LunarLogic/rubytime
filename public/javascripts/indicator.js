var Indicator = function(button) {
  this.button = button;
};

Indicator.IMAGE_SRC = '/images/ajax-loader.gif';
Indicator.TRANSPARENT_IMAGE_SRC = '/images/ajax-loader-transparent.gif';

Indicator.prototype = {
  start: function(imageSrc) {
    this.button.attr('disabled', true);
    this.button.after(this.imageTag(imageSrc));
    this.spinner = this.button.next();
  },

  stop: function() {
    this.button.attr('disabled', false);
    this.spinner.remove();
    this.spinner = null;
  },

  imageTag: function(imageSrc) {
    return '<img src="' + imageSrc + '" border="0" class="button-spinner" />';
  }
};
