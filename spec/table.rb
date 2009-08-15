
require('rubygems')
require('aurita-gui/table')

include Aurita::GUI

describe Aurita::GUI::Table, "basic rendering" do

  it "should provide headers" do
    table = Table.new(:headers => [ :username, :email, 'last login' ], 
                      :class => 'spectable')
    table.to_s.should == '<table class="spectable"><tr><th>username</th><th>email</th><th>last login</th></tr></table>'
  end

  it "should be possible to add rows" do
    table = Table.new(:headers => [ :username, :email, 'last login' ], 
                      :class => 'spectable')
    table.add_row('a','b','c')
    table.to_s.should == '<table class="spectable"><tr><th>username</th><th>email</th><th>last login</th></tr><tr><td>a</td><td>b</td><td>c</td></tr></table>'
  end

  it "should be possible to change cell values" do
    table = Table.new(:class => 'spectable')
    table.add_row('a','b','c')
    table[0][1] = 'changed'
    table.to_s.should == '<table class="spectable"><tr><td>a</td><td>changed</td><td>c</td></tr></table>'
  end

  it "should be possible to modify Table_Cell elements" do
    table = Table.new(:column_css_classes => [ :c1, :c2, :c3 ] )
    table.add_row('a','b','c')
    table.to_s.should == '<table><tr><td class="c1">a</td><td class="c2">b</td><td class="c3">c</td></tr></table>'
    table.add_row('a','b','c')
    table[0].add_css_class(:gnarg)
    table[0][1].add_css_class(:knorg)
    table.to_s.should == '<table><tr class="gnarg"><td class="c1">a</td><td class="c2 knorg">b</td><td class="c3">c</td></tr><tr><td class="c1">a</td><td class="c2">b</td><td class="c3">c</td></tr></table>'
  end

  it "should be possible to set CSS classes for columns" do
    table = Table.new(:class => 'spectable', :column_css_classes => [ :c1, :c2, :c3 ] )
    table.add_row('a','b','c')
    table.to_s.should == '<table class="spectable"><tr><td class="c1">a</td><td class="c2">b</td><td class="c3">c</td></tr></table>'
  end

  it "should be possible to set CSS classes for rows" do
    table = Table.new(:class => 'spectable', :row_css_classes => :trow )
    table.add_row('a','b','c')
    table.add_row('a','b','c')
    table.to_s.should == '<table class="spectable"><tr class="trow"><td>a</td><td>b</td><td>c</td></tr><tr class="trow"><td>a</td><td>b</td><td>c</td></tr></table>'
  end

end

