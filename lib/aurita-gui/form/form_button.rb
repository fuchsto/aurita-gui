
require('aurita-gui/element')

module Aurita
module GUI

  # Wrapper for Input_Field, sets type to :text. 
  #
  # Usage: 
  #
  #   i = Submit_Button.new() { 'Submit this form' }
  #
  class Form_Button < Element
    def initialize(params={}, &block)
      params[:tag]  ||= :button
      super(params, &block)
    end

    def is_form_button
      true
    end
  end
  
end
end
