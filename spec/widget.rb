
require('rubygems')
require('aurita-gui/element')
require('aurita-gui/widget')
require('./spec_units')

describe(Aurita::GUI::Widget) do 

  it "should be possible to rebuild the delegated element" do 
    
    box = Box.new(:opened => false) { 'content' }
    box.string.should == '<div class="box"><div class="content">content @opened is false</div></div>'
    box.opened  = true
    box.box_content = 'jada!'
    box.rebuild
    box.string.should == '<div class="box"><div class="content">jada! @opened is true</div></div>'
    
  end

end
