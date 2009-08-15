
require('rubygems')
require('aurita-gui/element')

include Aurita::GUI

describe Aurita::GUI::Element, "basic rendering" do
  before do
    @e1 = Element.new(:tag => :tagname)
    @inner = Element.new(:tag => :h2) { 'i am an inner header' }
    @outer = Element.new(:tag => :p, :class => :outer) { @inner }
  end

  it "should have a tag attribute" do
    e = Element.new(:tag => :tagname)
    e.tag.should == :tagname
  end

  it "should provide a shortcut for content as first constructor argument" do
    e = Element.new('I am the content')
    e.string.should == '<div>I am the content</div>'
    e = Element.new('I am the content', :tag => :p)
    e.string.should == '<p>I am the content</p>'
    e.class = 'highlight'
    e.string.should == '<p class="highlight">I am the content</p>'
  end

  it "should have :div as default attribute" do
    e = Element.new()
    e.tag.should == :div
  end

  it "should redirect id to a tag attribute (DOM id)" do
    e = Element.new(:id => :the_dom_id)
    e.id.should == :the_dom_id
    e.id = :changed_id
    e.id.should == :changed_id
  end

  it "should render to an array automatically if necessary" do
    e1 = Element.new(:id => :first)
    e2 = Element.new(:id => :second)

    (e1 + e2).should == [ e1, e2 ]
    e1 << e2
    e1[0].should == e2 
  end

  it "should be able to render to string" do 
    @e1.to_s.should == '<tagname></tagname>'
    @e1.string.should == '<tagname></tagname>'
  end

  it "should have enclosed content that is an array" do
    @e1.get_content.length.should == 0
    @e1.has_content?().should == false
    @e1.get_content.should == []
  end

  it "should close the tag depending on content" do
    @e1.content = 'the content'
    @e1.get_content.should == [ 'the content' ]
    @e1.to_s.should == '<tagname>the content</tagname>'
  end

  it "should not allow self-closing tags in some cases (textarea, label, button ...)" do
    textarea = Element.new(:tag => :textarea)
    textarea.to_s.should == '<textarea></textarea>'
    button = Element.new(:tag => :button, :param => :value)
    button.to_s.should == '<button param="value"></button>'
    label = Element.new(:tag => :label, :param => :value)
    label.to_s.should == '<label param="value"></label>'
  end

  it "should be possible to force a closing tag" do 
    e = Element.new(:tag => :something, :force_closing_tag => true)
    e.to_s.should == '<something></something>'
    e.force_closing_tag = false
    e.to_s.should == '<something />'
  end

  it "should offer tag attributes as hash, maintaining keys as provided" do
    e = Element.new(:foo => 1, :bar => 'barvalue', 'wombat' => 3)
    e.attrib[:foo].should == 1
    e.attrib[:bar].should == 'barvalue'
    e.attrib['wombat'].should == 3
  end

  it "should render parameters as tag attributes" do 
    e = Element.new(:tag => :foo, :some_param => :the_value) 
    e.to_s.should == '<foo some_param="the_value"></foo>'
  end

  it "should be possible to retreive original parameter values" do
    e = Element.new(:tag => :foo, :some_param => :the_value) 
    e.some_param.should == :the_value
  end

  it "should accept parameter :content" do 
    e = Element.new(:tag => :bar, :content => 'content here', :name => :wombat)
    e.get_content.should == ['content here']
    e.name.should == :wombat
    e.to_s.should == '<bar name="wombat">content here</bar>'
  end

  it "should accept content as block, maintaining object identity" do 
    test_obj_identity = 'lorem_ipsum'
    e = Element.new(:tag => :jada) { test_obj_identity } 
    e.get_content.should == [ test_obj_identity ]
    e.tag.should == :jada
  end

  it "should be possible to add new attributes" do 
    e = Element.new(:tag => :jada) { 'string' }
    added_value = 'added_value'
    e.added = added_value
    e.added.should == added_value
  end

  it "should accept other element instances as content" do
    @outer.get_content.should == [ @inner ]
    @outer.to_s.should == '<p class="outer"><h2>i am an inner header</h2></p>'
  end

  it "should maintain an object hierarchy" do
    @outer.get_content.first.new_attrib = 23
    @outer.get_content.first.new_attrib.should == 23
  end

  it "should be possible to alter an enclosed element after adding it as content" do
    @inner.decorated_attrib = 'decorated'
    @inner.get_content << ' with decoration'

    @outer.to_s.should == '<p class="outer"><h2 decorated_attrib="decorated">i am an inner header with decoration</h2></p>'

    @inner.content = 'maintaining hierarchies rocks!'

    @outer.to_s.should == '<p class="outer"><h2 decorated_attrib="decorated">maintaining hierarchies rocks!</h2></p>'
  end

  it "should delegate array operators to @content array" do
    inner = Element.new(:tag => :h2) { 'i am an inner header' }
    outer = Element.new(:tag => :p) { inner }
    outer[0].new_attrib = 23
    outer[0].new_attrib.should == 23
  end

  it "should be able to overwrite tag attributes" do 
    e = Element.new(:tag => :div, :the_param => 42) 
    e.the_param.should == 42
    e.the_param = 23
    e.the_param.should == 23
  end

  it "should be possible to add content elements" do 
    e = Element.new(:foo => :bar)
    ras = 'one'
    dwa = 'two'
    tri = 'three' 
    e.content = ras
    e.get_content.should == [ ras ] 
    e << dwa
    e << tri
    e.get_content.should == [ ras, dwa, tri ]
  end

end
