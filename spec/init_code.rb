
require('rubygems')
require('aurita-gui/element')
require('aurita-gui/html')

include Aurita::GUI

class Unit_1 < Element
  def js_initialize
    "alert('init me');"
  end
end
class Unit_2 < Element
  def js_initialize
    "init(this);"
  end
end

describe Aurita::GUI::Element, "managing javascript init codes" do
  before do
    @u1 = Unit_1.new(:tag => :div) 
    @u2 = Unit_2.new(:tag => :a) 
  end

  it "should be possible to apply javascript code to be eval'ed on rendering an element" do
    @u1.js_initialize.should == "alert('init me');"
    @u1.js_init_code.should == "alert('init me');"
  end

  it "should propagate its init code to its parent element" do 
    e = HTML.div { 
      HTML.span { 'bla' } + Unit_1.new(:tag => :div) 
    }
    e.js_init_code.should == "alert('init me');"
  end

  it "should concatenate all init codes from its children" do
    e = HTML.div { 
      HTML.span { 'bla' } + Unit_1.new(:tag => :inner) { Unit_2.new(:tag => :a) }
    }
    e.js_init_code.should == "alert('init me');init(this);"
  end

end


