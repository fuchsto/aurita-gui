
require('aurita-gui/form/options_field')

module Aurita
module GUI

  class Select_Field < Options_Field

    # Returns array of option elements for this 
    # select field. 
    #
    # Options may include option groups (HTML: optgroup) by 
    # using a Hash like
    # 
    #   { 
    #     'Cars' => { 
    #        0 => 'Convertible', 
    #        1 => 'Truck', 
    #        2 => 'SUV', 
    #        3 => 'Limo'
    #     }
    #     'Planes' => { 
    #        0 => 'Chesna', 
    #        1 => 'Boeing'
    #     }
    #   }
    #
    def option_elements
      elements = []
      options().each_pair { |k,v|
        if v.respond_to?(:each_pair) then
          optgroup_elements = []
          v.each_pair { |ok,ov|
            selected = (@value && ok.to_s == @value.to_s)? true : nil
            optgroup_elements << HTML.option(:value => ok, :selected => selected) { ov }
          }
          elements << HTML.optgroup(:label => k.to_s) { 
            optgroup_elements
          }
        else
          selected = (@value && k.to_s == @value.to_s)? true : nil
          elements << HTML.option(:value => k, :selected => selected) { v }
        end
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
        options()[@value] if @value
      }
    end
  end
  
end
end
