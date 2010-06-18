
require('aurita-gui/element')

module Aurita
module GUI

  # = Aurita::GUI 
  # Tobias Fuchs, 2009
  #
  # == About
  #
  # Aurita::GUI is a library for convenient, simple 
  # HTML generation for web applications. 
  #
  # It is a stand-alone library isolated from the 
  # Aurita Web Application Framework, where Aurita::GUI 
  # is used to support design of OO-accessible GUI 
  # elements. 
  #
  # Aurita::GUI is not intended to be used just for 
  # HTML rendering, that is: It is not just a builder. 
  # But it includes a builder syntax, extremely 
  # similar to Markaby, but also including Javascript: 
  #
  #   x = HTML.build { 
  #         div.main(:onclick => js.funcall({ :foo => 23, :bar => 'batz' })) { 
  #           h2.title 'This is what you already now from markaby'
  #         } + 
  #         div.footer('Footer content' :id => :footer)
  #       }
  # --> 
  #   <div class="main" onclick="funcall({ foo: 23, bar: 'batz' }); ">
  #     <h2 class="title">
  #       This is what you already now from markaby
  #     </h2>
  #     <div class="footer" id="footer">Footer content</div>
  #   </div>
  #
  # But HTML.build is not just rendering text. It 
  # maintains an object tree. After rendering, you can 
  # access elements by their index, like in an multi-
  # dimensional array: 
  #
  #   x[0][0].content = "But you didn't know this"
  #   x[0][0].onmouseover = Javascript.alert("or that")
  #
  # Or, more convenient, by their DOM id: 
  #
  #   x[:footer].content = 'Or finding an element by DOM id'
  #
  # You can even completely replace an element after 
  # rendering, but you won't be able to change it's DOM id 
  # (for obvious reasons): 
  #
  #   x[:footer] = HTML.span { 'i changed my mind' }
  #
  # --> 
  #   <div class="main" onclick="funcall({ foo: 23, bar: 'batz' }); ">
  #     <h2 class="title" onmouseover="alert('or that'); ">
  #       But you didn&apos;t know this
  #     </h2>
  #     <span id="footer">I changed my mind</span>
  #   </div>
  #
  # And *this* is the reason there is an own builder 
  # implementation for Aurita::GUI in the first place. 
  #
  # So, other than other builder implementations (there 
  # are many), Aurita::GUI is not just a collection 
  # of template helpers. It is data persistent and 
  # maintains object hierarchies. 
  # That is: The HTML hierarchy you build is not just 
  # rendered to a string - you can access and modify a 
  # generated HTML hierarchy before rendering it. 
  #
  # Altogether, Aurita::GUI implements a flexible and 
  # convenient toolkit for GUI element (e.g. Widgets) 
  # libraries. 
  #
  # This is especially useful (and necessary) when 
  # generating forms. 
  #
  # Aurita::GUI is designed to be especially useful
  # for automated form generation (Lore ORM uses it 
  # to generate forms for models). 
  #
  # Of course there is also Aurita::GUI::Template_Helper 
  # for templates, but this is just one possible 
  # implementation that wraps common tasks in methods. 
  # You can easily write your own template helpers 
  # and use them e.g. in Rails, Merb or Ramaze projects. 
  #
  #
  # Aurita::GUI::HTML is a convenient factory for 
  # Aurita::GUI::Element, the base class to almost 
  # every instance this library generates. 
  # HTML's class methods are redirected to generate a 
  # correspoding Element instance. 
  #
  # It implements an object-oriented, minimalistic 
  # generator for HTML code. 
  # For tags without enclosed content (i.e. without 
  # closing tag): 
  #
  #   HTML.br  
  #   # --> '<br />'
  #
  #   HTML.hr(:class => 'divide')  
  #   # --> '<hr class="divide" />'
  #
  # Same as 
  #
  #   HTML.hr.divide
  #
  # This is effectively a wrapper for 
  #
  #   Element.new(:tag => :hr, :class => 'divide')
  #
  # Enclosed content is passed in a block: 
  #
  #   HTML.a(:href => 'http://domain.com') { 'click me' }
  #   # --> '<a href="http://domain.com">click me</a>'
  #
  # Or as a constructor parameter: 
  #
  #   HTML.a(:href => 'http://domain.com', :content => 'click me')
  #
  # Or as first argument: 
  #
  #   HTML.a('click me', :href => 'http://domain.com')
  #
  # So the following statements are equivalent: 
  #
  #   e = HTML.div.highlight 'hello' 
  #   e = HTML.div 'hello', :class => 'highlight'
  #   e = HTML.div(:class => :highlight) { 'hello' }
  #   e = HTML.div(:class => :highlight, :content => 'hello')
  #
  # In all cases, e is an Element instance: 
  #
  #   e = Element.new(:tag => :div, :class => :highlight, :content => 'hello')
  #
  # That again renders to a String: 
  #
  #   <div class="highlight">hello</div>
  #
  # == Further Examples
  #
  # There are some few usage principles that are 
  # consistent for every class of Aurita::GUI. 
  # One of them: If a parameter can be passed as constructor 
  # argument, there are also getter and setter methods 
  # for this parameter: 
  #
  #   d = HTML.div { 'the content' }
  #   d.content = 'i changed the content'
  #   d.onclick = "alert('you clicked me');"
  #
  #
  # === The basics
  # 
  # This is the most convenient way to build 
  # HTML using aurita-gui. 
  # (Thanks to oGMo for demanding more magic)
  #
  #   t1 = HTML.build { 
  #     div(:class => :css_class, 
  #         :onmouseover => "do_something_with(this);") { 
  #       ul(:id => :the_list) { 
  #         li.first { 'foo' } +
  #         li.second { 'bar' } +
  #         li.third { 'batz' }
  #       }
  #     }
  #   }
  #   puts t1.to_s
  #
  # Note that all method calls are redirected to 
  # class HTML, so this won't work as expected: 
  #  
  #   HTML.build { 
  #     div { 
  #       h2 { compute_string() } 
  #     } 
  #   }.to_s
  #  
  # --> <div><h2><compute_string /></h2></div>
  #
  # This is due to a class_eval restriction every 
  # builder struggles with at the moment. 
  # (There is mixico, but it is not portable), as 
  # a price you pay for using class_eval on the 
  # build block, which enables the concise syntax. 
  #
  # To come by this inconvenience, use puts, as you'd
  # do in regular ruby code. 
  # In the example: 
  #  
  #   HTML.build { 
  #     div { 
  #       h2 { puts compute_string() }
  #     }
  #   }.to_s
  #  
  # --> <div><h2>computed string here</h2></div>
  #
  # This works, as explicit calls to class methods 
  # of HTML are not rendered using class_eval. 
  # 
  # 
  # Element is not a full Enumerable implementation (yet), 
  # but it offers random access operators ...
  # 
  #   assert_equal(t1[0].tag, :ul)  # First element of div is <ul>
  # 
  #   t1[0][1] = HTML.li(:class => :changed) { 'wombat' }
  # 
  # ... as well as #each ... 
  #  
  #   t1[0].each { |element|
  #     element.id = 'each_change'
  #   }
  #  
  # ... empty? and length. More to come in future releases. 
  #  
  #   assert_equal(t1[0].length, 3) # List has 3 entries
  #   assert_equal(t1[0].empty?, false) # List has 3 entries
  #  
  #  
  # === Form builder
  #  
  #   form = Form.new(:name   => :the_form, 
  #                   :id     => :the_form_id, 
  #                   :action => :where_to_send)
  #
  # You can either set all attributes in the 
  # constructor call ...
  #
  #   text = Input_Field.new(:name => :description, 
  #                          :class => :the_css_class, 
  #                          :onfocus => "alert('input focussed');", 
  #                          :value => 'some text')
  # Or set them afterwards: 
  #
  #   text.onblur = "alert('i lost focus :(');"
  # 
  # Enable / disable: 
  #
  #   text.disable! 
  #   text.enable! 
  #
  # Set an element to readonly mode (display value only): 
  #   text.readonly! 
  # 
  # And back to editable mode: 
  #
  #   text.editable! 
  #
  # Add it to the form: 
  #   form.add(text)
  #
  # Access it again, via name: 
  #
  #   assert_equal(form[:description], text)
  #
  # Or by using its index: 
  #
  #   assert_equal(form[0], text)
  #
  # This is useful! 
  #
  #   form[:description].value = 'change value'
  # 
  #   checkbox = Checkbox_Field.new(:name => :enable_me, 
  #                             :value => :foo, 
  #                             :label => 'Check me', 
  #                             :options => [ :foo, :bar ] )
  #   form.add(checkbox)
  #
  #   puts form.to_s
  # 
  class HTML

    # Statically defined as <br /> must not have any attributes. 
    def self.br
      Element.new(:tag => :br)
    end
    
    def self.render(meth_name, *args, &block)
      e = Element.new(*args, &block)
      e.tag = meth_name
      e
    end

    def self.build(&block)
      Element.new(:tag => :pseudo) { self.class_eval(&block) }
    end

    def self.method_missing(meth_name, *attribs, &block)
      render(meth_name, *attribs, &block) 
    end

    def self.render_list(tag, *attribs, &block)
      e = render(tag, *attribs, &block)
      e.add_css_class(:empty) if e.empty? 
      idx = 0
      e.each { |child|
        if child.respond_to?(:tag) && child.tag == :li then
          child.add_css_class("item_#{idx+1}")
          child.add_css_class("first") if idx == 0
          child.add_css_class("last") if idx == (e.length-1)
          idx += 1
        end
      }
      e
    end

    def self.ulist(*attribs, &block)
      render_list(:ul, *attribs, &block)
    end
    def self.olist(*attribs, &block)
      render_list(:ol, *attribs, &block)
    end


    def self.puts(arg)
      HTML.build { arg }
    end

    # Renders text non-wrapping by replacing whitespaces by 
    # &amp;nbsp; entities. 
    def self.nowrap(&block)
      t = yield
      t.gsub!(/\s/,'&nbsp;')
      t
    end

    XHTML_TAGS = [ :html, :div, :p, :input, :select, :option, 
                   :ul, :ol, :li, :title, :link, :a, :form, :fieldset, 
                   :h1, :h2, :h3, :h4, :img ]
    for t in XHTML_TAGS do 
      meth = <<EOC
        def self.#{t.to_s}(*attribs, &block)
          e = Element.new(*attribs, &block)
          e.tag = :#{t}
          e
        end
EOC
      class_eval(meth)
    end

  end # class

  class Builder
    
    def initialize(&block)
      raise ::Exception.new('Missing block for Builder') unless block_given?
      @output_buffer = ''
      instance_eval(&block)
    end

    # Statically defined as <br /> must not have any attributes. 
    def br
      @output_buffer << '<br />'
    end
    
    def render(meth_name, *args, &block)
      raise ::Exception.new('Missing attributes for HTML.' << meth_name.inspect) unless args
      e = Buffered_Element.new(@output_buffer, *args, &block)
      e.tag = meth_name
      @output_buffer << e.string
      e
    end

    # p is defined in Kernel, so we have to 
    # redirect it manually (method_missing won't be 
    # triggered for it)
    def p(*attribs, &block)
      render(:p, *attribs, &block)
    end

    def method_missing(meth_name, *attribs, &block)
      render(meth_name, *attribs, &block) 
    end

    def to_s
      @output_buffer
    end

  end
  
end # module
end # module

