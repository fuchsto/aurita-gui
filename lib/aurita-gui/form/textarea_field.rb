
require('aurita-gui/form/form_field')

module Aurita
module GUI

  class Textarea_Field < Form_Field
    def initialize(params, &block)
      params[:tag] = :textarea
      # Move value parameter to @content: 
      @value       = params[:value]
      super(params)
      params.delete(:value)
      @value       = yield.to_s if block_given?
    end
    def element
      # Always close <textarea> tags! 
      @attrib[:force_closing_tag] = true
      HTML.textarea(@attrib) { @value.to_s }
    end

  end
  
end
end
