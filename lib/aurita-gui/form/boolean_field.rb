
require('aurita-gui/form/options_field')

module Aurita
module GUI

  # Convenience configuration of Checkbox_Field. 
  # Renders one checkbox with :options => [1]
  class Boolean_Field < Checkbox_Field
    def initialize(params, &block)
      params[:options] = [ 1 ]
      super(params, &block)
    end
    def option_elements
      elements = []
      options().each_pair { |k,v|
        box_attribs = { :type => :checkbox, 
                        :value => k, 
                        :name => @attrib[:name] }
        checked = (@value && k.to_s == @value.to_s)? true : nil
        box_attribs[:checked] = checked
        element = []
        element << HTML.input(box_attribs) 
        elements << element
      }
      elements
    end
  end
  
end
end

