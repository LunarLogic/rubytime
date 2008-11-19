var Invoices = {
  init: function() {
    // table listing
    Invoices._initActivitiesList();
  },
  
  _initActivitiesList: function() {
    // style the table
    $(".activities").zebra();
    
    // init details icon/link
    Application.initCommentsIcons();
    
    // init remove from invoice icon/link
    $(".activities .remove_from_invoice_link").click(function() {
        Application.notice("Not implemented yet, sorry.");
        return false;
    });
  }
}

$(Invoices.init);
