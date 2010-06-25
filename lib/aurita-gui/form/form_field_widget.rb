
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

    attr_accessor :value, :name

    def initialize(params={}, &block)
      @attrib ||= params
      @value  ||= yield if block_given?
      @value  ||= params[:value]
      @name   ||= params[:name]
      @attrib.delete(:value)
      super()
    end

    def rebuild()
      @form_field = false
      super()
    end

    def value=(v)
      @value = v
      rebuild()
    end

    # Useful for identifying instances of meta classes (e.g. Aurita::GUI::Widget) 
    # as form fields. 
    # Example: 
    #
    #    if obj.respond_to?(:is_form_field) then
    #      # obj is instance of Form_Field or at least implements 
    #      # its behaviour
    #    end
    #
    def is_form_field
      true
    end
    
    def dom_id
      @attrib[:id]
    end
    def id
      @attrib[:id]
    end

    def form_field
      return @form_field if @form_field
      raise ::Exception.new("#{self.class}#form_field() is not defined")
    end

    def label
      form_field.label
    end
    
    def element
      @field ||= form_field()
      @field
    end

    def decorated_element
      self
    end
    
  end

end
end
