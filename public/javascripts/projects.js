$(function() {
  $('#project_form').validate({
    rules: {
      "project[name]": {
        required: true
      },
      "project[client_id]": {
        required: true
      }
    }
  });

  $('#project_form .activity_types a.toggler').click(function() { 
    $(this).parents('.activity_types').children('ul').toggle('fast');
  });
  
  $('#project_form .activity_types input[type=checkbox]').click(function() { 
    $(this).filter(':checked').siblings('ul').show().find('li input[type=checkbox]').attr("checked", "checked");
    $(this).filter(':not(:checked)').siblings('ul').hide().find('li input[type=checkbox]').removeAttr("checked");
  });
});

HourlyRates = function(node_or_selector, data_url, show_forms_for_empty_lists) {
  if (!HourlyRates.initialized) {
    HourlyRates.init();
  }
  
  this.node = $(node_or_selector);
  this.show_forms_for_empty_lists = show_forms_for_empty_lists;
  $.getJSON(data_url, this.onGetResponse.bind(this));
};

HourlyRates.init = function() {
  if (HourlyRates.initialized) {
    return;
  }
  
  HourlyRateView.initTemplate();
  HourlyRateForm.initTemplate();
  RoleHourlyRateList.initTemplate();
  
  HourlyRates.initialized = true;
};

$.extend(HourlyRates.prototype, {
  onGetResponse: function(data) {
    for (var roleCounter = 0; roleCounter < data.length; roleCounter++) {
      var list = new RoleHourlyRateList({
        project_id: data[roleCounter].project_id,
        role_id: data[roleCounter].role_id
      }, data[roleCounter].role_name);

      for (var rateCounter = 0; rateCounter < data[roleCounter].hourly_rates.length; rateCounter++) {
        list.add( data[roleCounter].hourly_rates[rateCounter] );
      }

      if (this.show_forms_for_empty_lists && list.isEmpty()) {
        list.add({});
      }

      this.node.append(list.node);
    }
  }
});

RoleHourlyRateList = function(common_hourly_rate_attrs, role_name) {
  this.common_hourly_rate_attrs = common_hourly_rate_attrs;
  this.node = RoleHourlyRateList.template.clone(true);
  this.node.find('.role_name').text(role_name);
  this.controllers = [];
  
  this.node.find('a.new_hourly_rate').click(function() { this.add({}); return false; }.bind(this));
};

RoleHourlyRateList.initTemplate = function() {
  RoleHourlyRateList.template = $('#role_hourly_rate_list_template').remove().show().removeAttr('id');
};

$.extend( RoleHourlyRateList.prototype, {
  add: function(hourly_rate_attrs) {
    var rate = new HourlyRate($.extend(Object.shallowCopy(this.common_hourly_rate_attrs), hourly_rate_attrs));
    var controller = new HourlyRateController(rate, this);
    
    this.controllers.push(controller);
    this.sort();
    controller.node.hide();
    controller.node.fadeIn("fast");
  },
  
  sort: function() {
    this.controllers.sort(function(c1, c2) {
      var v1 = c1.hourly_rate.takes_effect_at_unformatted;
      var v2 = c2.hourly_rate.takes_effect_at_unformatted;

      if (v1 < v2) {
        return -1;
      } else if (v1 > v2) {
        return 1;
      } else {
        return 0;
      }
    });
    
    for (var i = 0; i < this.controllers.length; i++) {
      if (i === 0) {
        this.node.find('table tr:first').after(this.controllers[i].node);
      } else {
        this.controllers[i - 1].node.after(this.controllers[i].node);
      }
    }
  },
  
  isEmpty: function() {
    return this.controllers.length === 0;
  }
});

HourlyRate = function(attrs) {
  this.updateAttributes(attrs);
};

$.extend( HourlyRate.prototype, {
  updateAttributes: function(attrs) {
    $.extend(this, attrs);
    this.resource_url = (this.isNewRecord() ? '/hourly_rates' : '/hourly_rates/' + this.id);
  },
  
  isNewRecord: function() {
    return !this.id;
  }
});

HourlyRateController = function(hourly_rate, list) {
  this.hourly_rate = hourly_rate;
  this.list = list;
  this.hourly_rate.isNewRecord() ? this.edit() : this.show();
};
  
