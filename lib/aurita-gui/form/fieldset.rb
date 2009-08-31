
require('aurita-gui/element')

module Aurita
module GUI

  class Fieldset < Element
    attr_accessor :legend
    
    attr_accessor :label 
    
    attr_accessor :name 
    
    attr_accessor :element_map
    
    attr_accessor :elements
    
    attr_accessor :field_decorator 
    
    attr_accessor :content_dacorator

    def initialize(params, &block)
      params[:tag]       = :fieldset
      params[:id]        = params[:name] unless params[:id]
      @name              = params[:name]
      @fields            = []
      @elements          = []
      @element_map       = {}
      @field_decorator   = Aurita::GUI::Form_Field_Wrapper
      @content_decorator = Aurita::GUI::Form_Content_Wrapper

      if block_given? then
        yield.each { |field_element|
          add(field_element)
        }
      end

      legend_element   = params[:legend]
      legend_element ||= params[:label]
      set_legend(legend_element) if legend_element
      params.delete(:legend)
      params.delete(:label)
      params.delete(:name)
      super(params, &block)

      @content = false
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

    def each(&block)
      @elements.each(&block)
    end

    def add(field_element)
      @elements << field_element
      @element_map[field_element.name.to_s] = field_element
      @fields   << field_element.name

      touch()
    end

    def fields=(attrib_array)
      @fields = attrib_array
      touch()
    end

    def fields
      @fields
    end
    
    # Set all elements to readonly rendering mode. 
    def readonly!
      @elements.each { |e|
        e.readonly!
      }
      touch()
    end
    # Set all form elements to editable mode. 
    def editable! 
      elements.each { |e|
        e.editable! 
      }
      touch()
    end

    def length
      @elements.length
    end

    def content
      return @content if (@content && !@touched)

      @content = fields().map { |field|
        @field_decorator.new(@element_map[field.to_s])
      }

      @content = @content_decorator.new() { @content } 
      @content.add_css_class(:fieldset)

      if @legend then
        @content = [ @legend ] + @content 
      end

      return @content
    end

    def string
      content().to_s
    end
    alias to_s string
    alias to_str string

  end
  
end
end
