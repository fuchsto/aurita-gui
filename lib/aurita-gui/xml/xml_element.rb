
require('delegate')
require('aurita-gui/sanitize')

module Aurita
module GUI

  class XML_Element < DelegateClass(Array)

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
      if !@content.is_a?(XML_Element) && 
         @content.respond_to?(:length) && 
         @content.length == 0 then
        @content   = nil 
      end

      @content   = [ @content ] unless (@content.kind_of? Array or @content.nil?)
      @content ||= []

      @content.each { |c|
        if c.is_a?(XML_Element) then
          c.parent = self
        end
      }
      params.delete(:content)
      params.delete(:tag)
      
      @attrib = params

      super(@content)
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

    # Retreive an element from object tree by 
    # its dom_id
    def find_by_dom_id(dom_id)
      return unless dom_id
      
      dom_id = dom_id.to_sym 
      each { |c|
        if c.is_a? XML_Element then
          return c if (c.dom_id.to_s == dom_id.to_s)
          sub = c.find_by_dom_id(dom_id)
          return sub if sub
        end
      }
      return nil
    end
    
    def inspect
      "#{self.class.to_s}: <#{@tag}>, #{@attrib.inspect} { #{@content.inspect} }"
    end

    # To definitely tell if a class is 
    # anyhow derived from XML_Element, use 
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
    
    # Return [ self, other ] so concatenation of 
    # XML_Element instances works as expected; 
    #
    #   HTML.build { 
    #     div { 'first' } + div { 'second' } 
    #   }
    #   --> <XML_Element [ <XML_Element 'first'>, <XML_Element 'second'> ] >
    #
    def +(other)
      touch() # ADDED
      other = [other] unless other.is_a?(Array) 
      other.each { |o| 
        if o.is_a?(XML_Element) then
          o.parent = @parent if @parent
        end
      }
      return [ self ] + other 
    end

    # Append object to array of nested elements. 
    # Object to append (other) does not have to 
    # be an XML_Element instance. 
    # If so, however, other#parent will be set 
    # to this instance. 
    def <<(other)
      if other.is_a?(XML_Element) then
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
    # Arrays and other XML_Element instances works 
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
    #   page = XML.page 'content'
    #   page.title = "The page title"
    #   puts page.to_s
    # --> 
    #   <page title="The page title">content</page>
    #
    # 2. Retreiving an attribute (no block, method does not end in '='). Example: 
    #
    #   puts page.title
    # --> 
    #   'The page title'
    #
    # 3. Setting the tag namespace (block or value passed, method does not end in '='). Example: 
    #
    #   XML.og.page { 'content' } 
    # or 
    #   XML.og.page 'content'
    #
    # --> 
    #   <og:page>content</page>
    #
    def method_missing(meth, value=nil, &block)
      touch()
      if block_given? then
        @tag = "#{@tag}:#{meth}"
        @attrib.update(value) if value.is_a? Hash
        c = yield
        c = [ c ] unless c.is_a?(Array)
        __setobj__(c)
        return self
      elsif !value.nil? && !meth.to_s.include?('=') then
        @tag = "#{@tag}:#{meth}"
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
        obj.each { |o| o.parent = self if o.is_a?(XML_Element) } 
        __setobj__(obj)
      else
        obj.parent = self if obj.is_a?(XML_Element)
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

    # Do not redirect random access operators. 
    def []=(index,element)
      if (index.is_a? Numeric) then
        if __getobj__[index].is_a?(XML_Element)
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
      @tag    = other.tag
      @attrib = other.attrib 
      @attrib[:id] = save_own_id
      __setobj__(other.get_content)
    end
    alias copy swap

    # Iterates over all XML_Elements in this
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
        if c.is_a?(XML_Element) then
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

    # XML_Element instances always are sane, as 
    # they are encoding non-sanitized content 
    # automatically when being rendered to a 
    # String. 
    #
    def sanitized?
      true
    end
    alias html_safe? sanitized? # Compatibility with ActiveSupport's ERB patch

    # Just returns self as XML_Element instances 
    # always are sane. 
    #
    def sanitized
      self
    end
    alias html_safe sanitized # Compatibility with ActiveSupport's ERB patch

    # Just returns self as XML_Element instances 
    # always are sane. 
    #
    def sanitize! 
      self
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

  end # class XML_Element

  class Pseudo_Element < XML_Element
    def initialize(params={}, &block)
      params[:tag] = :pseudo
      super(params)
    end
  end
  

end
end

