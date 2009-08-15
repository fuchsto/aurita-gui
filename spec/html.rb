
require('rubygems')
require('aurita-gui/html')

include Aurita::GUI

describe Aurita::GUI::HTML, "basic rendering" do
  before do
    @e = HTML.build { 
      div(:class => :outer) { 
        h2('Header', :id => :header) +
        p(:id => :content) { 'Content' }
      }
    }
  end

  it "should act as factory by setting tag attribute for Element on class method calls" do
    HTML.p.to_s.should == Element.new(:tag => :p).to_s
    HTML.p(:class => :auto).to_s.should == Element.new(:tag => :p, :class => :auto).to_s
  end

  it "should accept a block and pass it to Element as content" do
    HTML.p { 'string' }.to_s.should == '<p>string</p>'
  end

  it "should also accept the first constructor argument as content" do
    e = HTML.p 'I am the content' 
    e.to_s.should == Element.new(:tag => :p) { 'I am the content' }.to_s
    e = HTML.div 'foo', :class => 'highlight'
    e.to_s.should == '<div class="highlight">foo</div>'
  end

  it "should provide a build mechanism that delegates class methods" do
    @e.to_s = '<div class="outer"><h2 id="header">Header</h2><p id="content">Content</p></div>'
  end

  it "should still provide an object tree" do 
    @e[0].css_class.first.should == :outer
    @e[0][0].id.should == :header
    @e[0][1].id.should == :content
    @e[0][1].get_content.should == [ 'Content' ]
    @e[0][1].content = 'Altered'
    @e[0][1].get_content.should == [ 'Altered' ]
    @e.to_s.should == '<div class="outer"><h2 id="header">Header</h2><p id="content">Altered</p></div>'
  end

  it "should be possible to retreive elements just by DOM id" do
    e = @e[:header]
    e.get_content.first.should == 'Header'
  end

  it "should escape double-quotes in tag parameters" do
    e = Element.new(:onclick => 'alert("message");')
    e.onclick.should == 'alert("message");'
    e.to_s.should == '<div onclick="alert(\"message\");"></div>'
  end

  it "should provide a shortcut for setting css classes" do

    e = HTML.build { 
          div.wrapper { 
            h2.highlight {
             'content here'
            } +
            p.footer('footer content')
          }
        }
    e.to_s.should == '<div class="wrapper"><h2 class="highlight">content here</h2><p class="footer">footer content</p></div>'
  end

end
