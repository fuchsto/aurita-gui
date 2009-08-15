
require('aurita-gui/form/form_field')

module Aurita
module GUI

  # Usage: 
  #
  #   i = Hidden_Field.new(:name => :description, 
  #                        :label => 'Description', 
  #                        :value => 'Lorem ipsum dolor')
  #
  # Tag attributes like onclick, onchange, class etc. 
  # can be set, but will either be ignored or have 
  # no effect. 
  #
  class Hidden_Field < Form_Field
    def initialize(params, &block)
      params[:tag]  = :input
      params[:type] = :hidden
      if block_given? then
        params[:value] = yield
      end
      super(params)
    end
    def element
      HTML.input(@attrib)
    end
    def readonly_element
      element()
    end
  end

  class Form < Element

    def add_hidden(params)
      params.each_pair { |k,v| 
        add(Hidden_Field.new(:name => k, :value => v))
      }
    end
    alias add_hidden_fields add_hidden

  end
  
end
end
