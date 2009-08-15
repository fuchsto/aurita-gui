
require('aurita-gui/form/options_field')

module Aurita
module GUI

  class Select_Field < Options_Field

    # Returns array of option elements for this 
    # select field. 
    def option_elements
      elements = []
      options().each_pair { |k,v|
        selected = (@value && k.to_s == @value.to_s)? true : nil
        elements << HTML.option(:value => k, :selected => selected) { v }
      }
      elements
    end

    def element
      HTML.select(@attrib) { 
        option_elements()
      } 
    end
    def readonly_element
      HTML.div(@attrib) { 
        options()[@value]
      }
    end
  end
  
end
end
