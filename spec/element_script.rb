
require('rubygems')
require('aurita-gui/element')
require('aurita-gui/widget')
require('./spec_units')

include Aurita::GUI

describe(Aurita::GUI::Element) do 

  it "should collect javascript init code from its children" do

    box1 = Box.new(:id => :box_1, :opened => true)
    box2 = Box.new(:id => :box_2, :opened => false) 
    box3 = Box.new(:id => :box_3, :opened => false)

    HTML.div { box1 + box2 }.script.should == "alert('box_1 opened'); alert('box_2 closed'); "

    outer = HTML.p(:id => :outer) { HTML.div(:id => :inner) { box1 } + box2 + HTML.div { box3 } } 
    
    outer.script.should == "alert('box_1 opened'); alert('box_2 closed'); alert('box_3 closed'); "

  end

end
