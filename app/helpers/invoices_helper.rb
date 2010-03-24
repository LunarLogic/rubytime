module Merb
  module InvoicesHelper
    def filter_hash
      {:filter => params[:filter]}
    end
  end
end # Merb
