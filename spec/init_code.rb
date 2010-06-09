
require('rubygems')
require('aurita-gui/element')
require('aurita-gui/widget')
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

class Widget_1 < Widget
  def initialize
    @name = :foo
    super()
  end
  def element
    HTML.div { @name }
  end
  def js_initialize
    "widget_init(1, #{@name}); "
  end
end
class Widget_2 < Widget
  def initialize
    @name = :bar
    super()
  end
  def element
    HTML.div { HTML.div { @name } + HTML.span { [ Widget_1.new() ] } }
  end
  def js_initialize
    "widget_init(2, #{@name}); "
  end
end

describe Aurita::GUI::Element, "managing javascript init codes" do
  before do
    @u1 = Unit_1.new(:tag => :div) 
    @u2 = Unit_2.new(:tag => :a) 
  end

  it "should be possible to apply javascript code to be eval'ed on rendering an element" do
    @u1.js_initialize.should == "alert('init me');"
    @u1.script.should == "alert('init me');"
  end

  it "should propagate its init code to its parent element" do 
    e = HTML.div { 
      HTML.span { 'bla' } + Unit_1.new(:tag => :div) 
    }
    e.script.should == "alert('init me');"
  end

  it "should concatenate all init codes from its children" do
    e = HTML.div { 
      HTML.span { 'bla' } + Unit_1.new(:tag => :inner) { Unit_2.new(:tag => :a) }
    }
    e.script.should == "alert('init me');init(this);"
  end

  it "should return init scripts of nested Widgets" do
    Widget_2.new().script.should == "widget_init(2, bar); \nwidget_init(1, foo); \n"
  end

end


