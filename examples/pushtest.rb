
require 'rubygems'
require 'aurita-gui'

include Aurita::GUI

e1 = HTML.div.outer { 'Foo' }
e2 = HTML.div.inner { 'Bar' }

e1 << e2

puts e1.to_s
p e1[0] == 'Foo'
p e1[1] == e2

p e1[1].parent == e1
p e2.parent == e1
