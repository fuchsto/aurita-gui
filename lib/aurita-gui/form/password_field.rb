
require('aurita-gui/form/form_field')

module Aurita
module GUI

  # Wrapper for Input_Field, defaults type to :password. 
  #
  # Usage: 
  #
  #   i = Password_Field.new(:name  => :pass_confirm, 
  #                          :label => 'Confirm password', 
  #                          :value => 'oldpass')  # Possible, but not recommended
  #
  class Password_Field < Input_Field
    def initialize(params, &block)
      params[:type] = :password unless params[:type]
      super(params)
    end
  end
  
end
end
