
require('delegate')
require('aurita-gui/element')

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

    def initialize()
      super(element())
    end

    def element
      raise ::Exception.new('Missing method #element for ' << self.class.to_s)
    end

    def js_initialize
      ''
    end

  end

end
end

