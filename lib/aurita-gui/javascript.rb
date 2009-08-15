
module Aurita
module GUI

  # A minimalistic generator for javascript calls. 
  #
  # Javascript is a simple string factory so you can 
  # write pieces of javascript code in ruby instead of 
  # using plain old strings. 
  # This does not introduce functionality, it just 
  # eases the rendering of ruby objects to javascript: 
  # Aurita::GUI::Javascript  renders method parameters 
  # to their respective meaning in javascript, and also 
  # understands namespaces, variables, and object 
  # notation. 
  #
  # Sometimes i needed somethind like this in ERB 
  # templates: 
  #
  #   <%= button(:class => :cancel, :onclick => "Aurita.cancel_form('#{form.dom_id}"')) %>
  #
  # Now i can do the same in pure ruby: 
  #
  #   <%= button(:class => :cancel, :onclick => js.Aurita.cancel_form(form.dom_id)) %>
  #
  # Just by defining a helper method in 5 lines of 
  # code (see below, section Template helper example). 
  #
  # == Usage with block: 
  #
  #   Javascript.build { |j|
  #     j.Some.Namespace.do_stuff() 
  #     j.bla(123, { :gna => 23, :blu => '42' }) 
  #     j.alert("escape 'this' string")
  #   }
  #
  #   -->
  #   Some.Namespace.do_stuff(); bla(123,{gna: 23, blu: '42' }); alert('escape \'this\' string'); 
  #
  # == Calling class methods
  #
  # For a single call of a javascipt method, you can also use: 
  #
  #   my_element.onclick = Javascript.alert('an alert message')
  #   --> alert('an alert message'); 
  #  
  # This also provides method chaining. Uppercase 
  # methods are interpreted as namespaces. 
  #
  #   my_element.onclick = Javascript.Some.Namespace.my_function('foo', 2, 'bar')
  #   --> <div onclick="Some_Namespace.my_function('foo', 2, 'bar'); "> ... </div>
  #
  # == Template helper example
  #
  # In Aurita, there's a simple helper, defined as 
  #
  #    def js(&block) 
  #      if block_given? then 
  #        Javascript.build(&block)
  #      else
  #        Javascript
  #      end
  #    end
  #
  # It works like that: 
  #
  #    input = Input_Field.new(:onchange => js.Aurita.notify_change_of(:this))
  #    -->  <input onchange="Aurita.notify_change_of(this); " />
  # or
  #    input.onfocus = js.Aurita.notify_focus_on(:this)
  #    -->  <input onchange="Aurita.notify_change_of(this); " 
  #                onfocus="Aurita.notify_focus_of(this); " />
  #
  # == Render to <script> tag
  #
  # Method #to_tag renders the code enclosed in <script> tags: 
  #
  # Javascript.new("alert('message');").to_tag
  #   --> 
  #   <script language="Javascript" type="text/javascript">
  #   alert('message'); 
  #   </script>
  #
  class Javascript
    
    def initialize(script='')
      @script = script
      @scripy ||= ''
    end

    def self.build(&block)
      if block.arity > 0 then
        yield(Javascript.new)
      else 
        self.class_eval(&block) 
      end
    end
    
    # Renders script to a <script> block. 
    def to_tag
      '<script language="Javascript" type="text/javascript">' << "\n" << 
        @script + "\n" << 
      '</script>'
    end

    def string
      @script
    end
    alias to_s string

    def self.[](namespace) 
      return self.new(namespace.to_s + '.')
    end

    def method_missing(meth, *args)
      args = args.collect { |arg|
        arg = to_js(arg)
      }
      args_string = args.join(',') if args.size > 0
      meth = meth.to_s
      # Uppercase method => method call
      meth << '(' << args_string.to_s << '); ' if meth[0].to_i > 96
      # Uppercase method => Namespace
      meth << '.' if meth[0].to_i < 97
      @script << meth
      return self
    end
    alias render method_missing
    def self.method_missing(meth, *args)
      return self.new().__send__(meth, *args)
    end

  protected

    def to_js(arg)
      case arg
      when String then
        arg.gsub!("'","\\\\'")
        "'#{arg}'"
      when Hash then
        obj = []
        arg.each_pair { |k,v|
          v = to_js(v)
          obj << "#{k}: #{v}"
        }
        "{#{obj.join(', ')}}"
      when Symbol then
        arg.to_s
      else 
        arg
      end
    end

  end # class

  class HTML

    def self.js(&block) 
      if block_given? then 
        Javascript.build(&block)
      else
        Javascript
      end
    end

  end

end
end

