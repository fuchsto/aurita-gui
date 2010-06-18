
require('rubygems')
require('aurita-gui/xml')


include Aurita::GUI


describe Aurita::GUI::XML, "basic document generation" do
  before do
  end

  it "should provide a builder for XML documents" do
    images = [ 'birds.jpg', 'flowers.jpg' ]
    xmldoc = XML::Document.new(:encoding => 'utf-8') { |xml|
      xml.page(:id => 123) { 
        xml.title { 'The page title' } + 
        xml.text  { 'Lorem ipsum dolor ...' } + 
        xml.images { 
          img_count = 0
          images.map { |i| img_count += 1; xml.image(:id => "image_#{img_count}", :url => i) }
        }
      }
    } 
    
    xmldoc.content[:image_1].url.should == 'birds.jpg'
  end

end
