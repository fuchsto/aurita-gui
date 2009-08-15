
require('rubygems')
require('aurita-gui/form')

include Aurita::GUI

describe Aurita::GUI::Form, "basic rendering" do
  before do
    @form = Form.new()
    @text_field = Input_Field.new(:name => :textfield)
  end

  it "should probvide method #add to add form fields" do
    @form.add(@text_field)
  end

  it "should allow access to form fields by index" do
    text_field = Input_Field.new(:name => :compare_me)
    @form.add(text_field)
    @form.elements[0].should == text_field
  end

  it "should wrap form fields as list elements (<li>...</li>)" do
    @form.add(@text_field)
    @form.to_s.should == '<form method="POST" enctype="multipart/form-data"><ul class="form_fields"><li class="input_field_wrap form_field" id="textfield_wrap"><input type="text" name="textfield" id="textfield" /></li></ul></form>'
  end

end
