
require('aurita-gui/element')

module Aurita
module GUI

  class Fieldset < Element
    attr_accessor :legend, :label, :name

    def initialize(params, &block)
      params[:tag] = :fieldset
      @name = params[:name]
      @elements = []
      if block_given? then
        yield.each { |field_element|
          add(field_element)
        }
      end
      legend_element   = params[:legend]
      legend_element ||= params[:label]
      set_legend(legend_element)
      params.delete(:legend)
      params.delete(:label)
      params.delete(:name)
      super(params, &block)
    end
    alias legend label

    def legend=(field)
      if field.kind_of? Aurita::GUI::Element then
        @legend = field
      else
        @legend = HTML.legend { field }
      end
    end
    alias set_legend legend=
    alias label= legend=

    def add(field_element)
      @elements << field_element
    end

    def content
      if @legend then
        @content = [ @legend, @elements ]
      else 
        @content = @elements
      end
      return @content
    end

  end
  
end
end
