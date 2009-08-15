
require('aurita-gui/form/form_field')

module Aurita
module GUI

  # Factory for input fields. 
  # Default type is :text, accoring to W3C, possible 
  # types are :password, :radio, :checkbox. 
  #
  # For radio and checkbox input fields, there are 
  # classes Radio_Field and Checkbox_Field, providing 
  # more convenience than building option fields 
  # manually. 
  # See also Options_Field on this topic. 
  #
  # Usage: 
  #
  #   i = Input_Field.new(:type => :text, 
  #                       :name => :description, 
  #                       :label => 'Enter a discription', 
  #                       :value => 'Lorem ipsum dolor')
  #
  class Input_Field < Form_Field
    def initialize(params, &block)
      params[:tag]  = :input
      params[:type] = :text unless params[:type]
      if block_given? then
        params[:value] = yield
      end
      super(params)
    end
    def element
      @attrib[:value] = @value
      HTML.input(@attrib)
    end
  end

  
end
end
