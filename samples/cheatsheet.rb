
require('rubygems')
require('aurita-gui')
require('test/unit/assertions')

include Test::Unit::Assertions

include Aurita::GUI

#== The basics

# This is the most convenient way to build 
# HTML using aurita-gui. 
# (Thanks to oGMo for demanding more magic)

t1 = HTML.build { 
  div(:class => :css_class, 
      :onmouseover => "do_something_with(this);") { 
    ul(:id => :the_list) { 
      li(:class => :first) { 'foo' } +
      li(:class => :second) { 'bar' } +
      li(:class => :third) { 'batz' }
    }
  }
}
puts t1.to_s
puts '-----------------------------------------'

# Note that all method calls are redirected to 
# class HTML, so this won't work as expected: 

HTML.build { 
  div { 
    h2 { compute_string() } 
  } 
}

# --> <compute_string />
# This is due to a class_eval restriction every 
# builder struggles with at the moment. 
# (There is mixico, but it is not portable). 
#
# To come by this inconvenience, use, for 
# example: 

HTML.build { 
  div { 
    HTML.h2 { compute_string() }
  }
}

# --> <div>computed string here</div>
# This works, as explicit calls to class methods 
# of HTML are not rendered using class_eval. 

# The previous example effectively does the 
# following: 
t2 = HTML.div(:class => :css_class, 
              :onmouseover => "do_something_with(this);") { 
  HTML.ul(:id => :the_list) { 
    [ 
      HTML.li(:class => :first) { 'foo' }, 
      HTML.li(:class => :second) { 'bar' }, 
      HTML.li(:class => :third) { 'batz' }
    ]
  }
}
assert_equal(t1.to_s, t2.to_s)

# Element is not a full Enumerable implementation (yet), 
# but it offers random access operators ...

assert_equal(t1[0].tag, :ul)  # First element of div is <ul>

t1[0][1] = HTML.li(:class => :changed) { 'wombat' }
puts t1.to_s
puts '-----------------------------------------'

# ... as well as #each ... 

t1[0].each { |element|
  element.id = 'each_change'
}

puts t1.to_s

# ... empty? and length. More to come in future releases. 

assert_equal(t1[0].length, 3) # List has 3 entries
assert_equal(t1[0].empty?, false) # List has 3 entries


#== Form generation

puts '-----------------------------------------'
form = Form.new(:name   => :the_form, 
                :id     => :the_form_id, 
                :action => :where_to_send)
# You can either set all attributes in the 
# constructor call ...
text = Input_Field.new(:name => :description, 
                       :class => :the_css_class, 
                       :onfocus => "alert('input focussed');", 
                       :value => 'some text')
# Or set them afterwards: 
text.onblur = "alert('i lost focus :(');"

# Enable / disable: 
text.disable! 
text.enable! 
puts text.to_s
puts '-----------------------------------------'

# Set an element to readonly mode (display value only): 
text.readonly! 
puts text.to_s
puts '-----------------------------------------'
# And back to editable mode: 
text.editable! 

# Add it to the form: 
form.add(text)
puts form.to_s
puts '-----------------------------------------'

# Access it again, via name: 
assert_equal(form[:description], text)
# Or by using its index: 
assert_equal(form[0], text)

# This is useful! 
form[:description].value = 'change value'

checkbox = Checkbox_Field.new(:name => :enable_me, 
                              :value => :foo, 
                              :label => 'Check me', 
                              :options => [ :foo, :bar ] )
form.add(checkbox)
puts form.to_s

