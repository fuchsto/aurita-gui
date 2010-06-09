
require 'rubygems'
require 'aurita-gui'

include Aurita::GUI

x = HTML.build { 
     div.main { 
       h2.header { 'Title' } + 
       div.lead { 'Intro here' } + 
       div.body { 
         p.section { 'First' } + 
         p.section { 'Second' } + 
         p.section { 'Third' }  
       }
     }
}

x.recurse { |element| 
  p element.css_class
}
