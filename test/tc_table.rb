
require 'aurita-gui/table'


include Aurita::GUI

t = Table.new(:headers => ['user', 'phone', 'email'], 
              :options => { :class => 'css_class', :id => 'test_table', :border => 1, :cellpadding => 3 })

t.add_row([ 'a','b','c' ])
t.add_row([ 'd','e','f','g' ])

t[0][0].value = 'foo'
t[0][0].colspan = 2
t[1][0].onclick = 'test();'
t[0][1] = HTML.a(:href => 'http://google.com') { 'google' }

t[0][1].value.href = 'other'
t[0][1].value.content = 'clickme'

t[0].class = 'highlighted'

puts t
