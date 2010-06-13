
require('delegate')
require('aurita-gui/sanitize')

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
  class Element < DelegateClass(Array)
    
    @@element_count = 0
    @@render_count = 0
    
    attr_accessor :attrib, :parent, :force_closing_tag, :tag, :gui_element_id

    def force_closing_tag=(value)
      touch()
      @force_closing_tag = value
    end
    
    def parent=(value)
      touch()
      @parent = value
    end

    def attrib
      touch()
      @attrib
    end

    def tag=(value)
      touch()
      @tag = value
    end

    def initialize(*args, &block) 
    # {{{

      case args[0]
      when Hash 
        params   = args[0]
      else
        params   = args[1] 
        params ||= {}
        params[:content] = args[0]
      end

      @touched = false

      @@element_count   += 1
      @gui_element_id    = @@element_count
      @id                = @@element_count
      @parent          ||= params[:parent]
      @force_closing_tag = params[:force_closing_tag]

      params[:tag] = :div if params[:tag].nil?
      @tag = params[:tag]

      params.delete(:parent)
      params.delete(:force_closing_tag)

      if block_given? then
        @content = yield
      else
        @content = params[:content] unless @content
      end

# DON'T EVER USE @content.string UNLESS FOR RENDERING!
#     @content = nil if @content.to_s.length == 0    # <--- NOOOOooo!
# instead, test for an empty string like this: 
      if !@content.is_a?(Element) && 
         @content.respond_to?(:length) && 
         @content.length == 0 then
        @content   = nil 
      end

      @content   = [ @content ] unless (@content.kind_of? Array or @content.nil?)
      @content ||= []

      @content.each { |c|
        if c.is_a?(Element) then
          c.parent = self
        end
      }
      params.delete(:content)
      params.delete(:tag)
      
      @attrib = params

      super(@content)
    end

    def inspect
      "#{self.class.to_s}: <#{@tag}>, #{@attrib.inspect} { #{@content.inspect} }"
    end

    # To definitely tell if a class is 
    # anyhow derived from Element, use 
    # 
    #   something.respond_to? :aurita_gui_element
    #
    def aurita_gui_element
    end

    def length
      __getobj__.length
    end

    # Tell object tree instance to rebuild 
    # object tree on next call of #string 
    # as this element instance has been 
    # changed. 
    def touch
      @touched = true
      @string  = nil
      # Don't re-touch! Parent could have been caller!
      @parent.touch() if (@parent && !@parent.touched?) 
    end # }}}

    alias touch! touch
    def touched? 
      (@touched == true)
    end
    def untouch
      @touched = false
    end

    def has_content? 
      (length > 0)
    end
    def empty? 
      (length == 0)
    end

    # Alias definition for #dom_id=(value)
    # Define explicitly so built-in method #id
    # is not invoked instead
    def id=(value)
      @attrib[:id] = value if @attrib
    end
    alias dom_id= id=

    # Alias definition for #dom_id()
    def id
      @attrib[:id] if @attrib
    end
    alias dom_id id

    # Return [ self, other ] so concatenation of 
    # Element instances works as expected; 
    #
    #   HTML.build { 
    #     div { 'first' } + div { 'second' } 
    #   }
    #   --> <Element [ <Element 'first'>, <Element 'second'> ] >
    #
    def +(other)
      touch() # ADDED
      other = [other] unless other.is_a?(Array) 
      other.each { |o| 
        if o.is_a?(Element) then
          o.parent = @parent if @parent
        end
      }
      return [ self ] + other 
    end

    # Append object to array of nested elements. 
    # Object to append (other) does not have to 
    # be an Element instance. 
    # If so, however, other#parent will be set 
    # to this instance. 
    def <<(other)
      if other.is_a?(Element) then
        other.parent = self 
      end
      touch # ADDED
      __getobj__().push(other)
    end
    alias add_child << 
    alias add_content << 
    alias append <<

    def prepend(other)
      set_content(other + get_content)
    end

    # Returns [ self ], so concatenation with 
    # Arrays and other Element instances works 
    # as expected (see #<<(other).
    def to_ary
      [ self ]
    end
    alias to_a to_ary

    # Returns nested content as array. 
    def get_content
      __getobj__()
    end

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

    # Set enclosed content of this element. 
    # Will be automatically wrapped in an array. 
    def set_content(obj)
      touch()
      if obj.is_a?(Array) then
        obj.each { |o| o.parent = self if o.is_a?(Element) } 
        __setobj__(obj)
      else
        obj.parent = self if obj.is_a?(Element)
        return __setobj__([ obj ]) 
      end
    end
    alias content= set_content

    # Define explicitly so built-in method #type 
    # is not invoked instead
    def type=(type)
      @attrib[:type] = type
    end

    # Do not redirect random access operators. 
    def [](index)
      return super(index) if (index.is_a?(Numeric))
      return find_by_dom_id(index) 
    end

    # Retreive an element from object tree by 
    # its dom_id
    def find_by_dom_id(dom_id)
      return unless dom_id
      
      dom_id = dom_id.to_sym 
      each { |c|
        if c.is_a? Element then
          return c if (c.dom_id == dom_id)
          sub = c.find_by_dom_id(dom_id)
          return sub if sub
        end
      }
      return nil
    end

    # Do not redirect random access operators. 
    def []=(index,element)
      if (index.is_a? Numeric) then
        if __getobj__[index].is_a?(Element)
          __getobj__[index].swap(element) 
        end
      else
        e = find_by_dom_id(index) 
        e.swap(element) if e
      end
      touch()
      super(index,element) if (index.is_a? Numeric)
      e = find_by_dom_id(index) 
      e.swap(element) if e
    end

    # Copy constructor. Replace self with 
    # other element. 
    def swap(other)
      touch()
      save_own_id = dom_id()
      @tag = other.tag
      @attrib = other.attrib 
      @attrib[:id] = save_own_id
      __setobj__(other.get_content)
    end
    alias copy swap

    # Static helper definition for clearing 
    # CSS floats. 
    def clear_floating
      '<div style="clear: both;" />'.sanitized
    end

    # Render this element to a string. 
    def string

      return @string.sanitized if @string

      if @tag == :pseudo then
        @string = get_content
        if @string.is_a?(Array) then
          @string = @string.map { |e| e.to_s; e }.join('') 
        else 
          @string = @string.to_s
        end
        return @string.sanitized
      end

      @@render_count += 1

      attrib_string = ''
      if @attrib then
        @attrib.each_pair { |name,value|
          if value.instance_of?(Array) then
            value = value.reject { |e| e.to_s == '' }.join(' ')
          elsif value.instance_of?(TrueClass) then
            value = name
          else
            value = value.to_s unless value.nil?
          end
          if !value.nil? then # Empty attribute values are allowed, as in <option value="">label</option>
            value = value.to_s.gsub('"','\"')
            attrib_string << " #{name}=\"#{value}\""
          end
        } 
      end
     
      if (!(@force_closing_tag.instance_of?(FalseClass)) && 
          ![ :hr, :br, :input ].include?(@tag)) then
        @force_closing_tag = true
      end
      if @force_closing_tag || has_content? then
        
       if RUBY_VERSION[0..2] == '1.8' then
