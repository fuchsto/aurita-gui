
require('aurita-gui/element')
require('aurita-gui/widget')

include Aurita::GUI

class Box < Widget

  attr_accessor :opened, :box_content

  def initialize(params={}, &block)
    @opened   = params[:opened]
    @opened ||= false
    @id       = params[:id]
    @box_content  = yield if block_given? 
    super()
  end

  def element
    HTML.div(:id => @id).box { 
      HTML.div.content() {
        "#{@box_content} @opened is #{@opened}" 
      } 
    }
  end

  def js_initialize
    if @opened then
      "alert('#{@id} opened'); " 
    else
      "alert('#{@id} closed'); " 
    end
  end
end

