
require('rubygems')
require('aurita-gui/element')
require('aurita-gui/widget')
require('./spec_units')

describe(Aurita::GUI::Widget) do 

  it "should be possible to rebuild the delegated element" do 
    box = Box.new(:opened => false) { 'content' }
    box.string.should == '<div class="box"><div class="content">content<span>@opened is false</span></div></div>'
    box.opened  = true
    box.box_content = 'jada!'
    box.rebuild
    box.string.should == '<div class="box"><div class="content">jada!<span>@opened is true</span></div></div>'
  end

  it "provides method #build_count returning number of times a Widget instance has been rebuilt" do
    img = Annotated_Image.new('pic.jpg', 'Sample image')
    img.src.should == 'pic.jpg'
    img.desc.should == 'Sample image'
    img.build_count.should == 0 
    img.touched?.should == false
    string = img.to_s

    img.src = 'changed.jpg'
    img.touched?.should == true
    img.desc = 'Changed desc'
    img.src.should == 'changed.jpg'
    img.desc.should == 'Changed desc'
    img.build_count.should == 0

    string = img.to_s
    img.touched?.should == false
    img.build_count.should == 1

    string = img.to_s
    img.build_count.should == 1
  end

  it "provides method #script that collects all Javascript init codes from its elements" do
    widget_with_script = Box.new(:class => :inner)
    box = Box.new(:opened => true) { widget_with_script }
    
    box.script.should == "alert(' opened'); \nalert(' closed'); \n"
  end

end
