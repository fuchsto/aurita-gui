
require('aurita-gui/element')

module Aurita
module GUI

  # Specialization of Aurita::GUI::Element, extending 
  # it by @icon to display in the button. 
  #
  # Usage: 
  #
  #   b = Button.new(:type => :submit,             # default is :button
  #                  :icon => '/path/to/icon.png', # default is no icon
  #                  :onclick => 'alert('button clicked'); ") { 
  #         'click me' 
  #       }
  #   
  # Change button text: 
  #
  #   b.content = 'Custom button text'
  #
  # Disable icon again: 
  #
  #   b.icon   = false
  #
  class Button < Element
    attr_accessor :icon

    def initialize(params, &block)
      params[:tag]  = :button
      params[:type] = :button unless params[:type]
      @icon         = params[:icon]
      params.delete(:icon)
      super(params, &block)
    end

    def content
      if @icon then
        return [ HTML.img(:src => @icon), @content ]
      end
      return @content
    end

  end

=begin

  # Specialization of Aurita::GUI::Element for 
  # submit buttons. Set @tag to :input, @type to :submit. 
  # Block argument will be used as button label (:value)
  # Example: 
  #
  #   b = Submit_Button.new(:class => :css_class) { 'click me' }
  #
  class Submit_Button < Button
    def initialize(params={}, &block)
      params[:tag]  ||= :input
      params[:type] ||= :submit unless params[:type]
      if block_given? then
        params[:value] = yield
      end
      super(params)
    end
  end

  # Specialization of Aurita::GUI::Element for 
  # submit buttons. Set @tag to :input, @type to :reset. 
  # Block argument will be used as button label (:value)
  # Example: 
  #
  #   b = Reset_Button.new(:class => :css_class) { 'click me' }
  #
  # Note that reset buttons in forms are considered 
  # bad style in terms of usability. 
  class Reset_Button < Button
    def initialize(params, &block)
      params[:tag]  = :input
      params[:type] = :reset unless params[:type]
      if block_given? then
        params[:value] = yield
      end
      super(params)
    end
  end

=end

end
end
