
require('aurita-gui/form/form_field')

module Aurita
module GUI

  # Wrapper for Input_Field, sets type to :text. 
  #
  # Usage: 
  #
  #   i = Text_Field.new(:name => :description, 
  #                      :label => 'Description', 
  #                      :value => 'Lorem ipsum dolor')
  #
  class Text_Field < Input_Field
    def initialize(params, &block)
      params[:type] = :text unless params[:type]
      super(params)
    end
  end
  
end
end
