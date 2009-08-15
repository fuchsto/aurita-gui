
require('rubygems')
require('aurita-gui/javascript')
require('aurita-gui/html')

include Aurita::GUI

describe Aurita::GUI::Javascript, "basic rendering" do
  before do
  end

  it "should provide a nice DSL" do
    js = Javascript.build { |j|
      j.Some.Namespace.do_stuff() 
      j.bla(123, { :gna => 23, :blu => '42' }) 
      j.alert("escape 'this' string")
    }
    js.to_s.should == "Some.Namespace.do_stuff(); bla(123,{gna: 23, blu: '42'}); alert('escape \\'this\\' string'); "
  end

  it "should render on class method calls" do
    Javascript.Some.Namespace.do_stuff(23, 'wombat').to_s.should == "Some.Namespace.do_stuff(23,'wombat'); "
  end

  it "should extend class HTML by a helper method '.js'" do
    e = HTML.build { 
      div.outer(:id => :unit, :onclick => js.Wombat.alert('message')) { 
        p.inner 'click me'
      }
    }
    e[:unit].onclick.to_s.should == 'Wombat.alert(\'message\'); '
  end

end

