
require('aurita-gui/form/options_field')

module Aurita
module GUI

  # Factory for radio input fields, specialization 
  # of Options_Field. 
  # Example: 
  #  
  #   r = Radio_Field.new(:name => :color, 
  #                       :value => :red, 
  #                       :label => 'Select a color', 
  #                       :options => { :red => 'red color', :blue => 'blue color' })
  #
  # Same as 
  #
  #   r = Radio_Field.new(:name => :color, :value => :red, :label => 'Select a color') { 
  #         :red => 'red color', :blue => 'blue_color
  #       }
  #
  # For usage details  see documentation of Options_Fiels. 
  #
  class Radio_Field < Options_Field

    # Returns array of option elements for this 
    # radio field, i.e. an array of <input type="checkbox" ... />. 
    # Each option is a radio input field with 
    # @name as common name attribute. 
    def option_elements
      elements = []
      options().each_pair { |k,v|
        element = []
        selected = (@value.to_s == k.to_s)? true : nil
        element << HTML.input(:type => :radio, :value => k, :name => @attrib[:name], :checked => selected ) 
        element << HTML.label(:for => option_id) { v } if v
        elements << element
      }
      elements
    end

    # Renders this radio field to a HTML.ul element, 
    # including options from #option_elements. 
    def element
      HTML.ul(:class => :radio_options) { 
        option_elements().map { |o| HTML.li() { o } } 
      }
    end

  end
  
end
end
