
require('aurita-gui/xml/xml_element')

class Array

  def script
    map { |e| e.script if e.respond_to?(:script) }.join('')
  end

  def to_str
    to_s
  end

end

class Symbol
  def empty?
    false
  end
end

module Aurita
module GUI
    
  # GUI::Element is the base class for any rendering 
  # implementation. 
  # It consists of the following members: 
  #
  #   * @tag: The HTML tag to render. 
  #   * @attrib: A hash storing tag attributes, like 
  #              { :href => '/link/to/somewhere' }
  #   * @content: Content this element is wrapping. 
  #               Content can be set in the constructor 
  #               via parameter :content or using a 
  #               block or by #content and #content=. 
  #
  # == Usage as container
  #
  # Element implements all features expected from a 
  # container class. 
  # It delegates access to @content to class Array, 
  # so an element can be used as Array instance, too: 
  #
  #   e = Element.new { Element.new { 'first' } + Element.new { 'second' } }
  #   puts e.join(' -- ')
  #   -->
  #   'first -- second'
  #
  # You can also push elements into an element: 
  #
  #   e1 = HTML.div { 'Foo' }
  #   e2 = HTML.div { 'Bar' }
  #
  #   assert_equal(e[0], 'Foo')
  #   assert_equal(e[1], e2)
  #
  # It also keeps track of parent classes: 
  #
  #   assert_equal(e1[1].parent, e1)
  #
  # Random access operators are redefined, so you 
  # can either access elements by array index, as usual, 
  # as well as by their DOM id: 
  #
  #   e = Element.new { Element.new(:tag => :p, :id => :foo) { 'nested element' } }
  #   puts e[:foo].to_s
  #   -->
  #   '<p id="foo">nested element</p>'
  #
  # == Builder
  #
  # Most methods invoked on an Element instance are 
  # redirected to return or set a tag attribute. 
  # Example: 
  #
  #   link = Element.new(:tag => :a) { 'click me' }
  #   link.href = '/link/to/somewhere'
  #
  # Same as 
  #
  #   link = Element(:tag => :a, 
  #                  :content => 'click me', 
  #                  :href => '/link/to/somewhere')
  #
  # An Element instance can wrap one or more other 
  # elements: 
  #
  #   image_link = Element.new(:tag => :a, :href => '/link/') { 
  #                  Element.new(:tag => :img, :src => '/an_image.png')
  #                }
  #
  # In case an element has no content, it will render 
  # a self-closing tag, like <img ... />. 
  #
  # In most cases you won't use class Element directly, 
  # but by using a factory like Aurita::GUI::HTML or 
  # by any derived class like Aurita::GUI::Form or 
  # Aurita::GUI::Table. 
  #
  # == Markaby style
  #
  # A syntax similar to markaby is also provided: 
  #
  #   HTML.build { 
  #     div.outer { 
  #       p.inner 'click me'
  #     } + 
  #     div.footer 'text at the bottom'
  #   }.to_s
  #
  # --> 
  #
  #   <div class="outer">
  #    <p class="inner">paragraph</p>
  #   </div>
  #   <div class="footer">text at the bottom</div>
  #
  # == Javascript convenience
  #
  # When including the Javascript helper (aurita-gui/javascript), 
  # class HTML is extended by method .js, which provides 
  # building Javascript snippets in ruby: 
  #
  #   e = HTML.build { 
  #     div.outer(:onclick => js.Wombat.alert('message')) { 
  #       p.inner 'click me'
  #     }
  #   }
  #   e.to_s 
  # --> 
  #   <div class="outer" onclick="Wombat.alert(\'message\'); ">
  #     <p class="inner">click me</p>
  #   </div>
  #
  # But watch out for operator precedence! This won't work, as 
  # .js() catches the block first: 
  #
  #   HTML.build { 
  #     div :header, :onclick => js.funcall { 'i will not be passed to div' }
  #   }
  # --> 
  #   <div class="header" onclick="funcall();"></div>
  #
  #
  # So be explicit, use parentheses: 
  #
  #   HTML.build { 
  #     div(:header, :onclick => js.funcall) { 'aaah, much better' }
  #   }
  # -->
  #   <div class="header" onclick="funcall();">aaah, much better</div>
  #
  # == Notes
  #
  # Double-quotes in tag parameters will be escaped 
  # when rendering to string. 
  #
  #   e = Element.new(:onclick => 'alert("message");')
  #
  # The value of parameter :onclick does not change, 
  # but will be escaped when rendering: 
  #
  #   e.onclick == 'alert("message");'
  #   e.to_s    == '<div onclick="alert(\"message\");"></div>'
  #
  class Element < XML_Element
    
    # Redirect methods to setting or retreiving tag 
    # attributes. 
    # There are several possible routings for method_missing: 
    #
    # 1. Setting an attribute (no block, method ends in '=') Example: 
    #   my_div = HTML.div 'content'
    #   my_div.onlick = "alert('foo');"
    #   puts my_div.to_s
    # --> 
    #   <div onclick="alert('foo');">content</div>
    #
    # 2. Retreiving an attribute (no block, method does not end in '='). Example: 
    #
    #   puts my_div.onlick
    # --> 
    #   'alert(\'foo\');'
    #
    # 3. Setting the css class (block or value passed, method does not end in '='). Example: 
    #
    #   my_div.highlighted { 'content' } 
    # or 
    #   my_div.highlighted 'content'
    #
    # --> 
    #   <div class="highlighted">content</div>
    #
    def method_missing(meth, value=nil, &block)
      touch()
      if block_given? then
        @attrib[:class] = meth
        @attrib.update(value) if value.is_a? Hash
        c = yield
        c = [ c ] unless c.is_a?(Array)
        __setobj__(c)
        return self
      elsif !value.nil? && !meth.to_s.include?('=') then
        @attrib[:class] = meth
        case value
        when Hash then
          @attrib.update(value)
          c = value[:content] 
          c = [ c ] if (c && !c.is_a?(Array))
          __setobj__(c) if c
        when String then
          __setobj__([value])
        end
        return self
      else
        return @attrib[meth] unless (value || meth.to_s.include?('='))
        @attrib[meth.to_s.gsub('=','').intern] = value
      end
    end

    # Render this element to a string. 
    def string
      if (!(@force_closing_tag.instance_of?(FalseClass)) && 
          ![ :hr, :br, :input ].include?(@tag)) then
        @force_closing_tag = true
      end
      super()
    end
    alias to_s string
    alias to_str string
    alias to_string string
      
    # Recursively collects script code ( = js_initialize for Widgets) 
    # from children, including own. 
    def script
      scr = ''
      scr << js_initialize().to_s
      __getobj__.each { |c|
        if c.respond_to?(:script) then
          c_script = c.script
          scr << c_script
        end
      }
      scr << js_finalize()
      scr
    end

    # Javascript code to be called before javascript 
    # code of child elements. 
    def js_initialize
      ''
    end

    # Javascript code to be called after javascript 
    # code of child elements. 
    def js_finalize
      ''
    end

    # Return CSS classes as array. Note that 
    # Element#class is not redefined to return 
    # attribute :class, for obvious reasons. 
    def css_classes
      css_classes = @attrib[:class]
      if css_classes.kind_of? Array
        css_classes.flatten! 
      elsif css_classes.kind_of? String
        css_classes = css_classes.split(' ') 
      else # e.g. Symbol
        css_classes = [ css_classes ]
      end
      css_classes.map! { |c| c.to_sym if c }
      return css_classes
    end
    alias css_class css_classes

    # Add CSS class to this Element instance. 
    #   e = Element.new(:class => :first)
    #   e.add_class(:second)
    #   e.to_s 
    # -->
    #   <div class="first second"></div>
    def add_class(*css_class_names)
      touch()
      if css_class_names.first.is_a?(Array) then
        css_class_names = css_class_names.first
      end
      css_class_names.map! { |c| c.to_sym }
      @attrib[:class] = (css_classes + css_class_names) 
    end
    alias add_css_class add_class
    alias add_css_classes add_class
    alias add_classes add_class

    # Remove CSS class from this Element instance. 
    # Add CSS class to this Element instance. 
    #   e = Element.new(:class => [ :first, :second ])
    #   e.to_s 
    # -->
    #   <div class="first second"></div>
    #
    #   e.remove_class(:second)
    #   e.to_s 
    # -->
    #   <div class="first"></div>
    def remove_class(css_class_name)
      touch()
      classes = css_classes
      classes.delete(css_class_name.to_sym)
      @attrib[:class] = classes
    end
    alias remove_css_class remove_class

  end # class

end # module
end # module

