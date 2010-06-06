
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
  s.version = '0.6.5'
  s.author = 'Tobias Fuchs'
  s.email = 'fuchs@wortundform.de'
  s.date = Time.now
  s.files = '*.rb'
  s.add_dependency('arrayfields', '>= 4.6.0')
  s.files = [ 
    './README.txt', 
    './LICENSE', 
    'lib/aurita-gui.rb',
    'lib/aurita-gui/form/textarea_field.rb',
    'lib/aurita-gui/form/form_field.rb',
    'lib/aurita-gui/form/file_field.rb',
    'lib/aurita-gui/form/datetime_field.rb',
    'lib/aurita-gui/form/input_field.rb',
    'lib/aurita-gui/form/template_helper.rb',
    'lib/aurita-gui/form/text_field.rb',
    'lib/aurita-gui/form/date_field.rb',
    'lib/aurita-gui/form/boolean_field.rb',
    'lib/aurita-gui/form/password_field.rb',
    'lib/aurita-gui/form/time_field.rb',
    'lib/aurita-gui/form/checkbox_field.rb',
    'lib/aurita-gui/form/select_field.rb',
    'lib/aurita-gui/form/selection_list.rb',
    'lib/aurita-gui/form/form_error.rb',
    'lib/aurita-gui/form/fieldset.rb',
    'lib/aurita-gui/form/hidden_field.rb',
    'lib/aurita-gui/form/radio_field.rb',
    'lib/aurita-gui/form/options_field.rb',
    'lib/aurita-gui/button.rb',
    'lib/aurita-gui/element.rb',
    'lib/aurita-gui/table.rb',
    'lib/aurita-gui/sanitize.rb',
    'lib/aurita-gui/marshal.rb',
    'lib/aurita-gui/widget.rb',
    'lib/aurita-gui/html.rb',
    'lib/aurita-gui/form.rb',
    'lib/aurita-gui/javascript.rb',
    'samples/cheatsheet.rb',
    'samples/putstest.rb',
    'samples/pushtest.rb',
    'samples/recurse.rb',
    'samples/valuetest.rb',
    'spec/init_code.rb',
    'spec/element.rb',
    'spec/table.rb',
    'spec/marshal.rb',
    'spec/widget.rb',
    'spec/spec_units.rb',
    'spec/html.rb',
    'spec/selection_list.rb',
    'spec/options.rb',
    'spec/fieldset.rb',
    'spec/form.rb',
    'spec/element_script.rb',
    'spec/javascript.rb'
  ]

  s.has_rdoc = true
  s.rdoc_options << '--title' << 'Aurita::GUI' <<
                    '--main' << 'Aurita::GUI::HTML' <<
                    '--line-numbers'

  s.homepage = 'http://aurita.wortundform.de/'

}
