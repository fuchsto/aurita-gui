
require('rubygems')
require('aurita-gui/form')

include Aurita::GUI

describe Aurita::GUI::Options_Field, "values and labels" do
  before do
  end

  it "should allow setting option as array, using values as labels" do
    s = Select_Field.new(:name => :color)
    s.value = :red
    s.options = [ :blue, :red, :green, :yellow ]
  end

  it "should allow setting values as Hash (key / value map)" do
    s = Select_Field.new(:name => :color)
    s.value = 20
    s.options = { 10 => :blue, 20 => :red, 30 => :green, 40 => :yellow }
  end

  it "should be possible to set values and labels seperately" do
    s = Select_Field.new(:name => :color)
    s.value = 20
    s.option_values = [ 10, 20, 30, 40 ]
    s.option_labels = [ :apple, :orange, :pear, :banana ]
  end

  it "should be possible to set/rename labels with a hash, mapping { value => label }" do
    s = Radio_Field.new(:name => :color)
    s.value = 'foo'
    s.option_values = [ 10, 'foo', 30, 40 ]
    s.option_labels = { 10 => :bleu, 'foo' => :rouge }
    s.options['10'].should == :bleu
    s.options['10'] = :noire
    s.options['10'].should == :noire
    s.options['foo'].should == :rouge
    s.options['30'].should == 30
    s.options['40'].should == 40
    s.options[s.value.to_s].should == :rouge
  end

end
