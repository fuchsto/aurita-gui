
require('rubygems')
require('aurita-gui')

include Aurita::GUI

# If there are no option labels set, 
# option values will be displayed directly: 
s1 = Select_Field.new(:name => :test, 
                      :label => 'Priority', 
                      :options => (1..10))

# Set option values and labels at once using a hash: 
s1 = Select_Field.new(:name => :test, 
                      :label => 'Pick one', 
                      :options => { 1 => 'eins', 2 => 'zwei', 3 => 'drei' })

# Set option values as array, labels as hash: 
s1 = Select_Field.new(:name => :test, 
                      :label => { 'Pick one' => [ 'foo', 'bar', 'wombat' ] }, 
                      :options => [ 1,2,3 ])
# Same as 
puts '----------------------'
s1 = Select_Field.new(:name => :test, 
                      :label => 'Pick one', 
                      :option_labels => [ 'foo', 'bar', 'wombat' ] , 
                      :options => (1..3) )
puts '----------------------'
puts s1.to_s
# Ranges are ok, too: 
s1 = Select_Field.new(:name => :test, 
                      :label => 'Pick one', 
                      :option_labels => [ 'foo', 'bar', 'wombat' ], 
                      :options => (1..3) )

# Change option labels using an array. 
# Option labels will be assigned in order, 
# so options[0] has label[0] etc.
s1.option_labels = [ 'first', 'second', 'third' ]

# Change option labels using a hash. 
# Compared to using an array, this is useful 
# in case you don't know the order of option 
# values. 
s1.option_labels = { 1 => 'ras', 2 => 'dwa', 3 => 'tri' }

# Overwriting the labels field does the same, 
# but this way, you also can change the 
# field label: 
s1.label = { 'Select one' => [ 'foo', 'bar', 'wombat' ] }
# Or
s1.label = { 'Select one' => { 1 => 'foo', 2 => 'bar', 3 => 'wombat' } }

# Of yourse you can replace all option values 
# and their labels at once by overwriting 
# the options field: 
s1.label = 'Choose'
s1.options = { 1 => :foo, 2 => :bar, 3 => :wombat }

