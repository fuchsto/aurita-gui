
require 'rake'

spec = Gem::Specification.new { |s|

  s.name = 'aurita-gui' 
  s.rubyforge_project = 'aurita'
  s.summary = 'Dead-simple object-oriented creation of HTML elements, including forms, tables and many more. '
  s.description = <<-EOF
Aurita::GUI provides an intuitive and flexible API for object-oriented creation 
of primitive and complex HTML elements, such as tables and forms. 
It is a core module of the Aurita application framework, but it can be used 
as stand-alone library in any context (such as rails). 
As there seems to be a lack of ruby form generators, i decided to release this 
part of Aurita in a single gem with no dependencies on aurita itself. 
  EOF
  s.version = '0.4.0'
  s.author = 'Tobias Fuchs'
  s.email = 'fuchs@wortundform.de'
  s.date = Time.now
  s.files = '*.rb'
  s.add_dependency('arrayfields', '>= 4.6.0')
  s.files = FileList['*', 
                     'lib/*', 
                     'lib/aurita-gui/*', 
                     'lib/aurita-gui/form/*', 
                     'bin/*', 
                     'samples/*',
                     'spec/*'].to_a

  s.has_rdoc = true
  s.rdoc_options << '--title' << 'Aurita::GUI' <<
                    '--main' << 'Aurita::GUI::HTML' <<
                    '--line-numbers'

  s.homepage = 'http://aurita.wortundform.de/'

}