# Ruby 1.8 only: 
         tmp = __getobj__.to_s
       else
# Compatible to ruby 1.9 but slower in 1.8: 
         tmp = __getobj__
         tmp = tmp.map { |e| e.to_s; e }.join('') if tmp.is_a?(Array)
       end

        @string = "<#{@tag}#{attrib_string}>#{tmp}</#{@tag}>"
        untouch()
      else
        untouch()
        @string = "<#{@tag}#{attrib_string} />" 
      end
      
      return @string.sanitized
    end
    alias to_s string
    alias to_str string
    alias to_string string
      
    # Recursively collects script code ( = js_initialize for Widgets) 
    # from children, including own. 
    def script
      scr = ''
      scr << js_initialize()
      @content.each { |c|
        if c.respond_to?(:script) then
          c_script  = c.script
        # puts "#{c.dom_id} #{c.class} : #{c_script}"
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

    # Iterates over all Elements in this
    # instances object tree (depth first). 
    #
    #   x = HTML.build { 
    #        div.main { 
    #          h2.header { 'Title' } + 
    #          div.lead { 'Intro here' } + 
    #          div.body { 
    #            p.section { 'First' } + 
    #            p.section { 'Second' } 
    #          }
    #        }
    #       }
    #
    #   x.recurse { |element| 
    #     p element.css_class
    #   }
    #
    # --> 
    #
    #   :main
    #   :header
    #   :lead
    #   :body
    #   :section
    #   :section
    #
    def recurse(&block)
      each { |c| 
        if c.is_a?(Element) then
          yield(c)
          c.recurse(&block) 
        end
      }
    end
    
    # To avoid memory leak
    def flatten
      self
    end

    def flatten! 
    end

    # Element instances always are sane, as 
    # they are encoding non-sanitized content 
    # automatically when being rendered to a 
    # String. 
    #
    def sanitized?
      true
    end
    alias html_safe? sanitized? # Compatibility with ActiveSupport's ERB patch

    # Just returns self as Element instances 
    # always are sane. 
    #
    def sanitized
      self
    end
    alias html_safe sanitized # Compatibility with ActiveSupport's ERB patch

    # Just returns self as Element instances 
    # always are sane. 
    #
    def sanitize! 
      self
    end

  end # class

  class Buffered_Element < Element

    def initialize(buffer, *args, &block)
      @output_buffer = buffer
      super(*args, &block)
    end

    def method_missing(meth, value=nil, &block)
      if block_given? then
        @attrib[:class] = meth
        @attrib.update(value) if value.is_a? Hash
        c = yield
        c = [ c ] unless c.is_a?(Array)
        __setobj__(c)

        return string()
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

        return string()
      else
        return @attrib[meth] unless value or meth.to_s.include? '='
        @attrib[meth.to_s.gsub('=','').intern] = value
      end
    end

  end

  class Pseudo_Element < Element
    def initialize(params={}, &block)
      params[:tag] = :pseudo
      super(params)
    end
  end
  
end # module
end # module

