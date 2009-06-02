jQuery.fn.extend((function() {
  function _ajax_request(url, data, callback, type, method) {
    if (jQuery.isFunction(data)) {
      callback = data;
      data = {};
    }
    return jQuery.ajax({
      type: method,
      url: url,
      data: data,
      success: callback,
      dataType: type
      });
  };
  
  function stopLinkClick(e) {
  return false;
  };
  
  return {
  disableLinks: function() {
    this.find('a').click(stopLinkClick);
  },
  
  enableLinks: function() {
    this.find('a').unbind('click', stopLinkClick);
  },
  
  put: function(url, data, callback, type) {
    return _ajax_request(url, data, callback, type, 'PUT');
  },
  delete_: function(url, data, callback, type) {
    return _ajax_request(url, data, callback, type, 'DELETE');
  },
  
  blank: function() {
    return this.size() == 0;
  },

  url: function() {
    return this.attr('href') || this.attr('action');
  },
  
  focusFirstBlank: function() {
    this.find(":text:blank:eq(0)").focus();
  },
  
  zebra: function() {
    this.find("tr:not(.no_zebra):odd").addClass('odd').removeClass("even");
    this.find("tr:not(.no_zebra):even").addClass('even').removeClass("odd");
    return this;
  }
  };
})());

jQuery.extend({
  getDbId: function(s) {
  return s.match(/\d+/)[0];
  },
  
  once: (function() {
  var functions = {};
  return function(f) {
    if (!functions[f]) {
    var called = false;
    var self = this;
    functions[f] = function() {
      if (!called) {
      called = true;
      f.apply(self, arguments);
      }
    };
    }
    return functions[f];
  };
  })()
});