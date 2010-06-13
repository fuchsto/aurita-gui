
require('aurita-gui/form/form_button')

module Aurita
module GUI

  # Wrapper for Input_Field, sets type to :text. 
  #
  # Usage: 
  #
  #   i = Submit_Button.new() { 'Submit this form' }
  #
  class Submit_Button < Form_Button
    def initialize(params={}, &block)
      params[:tag]    = :input
      params[:type] ||= :submit unless params[:type]
      super(params, &block)
    end
  end
  
end
end
