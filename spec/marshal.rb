
require('rubygems')
require('aurita-gui/javascript')
require('aurita-gui/html')
require('aurita-gui/marshal')

include Aurita::GUI

describe Aurita::GUI::Marshal_Helper, "dump and load" do
  before do
  end

  it "should provide marshal dumping of Element instances" do
    e = HTML.div 'content here', :id => 'dump_test'
    l = Element.marshal_load(e.marshal_dump)
    e.to_s.should == l.to_s
  end

  it "should also work for object hierarchies" do
    e = HTML.build { 
      div.outer(:id => :outer_div) { 
        p.inner(:id => :inner_p) { 
          'nested content'
        } + 
        button.confirm(:onclick => js.alert('clicked')) { 'click me' }
      }
    }
    e.to_s.should == Element.marshal_load(e.marshal_dump).to_s
    e[0][1].onclick.to_s.should == "alert('clicked'); "
  end

end

