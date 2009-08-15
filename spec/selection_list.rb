
require('rubygems')
require('aurita-gui/form')

include Aurita::GUI

describe Aurita::GUI::Options_Field, "values and labels" do
  before do
  end

  it "should provide the same interface as an option field" do
    s = Selection_List_Field.new(:name => :the_list) 
    s.options = { 0 => :foo, 1 => :bar, 2 => :batz, 3 => :bla, 4 => :gna}
    s.value   = [ 1, 3 ]
  end

end
