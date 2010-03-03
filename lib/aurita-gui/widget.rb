
require('delegate')
require('aurita-gui/element')
require('aurita-gui/html')

module Aurita
module GUI

  # Widget is a proxy / factory for an actual Aurita::GUI::Element. 
  # Method #element has to be overloaded that defines the Element 
  # instance the class is delegating to. 
  #
  # A simple widget could look like this: 
  #
  #    class Annotated_Image < Aurita::GUI::Widget
  #
  #      attr_accessor :src, :title, :description
  #
  #      def initialize(params={})
  #         @src         = params[:src]
  #         @title       = params[:title]
  #         @description = params[:description]
  #      end
  #
  #      def element
  #         HTML.div.annotated_image {
  #           HTML.img(:src => @src, :title => @title, :alt => @title) + 
  #           HTML.p { @description }
  #         }
  #      end
  #
  #    end # class
  #
  # It then can be used like a regular Element instance: 
  #
  #    image = Annotated_Image.new(:src         => '/images/wombat.jpg', 
  #                                :title       => 'wombat', 
  #                                :description => 'A cute wombat')
  #    image.add_css_class(:active)
  #    puts image.string
  #    
  #    -->
  #
  #    <div class="annotated_image active">
  #      <img src="/images/wombat.jpg" title="wombat" alt="wombat" />
  #      <p>A cute wombat</p>
  #    </div>
  #
  class Widget < DelegateClass(Element)
  include Aurita::GUI

    def self.element_properties(*property_names)
      property_names.each { |p|
        send(:define_method, "#{p}=".to_sym) { |value|
          instance_variable_set("@#{p}", value)
          rebuild()
        }
        send(:define_method, p.to_sym) { 
          instance_variable_get("@#{p}")
        }
      }
    end

    def initialize()
      @params ||= {}
      super(element())
    end

    def element
      raise ::Exception.new('Missing method #element for ' << self.class.to_s)
    end

    def js_initialize
      ''
    end
    def js_finalize
      ''
    end

    # Recursively collects js_initialize and js_finalize 
    # code from children, wrapped by including own. 
    def script
      scr  = js_initialize 
      # Method #each is delegated to element 
      each { |c| 
        if c.respond_to?(:script) then
          scr << "\n"
          scr << c.script 
        end
      }
      scr << js_finalize
      scr
    end

    # Necessary, as implementation from Element would 
    # cast this Widget object into an Element object. 
    def +(other)
      other = [other] unless other.is_a?(Array) 
      other.each { |o| 
        if o.is_a?(Element) then
          o.parent = @parent if @parent
        end
      }
      touch # ADDED
      return [ self ] + other 
    end

    # Necessary, as implementation from Element would 
    # cast this Widget object into an Element object. 
    def to_ary
      [ self ]
    end
    alias to_a to_ary

    # As Widget and Element are implemented using DelegateClass, 
    # changes on instance variables that are used in #element() 
    # would not be noticed, as result of #element() is delegated 
    # in constructor. 
    # To indicate that the delegated element has to be updated, 
    # call #rebuild. 
    # Consider this example: 
    #
    #   class Box < Widget
    #     attr_accessor :opened, :box_content
    #
    #     def initialize(params={}, &block)
    #       @box_content = yield if block_given? 
    #       @opened  = params[:opened]
    #     end
    #     def element
    #       if @opened then
    #         HTML.div.box { "My content is {@box_content}" } 
    #       else 
    #         HTML.div.box
    #       end
    #     end
    #   end
    #
    #   box = Box.new(:opened => false) { 'content here' }
    #   box.opened = true
    #   box.box_content = 'Jada'
    #   box.string
    #   --> '<div class="box"></div>
    #   box.rebuild
    #   --> '<div class="box">My content is Jada</div>
    #
    def rebuild
      rebuilt = element()
      __setobj__(rebuilt)
      touch()
    end

    def dom_id
      @params[:id] if @params
    end

  end

end
end

