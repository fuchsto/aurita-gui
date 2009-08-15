
require('aurita-gui/form')

include Aurita::GUI

form = Form.new(:method => :post, :action => '/where/to/send', :onsubmit => "alert('submitting');") 

input1 = Input_Field.new(:name => :description, :label => 'Description', 
                         :class => :custom_input_field_class, 
                         :value => 'first input text'), 
input2 = Input_Field.new(:name => :custom, :label => 'Custom ID', 
                         :id => :custom_id_value, 
                         :value => 'second input text'), 
select = Select_Field.new(:name => :category, :label => 'Select category', 
                          :disabled => true, 
                          :value => :value_b,  # Value to be selected
                          :options => { :value_a => :key_a, :value_b => :key_b })
form[1].readonly!
form.each { |e| e.attrib[:class] = [ e.attrib[:class], :aurita ] }
form.each { |e| e.attrib[:onfocus] = "alert('focussed #{e.id}');" }

puts HTML.h1 { 'Single element' }
puts form.element_map[:description]

puts HTML.h1 { 'Editable form, one element disabled' }
puts form

puts HTML.h1 { 'Readonly form' }
form.readonly! 
puts form
