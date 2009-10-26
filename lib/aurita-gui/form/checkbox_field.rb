
require('aurita-gui/form/options_field')

module Aurita
module GUI

  # Factory for checkbox input fields, specialization 
  # of Options_Field. 
  # For usage see documentation of Options_Fiels. 
  #
  class Checkbox_Field < Options_Field
    def option_elements
      elements = []
      options().each_pair { |k,v|
        element = []
        box_attribs = { :type  => :checkbox, 
                        :value => k, 
                        :name  => @attrib[:name] }
        if @value.is_a?(Array) then
          checked = (@value.map { |x| x.to_s }.include?(k.to_s))? true : nil
        else
          checked = (@value && k.to_s == @value.to_s)? true : nil
        end
        box_attribs[:checked] = checked
        element << HTML.input(box_attribs) 
        element << HTML.label(:for => option_id) { v } if v
        elements << element
      }
      elements
    end

    def element
      element_attrib = @attrib.dup.update({ :class => :checkbox_options })
      element_attrib.delete(:name)
      element_attrib.delete(:value)
      HTML.ul(element_attrib) { 
        option_elements().map { |o| HTML.li() { o } } 
      }
    end

  end
  
end
end
