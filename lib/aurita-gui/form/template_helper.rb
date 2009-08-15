
require('aurita-gui/form')

module Aurita
module GUI

  # Provides wrapper methods for every 
  # form field type. 
  # Include this module in your template 
  # helper class. 
  #
  # Form_Helper methods each return a string 
  # for a respective Form_Field element. 
  # Rendering respects the form instances'
  # @field_decorator, but not @content_decorator, 
  # so you have to wrap form contents manually 
  # in your helper method. 
  #
  # Example: (what your template helper could look like)
  #
  #   module Form_Helper_Class_Methods
  #     def form_for(params, &block)
  #       form = Form.new(params, &block)
  #       render form.header_string        # <form ...> tag is prepared by form instance
  #       render '<ul class="form_fields">'   # begin content wrap
  #       yield(form)
  #       render '</ul>'                      # end content wrap
  #       render '</form>'                 # Closing tag for a form should always be </form>
  #     end
  #   end
  # 
  # Usage, e.g. in ERB templates: 
  #
  #   <% form_for(:action => '/where/to/send') do |f| %>
  #     <%= f.text(:name => :title) { 'Value for this field' } %>
  #     <%= f.select(:name => :color, :options => [ :blue, :red, :green ], :value => :red)
  #   <% end %>
  #
  # Form_Helper automatically extends Aurita::GUI::Form 
  # when included. 
  #
  module Form_Field_Helper

    def text(params, &block)
      params[:type] = :text
      @field_decorator.new(Input_Field.new(params, &block)).string
    end

    def boolean(params, &block)
      @field_decorator.new(Boolean_Field.new(params, &block)).string
    end

    def password(params, &block)
      params[:type] = :password
      @field_decorator.new(Password_Field.new(params, &block)).string
    end

    def select(params, &block)
      @field_decorator.new(Select_Field.new(params, &block)).string
    end

    def radio(params, &block)
      @field_decorator.new(Radio_Field.new(params, &block)).string
    end

    def checkbox(params, &block)
      @field_decorator.new(Checkbox_Field.new(params, &block)).string
    end

    def textarea(params, &block)
      @field_decorator.new(Textarea_Field.new(params, &block)).string
    end

    def hidden(params, &block)
      @field_decorator.new(Hidden_Field.new(params, &block)).string
    end

    def file(params, &block)
      @field_decorator.new(File_Field.new(params, &block)).string
    end

    def fieldset(params, &block)
      @field_decorator.new(Fieldset.new(params, &block)).string
    end

    def date(params, &block)
      @field_decorator.new(Date_Field.new(params, &block)).string
    end

    def datetime(params, &block)
      @field_decorator.new(Datetime_Field.new(params, &block)).string
    end

    def custom(params, &block)
      if params.is_a?(Element) then
        element = params
      else
        klass = params[:element]
        params.delete(:element)
        element = klass.new(params, &block)
      end
      @field_decorator.new(element).string
    end

  end

  # Extend class Aurita::GUI::Form by helper 
  # methods. 
  class Form
    include Form_Field_Helper
  end

end
end