$.extend( HourlyRateController.prototype, {
  _new_node: function(new_node) {
    if (this.node) {
      this.node.after(new_node).remove();
    }
    this.node = new_node;
  },
  
  show: function() {
    this.view = new HourlyRateView(this);
    this.form = null;
    this._new_node(this.view.node);
  },
  
  edit: function() {
    this.view = null;
    this.form = new HourlyRateForm(this);
    this._new_node(this.form.node);
  },
  
  cancelEdit: function() {
    this.hourly_rate.isNewRecord() ? this.quit() : this.show();
  },
  
  update: function(data) {
    $.post(this.hourly_rate.resource_url, data, this.onUpdateResponse.bind(this), "json");
  },
  
  onUpdateResponse: function(response) {
    if (response.status == 'ok') {
      this.hourly_rate.updateAttributes(response.hourly_rate);
      this.list.sort();
      this.show();
      this.animateJustUpdated();
    } else {
      this.form.populateErrorMessages(response.hourly_rate.error_messages);
    }
  },
  
  destroy: function() {
    $.ajax({
      type: "DELETE",
      url: this.hourly_rate.resource_url,
      dataType: "json",
      success: this.onDestroyResponse.bind(this)
    });
  },
  
  onDestroyResponse: function(response) {
    if (response.status == 'ok') {
      this.quit();
    } else if (response.status == 'error') {
      alert(response.hourly_rate.error_messages);
    }
  },
  
  animateJustUpdated: function() {
    this.node.addClass('justUpdated');
    window.setTimeout(function() { this.node.removeClass('justUpdated') }.bind(this), 700);
  },
  
  quit: function() {
    this.node.fadeOut("fast", function() { this.node.remove(); }.bind(this));
  }
});

HourlyRateView = function(hourly_rate_controller) {
  this.hourly_rate_controller = hourly_rate_controller;
  this.node = HourlyRateView.template.clone(true);
  this.populate();
  this.bindEvents();
};

HourlyRateView.initTemplate = function() {
  HourlyRateView.template = $('#hourly_rate_view_template').remove().show().removeAttr('id');
};

$.extend(HourlyRateView.prototype, {
  bindEvents: function() {
    this.node.find('a.edit').click(function() { this.hourly_rate_controller.edit(); return false; }.bind(this));
    this.node.find('a.delete').click(function() {
      if (confirm('Are you sure you want to delete this rate?')) {
        this.hourly_rate_controller.destroy();
      }
      return false;
    }.bind(this));
  },
  populate: function() {
    this.node.find('.takes_effect_at').text(this.hourly_rate_controller.hourly_rate.takes_effect_at);
    this.node.find('.value          ').text(this.hourly_rate_controller.hourly_rate.value);
    this.node.find('.currency       ').text(this.hourly_rate_controller.hourly_rate.currency.plural_name);
  }
});

HourlyRateForm = function(hourly_rate_controller) {
  this.hourly_rate_controller = hourly_rate_controller;
  this.node = HourlyRateForm.template.clone(true);
  
  this.submit_button = this.node.find('.submit');
  this.cancel_button = this.node.find('.cancel');
  
  this.populate();
  this.bindEvents();
};

HourlyRateForm.initTemplate = function() {
  HourlyRateForm.template = $('#hourly_rate_form_template').remove().show().removeAttr('id');
  HourlyRateForm.template.find('input, select').removeAttr('id');
};
  
$.extend(HourlyRateForm.prototype, {
  bindEvents: function() {
    this.submit_button.click(function() { this.submit(); return false; }.bind(this));
    this.cancel_button.click(function() { this.cancel(); return false; }.bind(this));
    this.node.find('form').submit( function() { this.submit(); return false; }.bind(this));
    Application.initDatepickers(this.node.find('input[name="hourly_rate[takes_effect_at]"]'));
  },
  
  populate: function() {
    var rate = this.hourly_rate_controller.hourly_rate;
    this.node.find('input[name="hourly_rate[project_id]"]').val(rate.project_id);
    this.node.find('input[name="hourly_rate[role_id]"]').val(rate.role_id);
    this.node.find('input[name="hourly_rate[takes_effect_at]"]').val(rate.takes_effect_at);
    this.node.find('input[name="hourly_rate[value]"]').val(rate.value);

    if (rate.currency) {
      this.node.find('select[name="hourly_rate[currency_id]"]').val(rate.currency.id);
    }

    this.node.find('input[name="_method"]').val(rate.isNewRecord() ? 'post' : 'put');

    this.populateErrorMessages(rate.error_messages);
  },
  
  populateErrorMessages: function(error_messages) {
    var messagesDiv = this.node.find('.error_messages');
    
    if (error_messages) {
      messagesDiv.text(error_messages).show();
    } else {
      messagesDiv.text('').hide();
    }
  },
  
  cancel: function() {
    this.hourly_rate_controller.cancelEdit();
  },
  
  submit: function() {
    this.hourly_rate_controller.update(this.node.find('input, select').serialize());
  }
});

$(function() { $('.sections .head').expander(); });
