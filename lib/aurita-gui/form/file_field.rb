
require('aurita-gui/form/form_field')

module Aurita
module GUI

  # Usage: 
  #
  # Like Input_Field, but skipping attribute @value, 
  # as file input fields do not support default values
  # (for good reason). 
  #
  #   i = File_Field.new(:name => :the_file, 
  #                      :label => 'Choose file')
  #
  class File_Field < Form_Field
    def initialize(params)
      params[:tag]  = :input
      params[:type] = :file unless params[:type]
      params.delete(:value)
      super(params)
    end
    def element
      HTML.input(@attrib)
    end
  end

  
end
end
