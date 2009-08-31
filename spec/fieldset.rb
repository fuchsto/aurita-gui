
require('rubygems')
require('aurita-gui/form')

include Aurita::GUI

describe Aurita::GUI::Form, "basic rendering" do
  before do
    @form = Form.new()
    @first_input_field  = Input_Field.new(:name => :first_input_field, :value => 42) 
    @second_input_field = Input_Field.new(:name => :second_input_field) 
    @fieldset = Fieldset.new(:legend => 'First fieldset', :name => :the_fieldset) { 
      @first_input_field + @second_input_field
    }
    @third_input_field = Input_Field.new(:name => :third_input_field) 
  end

  it "should provide method #add to add form fields" do
    @form.add(@third_input_field)
    @form.add(@fieldset)

    @form.elements.length.should == 2

    @form[:first_input_field].value.should == 42
    @form[:second_input_field].value = 23
    @form[:second_input_field].value.should == 23
  end

  it "should allow access to form fields by index" do
    @form.add(@fieldset)
    @form.add(@third_input_field)
    @form.elements[0].should == @fieldset
    @form.elements[1].should == @third_input_field
  end

  it "should render as a <fieldset> element" do
    @form.add(@fieldset)
    @form.add(@third_input_field)

    expected = <<END
<form method="POST" enctype="multipart/form-data">
  <ul class="form_fields">
    <li>
      <legend>First fieldset</legend>
      <ul class="form_fields fieldset">
        <li class="input_field_wrap form_field" id="first_input_field_wrap">
          <input type="text" value="42" name="first_input_field" id="first_input_field" />
        </li>

        <li class="input_field_wrap form_field" id="second_input_field_wrap">
          <input type="text" name="second_input_field" id="second_input_field" />
        </li>
      </ul>

    </li>

    <li class="input_field_wrap form_field" id="third_input_field_wrap">
      <input type="text" name="third_input_field" id="third_input_field" />
    </li>
  </ul>
</form>
END
    @form.to_s.gsub("\n",'').gsub(/>\s*</,'><').should == expected.gsub("\n",'').gsub(/>\s*</,'><')
  end

  it "should allow applying field settings to a form's fieldsets" do
    form = Form.new()

    first  = Text_Field.new(:name => :first,  :value => 1)
    second = Text_Field.new(:name => :second, :value => 2)
    third  = Text_Field.new(:name => :third,  :value => 3)

    form.add(first)
    form.add(second)
    form.add(third)

    form.fields = [ { :the_legend => [ :first, :third ] }, :second ]

    expected = <<END
<form method="POST" enctype="multipart/form-data">
  <ul class="form_fields">
    <li>
      <ul class="form_fields fieldset">
        <li class="text_field_wrap form_field" id="first_wrap">
          <input type="text" value="1" name="first" id="first" />
        </li>
        <li class="text_field_wrap form_field" id="third_wrap">
          <input type="text" value="3" name="third" id="third" />
        </li>
      </ul>
    </li>
    <li class="text_field_wrap form_field" id="second_wrap">
      <input type="text" value="2" name="second" id="second" />
    </li>
  </ul>
</form>
END

    form.to_s.gsub("\n",'').gsub(/>\s*</,'><').should == expected.gsub("\n",'').gsub(/>\s*</,'><')

    form.fields = [ { :the_legend => [ :third ] }, :second ]
    expected = <<END
<form method="POST" enctype="multipart/form-data">
  <ul class="form_fields">
    <li>
      <ul class="form_fields fieldset">
        <li class="text_field_wrap form_field" id="third_wrap">
          <input type="text" value="3" name="third" id="third" />
        </li>
      </ul>
    </li>
    <li class="text_field_wrap form_field" id="second_wrap">
      <input type="text" value="2" name="second" id="second" />
    </li>
  </ul>
</form>
END
    form.to_s.gsub("\n",'').gsub(/>\s*</,'><').should == expected.gsub("\n",'').gsub(/>\s*</,'><')
  end

end
