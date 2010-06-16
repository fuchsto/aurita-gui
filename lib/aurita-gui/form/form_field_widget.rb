
require('aurita-gui/widget')

module Aurita
module GUI

  # A regular Widget class, specialized as a 
  # Form_Field factory for a certain type. 
  #
  # Instead of overloading method #element(), 
  # build your Form_Field instance in method 
  # #form_field(). 
  # Example: 
  #   
  #   def form_field
  #     Textarea.new(@attrib) { @value } 
  #   end
  #
  class Form_Field_Widget < Widget

    attr_reader :value

    def initialize(params={}, &block)
      @attrib   = params
      @value    = yield if block_given?
      @value  ||= params[:value]
      super()
    end
    
    def dom_id
      @attrib[:id]
    end

    def form_field
      return @form_field if @form_field
      raise ::Exception.new("#{self.class}#form_field() is not defined")
    end
    
    # Delegates setting value to actual form field 
    # instance. 
    def value=(v)
      form_field().value = v
    end

    def element
      @field ||= form_field()
      @field
    end

  end

end
end
