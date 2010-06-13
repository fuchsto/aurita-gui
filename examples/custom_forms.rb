

require('rubygems')
require('aurita-gui')
require('aurita-gui/form/submit_button')

include Aurita::GUI

# Plain, manual HTML form, without any decorations (also without labels)
#
form = HTML.form(:name => :sample_form, :id => :sample_form) { 
  Text_Field.new(:name  => :forename, 
                 :value => 'Carl', 
                 :id    => :forename_field, 
                 :label => 'Forename') # label will not be rendered
}
puts '-----------------------------------'
puts form.to_s

# Fully automatic form generation
# Form will be rendered as <ul> with form fields wrapped in <li> tags. 
# Also applies automatic CSS classes. 
#
form = Form.new(:name => :sample_form, :id => :sample_form) 
form.add(Text_Field.new(:name  => :forename, 
                        :value => 'Carl', 
                        :id    => :forename_field, 
                        :label => 'Forename'))
form.add(Submit_Button.new(:value => 'Send me'))

puts '-----------------------------------'
puts form.to_s





