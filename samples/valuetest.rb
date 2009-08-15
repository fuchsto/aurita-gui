
require('rubygems')
require('aurita-gui')
require('test/unit/assertions')

include Test::Unit::Assertions

include Aurita::GUI

form = Form.new(:name   => :the_form, 
                :id     => :the_form_id, 
                :action => :where_to_send)
# You can either set all attributes in the 
# constructor call ...
text = Input_Field.new(:name => :description, 
                       :class => :the_css_class)

# Enable / disable: 
form.add(text)

checkbox = Checkbox_Field.new(:name => :enable_me, 
                              :label => 'Check me', 
                              :options => [ :foo, :bar ] )
form.add(checkbox)

textarea = Textarea_Field.new(:name => :message, 
                              :label => 'Tell me something', 
                              :value => 'Dear Sir ...')
form.add(textarea)
# You also can change values after adding them to the form: 
textarea.value.gsub!('Sir','Madam')

# Finally. form.values=(hash) replaces form values: 
form.values = { :enable_me => :foo, :description => 'The description' }

puts form.to_s

assert_equal(form[0].value, 'The description')
assert_equal(form[1].value, :foo)

h = HTML.build {
  p(:class => :oaragraph) { 
    div(:id => :content) { 
      'Here is text'
    }
  }
}

p h[0].content = 'Bla'
puts h.to_s
